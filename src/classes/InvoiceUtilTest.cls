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

        List<Transaction__c> testTransactionsList = new List<Transaction__c>();
        for (Charge_Group__c cg: testChargeGroupList) {
            for (Integer i = 0; i < 5; i++) {
                Transaction__c tempTransaction = TestUtility.generateTransaction(cg, TestUtility.generateRandomCurrency(), 'service');
                testTransactionsList.add(tempTransaction);
            }
        }
        insert testTransactionsList;

    }

    @isTest
    public static void checkInvoiceIndexValue() {
        Test.startTest();

        Invoice__c invoiceIndexValueCheck = [
                SELECT Id, Invoice_Status_Index__c
                FROM Invoice__c
                LIMIT 1
        ];

        Test.stopTest();

        system.assertEquals(9, invoiceIndexValueCheck.Invoice_Status_Index__c);
    }

    @isTest
    public static void checkAllSubstatusInvoiceString() {
        Test.startTest();

        List<Invoice__c> queryResults = [
                SELECT Id, All_Substatus__c
                FROM Invoice__c
        ];

        Test.stopTest();

        for (Invoice__c invoice : queryResults) {
            system.assertEquals(true, invoice.All_Substatus__c.contains('Inactive'));
            system.assertEquals(true, invoice.All_Substatus__c.contains('Paid'));
            system.assertEquals(true, invoice.All_Substatus__c.contains('Delinquent'));
        }
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

        Test.stopTest();

        system.assertEquals(null, errorMessage);
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

        Test.stopTest();

        // Assert the count of values from splitting the All_Substatus__c field
        // Assert that 'Delinquent' is no longer in the All_Substatus__c
        System.assertEquals(2, invoiceList[0].All_Substatus__c.split(',').size());
        System.assertEquals(false, invoiceList[0].All_Substatus__c.contains('Delinquent'));
    }

    @isTest
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

        Test.stopTest();

        System.assertEquals(null, invoiceList[0].All_Substatus__c);
    }

    @isTest
    public static void initialInvoiceBalanceTest() {
        Test.startTest();

        Invoice__c inv = [
                SELECT Id, Invoice_Balance__c
                FROM Invoice__c
                LIMIT 1
        ];

        AggregateResult[] cgBalanceSum = [
                SELECT SUM(Balance__c) balanceSum
                FROM Charge_Group__c
                WHERE Invoice__c = :inv.Id
                GROUP BY Invoice__c
        ];

        Decimal sumChargeGroupBalance;
        for (AggregateResult ar: cgBalanceSum) {
            sumChargeGroupBalance = (Decimal) ar.get('balanceSum');
        }

        Test.stopTest();

        System.assertNotEquals(null, inv.Invoice_Balance__c);
        System.assertEquals(sumChargeGroupBalance, inv.Invoice_Balance__c);
    }

    @isTest
    public static void invoiceBalanceCheckWithDeletedChargeGroup() {
        Test.startTest();

        Invoice__c inv = [
                SELECT Id, Invoice_Balance__c
                FROM Invoice__c
                LIMIT 1
        ];

        Decimal originalBalance = inv.Invoice_Balance__c;

        Charge_Group__c deleteChargeGroup = [
                SELECT Id
                FROM Charge_Group__c
                LIMIT 1
        ];

        delete deleteChargeGroup;

        Invoice__c updatedInv = [
                SELECT Id, Invoice_Balance__c
                FROM Invoice__c
                LIMIT 1
        ];

        Decimal updatedBalance = updatedInv.Invoice_Balance__c;

        Test.stopTest();

        System.assertNotEquals(originalBalance, updatedBalance);
    }

    @isTest
    public static void invoiceBalanceWithNoChargeGroups() {
        test.startTest();

        Invoice__c inv = [
                SELECT Id, Invoice_Balance__c
                FROM Invoice__c
                LIMIT 1
        ];

        Decimal originalBalance = inv.Invoice_Balance__c;

        List<Charge_Group__c> deleteAllChargeGroups = [
                SELECT Id
                FROM Charge_Group__c
        ];

        delete deleteAllChargeGroups;

        Invoice__c updatedInv = [
                SELECT Id, Invoice_Balance__c
                FROM Invoice__c
                LIMIT 1
        ];

        Decimal updatedBalance = updatedInv.Invoice_Balance__c;

        test.stopTest();

        System.assertNotEquals(originalBalance, updatedBalance);
        System.assertEquals(0.00, updatedBalance);
    }
}