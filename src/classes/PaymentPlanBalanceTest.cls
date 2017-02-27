@isTest
public class PaymentPlanBalanceTest {

    /*
     * Setup test data to be used in the following test methods.
     */

    @testSetup
    static void setupTestRecords() {
        // Use a modified CreatedDate so we can test transactions added in the future
        Datetime newCreateDate = system.now().addDays(-5);

        // Generate and insert initial Transaction, Charge Group, Guarantor, and Patient
        Contact patient = TestUtility.generatePatientContact();
        patient.CreatedDate = Date.valueOf(newCreateDate);
        insert patient;


        Contact guarantor = TestUtility.generateGuarantorContact();
        guarantor.CreatedDate = Date.valueOf(newCreateDate);
        insert guarantor;


        Map<String, String> recordTypeMap = new Map<String, String>();
        for (RecordType recordType : [
                Select Id, Name
                From RecordType
                Where sObjectType = 'Payment_Method__c'
        ]) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }

        Payment_Method__c testPM = TestUtility.generatePaymentMethod(guarantor.Id, recordTypeMap.get('Credit Card'));
        testPM.CreatedDate = Date.valueOf(newCreateDate);
        insert testPM;

        Payment_Plan__c testPP = TestUtility.generatePaymentPlan(guarantor);
        testPP.CreatedDate = newCreateDate;
        testPP.Plan_Value_Modified_Date__c = newCreateDate;
        testPP.Original_Balance__c = TestUtility.generateRandomCurrency();
        insert testPP;

        Charge_Group__c testCG = TestUtility.generateChargeGroup(guarantor.Id, patient.Id, 887887, testPP.Id);
        testCG.CreatedDate = Date.valueOf(newCreateDate);
        insert testCG;

        Service__c testService = TestUtility.generateService(testCG, TestUtility.generateRandomCurrency());
        testService.Post_Date__c = Date.valueOf(newCreateDate);
        insert testService;

        Transaction__c testTransaction = TestUtility.generateServiceTxn(testCG, testService.Amount__c, testService);
        testTransaction.Post_Date__c = Date.valueOf(newCreateDate);
        testTransaction.Transaction_Date__c = Date.valueOf(testPP.Plan_Value_Modified_Date__c);
        insert testTransaction;
    }

    /*
     * Upon initial insert of charge group and related data, make sure Charges_Added_Since_Start__c = 0 or null
     */
    @isTest
    static void initialCGInsertTest() {
        Test.startTest();

        List<Payment_Plan__c> ppResults = [
                SELECT Id, Charges_Added_Since_Start__c
                FROM Payment_Plan__c
        ];

        Test.stopTest();

        for(Payment_Plan__c pp : ppResults){
            system.debug('Charges added since plan start: ' + pp.Charges_Added_Since_Start__c);
            system.assert(pp.Charges_Added_Since_Start__c == 0.00 || pp.Charges_Added_Since_Start__c == null,
                    'Charges Added Should be 0 or null on initial insert.');
        }
    }

    /*
     * Add a new transaction to the charge group, Charges_Added_Since_Start__c should equal transaction amount
     */
    @isTest
    static void addNewTransactionTest() {
        Test.startTest();

        Charge_Group__c testCG = [SELECT Id, Balance__c from Charge_Group__c LIMIT 1];

        Service__c newService = TestUtility.generateService(testCG, TestUtility.generateRandomCurrency());
        insert newService;

        Transaction__c newServiceTransaction = TestUtility.generateServiceTxn(testCG, newService.Amount__c, newService);
        newServiceTransaction.Post_Date__c = Date.valueOf(newService.Post_Date__c);
        newServiceTransaction.Transaction_Date__c =  Date.valueOf(newServiceTransaction.Post_Date__c);
        insert newServiceTransaction;

        Payment_Plan__c ppResults = [
                SELECT Id, Charges_Added_Since_Start__c
                FROM Payment_Plan__c
                LIMIT 1
        ];

        Test.stopTest();

        system.assertEquals(newServiceTransaction.Amount__c, ppResults.Charges_Added_Since_Start__c,
                'Charges added since plan start should equal the inserted transaction amount.');
    }

    /*
     * Add a new transaction and then modify the payment plan's value modified date
     * Assert that Charges_Added_Since_Start__c equals 0
     */
    @isTest
    static void changePPValueModifiedDateTest() {
        Test.startTest();

        Charge_Group__c testCG = [SELECT Id, Balance__c from Charge_Group__c LIMIT 1];

        Service__c newService = TestUtility.generateService(testCG, TestUtility.generateRandomCurrency());
        insert newService;

        Transaction__c secondTestTransaction = TestUtility.generateServiceTxn(testCG, newService.Amount__c, newService);
        secondTestTransaction.Transaction_Date__c = system.today().addDays(-3);
        insert secondTestTransaction;

        Payment_Plan__c updatedPPResults = [
                SELECT Id, Charges_Added_Since_Start__c, Remaining_Balance__c, Plan_Value_Modified_Date__c
                FROM Payment_Plan__c
                LIMIT 1
        ];

        // Modify PP value modified date and recalculate
        updatedPPResults.Plan_Value_Modified_Date__c = date.today();
        update updatedPPResults;

        Payment_Plan__c finalPPResults = [
                SELECT Id, Charges_Added_Since_Start__c, Remaining_Balance__c, Plan_Value_Modified_Date__c
                FROM Payment_Plan__c
                LIMIT 1
        ];

        Test.stopTest();

        system.assertEquals(0, finalPPResults.Charges_Added_Since_Start__c,
                'Value date was updated, charges added should be 0.');
    }

    /*
     * Insert a payment transaction and
     * Assert that the added charges field isn't updated
     * Charges_Added_Since_Start__c sums only service transactions
     */
    @isTest
    static void insertPaymentTransactionTest() {
        Test.startTest();

        Charge_Group__c testCG = [SELECT Id, Balance__c from Charge_Group__c LIMIT 1];
        Contact guarantor = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Payment__c pmt = TestUtility.generateSironoPayment(guarantor.Id, Decimal.valueOf(Math.random()), TestUtility.generateRandomCurrency());
        insert pmt;

        Transaction__c secondTestTransaction = TestUtility.generatePaymentTxn(testCG, pmt.Amount__c, pmt);
        secondTestTransaction.Transaction_Date__c = Date.valueOf(secondTestTransaction.Post_Date__c);
        insert secondTestTransaction;

        Payment_Plan__c ppResults = [
                SELECT Id, Charges_Added_Since_Start__c
                FROM Payment_Plan__c
                LIMIT 1
        ];

        Test.stopTest();

        system.assertEquals(0, ppResults.Charges_Added_Since_Start__c,
                'Transaction was payment type; charges added should not have been updated.');
    }
}