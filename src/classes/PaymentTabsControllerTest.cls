/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@isTest
public with sharing class PaymentTabsControllerTest {

    private static String PLAN_SIRONO_ID = '2876';

    @isTest
    public static void getCardSelectOptionsTest() {
        Test.startTest();
        Map<String, Map<String, String>> opts = PaymentTabsController.getCardSelectOptions();
        Test.stopTest();

        System.assertEquals(2, opts.keySet().size(), 'Should have both YEARS and MONTHS');
    }

    @isTest
    public static void testGetPaymentPlanInfoNullForNoContact() {
        Test.startTest();
        PaymentTabsController.GuarantorPaymentInfo gpi = PaymentTabsController.getPaymentPlanInfo();
        Test.stopTest();

        System.assertEquals(null, gpi, 'Should be null if no contact id is found.');
    }

    @isTest
    public static void testGetPaymentPlanInfoForNoActiveCGs() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        // Update all the portal users charge groups to not active.
        System.runAs(adminUser) {
            List<Charge_Group__c> cgs = [
                SELECT Id, Active__c
                FROM Charge_Group__c
                WHERE Id = :portalUser.ContactId
            ];

            for (Charge_Group__c cg : cgs) {
                cg.Active__c = false;
            }
            UPDATE cgs;
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

    @isTest
    public static void testGetPaymentPlanInfoHasChargeGroups() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        PaymentTabsController.GuarantorPaymentInfo gpi;
        insertPaymentPlan(adminUser, portalUser);

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

    @isTest
    public static void testCreatePaymentPlan() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User portalUser = TestUtility.getGuarantorCommunityUser();
        // Update the mock response to use the community guarantor sirono id.
        MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.Profile_Pointer_Id__c.toPlainString();

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(PaymentPlanInformation.PLAN_TYPE, Constants.PLANTYPE_AUTO);
        ppInfoMap.put(PaymentPlanInformation.PLAN_VALUE, '');
        ppInfoMap.put(PaymentPlanInformation.AMOUNT_KEY, '234');
        ppInfoMap.put(PaymentPlanInformation.EXECUTE_ON_DAY, '1');
        ppInfoMap.put(PaymentPlanInformation.GUARANTOR_ID, portalUser.ContactId);
        ppInfoMap.put(PaymentPlanInformation.CARD_HOLDER_NAME, 'Pork nBeans');
        ppInfoMap.put(PaymentPlanInformation.EXPIRATION_YEAR, String.valueof(System.today().Year() + 1));
        ppInfoMap.put(PaymentPlanInformation.EXPIRATION_MONTH, '7');
        ppInfoMap.put(PaymentPlanInformation.CVV_KEY, '127');
        ppInfoMap.put(PaymentPlanInformation.STATE_KEY, 'CA');
        ppInfoMap.put(PaymentPlanInformation.ZIP_KEY, '78717');
        ppInfoMap.put(PaymentPlanInformation.ADDRESS_KEY, '123 St. Road');
        ppInfoMap.put(PaymentPlanInformation.CITY_KEY, 'San Diego');

        Payment_Plan__c plan;
        System.runAs(portalUser) {
            Test.startTest();
            plan = PaymentTabsController.createPaymentPlan(ppInfoMap, false);
            Test.stopTest();
        }

        System.assertNotEquals(null, plan, 'Should create a paymentPlan.');
        System.assertEquals(null, plan.Payment_Method__c, 'Should not have inserted the payment method.');
    }

    @isTest
    public static void testDoEditPaymentMethodNoId() {
        Map<String, Object> ppInfoMap = new Map<String, Object>();

        try {
            Test.startTest();
            Payment_Plan__c plan = PaymentTabsController.doEditPaymentMethod(ppInfoMap, false);
            System.assert(false, 'Should have thown aura exception.');
        } catch (AuraHandledException e) {
            Test.stopTest();
            System.assertNotEquals(null, e.getMessage(), 'Should have an error message.');
        } catch (Exception ex) {
            System.assert(false, 'Should not have thrown unexpected exception.');
        }

    }

    @isTest
    public static void testDoEditPaymentMethodNewCardNoSave() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        Payment_Plan__c createdPlan = insertPaymentPlan(adminUser, portalUser);
        String cHolderName = 'Pork nBeans';

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(PaymentPlanInformation.CARD_HOLDER_NAME, cHolderName);
        ppInfoMap.put(PaymentPlanInformation.EXPIRATION_YEAR, String.valueof(System.today().Year() + 1));
        ppInfoMap.put(PaymentPlanInformation.EXPIRATION_MONTH, '7');
        ppInfoMap.put(PaymentPlanInformation.CVV_KEY, '127');
        ppInfoMap.put(PaymentPlanInformation.CREDITCARD_NUMBER, '4111111111111111');
        ppInfoMap.put('id', createdPlan.Id);

        Payment_Plan__c plan;
        System.runAs(portalUser) {
            Test.startTest();
            plan = PaymentTabsController.doEditPaymentMethod(ppInfoMap, false);
            Test.stopTest();
        }

        List<Payment_Method__c> savedMethods = [SELECT Id FROM Payment_Method__c WHERE Card_Holder_Name__c = :cHolderName];
        System.assertNotEquals(null, plan, 'Should return payment plan');
        System.assertEquals(0, savedMethods.size(), 'Should not have saved the new payment method.');
    }

    @isTest
    public static void testDoEditPaymentMethodNewCardSaved() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        Payment_Plan__c createdPlan = insertPaymentPlan(adminUser, portalUser);
        String cHolderName = 'Pork nBeans';

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(PaymentPlanInformation.CARD_HOLDER_NAME, cHolderName);
        ppInfoMap.put(PaymentPlanInformation.EXPIRATION_YEAR, String.valueof(System.today().Year() + 1));
        ppInfoMap.put(PaymentPlanInformation.EXPIRATION_MONTH, '7');
        ppInfoMap.put(PaymentPlanInformation.CVV_KEY, '127');
        ppInfoMap.put(PaymentPlanInformation.CREDITCARD_NUMBER, '4111111111111111');
        ppInfoMap.put('id', createdPlan.Id);

        Payment_Plan__c plan;
        System.runAs(portalUser) {
            Test.startTest();
            plan = PaymentTabsController.doEditPaymentMethod(ppInfoMap, true);
            Test.stopTest();
        }

        List<Payment_Method__c> savedMethods = [SELECT Id FROM Payment_Method__c WHERE Card_Holder_Name__c = :cHolderName];
        System.assertNotEquals(null, plan, 'Should return payment plan');
        System.assertEquals(1, savedMethods.size(), 'Should have saved the new payment method.');
    }

    @isTest
    public static void testDoEditPaymentPlanNoId() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
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

    @isTest
    public static void testDoEditPaymentPlanSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();
        MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.Profile_Pointer_Id__c.toPlainString();

        Payment_Plan__c createdPlan = insertPaymentPlan(adminUser, portalUser);

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(PaymentPlanInformation.AMOUNT_KEY, '12345');
        ppInfoMap.put(PaymentPlanInformation.SIRONO_PP_KEY, '2876');
        ppInfoMap.put(PaymentPlanInformation.PLAN_TYPE, Constants.PLANTYPE_AUTO);

        Test.startTest();
        Payment_Plan__c updatedPlan = PaymentTabsController.doEditPaymentPlan(ppInfoMap);
        Test.stopTest();

        System.assertNotEquals(null, updatedPlan, 'Should have updated the plan and returned it.');
        System.debug(updatedPlan);
    }

    @isTest
    public static void testDoEditPaymentPlanBadPlanId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        Payment_Plan__c createdPlan = insertPaymentPlan(adminUser, portalUser);

        Map<String, Object> ppInfoMap = new Map<String, Object>();
        ppInfoMap.put(PaymentPlanInformation.AMOUNT_KEY, '12345');
        ppInfoMap.put(PaymentPlanInformation.SIRONO_PP_KEY, '91929394');
        ppInfoMap.put(PaymentPlanInformation.PLAN_TYPE, Constants.PLANTYPE_AUTO);

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

    @isTest
    public static void testDeletePaymentPlan() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();
        MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.Profile_Pointer_Id__c.toPlainString();


        Payment_Plan__c createdPlan = insertPaymentPlan(adminUser, portalUser);
        MockHttpResponseGenerator.planSironoId = createdPlan.Sirono_ID__c.toPlainString();

        Payment_Plan__c p1 = [SELECT Id, Active__c, Cancellation_Date__c FROM Payment_Plan__c WHERE Id = :createdPlan.Id];

        System.assertEquals(null, p1.Cancellation_Date__c, 'Should not have a cancelation date.');
        System.assertEquals(true, p1.Active__c, 'Should be an active plan.');

        System.runAs(portalUser) {
            Test.startTest();
            PaymentTabsController.deletePaymentPlan(createdPlan.Id);
            Test.stopTest();
        }

        p1 = [SELECT Id, Active__c, Cancellation_Date__c FROM Payment_Plan__c WHERE Id = :createdPlan.Id];
        System.assertNotEquals(null, p1.Cancellation_Date__c, 'Should be canceled.');
        System.assertEquals(false, p1.Active__c, 'Should be inactive.');

    }

    @isTest
    public static void testDeletePaymentPlanNoPlanFound() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        User portalUser = TestUtility.getGuarantorCommunityUser();
        MockHttpResponseGenerator.guarantorSironoId = portalUser.Contact.Profile_Pointer_Id__c.toPlainString();

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

    @isTest
    public static void getChargeGroupsTest() {
        Contact guarantorContact;
        Contact patientContact;
        Invoice__c invoice1;
        User portalUser = TestUtility.getGuarantorCommunityUser();
        User adminUser = TestUtility.getPortalAdminUser();

        System.runAs(adminUser) {
            Account testAcc = TestUtility.getPortalAccount();
            guarantorContact = TestUtility.getPortalGuarantor();

            patientContact = TestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.Medical_Record_Number__c = '1234512345';
            INSERT patientContact;

            Payment_Plan__c pPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
            INSERT pPlan;

            List<Invoice__c> lstInvoice = new List<Invoice__c>();
            invoice1 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice1);

            Invoice__c invoice2 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            lstInvoice.add(invoice2);

            Invoice__c invoice3 = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            invoice3.Invoice_Status_Index__c = 2;
            lstInvoice.add(invoice3);

            INSERT lstInvoice;

            List<Charge_Group__c> lstChrgGroup = new List<Charge_Group__c>();
            Charge_Group__c chargeGroup1 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup1.Invoice__c = invoice1.Id;
            lstChrgGroup.add(chargeGroup1);

            Charge_Group__c chargeGroup2 = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, pPlan.Id);
            chargeGroup2.Invoice__c = invoice2.Id;
            lstChrgGroup.add(chargeGroup2);

            INSERT lstChrgGroup;

            Payor__c payorTest = new Payor__c(
                Name = 'payotTest'
            );
            INSERT payorTest;

            Coverage__c objcoverage = new Coverage__c(
                Name = 'Test',
                Payor__c = payorTest.Id
            );
            INSERT objcoverage;

            Charge_Group_Coverage_Junction__c objCGCoverage = new Charge_Group_Coverage_Junction__c();
            objCGCoverage.Name = 'Test';
            objCGCoverage.Charge_Group__c = chargeGroup1.Id;
            objCGCoverage.Coverage__c = objcoverage.Id;
            INSERT objCGCoverage;

            Payment__c payment1 = TestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
            Payment__c payment2 = TestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
            List<Payment__c> lstPayment = new List<Payment__c>{
                payment1, payment2
            };
            INSERT lstPayment;

            List<Transaction__c> lstTransaction = new List<Transaction__c>();
            Transaction__c transaction1 = TestUtility.generatePaymentTxn(chargeGroup1, 20, payment1);
            lstTransaction.add(transaction1);

            Transaction__c transaction2 = TestUtility.generatePaymentTxn(chargeGroup1, 200, payment2);
            lstTransaction.add(transaction2);

            INSERT lstTransaction;


            invoice1.Invoice_Status_Index__c = 9;
            invoice2.Invoice_Status_Index__c = 4;
            List<Invoice__c> lstInvoiceUpdate = new List<Invoice__c>{
                invoice1, invoice2
            };
            UPDATE lstInvoiceUpdate;

            List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithInvoicesController.getPatientList();
            System.assertEquals(0, patientList.size());
        }

        System.runAs(portalUser) {
            Test.startTest();
            List<Charge_Group__c> chargeGroups = PaymentTabsController.getChargeGroups(guarantorContact.Id);
            Test.stopTest();
            System.assertEquals(1, chargeGroups.size(), 'Should have found an active charge group with non-zerio balance.');
            System.assert(chargeGroups[0].Active__c == true, 'Should be active.');
            System.assert(chargeGroups[0].Balance__c > 0 , 'Should have a balance.');

        }
    }

    @isTest
    public static void getCreditCardsNoResultsTest() {

        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();

        System.runAs(portalUser) {

            Test.startTest();
            List<CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(0, cards.size(), 'Should be no results.');
        }

    }

    @isTest
    public static void getCreditCardsVerifyResultsTest() {

        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();
        String CCardRecordType = RecordTypeUtil.getPayMethodRecordTypes().get(Constants.CREDIT_CARD);
        List<Payment_Method__c> payMethods = new List<Payment_Method__c>();
        payMethods.add(TestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        payMethods.add(TestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        payMethods.get(0).Card_Type__c = 'Visa';
        payMethods.get(0).Last_4__c = '1111';
        payMethods.get(0).Type__c = Constants.CREDIT_CARD;
        INSERT payMethods;

        //TODO Figure out sharing for portal users!
        List<Payment_Method__Share> shares = new List<Payment_Method__Share>();
        for (Payment_Method__c pm : payMethods) {
            Payment_Method__Share share  = new Payment_Method__Share();
            share.ParentId = pm.Id;
            share.UserOrGroupId = portalUser.Id;
            share.AccessLevel = 'edit';
            shares.add(share);
        }

        INSERT shares;

        System.runAs(portalUser) {

            Test.startTest();
            List<CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(1, cards.size(), 'Should have a single result as Display_Name is dependant on Type.');
        }

    }

    @isTest
    public static void getCreditCardsVerifyMultipleResultsTest() {

        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();
        String CCardRecordType = RecordTypeUtil.getPayMethodRecordTypes().get(Constants.CREDIT_CARD);
        List<Payment_Method__c> payMethods = new List<Payment_Method__c>();

        Payment_Method__c pm1 = TestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType);
        payMethods.add(TestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        pm1.Card_Type__c = 'Visa';
        pm1.Last_4__c = '1111';
        pm1.Type__c = Constants.CREDIT_CARD;
        payMethods.add(pm1);

        Payment_Method__c pm2 = TestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType);
        pm2.Card_Type__c = 'Master Card';
        pm2.Last_4__c = '2222';
        pm2.Type__c = Constants.CREDIT_CARD;

        payMethods.add(pm2);

        INSERT payMethods;

        //TODO Figure out sharing for portal users!
        List<Payment_Method__Share> shares = new List<Payment_Method__Share>();
        for (Payment_Method__c pm : payMethods) {
            Payment_Method__Share share  = new Payment_Method__Share();
            share.ParentId = pm.Id;
            share.UserOrGroupId = portalUser.Id;
            share.AccessLevel = 'edit';
            shares.add(share);
        }

        INSERT shares;

        System.runAs(portalUser) {

            Test.startTest();
            List<CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(2, cards.size(), 'Should have a found both payment methods.');
        }

    }

    private static Payment_Plan__c insertPaymentPlan(User adminUser, User portalUser) {
        Contact guarantorContact;
        Contact patientContact;
        Payment_Plan__c testPP;

        System.runAs(adminUser) {
            Account testAcc = TestUtility.getPortalAccount();
            guarantorContact = TestUtility.getPortalGuarantor();

            patientContact = TestUtility.generatePatientContact();
            patientContact.AccountId = testAcc.Id;
            patientContact.Medical_Record_Number__c = '1234512345';
            INSERT patientContact;

            // Use a modified CreatedDate so we can test transactions added in the future
            Datetime newCreateDate = System.now().addDays(-5);

            Test.setCreatedDate(patientContact.Id, newCreateDate);

            Map<String, String> recordTypeMap = new Map<String, String>();
            for (RecordType recordType : [
                Select Id, Name
                From RecordType
                Where sObjectType = :Payment_Method__c.class.getName()
            ]) {
                recordTypeMap.put(recordType.Name, recordType.Id);
            }

            Payment_Method__c testPM = TestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Credit Card'));
            INSERT testPM;
            Test.setCreatedDate(testPM.Id, newCreateDate);

            Invoice__c invoiceOne = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
            INSERT invoiceOne;

            testPP = TestUtility.generatePaymentPlan(guarantorContact);
            testPP.Plan_Value_Modified_Date__c = newCreateDate;
            testPP.Original_Balance__c = TestUtility.generateRandomCurrency();
            INSERT testPP;
            Test.setCreatedDate(testPP.Id, newCreateDate);

            Charge_Group__c testCG = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 1234, testPP.Id);
            testCG.Invoice__c = invoiceOne.Id;
            INSERT testCG;
            Test.setCreatedDate(testCG.Id, newCreateDate);

            Service__c testService = TestUtility.generateService(testCG, TestUtility.generateRandomCurrency());
            testService.Post_Date__c = newCreateDate.date();
            INSERT testService;

            Transaction__c testTransaction = TestUtility.generateServiceTxn(testCG, testService.Amount__c, testService);
            testTransaction.Post_Date__c = newCreateDate;
            testTransaction.Transaction_Date__c = testPP.Plan_Value_Modified_Date__c.date();
            INSERT testTransaction;

            // Update invoide status to ensure the charge groups show up.
            invoiceOne.Invoice_Status_Index__c = 9;
            UPDATE invoiceOne;

            List<Charge_Group__c> createdChargeGroups = PaymentTabsController.getChargeGroups(guarantorContact.Id);

            // Check system asserts.
            System.assertEquals(1, createdChargeGroups.size(), 'Should be able to get charge groups using controller method.');
        }

        return testPP;
    }
}