/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public class PaymentPlanBalanceTest {

    /*
     * Setup test data to be used in the following test methods.
     */

    @TestSetup
    static void setupTestRecords() {
        // Use a modified CreatedDate so we can test transactions added in the future
        Datetime newCreateDate = System.now().addDays(-5);

        // Generate and insert initial Transaction, Charge Group, Guarantor, and Patient
        Contact patient = TestUtility.generatePatientContact();
        insert patient;
        Test.setCreatedDate(patient.Id, newCreateDate);

        Contact guarantor = TestUtility.generateGuarantorContact();
        insert guarantor;
        Test.setCreatedDate(guarantor.Id, newCreateDate);

        Map<String, String> recordTypeMap = new Map<String, String>();
        for (RecordType recordType : [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = :Payment_Method__c.class.getName()
        ]) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }

        Payment_Method__c testPM = TestUtility.generatePaymentMethod(guarantor.Id, recordTypeMap.get('Credit Card'));
        insert testPM;
        Test.setCreatedDate(testPM.Id, newCreateDate);

        Payment_Plan__c testPP = TestUtility.generatePaymentPlan(guarantor);
        testPP.Plan_Value_Modified_Date__c = newCreateDate;
        testPP.Original_Balance__c = TestUtility.generateRandomCurrency();
        insert testPP;
        Test.setCreatedDate(testPP.Id, newCreateDate);

        Charge_Group__c testCG = TestUtility.generateChargeGroup(guarantor.Id, patient.Id, 887887, testPP.Id);
        insert testCG;
        Test.setCreatedDate(testCG.Id, newCreateDate);

        Service2__c testService = TestUtility.generateService(guarantor, TestUtility.generateRandomCurrency());
        insert testService;

        Transaction__c testTransaction = TestUtility.generateServiceTxn(testCG, testService.Amount__c, testService);
        testTransaction.Post_Date__c = newCreateDate.date();
        testTransaction.Transaction_Date__c = testPP.Plan_Value_Modified_Date__c.date();
        insert testTransaction;

        // Check system asserts.
        System.assertEquals(newCreateDate, testPP.Plan_Value_Modified_Date__c,
            'Expected PP modified date ' + newCreateDate + ' but got ' + testPP.Plan_Value_Modified_Date__c);
    }

    /*
     * Upon initial insert of charge group and related data, make sure Charges_Added_Since_Start__c = 0 or null
     */
    @IsTest
    static void initialCGInsertTest() {
        Test.startTest();

        List<Payment_Plan__c> ppResults = [
            SELECT Id, Charges_Added_Since_Start__c
            FROM Payment_Plan__c
        ];

        Test.stopTest();

        for (Payment_Plan__c pp : ppResults) {
            System.debug('Charges added since plan start: ' + pp.Charges_Added_Since_Start__c);
            System.assert(pp.Charges_Added_Since_Start__c == 0.00 || pp.Charges_Added_Since_Start__c == null,
                'Charges Added Should be 0 or null on initial insert.');
        }
    }

    /*
     * Add a new transaction to the charge group, Charges_Added_Since_Start__c should equal transaction amount
     */
    @IsTest
    static void addNewTransactionTest() {
        Test.startTest();

        Charge_Group__c testCG = [SELECT Id, Balance__c FROM Charge_Group__c LIMIT 1];
        Contact guarantor = [SELECT Id FROM Contact WHERE RecordType.Name = 'Guarantor' LIMIT 1];

        Service2__c newService = TestUtility.generateService(guarantor, TestUtility.generateRandomCurrency());
        insert newService;

        Transaction__c newServiceTransaction = TestUtility.generateServiceTxn(testCG, newService.Amount__c, newService);
        newServiceTransaction.Post_Date__c = System.today();
        newServiceTransaction.Transaction_Date__c = newServiceTransaction.Post_Date__c;
        insert newServiceTransaction;

        Payment_Plan__c ppResults = [
            SELECT Id, Charges_Added_Since_Start__c
            FROM Payment_Plan__c
            LIMIT 1
        ];

        Test.stopTest();

        System.assertEquals(newServiceTransaction.Amount__c, ppResults.Charges_Added_Since_Start__c,
            'Charges added since plan start should equal the inserted transaction amount.');
    }

    /*
     * Add a new transaction and then modify the payment plan's value modified date
     * Assert that Charges_Added_Since_Start__c equals 0
     */
    @IsTest
    static void changePPValueModifiedDateTest() {
        Test.startTest();

        Charge_Group__c testCG = [SELECT Id, Balance__c FROM Charge_Group__c LIMIT 1];
        Contact guarantor = [SELECT Id FROM Contact WHERE RecordType.Name = 'Guarantor' LIMIT 1];

        Service2__c newService = TestUtility.generateService(guarantor, TestUtility.generateRandomCurrency());
        insert newService;

        Transaction__c secondTestTransaction = TestUtility.generateServiceTxn(testCG, newService.Amount__c, newService);
        secondTestTransaction.Transaction_Date__c = System.today().addDays(-3);
        insert secondTestTransaction;

        Payment_Plan__c updatedPPResults = [
            SELECT Id, Charges_Added_Since_Start__c, Remaining_Balance__c, Plan_Value_Modified_Date__c
            FROM Payment_Plan__c
            LIMIT 1
        ];

        // Modify PP value modified date and recalculate
        updatedPPResults.Plan_Value_Modified_Date__c = Date.today();
        update updatedPPResults;

        Payment_Plan__c finalPPResults = [
            SELECT Id, Charges_Added_Since_Start__c, Remaining_Balance__c, Plan_Value_Modified_Date__c
            FROM Payment_Plan__c
            LIMIT 1
        ];

        Test.stopTest();

        System.assertEquals(0, finalPPResults.Charges_Added_Since_Start__c,
            'Value date was updated, charges added should be 0.');
    }

    /*
     * Insert a payment transaction and
     * Assert that the added charges field isn't updated
     * Charges_Added_Since_Start__c sums only service transactions
     */
    @IsTest
    static void insertPaymentTransactionTest() {
        Test.startTest();

        Charge_Group__c testCG = [SELECT Id, Balance__c FROM Charge_Group__c LIMIT 1];
        Contact guarantor = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Payment__c pmt = TestUtility.generateSironoPayment(guarantor.Id, Decimal.valueOf(Math.random()), TestUtility.generateRandomCurrency());
        insert pmt;

        Transaction__c secondTestTransaction = TestUtility.generatePaymentTxn(testCG, pmt.Amount__c, pmt);
        secondTestTransaction.Transaction_Date__c = secondTestTransaction.Post_Date__c;
        insert secondTestTransaction;

        Payment_Plan__c ppResults = [
            SELECT Id, Charges_Added_Since_Start__c
            FROM Payment_Plan__c
            LIMIT 1
        ];

        Test.stopTest();

        System.assertEquals(0, ppResults.Charges_Added_Since_Start__c,
            'Transaction was payment type; charges added should not have been updated.');
    }
}