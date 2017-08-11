/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Unit class for the EditPaymentPlan class.
 **/
@IsTest
public class EditPaymentPlanTest {

    @IsTest
    private static void testExpYearOptions() {
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        System.assertEquals(UIUtils.expYearOptions, editPaymentPlan.expYearOptions);
    }

    @IsTest
    private static void testExpMonthOptions() {
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        System.assertEquals(UIUtils.expMonthOptions, editPaymentPlan.expMonthOptions);
    }

    /**
     * This method tests the logic of Amount Validation.
     **/
    static testMethod void checkValidationForAmount() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234';
        editPaymentPlan.cvv = '';
        editPaymentPlan.zip = 'asdsads';

        editPaymentPlan.cardHolderName = '';

        Test.startTest();
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should we got error Amount must be greater than zero.');

        editPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Validation. CG is require.
     **/
    static testMethod void checkAmountValidationForChargeGroup() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year());
        editPaymentPlan.expirationMonth = String.valueOf(System.today().month() - 1) ;
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.amount = '0';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = '11112';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Charge Group is a required field.')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to missing CG');

        editPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Amount Validation.
     **/
    static testMethod void checkZeroAmountWithChargeGroup() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.amount = '-1';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should we got Amount related Error.');

        editPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Amount Validation with CG Balance.
     **/
    static testMethod void checkAmountWithBalanceValue() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.amount = '20';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '301';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to amount exceed balance');

        editPaymentPlan.cancel();
    }
    
    /**
     * Validate NumberOfInstallments based on Monthly Amount.
     **/
    @IsTest
    static void testNumberOfInstallmentsExceeded() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;

        Service2__c svc = TestUtility.generateService(guarantorContact, 24 * 250);
        insert svc;

        Transaction__c txn = TestUtility.generateServiceTxn(chargeGroup, svc.Amount__c, svc);
        insert txn;

        chargeGroup = [SELECT Id, Balance__c FROM Charge_Group__c WHERE Id = :chargeGroup.Id];

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.amount = '100';
        editPaymentPlan.payableAmount = String.valueOf(SironoSettingsUtil.getPaymentPlanSettings().Max_Number_Plan_Installments__c * 250);
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '301';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('This monthly amount would exceed')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to monthly amount exceed');

        editPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Amount Validation.
     **/
    static testMethod void checkAmountValidation() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '10';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to amount is greater than balance value.');

        editPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Page Reference.
     * Redirect to Contact Page.
     **/
    static testMethod void checkPageReferenceWithContact() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);

        Test.startTest();
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        PageReference pageReference = editPaymentPlan.cancel();
        Test.stopTest();

        // Check system assert, It is redirect into Contact or not?        
        System.assert(String.valueOf(pageReference).contains(guarantorContact.Id), 'Should have failed to redirect into contact page.');
    }
    
    /**
     * This method tests the logic of Page Reference.
     * Redirect to Home Page.
     **/
    static testMethod void checkPageReferenceHome() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        Test.startTest();
        PageReference pageReference = editPaymentPlan.cancel();
        Test.stopTest();

        // Check system assert, It is redirect into Home or not?        
        System.assert(String.valueOf(pageReference).contains('home'), 'Should have failed to redirect into home page.');
    }
    
    /**
     * This method tests the logic of Amount Validation for Manual Payment Plan.
     **/
    static testMethod void checkValidationsByManualSubmit() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Plan_Type__c = 'Manual';
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should be amount exceed the balance.');
    }
    
    /**
     * This method tests the logic of Submit method with Amount Exceed error.
     **/
    static testMethod void submitWithAmountExceed() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) {
                isError = true;
            }
        }
        System.assert(isError, 'May be amount exceed the balance.');
    }

    /**
     * This method tests the logic of Submit method with Promise Plan Type. 
     **/
    public static testMethod void submitForPromisePlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'promise';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) {
                isSuccess = true;
            }
        }
        System.assert(isSuccess, 'Payment plan saved successfully with promise plan type.');
    }    
    
    /**
     * This method tests the logic of Submit Method.
     **/
    static testMethod void submitWithPromisePlanType() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'promise';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) {
                isSuccess = true;
            }
        }
        System.assert(isSuccess, 'Payment plan saved successfully.');
    }
    
    /**
     * This method tests the logic of Submit Method.
     **/
    static testMethod void submitForPromisePlanSuccess() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'promise';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) {
                isSuccess = true;
            }
        }
        System.assert(isSuccess, 'Payment plan saved successfully.');
    }
    
    /**
     * This method tests the logic of Submit method else Part.
     **/
    static testMethod void submitElse() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('PROCESS PAYMENT EXCEPTION')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to Process Payment Exception');
    }
    
    /**
     * This method tests the logic of submit payment plan record with "Auto" Plan Type.
     * We got Process payment exception due to Insufficient data.
     **/
    static testMethod void submitForAutomaticPlanJSONParsing() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('PROCESS PAYMENT EXCEPTION')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed to save payment plan due to Process Payment Exception');
    }
    
    
    /**
     * This method tests the logic of Amount Validation with "Auto" plan type.
     **/
    static testMethod void submitForAutomaticPlanJSONParsingWithAmountError() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        TestUtility.errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_EXISTING_PLAN);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount exceeds selected charge groups')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to Amount exceeds for selected CGs.');
    }
    
    /**
     * This method tests the logic of card validation.
     **/
    static testMethod void submitForAutoPlanJSONParsingPaymentException() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_LIST);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Credit card number is invalid')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to invalid Credit card number.');
    }
    
    /**
     * This method tests the logic/code coverage of exceptions. 
     **/
    static testMethod void submitForAutoPlanJSONParsingInvalidHyperlink() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_CHARGEGROUPS);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        editPaymentPlan.doTesting();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Invalid hyperlink')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to invalid hyperlink.');
    }
    
    /**
     * This method tests the logic of Payment Plan Execute on Day.
     **/
    static testMethod void checkExecuteonDayPopulated() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Test.startTest();
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        Test.stopTest();

        // Check system assert.
        System.assertEquals(editPaymentPlan.executeOnDayExisting, '1', 'Should have failed due to execute On Day Existing.');
    }    
    
    /**
     * This method tests the logic of Update CG in Existing Payment Plan.
     **/
    static testMethod void submitForAutoPlanJSONParsingUpdateCGOnExistingPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        editPaymentPlan.fillNameAndAddress();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.VALIDATION_EXISTING_PLAN);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        editPaymentPlan.doTesting();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to directly change CG on an existing PP.');
    }
    
    /**
     * This method tests the logic of Submit method.
     **/
    static testMethod void submitForAutoPlanJSONParsingSuccess() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }

        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'promise';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse1();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) {
                isSuccess = true;
            }
        }
        System.assert(isSuccess, 'PP Saved Successfully.');
    }
    
    /**
     * This method tests the logic/code coverage of Exceptions.
     **/
    static testMethod void submitForAutoPlanJSONParsingNonFieldErrors() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c txn = TestUtility.generateTransaction(chargeGroup, 100, Constants.AUTOMATIC);
        insert txn;

        ApexPages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan editPaymentPlan = new EditPaymentPlan();
        editPaymentPlan.fillNameAndAddress();

        for (ChargeGroupWrapper chargeGroupWrapper : editPaymentPlan.chargeGroupList) {
            chargeGroupWrapper.isSelected = true;
        }
        editPaymentPlan.paymentPlanType = '2';
        editPaymentPlan.creditCardNumber = '';
        editPaymentPlan.expirationYear = String.valueOf(System.today().year() + 1);
        editPaymentPlan.expirationMonth = '07';
        editPaymentPlan.creditCardNumber = '1234567891113';
        editPaymentPlan.cardHolderName = '1234567891113';
        editPaymentPlan.zip = '07897';
        editPaymentPlan.promiseAmount = '100';
        editPaymentPlan.amount = '100';
        editPaymentPlan.planType = 'auto';
        editPaymentPlan.planValue = '0';
        editPaymentPlan.executeOnDay = '10';
        editPaymentPlan.cvv = 'test';
        editPaymentPlan.state = 'test';
        editPaymentPlan.address = 'test';
        editPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.errorbody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.VALIDATION_EXISTING_PLAN);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        editPaymentPlan.doSubmit();
        editPaymentPlan.doTesting();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing')) {
                isError = true;
            }
        }
        System.assert(isError, 'Should have failed due to change CG.');
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @IsTest
    static void checkAccessRights() {
        List<PaymentPlanSecurityContext> allContexts = new List<PaymentPlanSecurityContext> {
            PaymentPlanSecurityContext.UPSERT_CONTEXT,
            PaymentPlanSecurityContext.UPDATE_CONTEXT,
            PaymentPlanSecurityContext.DP_UPDATE_CONTEXT,
            PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentPlanSecurityContext context : allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}