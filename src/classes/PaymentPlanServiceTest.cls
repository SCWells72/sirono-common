/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test the PaymentPlanService
 */
@IsTest
public with sharing class PaymentPlanServiceTest {

    private static String PLAN_SIRONO_ID = '2876';
    private static Decimal CG_TO_ADD_ID = 123456;
    private static Decimal CG_SIRONO_ID = 12345;

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = 23232323;
        insert gt;

        Contact pt = TestUtility.generatePatientContact();
        insert pt;

        Datetime createdDT = Datetime.now().addDays(-3);

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(gt);
        pp.Plan_Type__c = Constants.AUTOMATIC;
        pp.Sirono_ID__c = Decimal.valueOf(PLAN_SIRONO_ID);
        pp.Plan_Value_Modified_Date__c = createdDT;
        insert pp;
        Test.setCreatedDate(pp.Id, createdDT);

        Charge_Group__c cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, CG_SIRONO_ID, pp.Id);
        cg.Sirono_ID__c = CG_SIRONO_ID;
        insert cg;

        Service__c svc = TestUtility.generateService(cg, 450.00);
        insert svc;

        Transaction__c txn = TestUtility.generateServiceTxn(cg, svc.Amount__c, svc);
        insert txn;

        cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, CG_TO_ADD_ID);
        cg.Sirono_ID__c = CG_TO_ADD_ID;
        insert cg;

        svc = TestUtility.generateService(cg, 200.00);
        insert svc;

        txn = TestUtility.generateServiceTxn(cg, svc.Amount__c, svc);
        insert txn;

        // Check system assert.
        System.assertEquals(Decimal.valueOf(PLAN_SIRONO_ID), pp.Sirono_ID__c, 'Expected ' + PLAN_SIRONO_ID + ' but got ' + pp.Sirono_ID__c);
    }

    /*
     *
     * Test adding a chargegroup to an existing paymentplan
     */
    @IsTest
    public static void testAddChargeGroup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        PaymentPlanService.addChargeGroups(PLAN_SIRONO_ID, new String[] { String.valueOf(CG_TO_ADD_ID) });
        Test.stopTest();

        Payment_Plan__c pp = [
            SELECT Id, Sirono_ID__c, Plan_Value_Modified_Date__c, CreatedDate
            FROM Payment_Plan__c
            WHERE Sirono_ID__c = :Decimal.valueOf(PLAN_SIRONO_ID)
            LIMIT 1
        ];

        Charge_Group__c[] cgs = [SELECT Id, Sirono_ID__c, Payment_Plan__c FROM Charge_Group__c WHERE Payment_Plan__c = :pp.Id];

        System.assert(cgs.size() == 2, 'Expected 2 cgs on the payment plan, but had ' + cgs.size());
        System.assert(pp.Plan_Value_Modified_Date__c > pp.CreatedDate,
            'Expected Plan_Value_Modified_Date__c (' + pp.Plan_Value_Modified_Date__c +
                ') > pp.CreatedDate (' + pp.CreatedDate + ')');
    }

    /**
     * Test adding a bad chargegroupId to an existing paymentplan
     */
    @IsTest
    public static void testAddBadChargeGroupId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Boolean expectedFailure = false;
        Test.startTest();
        try {
            PaymentPlanService.addChargeGroups(PLAN_SIRONO_ID, new String[] { '1962' });
        } catch (SironoServiceException ex) {
            System.assertEquals('Unknown chargegroup requested: 1962', ex.getMessage());
            expectedFailure = true;
        }
        Test.stopTest();

        System.assert(expectedFailure, 'Exception expected adding unknown chargegroupId');
    }

    /*
     *
     * Test adding a chargegroupId to a non-existing paymentplan
     */
    @IsTest
    public static void testAddChargeGroupBadPlanId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Boolean expectedFailure = false;
        Test.startTest();
        try {
            PaymentPlanService.addChargeGroups('1492', new String[] { String.valueOf(CG_TO_ADD_ID) });
        } catch (SironoServiceException ex) {
            System.assertEquals('Unknown Payment Plan: 1492', ex.getMessage());
            expectedFailure = true;
        }
        Test.stopTest();

        System.assert(expectedFailure, 'Exception expected adding to unknown payment plan');
    }

    @IsTest
    public static void testPlanJSONParsing() {
        Test.startTest();

        PaymentPlanService.PaymentPlanJSONParser parser = new PaymentPlanService.PaymentPlanJSONParser(MockHttpResponseGenerator.getPaymentPlanJSONBody());
        Payment_Plan__c pp = parser.parseAsPaymentPlan();

        Test.stopTest();

        // We have commented this line because of We can't update Payment Plan name when Payment Plan already exists.
        // When we create new payment plan at that time we assign name in it.
        // As per below assert, we already insert payment plan with same sirono Id in set up data.
        // System.assertEquals(pp.Name, '2876', 'Plan Name is: '+pp.Name);
        System.assertEquals(pp.Sirono_ID__c, Decimal.valueOf(PLAN_SIRONO_ID), 'Plan sirono_id is: ' + pp.Sirono_ID__c);
        System.assertEquals(pp.Installment_Amount__c, 50, 'Expected Installment_Amount to be 50, but was: ' + pp.Installment_Amount__c);
        System.assert(pp.Active__c, 'Expected Plan to be active, but was not');
        System.assertEquals(pp.Original_Balance__c, 327.72, 'Expected Plan Original_Balance__c to be 327.72, but was: ' + pp.Original_Balance__c);
        System.assertEquals(pp.Plan_Type__c, Constants.AUTOMATIC, 'Expected Plan_Type__c to be Automatic, but was: ' + pp.Plan_Type__c);
        System.assertEquals(pp.Remaining_Balance__c, 327.72, 'Expected Plan Remaining_Balance__c to be 327.72, but was: ' + pp.Remaining_Balance__c);
        System.assertEquals(pp.Status__c, 'started', 'Expected Status__c to be "started", but was: ' + pp.Status__c);
        System.assertEquals(pp.NextPaymentDate__c, Date.newInstance(2017, 05, 13), 'Expected NextPaymentDate__c to be "2017-05-13", but was: ' + pp.NextPaymentDate__c);
    }

    /**
     * Test to Add Payment Plan for Auto plan Type.
     **/
    @IsTest
    public static void testAddPaymentPlanForAuto() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        PaymentPlanInformation objPPInfo = new PaymentPlanInformation();
        objPPInfo.chargeGroupIds = new String[] { String.valueOf(CG_TO_ADD_ID) };
        objPPInfo.guarantorId = gt.Id;
        objPPInfo.planType = Constants.PLANTYPE_AUTO;
        objPPInfo.expirationYear = String.valueOf(System.today().year() + 1);
        objPPInfo.expirationMonth = '07';
        objPPInfo.creditCardNumber = '1234567891113';
        objPPInfo.cardholderName = '1234567891113';
        objPPInfo.zip = '07897';
        objPPInfo.amount = '100';
        objPPInfo.planValue = '1000';
        objPPInfo.executeOnDay = '10';
        objPPInfo.cvv = 'test';
        objPPInfo.state = 'test';
        objPPInfo.address = 'test';
        objPPInfo.city = 'test';

        Test.startTest();
        PaymentPlanService.addPaymentPlan(objPPInfo);
        Test.stopTest();

        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);

        System.assertNotEquals(pp, null, 'Expected Payment Plan not null');
    }

    /**
     * Test to Add Credit Card/ Payment Plan for Promise plan Type.
     **/
    @IsTest
    public static void testAddPaymentPlanForPromise() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        PaymentPlanInformation objPPInfo = new PaymentPlanInformation();
        objPPInfo.chargeGroupIds = new String[] { String.valueOf(CG_TO_ADD_ID) };
        objPPInfo.guarantorId = gt.Id;
        objPPInfo.planType = Constants.PLANTYPE_PROMISE;
        objPPInfo.planValue = '100';
        objPPInfo.amount = '10';

        Test.startTest();
        PaymentPlanService.addPaymentPlan(objPPInfo);
        Test.stopTest();

        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);

        System.assertNotEquals(pp, null, 'Expected Payment Plan not null');
    }

    /**
     * Test to verify the call to the Sirono Server for updating a Payment Plan.
     */
    @IsTest
    public static void testUpdateAutoPaymentPlanTerms() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);

        System.assertNotEquals(pp, null, 'Expected Payment Plan not null');

        PaymentPlanInformation ppInfo = new PaymentPlanInformation();
        ppInfo.planType = Constants.PLANTYPE_AUTO;
        ppInfo.amount = '9999';
        ppInfo.executeOnDay = '1';

        Test.startTest();
        Payment_Plan__c updatedPlan = PaymentPlanService.updateAutoPaymentPlanTerms(PLAN_SIRONO_ID, ppInfo);
        Test.stopTest();

        System.assertNotEquals(null, updatedPlan, 'Should find updated plan');
        System.assertEquals(pp.Id, updatedPlan.Id, 'Should be the the same plan.');
    }

    /**
     * Verify exception is thrown for update call on PP that does not have type auto.
     */
    @IsTest
    public static void testUpdateAutoPaymentPlanTermsNotAuto() {


        PaymentPlanInformation ppInfo = new PaymentPlanInformation();
        ppInfo.planType = Constants.PLANTYPE_PROMISE;
        ppInfo.amount = '9999';
        ppInfo.executeOnDay = '1';

        Test.startTest();
        try {
            Payment_Plan__c updatedPlan = PaymentPlanService.updateAutoPaymentPlanTerms(PLAN_SIRONO_ID, ppInfo);
        } catch (AbstractService.ServiceException svcException) {
            Test.stopTest();
            System.assertNotEquals(null, svcException, 'Should have thrown the service exception');
            System.assertEquals('This method only supports auto payment plans.', svcException.getMessage(), 'Should have auto plan message.');
        }

    }

    /**
     * Create a new payment plan and associated payment method without persisting the payment method.
     */
    @IsTest
    public static void testAddPaymentPlanWithPaymentMethodNoSave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        PaymentPlanInformation objPPInfo = new PaymentPlanInformation();
        objPPInfo.chargeGroupIds = new String[] { String.valueOf(CG_TO_ADD_ID) };
        objPPInfo.guarantorId = gt.Id;
        objPPInfo.planType = Constants.PLANTYPE_AUTO;
        objPPInfo.expirationYear = String.valueOf(System.today().year() + 1);
        objPPInfo.expirationMonth = '07';
        objPPInfo.creditCardNumber = '1234567891113';
        objPPInfo.cardholderName = '1234567891113';
        objPPInfo.zip = '07897';
        objPPInfo.amount = '100';
        objPPInfo.planValue = '1000';
        objPPInfo.executeOnDay = '10';
        objPPInfo.cvv = 'test';
        objPPInfo.state = 'test';
        objPPInfo.address = 'test';
        objPPInfo.city = 'test';

        Test.startTest();
        Payment_Plan__c newPlan = PaymentPlanService.addPaymentPlanWithPaymentMethod(objPPInfo, false, gt.Id);
        Test.stopTest();

        System.assertNotEquals(newPlan, null, 'Expected Payment Plan not null');
        System.assertNotEquals(null, newPlan.Payment_Method__r, 'Returned plan should have a defined pay method.');

        List<Payment_Plan__c> plans = PaymentPlanDao.getActivePaymentPlanWithMethod(gt.Id);
        System.assertNotEquals(0, plans.size(), 'Should have found a plan.');
        Payment_Plan__c pp = plans.get(0);
        System.assertEquals(null, pp.Payment_Method__r, 'Should not have persisted the Payment method.');
    }

    /**
     * Create a new payment plan and associated payment method, persisting the payment method.
     */
    @IsTest
    public static void testAddPaymentPlanWithPaymentMethodSave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        PaymentPlanInformation objPPInfo = new PaymentPlanInformation();
        objPPInfo.chargeGroupIds = new String[] { String.valueOf(CG_TO_ADD_ID) };
        objPPInfo.guarantorId = gt.Id;
        objPPInfo.planType = Constants.PLANTYPE_AUTO;
        objPPInfo.expirationYear = String.valueOf(System.today().year() + 1);
        objPPInfo.expirationMonth = '07';
        objPPInfo.creditCardNumber = '1234567891113';
        objPPInfo.cardholderName = '1234567891113';
        objPPInfo.zip = '07897';
        objPPInfo.amount = '100';
        objPPInfo.planValue = '1000';
        objPPInfo.executeOnDay = '10';
        objPPInfo.cvv = 'test';
        objPPInfo.state = 'test';
        objPPInfo.address = 'test';
        objPPInfo.city = 'test';

        Test.startTest();
        Payment_Plan__c newPlan = PaymentPlanService.addPaymentPlanWithPaymentMethod(objPPInfo, true, gt.Id);
        Test.stopTest();

        System.assertNotEquals(newPlan, null, 'Expected Payment Plan not null');
        System.assertNotEquals(null, newPlan.Payment_Method__r, 'Returned plan should have a defined pay method.');

        List<Payment_Plan__c> plans = PaymentPlanDao.getActivePaymentPlanWithMethod(gt.Id);
        System.assertNotEquals(0, plans.size(), 'Should have found a plan.');
        Payment_Plan__c pp = plans.get(0);
        System.assertNotEquals(null, pp.Payment_Method__r, 'Should have persisted the Payment method.');
    }

    /**
     * Get the play by sirono id.
     */
    @IsTest
    public static void testGetBySironoId() {

        Test.startTest();
        Payment_Plan__c plan = PaymentPlanService.getPaymentPlanBySironoId(PLAN_SIRONO_ID);
        Test.stopTest();

        System.assertNotEquals(null, plan, 'Should have been able to lookup payment plan by sirono id.');
    }

    @IsTest
    public static void testGetBySironoIdDecimal() {

        Decimal sid = Decimal.valueOf(PLAN_SIRONO_ID);
        Test.startTest();
        Payment_Plan__c plan = PaymentPlanService.getPaymentPlanBySironoId(sid);
        Test.stopTest();

        System.assertNotEquals(null, plan, 'Should have been able to lookup payment plan by sirono id.');
    }

    /**
     * Ensure we can look up active plan by guarantor id.
     */
    @IsTest
    public static void testGetActivePaymentPlan() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Test.startTest();
        Payment_Plan__c activePlan = PaymentPlanService.getActivePaymentPlan(gt.Id);
        Test.stopTest();

        System.assertNotEquals(null, activePlan, 'Should have found an active plan.');
        System.assertEquals(true, activePlan.Active__c, 'Should be active.');
    }

    /**
     * Test if we can find a Payment plan by plan id.
     */
    @IsTest
    public static void testGetPaymentPlanByPlanId() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);
        System.assertNotEquals(null, pp, 'Should find an existing plan.');

        Test.startTest();
        Payment_Plan__c plan = PaymentPlanService.getPaymentPlan(pp.Id);
        Test.stopTest();

        System.assertNotEquals(null, plan, 'Should find the plan.');
        System.assertEquals(pp.Id, plan.Id, 'Should be the same plan.');
    }

    /**
     * Add a Payment Method to an existing plan, without saving.
     */
    @IsTest
    public static void testAddPaymentMethod_NewNoSave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact gt = [SELECT Id, Profile_Pointer_ID__c FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        String cardNumber = '378282246310005';
        String lastFour = '0005';
        MockHttpResponseGenerator.guarantorSironoId = gt.Profile_Pointer_Id__c.toPlainString();


        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);
        System.assertNotEquals(null, pp, 'Should find an existing plan.');

        PaymentPlanInformation objPPInfo = new PaymentPlanInformation();
        objPPInfo.expirationYear = String.valueOf(System.today().year() + 1);
        objPPInfo.expirationMonth = '07';
        objPPInfo.creditCardNumber = '1234567891113';
        objPPInfo.cardholderName = '1234567891113';
        objPPInfo.chargeGroupIds = new String[]{String.valueOf(CG_TO_ADD_ID)};
        objPPInfo.guarantorId = gt.Id;
        objPPInfo.planType = Constants.PLANTYPE_AUTO;
        objPPInfo.zip = '07897';
        objPPInfo.amount = '100';
        objPPInfo.planValue = '1000';
        objPPInfo.executeOnDay = '10';
        objPPInfo.cvv = 'test';
        objPPInfo.state = 'test';
        objPPInfo.address = 'test';
        objPPInfo.city = 'test';
        objPPInfo.planType = Constants.PLANTYPE_AUTO;

        List<Payment_Method__c> originalMethods = PaymentMethodDao.getPaymentMethods(gt.Id);

        Test.startTest();
        Payment_Plan__c plan = PaymentPlanService.addPaymentMethod(pp.Id, '', objPPInfo, false);
        Test.stopTest();

        System.assertNotEquals(null, plan, 'Should return a plan.');
        System.assertNotEquals(null, plan.Payment_Method__r, 'Should include payment method on returned plan.');

        List<Payment_Method__c> updatedMethods = PaymentMethodDao.getPaymentMethods(gt.Id);
        System.assertEquals(originalMethods.size(), updatedMethods.size(), 'Should no have a new payment method.');

        List<Payment_Plan__c> plans = PaymentPlanDao.getActivePaymentPlanWithMethod(gt.Id);
        System.assertNotEquals(0, plans.size(), 'Should have found a plan.');
        Payment_Plan__c planWithMethod = plans.get(0);

        System.assertNotEquals(lastFour, plan.Payment_Method__r.Last_4__c, 'Should not have the new method.');
    }

    /**
     * Add a Payment Method to an existing plan, without saving.
     */
    @IsTest
    public static void testAddPaymentMethod_NewSave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact gt = [SELECT Id, Profile_Pointer_Id__c FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        String cardNumber = '378282246310005';
        String lastFour = '0005';
        MockHttpResponseGenerator.guarantorSironoId = gt.Profile_Pointer_Id__c.toPlainString();

        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);
        System.assertNotEquals(null, pp, 'Should find an existing plan.');

        PaymentPlanInformation objPPInfo = new PaymentPlanInformation();
        objPPInfo.expirationYear = String.valueOf(System.today().year() + 1);
        objPPInfo.expirationMonth = '07';
        objPPInfo.creditCardNumber = cardNumber;
        objPPInfo.cardholderName = '1234567891113';
        objPPInfo.chargeGroupIds = new String[]{String.valueOf(CG_TO_ADD_ID)};
        objPPInfo.guarantorId = gt.Id;
        objPPInfo.planType = Constants.PLANTYPE_AUTO;
        objPPInfo.zip = '07897';
        objPPInfo.amount = '100';
        objPPInfo.planValue = '1000';
        objPPInfo.executeOnDay = '10';
        objPPInfo.cvv = 'test';
        objPPInfo.state = 'test';
        objPPInfo.address = 'test';
        objPPInfo.city = 'test';
        objPPInfo.planType = Constants.PLANTYPE_AUTO;

        List<Payment_Method__c> originalMethods = PaymentMethodDao.getPaymentMethods(gt.Id);

        Test.startTest();
        Payment_Plan__c plan = PaymentPlanService.addPaymentMethod(pp.Id, '', objPPInfo, true);
        Test.stopTest();

        System.assertNotEquals(null, plan, 'Should return a plan.');
        System.assertNotEquals(null, plan.Payment_Method__r, 'Should include payment method on returned plan.');

        List<Payment_Method__c> updatedMethods = PaymentMethodDao.getPaymentMethods(gt.Id);
        System.assertEquals(originalMethods.size() + 1, updatedMethods.size(), 'Should have one new plan.');

        List<Payment_Plan__c> plans = PaymentPlanDao.getActivePaymentPlanWithMethod(gt.Id);
        System.assertNotEquals(0, plans.size(), 'Should have found a plan.');
        Payment_Plan__c planWithMethod = plans.get(0);

        System.assertEquals(lastFour, planWithMethod.Payment_Method__r.Last_4__c, 'Should have the new method.');
    }

    /**
     * Add an existing Payment Method to existing plan, without saving.
     */
    @IsTest
    public static void testAddPaymentMethod_ExistingSave() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Contact gt = [SELECT Id, Profile_Pointer_Id__c  FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        String cardNumber = '378282246310005';
        String lastFour = '0005';
        MockHttpResponseGenerator.guarantorSironoId = gt.Profile_Pointer_Id__c.toPlainString();


        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);
        System.assertNotEquals(null, pp, 'Should find an existing plan.');

        PaymentPlanInformation objPPInfo = new PaymentPlanInformation();
        objPPInfo.expirationYear = String.valueOf(System.today().year() + 1);
        objPPInfo.expirationMonth = '07';
        objPPInfo.creditCardNumber = cardNumber;
        objPPInfo.cardholderName = '1234567891113';
        objPPInfo.chargeGroupIds = new String[]{String.valueOf(CG_TO_ADD_ID)};
        objPPInfo.guarantorId = gt.Id;
        objPPInfo.planType = Constants.PLANTYPE_AUTO;
        objPPInfo.zip = '07897';
        objPPInfo.amount = '100';
        objPPInfo.planValue = '1000';
        objPPInfo.executeOnDay = '10';
        objPPInfo.cvv = 'test';
        objPPInfo.state = 'test';
        objPPInfo.address = 'test';
        objPPInfo.city = 'test';
        objPPInfo.planType = Constants.PLANTYPE_AUTO;

        Payment_Method__c newMethod = PaymentMethodService.generatePaymentMethod(objPPInfo, gt.Id);
        PaymentMethodDao.insertPaymentMethod(newMethod);

        Test.startTest();
        Payment_Plan__c plan = PaymentPlanService.addPaymentMethod(pp.Id, newMethod.Id, objPPInfo, true);
        Test.stopTest();

        System.assertNotEquals(null, plan, 'Should return a plan.');
        System.assertNotEquals(null, plan.Payment_Method__r, 'Should include payment method on returned plan.');

        List<Payment_Plan__c> plans = PaymentPlanDao.getActivePaymentPlanWithMethod(gt.Id);
        System.assertNotEquals(0, plans.size(), 'Should have found a plan.');
        Payment_Plan__c planWithMethod = plans.get(0);

        System.assertEquals(lastFour, planWithMethod.Payment_Method__r.Last_4__c, 'Should have the new method.');
    }

    /**
     * Test the Patch requestor setup.
     */
    @IsTest
    public static void testPatchRequestor() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        PaymentPlanService.PaymentPlanRestClient patchRequest = new PaymentPlanService.PaymentPlanRestClient();
        patchRequest.patchRequestor();
        HttpRequest req = patchRequest.getRequest();
        Test.stopTest();

        System.assert(req != null, 'Should have built a request.');

        String overrideValue = req.getHeader(RestClientConstants.METHOD_OVERRIDE);
        System.assert(overrideValue != null, 'Should have the override header.');
        System.assertEquals(RestClientConstants.PATCH, overrideValue, 'Should set override header to patch.');

    }

    /**
     * Verify a successful delete payment plan call.
     */
    @IsTest
    public static void testRemovePaymentPlan() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Payment_Plan__c plan = [
            SELECT Id, Active__c, Cancellation_Date__c, Plan_Type__c
            FROM Payment_Plan__c
            WHERE Sirono_ID__c = :Decimal.valueOf(PLAN_SIRONO_ID)
        ];
        plan.Plan_Type__c = Constants.PLANTYPE_AUTO;
        UPDATE plan;

        System.assertEquals(true, plan.Active__c, 'Should be active before delete.');
        System.assertEquals(null, plan.Cancellation_Date__c, 'Should not have a cancelation date.');

        List<Charge_Group__c> cgs = ChargeGroupDao.getBySironoIds(new List<Decimal> { CG_SIRONO_ID });
        Charge_Group__c cg = (cgs.size() >= 1) ? cgs.get(0) : null;
        cg.Account_Sub_Status__c = Constants.ON_PAYMENT_PLAN;
        UPDATE cg;

        System.assertEquals(plan.Id, cg.Payment_Plan__c, 'Should have payment plan.');

        Test.startTest();
        PaymentPlanService.removePaymentPlan(plan.Id);
        Test.stopTest();

        Payment_Plan__c planAfterDelete = [
            SELECT Id, Active__c, Cancellation_Date__c
            FROM Payment_Plan__c
            WHERE Sirono_ID__c = :Decimal.valueOf(PLAN_SIRONO_ID)
        ];

        System.assertEquals(false, planAfterDelete.Active__c, 'Should not be active after delete.');
        System.assertNotEquals(null, planAfterDelete.Cancellation_Date__c, 'Should populate cancelation date.');

        cgs = ChargeGroupDao.getBySironoIds(new List<Decimal> { CG_SIRONO_ID });
        Charge_Group__c updatedCg = (cgs.size() >= 1) ? cgs.get(0) : null;

        // Note the mock here makes use of the existing cg json body, and in that body the Account_Sub_Status is third party payer.
        System.assertNotEquals(cg.Account_Sub_Status__c, updatedCg.Account_Sub_Status__c, 'Should have updated Accont substatus.');
        System.assertEquals(Constants.ACCT_SUBSTATUS_THIRD_PARTY, updatedCg.Account_Sub_Status__c, 'Should match the substate of mock cg.');
        System.assertEquals(null, updatedCg.Payment_Plan__c, 'Should not be assigned to payment plan.');
    }

    @IsTest
    public static void testRemovePaymentPlanNoPlan() {
        Payment_Plan__c plan = [
            SELECT Id
            FROM Payment_Plan__c
            WHERE Sirono_ID__c = :Decimal.valueOf(PLAN_SIRONO_ID)
        ];
        delete plan;

        Test.startTest();
        try {
            PaymentPlanService.removePaymentPlan(plan.Id);
            System.assert(false, 'Should have thrown service exception');
        } catch (AbstractService.ServiceException e) {
            Test.stopTest();
            System.assertEquals('No Payment Plan found.', e.getMessage(), 'Should have appropriate error message.');
        }

    }
}
