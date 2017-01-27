@isTest
public class InvoiceUtilTest {

    @testSetup
    public static void setupTestRecords() {

        final String INACTIVE = 'Inactive';
        final String PAID = 'Paid';
        final String DELINQUENT = 'Delinquent';

        List<String> statusList = new List<String>();
        statusList.add(INACTIVE);
        statusList.add(PAID);
        statusList.add(DELINQUENT);

        Contact testGuarantor = TestUtility.generateGuarantorContact();
        insert testGuarantor;

        Contact testPatient = TestUtility.generatePatientContact();
        insert testPatient;

        Invoice__c testInvoice = TestUtility.generateInvoice(testGuarantor.Id, testPatient.Id);
        insert testInvoice;

        List<Charge_Group__c> testChargeGroupList = new List<Charge_Group__c>();
        for (Integer i = 0; i < 3; i++) {
            Charge_Group__c testChargeGroup = TestUtility.generateChargeGroup(testGuarantor.Id, testPatient.Id, i, null);
            testChargeGroup.Account_Sub_Status__c = statusList[i];
            testChargeGroup.Invoice__c = testInvoice.Id;

            testChargeGroupList.add(testChargeGroup);
        }
        insert testChargeGroupList;

    }

    @isTest
    public static void checkInvoiceIndexValue() {
        Test.startTest();

        Invoice__c invoiceIndexValueCheck = [
                SELECT Id, Invoice_Status_Index__c
                FROM Invoice__c
                LIMIT 1
        ];

        system.assertEquals(7, invoiceIndexValueCheck.Invoice_Status_Index__c);

        Test.stopTest();
    }

    @isTest
    public static void checkAllSubstatusInvoiceString() {
        Test.startTest();

        List<Invoice__c> queryResults = [
                SELECT Id, All_Substatus__c
                FROM Invoice__c
        ];

        for (Invoice__c invoice : queryResults) {
            system.assertEquals(true, invoice.All_Substatus__c.contains('Inactive'));
            system.assertEquals(true, invoice.All_Substatus__c.contains('Paid'));
            system.assertEquals(true, invoice.All_Substatus__c.contains('Delinquent'));
        }

        Test.stopTest();
    }

    @isTest
    public static void checkAllSubstatusInvoiceFieldEmptySet() {
        Test.startTest();

        String errorMessage;
        Set<Id> emptyInvoiceIdSet = new Set<Id>();

        try {
            InvoiceUtil.updateAllSubstatusInvoiceField(emptyInvoiceIdSet);
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }

        system.assertEquals(null, errorMessage);

        Test.stopTest();
    }

    @isTest
    public static void changeChargeGroupSubstatusTest() {
        Test.startTest();

        List<Charge_Group__c> chargeGroupList = [
                SELECT Id, Account_Sub_Status__c
                FROM Charge_Group__c
                WHERE Account_Sub_Status__c = 'Delinquent'
        ];

        chargeGroupList[0].Account_Sub_Status__c = 'Paid';
        update chargeGroupList[0];

        List<Invoice__c> invoiceList =[
                SELECT Id, All_Substatus__c
                FROM Invoice__c
        ];

        // Assert the count of values from splitting the All_Substatus__c field
        // Assert that 'Delinquent' is no longer in the All_Substatus__c
        System.assertEquals(2, invoiceList[0].All_Substatus__c.split(',').size());
        System.assertEquals(false, invoiceList[0].All_Substatus__c.contains('Delinquent'));

        Test.stopTest();
    }

    public static void deleteRelatedChargeGroupTest() {
        Test.startTest();

        List<Charge_Group__c> chargeGroupList = [
            SELECT Id
            FROM Charge_Group__c
        ];

        delete chargeGroupList;

        List<Invoice__c> invoiceList = [
                SELECT Id, All_Substatus__c
                FROM Invoice__c
        ];

        System.assertEquals(null, invoiceList[0].All_Substatus__c);

        Test.stopTest();
    }
}