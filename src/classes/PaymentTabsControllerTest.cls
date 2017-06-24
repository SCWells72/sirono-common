
@isTest
public with sharing class PaymentTabsControllerTest {

    @isTest
    public static void getCardSelectOptions() {
        Test.startTest();
        Map<String, Map<String, String>> opts = PaymentTabsController.getCardSelectOptions();
        Test.stopTest();

        System.assertEquals(2, opts.keySet().size(), 'Should have both YEARS and MONTHS');
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
    public static void getCreditCards_NoResults() {

        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();

        System.runAs(portalUser) {

            Test.startTest();
            List<MakeAPaymentController.CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(0, cards.size(), 'Should be no results.');
        }

    }

    @isTest
    public static void getCreditCards_verifyResults() {

        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();
        String CCardRecordType = getPayMethodRecordTypes().get(Constants.CREDIT_CARD);
        List<Payment_Method__c> payMethods = new List<Payment_Method__c>();
        payMethods.add(TestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        payMethods.add(TestUtility.generatePaymentMethod(guarantorContact.Id, CCardRecordType));
        payMethods.get(0).Card_Type__c = 'Visa';
        payMethods.get(0).Last_4__c = '1111';
        payMethods.get(0).Type__c = Constants.CREDIT_CARD;
        INSERT payMethods;

        System.runAs(portalUser) {

            Test.startTest();
            List<MakeAPaymentController.CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(1, cards.size(), 'Should have a single result as Display_Name is dependant on Type.');
        }

    }

    @isTest
    public static void getCreditCards_verifyMultipleResults() {

        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();
        String CCardRecordType = getPayMethodRecordTypes().get(Constants.CREDIT_CARD);
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

        System.runAs(portalUser) {

            Test.startTest();
            List<MakeAPaymentController.CardInformation> cards = PaymentTabsController.getCreditCards(guarantorContact.Id);
            Test.stopTest();

            System.assertEquals(2, cards.size(), 'Should have a found both payment methods.');
        }

    }

    @isTest
    private static Map<String, String> getPayMethodRecordTypes() {
        Map<String, String> recordTypeMap = new Map<String, String>();
        for (RecordType recordType : [
            Select Id, Name
            From RecordType
            Where sObjectType = :Payment_Method__c.class.getName()
        ]) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }

        System.assert(recordTypeMap.size() != 0);
        return recordTypeMap;
    }
}