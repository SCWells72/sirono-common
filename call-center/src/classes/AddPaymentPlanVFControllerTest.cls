/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * AddPaymentPlanVFControllerTest Class for the AddPaymentPlanVFController.
 **/
@IsTest
public class AddPaymentPlanVFControllerTest {

    /**
     * This method tests the logic of constructor, init, doCancel, doNothing, doNext and getPaymentPlanSettings methods.
     * If guarantor already has an active payment plan than it will not allow to create another payment plan.
     **/
    @IsTest
    static void testActivePaymentPlan() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        insert paymentPlan;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        // Create instance of AddPaymentPlanVFController class.
        //noinspection ApexUnusedDeclaration
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();
        Test.stopTest();

        // Check system assert, We got 'This guarantor have already active Payment Plan.' error.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains(Label.Payment_Plan_Error)) {
                isError = true;
            }
        }
        System.assert(isError, 'Expected ' + Label.Payment_Plan_Error + ' error message but got different');
    }

    /**
     * This method tests the logic of fillNameAndAddress method.
     **/
    @IsTest
    static void testFillNameAddress() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();

        // Check system assert, cardHolderName become null before call fillNameAndAddress method.
        System.assert(addPaymentPlanVFController.cardHolderName == null, 'Expected card holder name is null');

        // Call fillNameAndAddress method.
        addPaymentPlanVFController.fillNameAndAddress();
        Test.stopTest();

        Contact gc = GuarantorDao.getGuarantor(guarantorContact.Id);
        // Check system assert, cardHolderName set as contact's name.
        System.assertEquals(gc.Name, addPaymentPlanVFController.cardHolderName, 'Expected card holder name ' + gc.Name + ' but got ' + addPaymentPlanVFController.cardHolderName);
    }

    /**
     * This method tests the logic of page reference when doCancel method call for home page.
     **/
    @IsTest
    static void testdoCancelForHomePage() {

        Test.startTest();
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();

        PageReference pg = addPaymentPlanVFController.doCancel();
        Test.stopTest();

        // Check system assert, We got page reference as a Home page.
        System.assert(pg != null, 'Expected page reference "/home/home.jsp" but got null');
    }

    /**
     * This method tests the logic of page reference when doCancel method call for guarantor.
     **/
    @IsTest
    static void testdoCancelForGuarantorPage() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();

        PageReference pg = addPaymentPlanVFController.doCancel();
        Test.stopTest();

        // Check system assert, We got page reference as a Home page.
        System.assert(pg != null, 'Expected page reference "/' + guarantorContact.Id + '" but got ' + pg);
    }

    /**
     * This method tests the logic of doSubmit method with all necessary parameters.
     **/
    @IsTest
    public static void testCreatePaymentPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Guarantor_Id__c = 23232323;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Sirono_Id__c = 1321212;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();
        for (ChargeGroupWrapper chargeGroupWrapper : addPaymentPlanVFController.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        addPaymentPlanVFController.expirationYear = String.valueOf(System.today().year() + 1);
        addPaymentPlanVFController.expirationMonth = '07';
        addPaymentPlanVFController.creditCardNumber = '378282246310005';
        addPaymentPlanVFController.cardHolderName = 'Test';
        addPaymentPlanVFController.zip = '07897';
        addPaymentPlanVFController.amount = '100';
        addPaymentPlanVFController.planType = 'auto';
        addPaymentPlanVFController.planValue = '100';
        addPaymentPlanVFController.executeOnDay = '10';
        addPaymentPlanVFController.cvv = '1234';
        addPaymentPlanVFController.state = 'test';
        addPaymentPlanVFController.address = 'test';
        addPaymentPlanVFController.city = 'test';
        addPaymentPlanVFController.doNext();
        addPaymentPlanVFController.getPaymentPlanSettings();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        addPaymentPlanVFController.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY)) {
                isSuccess = true;
            }
        }
        System.assert(isSuccess, 'Expected Payment Plan record created but it\'s not created.');
    }

    /**
     * This method tests the logic of doSubmit method's error.
     **/
    @IsTest
    static void testFailPaymentPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();
        for (ChargeGroupWrapper chargeGroupWrapper : objAddPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        objAddPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
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
        objAddPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> messages = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message message : messages) {
            if (message.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO)) {
                isError = true;
            }
        }
        System.assert(isError, 'Expected ' + Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO + ' error message');
    }

    /**
     * This method tests the logic of Charge Group List.
     **/
    @IsTest
    static void testChargeGroupList() {
        // Create contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
        // Create charge group record with account sub status equals to overdue.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to Paid.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 13);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAID;
        chargeGroups.add(chargeGroup);

        insert chargeGroups;

        // Create transaction records to populate balance in CG.
        List<Transaction__c> transactions = new List<Transaction__c>();
        transactions.add(TestUtility.generateTransaction(chargeGroups[0], 10, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[1], 20, Constants.AUTOMATIC));
        insert transactions;

        Test.startTest();
        // Create AddPaymentPlanVFController class object.
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();
        List<ChargeGroupWrapper> chargeGroupWrappers = addPaymentPlanVFController.chargeGroupList;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, chargeGroupWrappers.size(), 'Expected Charge Groups size equals to 1 but we got ' + chargeGroupWrappers.size());
        System.assertEquals(Constants.ACCT_SUBSTATUS_OVERDUE, chargeGroupWrappers[0].cg.Account_Sub_Status__c,
            'Expected Charge Groups sub status equals to Overdue but we got ' + chargeGroupWrappers[0].cg.Account_Sub_Status__c);
    }

    /**
     * This method tests the logic of build Charge Group List negative.
     **/
    @IsTest
    static void testChargeGroupListNegative() {
        // Create contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
        // Create charge group record with account sub status equals to Credit.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 13);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_CREDIT;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to Pre-Invoiced.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PREINVOICED;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to Bad Debt.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        chargeGroups.add(chargeGroup);

        insert chargeGroups;

        // Create transaction records to populate balance in CG.
        List<Transaction__c> transactions = new List<Transaction__c>();
        transactions.add(TestUtility.generateTransaction(chargeGroups[0], 100, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[1], 500, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[2], 200, Constants.AUTOMATIC));
        insert transactions;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();
        List<ChargeGroupWrapper> chargeGroupWrappers = addPaymentPlanVFController.chargeGroupList;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, chargeGroupWrappers.size(), 'Should be Charge Group list size is 0 but we got ' + chargeGroupWrappers.size());
    }

    /**
     * This method tests the logic of Charge Group List with multiple CGs.
     **/
    @IsTest
    static void testChargeGroupListWithMultiple() {
        Set<String> accountSubStatuses = new Set<String> {
            Constants.ACCT_SUBSTATUS_DELINQUENT,
            Constants.ACCT_SUBSTATUS_OVERDUE,
            Constants.ACCT_SUBSTATUS_DUE_BY
        };

        // Create contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
        // Create charge group record with account sub status equals to Delinquent.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 13);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to overdue.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to Due By.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1123);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to Pre-Invoiced.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 131);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PREINVOICED;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to Credit.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 153);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_CREDIT;
        chargeGroups.add(chargeGroup);

        // Create charge group record with account sub status equals to Paid.
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 15345);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAID;
        chargeGroups.add(chargeGroup);

        insert chargeGroups;

        // Create transaction records to populate balance in CG.
        List<Transaction__c> transactions = new List<Transaction__c>();
        transactions.add(TestUtility.generateTransaction(chargeGroups[0], 100, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[1], 500, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[2], 200, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[3], 10, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[4], 250, Constants.AUTOMATIC));
        transactions.add(TestUtility.generateTransaction(chargeGroups[5], 300, Constants.AUTOMATIC));
        insert transactions;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController addPaymentPlanVFController = new AddPaymentPlanVFController();
        List<ChargeGroupWrapper> chargeGroupWrappers = addPaymentPlanVFController.chargeGroupList;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(3, chargeGroupWrappers.size(), 'Expected Charge Groups size equals to 1 but we got ' + chargeGroupWrappers.size());
        for (ChargeGroupWrapper chargeGroupWrapper : chargeGroupWrappers) {
            System.assert(accountSubStatuses.contains(chargeGroupWrapper.cg.Account_Sub_Status__c),
                'We got different Charge Group that sub status not exist in set ' + chargeGroupWrapper.cg.Account_Sub_Status__c);
        }
    }
}