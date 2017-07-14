/**
 * Unit class for the EditPaymentPlan class.
 **/

@isTest
public class EditPaymentPlanTest {
    
    /**
     * This method tests the logic of Amount Validation.
     **/
    static testMethod void checkValidationForAmount() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234';
        objEditPaymentPlan.cvv = '';
        objEditPaymentPlan.zip = 'asdsads';

        objEditPaymentPlan.cardHolderName = '';

        Test.startTest();
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError = true;
        }
        System.assert(isError, 'Should we got error Amount must be greater than zero.');

        objEditPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Validation. CG is require.
     **/
    static testMethod void checkAmountValidationForChargeGroup() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        INSERT chargeGroup;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }

        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year());
        objEditPaymentPlan.expirationMonth = String.valueof(System.today().Month() - 1) ;
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.amount = '0';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = '11112';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Charge Group is a required field.')) isError = true;
        }
        System.assert(isError, 'Should have failed due to missing CG');

        objEditPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Amount Validation.
     **/
    static testMethod void checkZeroAmountWithChargeGroup() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }

        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.amount = '-1';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError = true;
        }
        System.assert(isError, 'Should we got Amount related Error.');

        objEditPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Amount Validation with CG Balance.
     **/
    static testMethod void checkAmountWithBalanceValue() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;
        
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        INSERT chargeGroup;
        
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList ) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber= '1234567891113';
        objEditPaymentPlan.cardHolderName= '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.amount = '20';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue= '301';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv= 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';
        
        Test.startTest();        
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError  = true;
        }
        System.assert(isError, 'Should have failed due to amount exceed balance');
        
        objEditPaymentPlan.cancel();
    }
    
    /**
     * Validate NumberOfInstallments based on Monthly Amount.
     **/
    @IsTest
    static void testNumberOfInstallmentsExceeded() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;
        
        Charge_Group__c   chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        INSERT chargeGroup;

        Service__c svc = TestUtility.generateService(chargeGroup, 24*250);
        INSERT svc;

        Transaction__c  objTransaction = TestUtility.generateServiceTxn(chargeGroup, svc.Amount__c, svc);
        INSERT objTransaction;

        chargeGroup = [SELECT Id, Balance__c FROM Charge_Group__c WHERE Id = :chargeGroup.Id];
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber= '1234567891113';
        objEditPaymentPlan.cardHolderName= '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.payableAmount = String.valueOf(SironoSettingsUtil.getPaymentPlanSettings().Max_Number_Plan_Installments__c * 250);
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue= '301';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv= 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';
        
        Test.startTest();
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('This monthly amount would exceed')) {
                isError  = true;
            }
        }
        System.assert(isError, 'Should have failed due to monthly amount exceed');
        
        objEditPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Amount Validation.
     **/
    static testMethod void checkAmountValidation() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }

        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '10';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError = true;
        }
        System.assert(isError, 'Should have failed due to amount is greater than balance value.');

        objEditPaymentPlan.cancel();
    }
    
    /**
     * This method tests the logic of Page Reference.
     * Redirect to Contact Page.
     **/
    static testMethod void checkPageReferenceWithContact() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        
        Test.startTest();
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        Pagereference pr = objEditPaymentPlan.cancel();
        Test.stopTest();        
        
        // Check system assert, It is redirect into Contact or not?        
        System.assert(String.valueOf(pr).contains(guarantorContact.Id), 'Should have failed to redirect into contact page.');
    }
    
    /**
     * This method tests the logic of Page Reference.
     * Redirect to Home Page.
     **/
    static testMethod void checkPageReferenceHome() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        Test.startTest();
        Pagereference pr = objEditPaymentPlan.cancel();
        Test.stopTest();
        
        // Check system assert, It is redirect into Home or not?        
        System.assert(String.valueOf(pr).contains('home'), 'Should have failed to redirect into home page.');
    }
    
    /**
     * This method tests the logic of Amount Validation for Manual Payment Plan.
     **/
    static testMethod void checkValidationsByManualSubmit() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Plan_Type__c = 'Manual';
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }

        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError = true;
        }
        System.assert(isError, 'Should be amount exceed the balance.');
    }
    
    /**
     * This method tests the logic of Submit method with Amount Exceed error.
     **/
    static testMethod void submitWithAmountExceed() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }

        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError = true;
        }
        System.assert(isError, 'May be amount exceed the balance.');
    }

    /**
     * This method tests the logic of Submit method with Promise Plan Type. 
     **/
    public static testMethod void submitForPromisePlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }

        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'promise';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isSuccess = true;
        }
        System.assert(isSuccess, 'Payment plan saved successfully with promise plan type.');
    }    
    
    /**
     * This method tests the logic of Submit Method.
     **/
    static testMethod void submitWithPromisePlanType() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        INSERT paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'promise';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isSuccess = true;
        }
        System.assert(isSuccess, 'Payment plan saved successfully.');
    }
    
    /**
     * This method tests the logic of Submit Method.
     **/
    static testMethod void submitForPromisePlanSuccess() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        INSERT paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'promise';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isSuccess = true;
        }
        System.assert(isSuccess, 'Payment plan saved successfully.');
    }
    
    /**
     * This method tests the logic of Submit method else Part.
     **/
    static testMethod void submitElse() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        INSERT paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('PROCESS PAYMENT EXCEPTION')) isError = true;
        }
        System.assert(isError, 'Should have failed due to Process Payment Exception');
    }
    
    /**
     * This method tests the logic of submit payment plan record with "Auto" Plan Type.
     * We got Process payment exception due to Insufficient data.
     **/
    static testMethod void submitForAutomaticPlanJSONParsing() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('PROCESS PAYMENT EXCEPTION')) isError = true;
        }
        System.assert(isError, 'Should have failed to save payment plan due to Process Payment Exception');
    }
    
    
    /**
     * This method tests the logic of Amount Validation with "Auto" plan type.
     **/
    static testMethod void submitForAutomaticPlanJSONParsingWithAmountError() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        TestUtility.errorBody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_EXISTING_PLAN);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();        
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Amount exceeds selected charge groups')) isError = true;
        }
        System.assert(isError, 'Should have failed due to Amount exceeds for selected CGs.');
    }
    
    /**
     * This method tests the logic of card validation.
     **/
    static testMethod void submitForAutoPlanJSONParsingPaymentException() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.errorBody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_LIST);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Credit card number is invalid')) isError = true;
        }
        System.assert(isError, 'Should have failed due to invalid Credit card number.');
    }
    
    /**
     * This method tests the logic/code coverage of exceptions. 
     **/
    static testMethod void submitForAutoPlanJSONParsingInvalidHyperlink() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.errorBody = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.PAYMENT_CHARGEGROUPS);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        objEditPaymentPlan.doTesting();       
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Invalid hyperlink')) isError = true;
        }
        System.assert(isError, 'Should have failed due to invalid hyperlink.');
    }
    
    /**
     * This method tests the logic of Payment Plan Execute on Day.
     **/
    static testMethod void checkExecuteonDayPopulated() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Test.startTest();
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        INSERT paymentPlan;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        Test.stopTest();
        
        // Check system assert.
        System.assertEquals(objEditPaymentPlan.executeOnDayExisting, '1', 'Should have failed due to execute On Day Existing.');
    }    
    
    /**
     * This method tests the logic of Update CG in Existing Payment Plan.
     **/
    static testMethod void submitForAutoPlanJSONParsingUpdateCGOnExistingPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        INSERT paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        INSERT objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        objEditPaymentPlan.fillNameAndAddress();

        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber = '1234567891113';
        objEditPaymentPlan.cardHolderName = '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue = '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv = 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';
        
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.Errorbody  = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.VALIDATION_EXISTING_PLAN);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        objEditPaymentPlan.doTesting();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing')) isError  = true;
        }
        System.assert(isError, 'Should have failed due to directly change CG on an existing PP.'); 
    }
    
    /**
     * This method tests the logic of Submit method.
     **/
    static testMethod void submitForAutoPlanJSONParsingSuccess() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        INSERT paymentPlan;
        
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;
        
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        INSERT objTransaction;
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList ) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber= '1234567891113';
        objEditPaymentPlan.cardHolderName= '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'promise';
        objEditPaymentPlan.planValue= '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv= 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';
        
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.responsebody =  PaymentPlanJSONParsing.testResponse1();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for(Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isSuccess  = true;
        }
        System.assert(isSuccess, 'PP Saved Successfully.');
    }
    
    /**
     * This method tests the logic/code coverage of Exceptions.
     **/
    static testMethod void submitForAutoPlanJSONParsingNonFieldErrors() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Original_Installment_Count__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        INSERT paymentPlan;
        
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        INSERT chargeGroup;
        
        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        INSERT objTransaction;
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        objEditPaymentPlan.fillNameAndAddress();
        
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper: objEditPaymentPlan.chargeGroupList ) {
            objChargeGroupWrapper.isSelected = true;
        }
        objEditPaymentPlan.paymentPlanType = '2';
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber= '1234567891113';
        objEditPaymentPlan.cardHolderName= '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.promiseAmount = '100';
        objEditPaymentPlan.amount = '100';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue= '0';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv= 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';
        
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.Errorbody  = TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.VALIDATION_EXISTING_PLAN);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        objEditPaymentPlan.doTesting();
        Test.stopTest();
        
        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing')) isError  = true;
        }
        System.assert(isError, 'Should have failed due to change CG.');
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<PaymentPlanSecurityContext> allContexts = new List<PaymentPlanSecurityContext>{PaymentPlanSecurityContext.UPSERT_CONTEXT,
        	PaymentPlanSecurityContext.UPDATE_CONTEXT, PaymentPlanSecurityContext.DP_UPDATE_CONTEXT, 
                PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentPlanSecurityContext context: allContexts) {
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