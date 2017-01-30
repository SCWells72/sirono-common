@isTest
public class InvoiceUtilTest {

    @testSetup
    public static void setupTestRecords() {

        final String INACTIVE = 'Inactive';
        final String PAID = 'Paid';
        final String DELINQUENT = 'Delinquent';
        final String TXN_SERVICE = 'serivce';


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
            testChargeGroup.Sirono_ID__c = i;

            testChargeGroupList.add(testChargeGroup);
        }
        insert testChargeGroupList;

        List<Transaction__c> testTransactionsList = new List<Transaction__c>();
        for (Charge_Group__c cg : testChargeGroupList) {
            for (Integer i = 0; i < 5; i++) {
                Integer randomInt = Integer.valueOf(Math.random()*100000);
                Transaction__c tempTransaction = TestUtility.generateTransaction(cg, TestUtility.generateRandomCurrency(), 'service');
                tempTransaction.Sirono_ID__c = randomInt;
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

        system.assertEquals(7, invoiceIndexValueCheck.Invoice_Status_Index__c);

        Test.stopTest();
    }

    @isTest
    public static void checkInvoiceBalance() {
        Test.startTest();

        List<Invoice__c> insertedInvoices = [
                SELECT Id
                FROM Invoice__c
        ];
        Set<Id> invoiceIdSet = (new Map<Id, Invoice__c>(insertedInvoices)).keySet();

        // call invoice utility to update invoice balance
        InvoiceUtil.updateInvoiceBalances(invoiceIdSet);

        AggregateResult[] transactionSum = [
                SELECT SUM(Amount__c) txnAmount, Charge_Group__r.Invoice__c
                FROM Transaction__c
                GROUP BY Charge_Group__r.Invoice__c
        ];

        // Get the invoice Id and make sure they're the same as the txn sum
        Invoice__c invoiceBalanceCheck = [
                SELECT Id, Invoice_Balance__c
                FROM Invoice__c
                LIMIT 1
        ];

        system.assertEquals(transactionSum[0].get('txnAmount'), invoiceBalanceCheck.Invoice_Balance__c);

        Test.stopTest();
    }

    @isTest
    public static void invoiceBalanceDeletedChargeGroupTest() {
        // Get a list of charge groups and delete them
        // Assert that invoice balance = 0.00
        Test.startTest();

        List<Charge_Group__c> chargeGroups = [
                SELECT Id
                FROM Charge_Group__c
        ];
        delete chargeGroups;

        Invoice__c invoice = [
                SELECT Id, Invoice_Balance__c
                FROM Invoice__c
                LIMIT 1
        ];

        system.assertEquals(0.00, invoice.Invoice_Balance__c);

        Test.stopTest();
    }
}