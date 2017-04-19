/**
 * AddPaymentPlanLightningControllerTest Class for the AddPaymentPlanLightningController.
 **/

@isTest
private class AddPaymentPlanLightningControllerTest {
	
    /**
     * This method tests the logic of constructor, init, doCancel, doNothing, doNext and getPaymentPlanSettings methods.
     * If guarantor have already active payment plan than it will not allow to create another payment plan.
     **/
    @isTest
    static void testActivePaymentPlan() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        INSERT paymentPlan;

        Test.startTest();
        // Create instance of AddPaymentPlanLightningController class.
        AddPaymentPlanLightningController objAddPaymentPlan = new AddPaymentPlanLightningController(guarantorContact.Id);
        Test.stopTest();

        // Check system assert, We got 'This guarantor have already active Payment Plan.' error.        
        System.assertEquals(objAddPaymentPlan.Message, System.Label.Payment_Plan_Error,
            'Expected ' + System.Label.Payment_Plan_Error + ' error message but got different');
    }

    /**
     * This method tests the logic of fillNameAndAddress method.
     **/
    @isTest
    static void testFillNameAddress() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Test.startTest();
        AddPaymentPlanLightningController objAddPaymentPlan = new AddPaymentPlanLightningController(guarantorContact.Id);

        // Check system assert, cardHolderName become null before call fillNameAndAddress method.
        System.assert(objAddPaymentPlan.cardHolderName == null, 'Expected card holder name is null');

        // Call fillNameAndAddress method.
        objAddPaymentPlan.fillNameAndAddress();
        Test.stopTest();

        Contact gc = GuarantorDao.getGuarantor(guarantorContact.Id);
        // Check system assert, cardHolderName set as contact's name.
        System.assertEquals(gc.Name, objAddPaymentPlan.cardHolderName, 'Expected card holder name ' + gc.name + ' but got ' + objAddPaymentPlan.cardHolderName);
    }

    /**
     * This method tests the logic of addPaymentPlan method with all necessary parameters.
     **/
    @isTest
    static void testCreatePaymentPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 23232323;
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        objCG.Sirono_ID__c = 1321212;
        INSERT objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        INSERT transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        AddPaymentPlanLightningController objAddPaymentPlan = new AddPaymentPlanLightningController(guarantorContact.Id);
        for (ChargeGroupWrapper cg: objAddPaymentPlan.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objAddPaymentPlan.expirationMonth = '07';
        objAddPaymentPlan.creditCardNumber = '378282246310005';
        objAddPaymentPlan.cardHolderName = 'Test';
        objAddPaymentPlan.zip = '07897';
        objAddPaymentPlan.amount = '100';
        objAddPaymentPlan.planType = 'auto';
        objAddPaymentPlan.planValue = '100';
        objAddPaymentPlan.executeOnDay = '10';
        objAddPaymentPlan.cvv = '1234';
        objAddPaymentPlan.state = 'test';
        objAddPaymentPlan.address = 'test';
        objAddPaymentPlan.city = 'test';
        objAddPaymentPlan.doNext();
        objAddPaymentPlan.getPaymentPlanSettings();
        List<SelectOption> paymentPlanType = objAddPaymentPlan.paymentPlanTypeOptions;

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        String msg = objAddPaymentPlan.addPaymentPlan();
        Test.stopTest();

        // Check system assert.
        System.assert(msg.contains(Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY),
            'Expected Payment Plan record created but its not created.');
    }

    /**
     * This method tests the logic of addPaymentPlan method's error.
     **/
    @isTest
    static void testFailPaymentPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        INSERT objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        INSERT transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        AddPaymentPlanLightningController objAddPaymentPlan = new AddPaymentPlanLightningController(guarantorContact.Id);
        for (ChargeGroupWrapper cg: objAddPaymentPlan.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objAddPaymentPlan.expirationMonth = '07';
        objAddPaymentPlan.creditCardNumber = '1234567891113';
        objAddPaymentPlan.cardHolderName = '1234567891113';
        objAddPaymentPlan.zip = '07897';
        objAddPaymentPlan.amount = '';
        objAddPaymentPlan.planType = 'promise';
        objAddPaymentPlan.planValue = '100';
        objAddPaymentPlan.executeOnDay = '10';
        objAddPaymentPlan.cvv = 'test';
        objAddPaymentPlan.state = 'test';
        objAddPaymentPlan.address = 'test';
        objAddPaymentPlan.city = 'test';
        objAddPaymentPlan.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        String msg = objAddPaymentPlan.addPaymentPlan();
        Test.stopTest();

        // Check system assert.
        System.assert(msg.contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO),
            'Expected ' + Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO + ' error message but got ' + msg);
    }
}