@isTest
public class InvoiceUtilTest {

    @isTest
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
            testChargeGroup.Balance__c = TestUtility.;

            testChargeGroupList.add(testChargeGroup);
        }
        insert testChargeGroupList;

    }

    @isTest
    public static void checkInvoiceIndexValue() {
        Invoice__c invoiceIndexValueCheck = [
                SELECT Id, Invoice_Status_Index__c
                FROM Invoice__c
                LIMIT 1
        ];

        system.assertEquals(7, invoiceIndexValueCheck.Invoice_Status_Index__c);
    }
}