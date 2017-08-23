/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class PaymentTabsControllerTest {

    // TODO: These were copied over from PaymentTabsController where they were @TestVisible.
    // TODO: Need to figure out a better option for where they should live.
    private static final String PLAN_TYPE = 'planType';
    private static final String PLAN_VALUE = 'planValue';
    private static final String AMOUNT_KEY = 'amount';
    private static final String EXECUTE_ON_DAY = 'executeOnDay';
    private static final String CHARGE_GROUP_IDS = 'chargeGroupIds';
    private static final String GUARANTOR_ID = 'guarantorId';
    private static final String CARD_HOLDER_NAME = 'cardHolderName';
    private static final String EXPIRATION_YEAR = 'expirationYear';
    private static final String EXPIRATION_MONTH = 'expirationMonth';
    private static final String CREDITCARD_NUMBER = 'creditCardNumber';
    private static final String CVV_KEY = 'cvv';
    private static final String STATE_KEY = 'state';
    private static final String ZIP_KEY = 'zip';
    private static final String ADDRESS_KEY = 'address';
    private static final String CITY_KEY = 'city';

    @IsTest
    public static void getCardSelectOptionsTest() {
        Test.startTest();
        Map<String, Map<String, String>> opts = PaymentTabsController.getCardSelectOptions();
        Test.stopTest();

        System.assertEquals(2, opts.keySet().size(), 'Should have both YEARS and MONTHS');
    }

    @IsTest
    public static void testGetPaymentPlanInfoNullForNoContact() {
        Test.startTest();
        PaymentTabsController.GuarantorPaymentInfo gpi = PaymentTabsController.getPaymentPlanInfo();
        Test.stopTest();

        System.assertEquals(null, gpi, 'Should be null if no contact id is found.');
    }

    @IsTest
    public static void testGetPaymentPlanInfoForNoActiveCGs() {
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();

        // Update all the portal users charge groups to not active.
        System.runAs(adminUser) {
            List<sPRS__Charge_Group__c> cgs = [
                SELECT Id, sPRS__Active__c
                FROM sPRS__Charge_Group__c
                WHERE Id = :portalUser.ContactId
            ];

            for (sPRS__Charge_Group__c cg : cgs) {
                cg.sPRS__Active__c = false;
            }
            update cgs;
        }
        PaymentTabsController.GuarantorPaymentInfo gpi;

        System.runAs(portalUser) {
            Test.startTest();
            gpi = PaymentTabsController.getPaymentPlanInfo();
            Test.stopTest();
        }
        System.assertNotEquals(null, gpi, 'Should populate the PaymentInfoObject.');
        System.assertEquals(0, gpi.chargeGroups.size(), 'Should have no charge groups.');
        System.assertEquals(false, gpi.addToPaymentAvail, 'Should set add to PP to false');

    }

    @IsTest
    public static void testGetPaymentPlanInfoHasChargeGroups() {
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();

        PaymentTabsController.GuarantorPaymentInfo gpi;
        insertPaymentPlan(adminUser);

        System.runAs(portalUser) {
            Test.startTest();
            gpi = PaymentTabsController.getPaymentPlanInfo();
            Test.stopTest();
        }

        System.assertNotEquals(null, gpi, 'Should populate the PaymentInfoObject.');
        System.assertEquals(1, gpi.chargeGroups.size(), 'Should have a charge groups.');
        System.assertEquals(false, gpi.addToPaymentAvail, 'Should set add to PP to false');
        System.assertNotEquals(null, gpi.settings, 'Should have pp settings.');
    }

    @IsTest
    public static void testCreatePaymentPlan() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        // Update the mock response to use the community guarantor sirono id.
        sPRS.MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.sPRS__Guarantor_Id__c.toPlainString();

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(PLAN_TYPE, PortalConstants.PLANTYPE_AUTO);
        ppInfoMap.put(PLAN_VALUE, '');
        ppInfoMap.put(AMOUNT_KEY, '234');
        ppInfoMap.put(EXECUTE_ON_DAY, '1');
        ppInfoMap.put(GUARANTOR_ID, portalUser.ContactId);
        ppInfoMap.put(CARD_HOLDER_NAME, 'Pork nBeans');
        ppInfoMap.put(EXPIRATION_YEAR, String.valueOf(System.today().year() + 1));
        ppInfoMap.put(EXPIRATION_MONTH, '7');
        ppInfoMap.put(CVV_KEY, '127');
        ppInfoMap.put(STATE_KEY, 'CA');
        ppInfoMap.put(ZIP_KEY, '78717');
        ppInfoMap.put(ADDRESS_KEY, '123 St. Road');
        ppInfoMap.put(CITY_KEY, 'San Diego');

        sPRS__Payment_Plan__c plan;
        System.runAs(portalUser) {
            Test.startTest();
            plan = PaymentTabsController.createPaymentPlan(ppInfoMap);
            Test.stopTest();
        }

        System.assertNotEquals(null, plan, 'Should create a paymentPlan.');
        System.assertNotEquals(null, plan.sPRS__Payment_Method__c, 'Should have inserted the payment method.');
    }

    @IsTest
    public static void testDoEditPaymentMethodNoId() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());
        Map<String, Object> ppInfoMap = new Map<String, Object>();

        try {
            Test.startTest();
            PaymentTabsController.doEditPaymentMethod(ppInfoMap);
            System.assert(false, 'Should have thown aura exception.');
        } catch (AuraHandledException e) {
            Test.stopTest();
            System.assertNotEquals(null, e.getMessage(), 'Should have an error message.');
        } catch (Exception ex) {
            System.assert(false, 'Should not have thrown unexpected exception.');
        }

    }

    @IsTest
    public static void testDoEditPaymentMethodNewCardSave() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());

        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();
        sPRS.MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.sPRS__Guarantor_Id__c.toPlainString();


        sPRS__Payment_Plan__c createdPlan = insertPaymentPlan(adminUser);
        String cHolderName = 'Pork nBeans';

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(CARD_HOLDER_NAME, cHolderName);
        ppInfoMap.put(EXPIRATION_YEAR, String.valueOf(System.today().year() + 1));
        ppInfoMap.put(EXPIRATION_MONTH, '7');
        ppInfoMap.put(CVV_KEY, '127');
        ppInfoMap.put(CREDITCARD_NUMBER, '4111111111111111');
        ppInfoMap.put('id', createdPlan.Id);
        ppInfoMap.put(PLAN_TYPE, PortalConstants.PLANTYPE_AUTO);
        ppInfoMap.put(PLAN_VALUE, '');
        ppInfoMap.put(AMOUNT_KEY, '234');
        ppInfoMap.put(EXECUTE_ON_DAY, '1');
        ppInfoMap.put(GUARANTOR_ID, portalUser.ContactId);
        ppInfoMap.put(STATE_KEY, 'CA');
        ppInfoMap.put(ZIP_KEY, '78717');
        ppInfoMap.put(ADDRESS_KEY, '123 St. Road');
        ppInfoMap.put(CITY_KEY, 'San Diego');


        sPRS__Payment_Plan__c plan;
        System.runAs(portalUser) {
            Test.startTest();
            plan = PaymentTabsController.doEditPaymentMethod(ppInfoMap);
            Test.stopTest();
        }

        List<sPRS__Payment_Method__c> savedMethods = [SELECT Id FROM sPRS__Payment_Method__c WHERE sPRS__Card_Holder_Name__c = :cHolderName];
        System.assertNotEquals(null, plan, 'Should return payment plan');
        System.assertEquals(1, savedMethods.size(), 'Should have saved the new payment method.');
    }

    @IsTest
    public static void testDoEditPaymentMethodNewCardSaved() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());

        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();
        sPRS.MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.sPRS__Guarantor_Id__c.toPlainString();


        sPRS__Payment_Plan__c createdPlan = insertPaymentPlan(adminUser);
        String cHolderName = 'Pork nBeans';

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(CARD_HOLDER_NAME, cHolderName);
        ppInfoMap.put(EXPIRATION_YEAR, String.valueOf(System.today().year() + 1));
        ppInfoMap.put(EXPIRATION_MONTH, '7');
        ppInfoMap.put(CVV_KEY, '127');
        ppInfoMap.put(CREDITCARD_NUMBER, '4111111111111111');
        ppInfoMap.put('id', createdPlan.Id);
        ppInfoMap.put(PLAN_TYPE, PortalConstants.PLANTYPE_AUTO);
        ppInfoMap.put(PLAN_VALUE, '');
        ppInfoMap.put(AMOUNT_KEY, '234');
        ppInfoMap.put(EXECUTE_ON_DAY, '1');
        ppInfoMap.put(GUARANTOR_ID, portalUser.ContactId);
        ppInfoMap.put(STATE_KEY, 'CA');
        ppInfoMap.put(ZIP_KEY, '78717');
        ppInfoMap.put(ADDRESS_KEY, '123 St. Road');
        ppInfoMap.put(CITY_KEY, 'San Diego');

        sPRS__Payment_Plan__c plan;
        System.runAs(portalUser) {
            Test.startTest();
            plan = PaymentTabsController.doEditPaymentMethod(ppInfoMap);
            Test.stopTest();
        }

        List<sPRS__Payment_Method__c> savedMethods = [SELECT Id FROM sPRS__Payment_Method__c WHERE sPRS__Card_Holder_Name__c = :cHolderName];
        System.assertNotEquals(null, plan, 'Should return payment plan');
        System.assertEquals(1, savedMethods.size(), 'Should have saved the new payment method.');
    }

    @IsTest
    public static void testDoEditPaymentPlanServiceExcpetion() {
        PortalTestUtility.getGuarantorCommunityUser();
        Map<String, Object> ppInfoMap = new Map<String, Object>();
        // Fake Id
        ppInfoMap.put('id', '548302');


        try {
            Test.startTest();
            PaymentTabsController.doEditPaymentMethod(ppInfoMap);
            System.assert(false, 'Should have thown aura exception.');
        } catch (AuraHandledException e) {
            Test.stopTest();
            System.assertNotEquals(null, e.getMessage(), 'Should have an error message.');
            System.assertEquals('Error encountered updating plan payment method. Please contact support', e.getMessage(), 'Should have proper error.');
        } catch (Exception ex) {
            System.assert(false, 'Should not have thrown unexpected exception.');
        }

    }

    @IsTest
    public static void testDoEditPaymentPlanNoId() {
        PortalTestUtility.getGuarantorCommunityUser();
        Map<String, Object> ppInfoMap = new Map<String, Object>();

        try {
            Test.startTest();
            PaymentTabsController.doEditPaymentPlan(ppInfoMap);
            System.assert(false, 'Should have thown aura exception.');
        } catch (AuraHandledException e) {
            Test.stopTest();
            System.assertNotEquals(null, e.getMessage(), 'Should have an error message.');
        } catch (Exception ex) {
            System.assert(false, 'Should not have thrown unexpected exception.');
        }

    }

    @IsTest
    public static void testDoEditPaymentPlanSuccess() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();
        sPRS.MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.sPRS__Guarantor_Id__c.toPlainString();

        insertPaymentPlan(adminUser);

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(AMOUNT_KEY, '12345');
        ppInfoMap.put(sPRS.PaymentPlanInformation.SIRONO_PP_KEY, '2876');
        ppInfoMap.put(PLAN_TYPE, PortalConstants.PLANTYPE_AUTO);

        Test.startTest();
        sPRS__Payment_Plan__c updatedPlan = PaymentTabsController.doEditPaymentPlan(ppInfoMap);
        Test.stopTest();

        System.assertNotEquals(null, updatedPlan, 'Should have updated the plan and returned it.');
        System.debug(updatedPlan);
    }

    @IsTest
    public static void testDoEditPaymentPlanBadPlanId() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());
        // Required as part of setup even though it's not used
        PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();

        insertPaymentPlan(adminUser);

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(AMOUNT_KEY, '12345');
        ppInfoMap.put(sPRS.PaymentPlanInformation.SIRONO_PP_KEY, '91929394');
        ppInfoMap.put(PLAN_TYPE, PortalConstants.PLANTYPE_AUTO);

        try {
            Test.startTest();
            PaymentTabsController.doEditPaymentPlan(ppInfoMap);
            System.assert(false, 'Should have thown aura exception.');
        } catch (AuraHandledException e) {
            Test.stopTest();
            System.assertNotEquals(null, e.getMessage(), 'Should have an error message.');
            System.assertEquals('Error encountered updating plan. Please contact support', e.getMessage(), 'Should have support message.');
        } catch (Exception ex) {
            System.assert(false, 'Should not have thrown unexpected exception.');
        }

    }

    @IsTest
    public static void testDeletePaymentPlan() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();
        sPRS.MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.sPRS__Guarantor_Id__c.toPlainString();


        sPRS__Payment_Plan__c createdPlan = insertPaymentPlan(adminUser);
        sPRS.MockHttpResponseGenerator.planSironoId = createdPlan.sPRS__Sirono_Id__c.toPlainString();

        sPRS__Payment_Plan__c p1 = [SELECT Id, sPRS__Active__c, sPRS__Cancellation_Date__c FROM sPRS__Payment_Plan__c WHERE Id = :createdPlan.Id];

        System.assertEquals(null, p1.sPRS__Cancellation_Date__c, 'Should not have a cancelation date.');
        System.assertEquals(true, p1.sPRS__Active__c, 'Should be an active plan.');

        System.runAs(portalUser) {
            Test.startTest();
            PaymentTabsController.deletePaymentPlan(createdPlan.Id);
            Test.stopTest();
        }

        p1 = [SELECT Id, sPRS__Active__c, sPRS__Cancellation_Date__c FROM sPRS__Payment_Plan__c WHERE Id = :createdPlan.Id];
        System.assertNotEquals(null, p1.sPRS__Cancellation_Date__c, 'Should be canceled.');
        System.assertEquals(false, p1.sPRS__Active__c, 'Should be inactive.');

    }

    @IsTest
    public static void testDeletePaymentPlanNoPlanFound() {
        Test.setMock(HttpCalloutMock.class, new sPRS.MockHttpResponseGenerator());
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        sPRS.MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.sPRS__Guarantor_Id__c.toPlainString();

        System.runAs(portalUser) {
            try {
                Test.startTest();
                PaymentTabsController.deletePaymentPlan('657438');
                System.assert(false, 'Should have thrown exception.');
            } catch (AuraHandledException e) {
                System.assertEquals('An error has occurred, please contact support.', e.getMessage(), 'Should have the expected support message.');
            } catch (Exception ex) {
                System.assert(false, 'Should not have been an unexpected exception.');
            }
        }
    }

    @IsTest
    public static void getChargeGroupsTest() {
        Contact guarantorContact;
        Contact patientContact;
        sPRS__Invoice__c invoice1;
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        User adminUser = PortalTestUtility.getPortalAdminUser();

        System.runAs(adminUser) {
            Account testAcc = PortalTestUtility.getPortalAccount();
            guarantorContact = PortalTestUtility.getPortalGuarantor();

            patientContact = PortalTestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.sPRS__Medical_Record_Number__c = '1234512345';
            insert patientContact;

            sPRS__Payment_Plan__c pPlan = PortalTestUtility.generatePaymentPlan(guarantorContact.Id);
            insert pPlan;

            List<sPRS__Invoice__c> lstInvoice = new List<sPRS__Invoice__c>();
            invoice1 = PortalTestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice1);

            sPRS__Invoice__c invoice2 = PortalTestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice2);

            sPRS__Invoice__c invoice3 = PortalTestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            invoice3.sPRS__Status_Index__c = 2;
            lstInvoice.add(invoice3);

            insert lstInvoice;

            List<sPRS__Charge_Group__c> lstChrgGroup = new List<sPRS__Charge_Group__c>();
            sPRS__Charge_Group__c chargeGroup1 = PortalTestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup1.sPRS__Invoice__c = invoice1.Id;
            lstChrgGroup.add(chargeGroup1);

            sPRS__Charge_Group__c chargeGroup2 = PortalTestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup2.sPRS__Invoice__c = invoice2.Id;
            lstChrgGroup.add(chargeGroup2);

            insert lstChrgGroup;

            sPRS__Payor__c payorTest = new sPRS__Payor__c(
                Name = 'payotTest'
            );
            insert payorTest;

            sPRS__Coverage__c objcoverage = new sPRS__Coverage__c(
                Name = 'Test',
                sPRS__Payor__c = payorTest.Id
            );
            insert objcoverage;

            sPRS__Charge_Group_Coverage_Junction__c objCGCoverage = new sPRS__Charge_Group_Coverage_Junction__c();
            objCGCoverage.Name = 'Test';
            objCGCoverage.sPRS__Charge_Group__c = chargeGroup1.Id;
            objCGCoverage.sPRS__Coverage__c = objcoverage.Id;
            insert objCGCoverage;

            sPRS__Payment__c payment1 = PortalTestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
            sPRS__Payment__c payment2 = PortalTestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
            List<sPRS__Payment__c> lstPayment = new List<sPRS__Payment__c> {
                payment1, payment2
            };
            insert lstPayment;

            List<sPRS__Transaction__c> lstTransaction = new List<sPRS__Transaction__c>();
            sPRS__Transaction__c transaction1 = PortalTestUtility.generatePaymentTxn(chargeGroup1, 20, payment1);
            lstTransaction.add(transaction1);

            sPRS__Transaction__c transaction2 = PortalTestUtility.generatePaymentTxn(chargeGroup1, 200, payment2);
            lstTransaction.add(transaction2);

            insert lstTransaction;


            invoice1.sPRS__Status_Index__c = 9;
            invoice2.sPRS__Status_Index__c = 4;
            List<sPRS__Invoice__c> lstInvoiceUpdate = new List<sPRS__Invoice__c> {
                invoice1, invoice2
            };
            update lstInvoiceUpdate;

            List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithInvoicesController.getPatientList();
            System.assertEquals(0, patientList.size());
        }

        System.runAs(portalUser) {
            Test.startTest();
            List<sPRS__Charge_Group__c> chargeGroups = PaymentTabsController.getChargeGroups(guarantorContact.Id);
            Test.stopTest();
            System.assertEquals(1, chargeGroups.size(), 'Should have found an active charge group with non-zerio balance.');
            System.assert(chargeGroups[0].sPRS__Active__c == true, 'Should be active.');
            System.assert(chargeGroups[0].sPRS__Balance__c > 0, 'Should have a balance.');

        }
    }

    @IsTest
    public static void getCreditCardsNoResultsTest() {

        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = PortalTestUtility.getPortalGuarantor();

        System.runAs(portalUser) {

            Test.startTest();
            List<CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(0, cards.size(), 'Should be no results.');
        }

    }

    @IsTest
    public static void getCreditCardsVerifyResultsTest() {

        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = PortalTestUtility.getPortalGuarantor();
        String CCardRecordType = PortalRecordTypeUtil.getPayMethodRecordTypes().get(PortalConstants.CREDIT_CARD);
        List<sPRS__Payment_Method__c> payMethods = new List<sPRS__Payment_Method__c>();
        payMethods.add(PortalTestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        payMethods.add(PortalTestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        payMethods.get(0).sPRS__Card_Type__c = 'Visa';
        payMethods.get(0).sPRS__Last_4__c = '1111';
        payMethods.get(0).sPRS__Type__c = PortalConstants.CREDIT_CARD;
        insert payMethods;

        System.runAs(portalUser) {

            Test.startTest();
            List<CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(1, cards.size(), 'Should have a single result as Display_Name is dependant on Type.');
        }

    }

    @IsTest
    public static void getCreditCardsVerifyMultipleResultsTest() {

        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = PortalTestUtility.getPortalGuarantor();
        String CCardRecordType = PortalRecordTypeUtil.getPayMethodRecordTypes().get(PortalConstants.CREDIT_CARD);
        List<sPRS__Payment_Method__c> payMethods = new List<sPRS__Payment_Method__c>();

        sPRS__Payment_Method__c pm1 = PortalTestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType);
        payMethods.add(PortalTestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        pm1.sPRS__Card_Type__c = 'Visa';
        pm1.sPRS__Last_4__c = '1111';
        pm1.sPRS__Type__c = PortalConstants.CREDIT_CARD;
        payMethods.add(pm1);

        sPRS__Payment_Method__c pm2 = PortalTestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType);
        pm2.sPRS__Card_Type__c = 'Master Card';
        pm2.sPRS__Last_4__c = '2222';
        pm2.sPRS__Type__c = PortalConstants.CREDIT_CARD;

        payMethods.add(pm2);

        insert payMethods;

        System.runAs(portalUser) {

            Test.startTest();
            List<CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(2, cards.size(), 'Should have a found both payment methods.');
        }

    }

    private static sPRS__Payment_Plan__c insertPaymentPlan(User adminUser) {
        Contact guarantorContact;
        Contact patientContact;
        sPRS__Payment_Plan__c testPP;

        System.runAs(adminUser) {
            Account testAcc = PortalTestUtility.getPortalAccount();
            guarantorContact = PortalTestUtility.getPortalGuarantor();

            patientContact = PortalTestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.sPRS__Medical_Record_Number__c = '1234512345';
            insert patientContact;

            // Use a modified CreatedDate so we can test transactions added in the future
            Datetime newCreateDate = System.now().addDays(-5);

            Test.setCreatedDate(patientContact.Id, newCreateDate);

            Map<String, String> recordTypeMap = new Map<String, String>();
            for (RecordType recordType : [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = :sPRS__Payment_Method__c.class.getName()
            ]) {
                recordTypeMap.put(recordType.Name, recordType.Id);
            }

            sPRS__Payment_Method__c testPM = PortalTestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Credit Card'));
            insert testPM;
            Test.setCreatedDate(testPM.Id, newCreateDate);

            sPRS__Invoice__c invoiceOne = PortalTestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            insert invoiceOne;

            testPP = PortalTestUtility.generatePaymentPlan(guarantorContact);
            testPP.sPRS__Plan_Value_Modified_Date__c = newCreateDate;
            testPP.sPRS__Original_Balance__c = PortalTestUtility.generateRandomCurrency();
            insert testPP;
            Test.setCreatedDate(testPP.Id, newCreateDate);

            sPRS__Charge_Group__c testCG = PortalTestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, testPP.Id);
            testCG.sPRS__Invoice__c = invoiceOne.Id;
            insert testCG;
            Test.setCreatedDate(testCG.Id, newCreateDate);

            sPRS__Service2__c testService = PortalTestUtility.generateService(guarantorContact, PortalTestUtility.generateRandomCurrency());
            insert testService;

            sPRS__Transaction__c testTransaction = PortalTestUtility.generateServiceTxn(testCG, testService.sPRS__Amount__c, testService);
            testTransaction.sPRS__Post_Date__c = newCreateDate.date();
            testTransaction.sPRS__Transaction_Date__c = testPP.sPRS__Plan_Value_Modified_Date__c.date();
            insert testTransaction;

            // Update invoice status to ensure the charge groups show up.
            invoiceOne.sPRS__Status_Index__c = 9;
            update invoiceOne;

            List<sPRS__Charge_Group__c> createdChargeGroups = PaymentTabsController.getChargeGroups(guarantorContact.Id);

            // Check system asserts.
            System.assertEquals(1, createdChargeGroups.size(), 'Should be able to get charge groups using controller method.');
        }

        return testPP;
    }
}