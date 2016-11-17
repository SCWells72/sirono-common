/*
* @author Sirono
* @version 1.0.1
* @Date: 09-01-2016
* @AddDiscount Class for the Add Discount.
*/

@isTest
private class EditPaymentPlanTest {
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage
    */
    static testMethod void myCheckAmountValidationTest() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

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

        objEditPaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError = true;
        }
        System.assertEquals(isError, true);

        objEditPaymentPlan.cancel();
    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage
    */
    static testMethod void myCheckAmountValidationTest1() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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

        objEditPaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Charge Group is a required field.')) isError = true;
        }
        System.assertEquals(isError, true);

        objEditPaymentPlan.cancel();
    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage
    */
    static testMethod void myCheckAmountValidationTest2() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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

        objEditPaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError = true;
        }
        System.assertEquals(isError, true);

        objEditPaymentPlan.cancel();
    }
    
    static testMethod void myCheckAmountValidationTest3() {
        TestUtility objTestUtil = new TestUtility();
        
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;
        
        Charge_Group__c   chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        insert chargeGroup;
        
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;
        
        Sirono_Settings__c PaymentPlanSettings = new Sirono_Settings__c(SetupOwnerId = userinfo.getProfileId());
        PaymentPlanSettings.Max_Number_Plan_Installments__c = 2;
        PaymentPlanSettings.Min_Installment_Amount__c = 101;
        PaymentPlanSettings.Min_Number_Plan_Installments__c = 1;
        insert PaymentPlanSettings;
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList ) {
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
        
        objEditPaymentPlan.getPaymentPlanSettings();
        
        Test.startTest();        
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError  = true;
        }
        System.assertEquals(isError,true);
        
        objEditPaymentPlan.cancel();
    }
    
    static testMethod void myCheckAmountValidationTest4() {
        TestUtility objTestUtil = new TestUtility();
        
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;
        
        Charge_Group__c   chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        insert chargeGroup;
        
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;
        
        Sirono_Settings__c PaymentPlanSettings = new Sirono_Settings__c(SetupOwnerId = userinfo.getProfileId());
        PaymentPlanSettings.Max_Number_Plan_Installments__c = 2;
        PaymentPlanSettings.Min_Installment_Amount__c = 101;
        PaymentPlanSettings.Min_Number_Plan_Installments__c = 1;
        insert PaymentPlanSettings;
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList ) {
            objChargeGroupWrapper.isSelected = true;
        }
        
        objEditPaymentPlan.creditCardNumber = '';
        objEditPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objEditPaymentPlan.expirationMonth = '07';
        objEditPaymentPlan.creditCardNumber= '1234567891113';
        objEditPaymentPlan.cardHolderName= '1234567891113';
        objEditPaymentPlan.zip = '07897';
        objEditPaymentPlan.amount = '101';
        objEditPaymentPlan.payableAmount = '1000';
        objEditPaymentPlan.planType = 'auto';
        objEditPaymentPlan.planValue= '301';
        objEditPaymentPlan.executeOnDay = '10';
        objEditPaymentPlan.cvv= 'test';
        objEditPaymentPlan.state = 'test';
        objEditPaymentPlan.address = 'test';
        objEditPaymentPlan.city = 'test';
        
        objEditPaymentPlan.getPaymentPlanSettings();
        
        Test.startTest();        
        objEditPaymentPlan.doSubmit();
        Test.stopTest();
        
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(3 ,msgList.size());
        
        objEditPaymentPlan.cancel();
    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage
    */
    static testMethod void myPassAllValidations() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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

        objEditPaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError = true;
        }
        System.assertEquals(isError, true);

        objEditPaymentPlan.cancel();
    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage
    */
    static testMethod void myNestedIfCodeCoverage() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Plan_Type__c = 'Manual';
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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

        objEditPaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());

        objEditPaymentPlan.cancel();
    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage for cancel method
    */
    static testMethod void cancel() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        objEditPaymentPlan.cancel();

        boolean isError = false;
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains(guarantorContact.Id)) isError = true;
        }

    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage for cancel method
    */
    static testMethod void cancel1() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;


        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        objEditPaymentPlan.cancel();

        boolean isError = false;
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('home')) isError = true;
        }
        System.assertEquals(isError, false);
    }
    
    /*
    * 08-19-2016: Sirono - Tracker # 127324171
    * Improve the code coverage
    */
    static testMethod void myPassAllValidationsForManual() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Plan_Type__c = 'Manual';
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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

        objEditPaymentPlan.doSubmit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError = true;
        }
        System.assertEquals(isError, true);
    }
    
    
    /*
    * 09-06-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submit() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }
    
    /*
    * 09-06-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForPromisePlan() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isError = true;
        }
        System.assertEquals(isError, true);
        Test.stopTest();
    }
    
    
    /*
    * 09-06-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForPromisePlan1() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isError = true;
        }
        System.assertEquals(isError, true);
        Test.stopTest();
    }
    
    /*
    * 09-06-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForPromisePlan5() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isError = true;
        }
        System.assertEquals(isError, true);
        Test.stopTest();
    }
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForAutomaticPlan() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        System.debug('23121' + paymentPlan);

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('non_field_errors')) isError = true;
        }
        System.assertEquals(isError, false);
        Test.stopTest();
    }
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForAutomaticPlanJSONParsing() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        //objEditPaymentPlan.testResponse();
        //objEditPaymentPlan.parseResponse(objEditPaymentPlan.responseBody);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('non_field_errors')) isError = true;
        }
        System.assertEquals(isError, false);
        Test.stopTest();
    }
    
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForAutomaticPlanJSONParsing1() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        TestUtility.errorBody = '{"kind":"Payments Exception","errors":{"non_field_errors":["Amount exceeds selected charge groups"]}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        //objEditPaymentPlan.testResponse();
        //objEditPaymentPlan.parseResponse(objEditPaymentPlan.responseBody);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount exceeds selected charge groups')) isError = true;
        }
        System.assertEquals(isError, true);
        Test.stopTest();
    }
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForAutomaticPlanJSONParsing2() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        TestUtility.errorBody = '{"kind":"Payments Exception","errors":["Credit card number is invalid.","Merchant account does not support payment instrument."]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        //objEditPaymentPlan.testResponse();
        //objEditPaymentPlan.parseResponse(objEditPaymentPlan.responseBody);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Credit card number is invalid')) isError = true;
        }
        System.assertEquals(isError, true);
        Test.stopTest();
    }
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForAutomaticPlanJSONParsing3() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        TestUtility.errorBody = '{"kind":"Payments Exception","errors":{"chargegroups":["Invalid hyperlink - Object does not exist."],"guarantor":["Invalid hyperlink - Object does not exist."]}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        objEditPaymentPlan.doTesting();
        //objEditPaymentPlan.testResponse();
        //objEditPaymentPlan.parseResponse(objEditPaymentPlan.responseBody);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Invalid hyperlink')) isError = true;
        }
        System.assertEquals(isError, true);
        Test.stopTest();
    }
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void executeonDay() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = null;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        System.assertEquals(objEditPaymentPlan.executeOnDayExisting, '1');
    }
    
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForAutomaticPlanJSONParsing4() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        insert paymentPlan;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        Apexpages.currentPage().getParameters().put('paymentPlanId', paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        objEditPaymentPlan.fillNameAndAddress();

        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;

        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList) {
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
        TestUtility.Errorbody  = '{"kind":"Validation exception","errors":[{"non_field_errors":"Cannot directly change ChargeGroups on an existing plan"}]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        objEditPaymentPlan.doTesting();
        //objEditPaymentPlan.testResponse();
        //objEditPaymentPlan.parseResponse(objEditPaymentPlan.responseBody);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing')) isError  = true;
        }
        System.assertEquals(isError,true);
        Test.stopTest(); 
    }
    
    
    /*
    * 09-13-2016: Viraj
    * Improve the code coverage
    */
    static testMethod void submitForAutomaticPlanJSONParsing5() {
        TestUtility objTestUtil = new TestUtility();
        
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        insert paymentPlan;
        
        Charge_Group__c   chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;
        
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList ) {
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
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Saved Successfully')) isError  = true;
        }
        System.assertEquals(isError,true);
        Test.stopTest(); 
    }
    
    /*
    * 10-24-2016: Viraj
    * Improve the code coverage.
    * Method used to cover code coverage of "non_field_errors" part.
    */
    static testMethod void submitForAutomaticPlanJSONParsing6() {
        TestUtility objTestUtil = new TestUtility();
        
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        
        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Payable_Amount__c = 100;
        paymentPlan.Installment_Amount__c = 10;
        paymentPlan.Number_of_Installments__c = 10;
        paymentPlan.Execute_on_Day__c = 1;
        insert paymentPlan;
        
        Charge_Group__c   chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        chargeGroup.Reported_Selfpay_Balance__c = -100;
        insert chargeGroup;
        
        Transaction__c  objTransaction = TestUtility.generateTransaction(chargeGroup,100,'Automatic');
        insert objTransaction;
        
        Apexpages.currentPage().getParameters().put('paymentPlanId',paymentPlan.Id);
        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        EditPaymentPlan objEditPaymentPlan = new EditPaymentPlan();
        objEditPaymentPlan.fillNameAndAddress();
        
        List<SelectOption> expYearOptions = objEditPaymentPlan.expYearOptions;
        List<SelectOption> expMonthOptions = objEditPaymentPlan.expMonthOptions;      
        
        for (ChargeGroupWrapper objChargeGroupWrapper : objEditPaymentPlan.chargeGroupList ) {
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
        TestUtility.Errorbody  = '{"non_field_errors":["Cannot directly change ChargeGroups on an existing plan"]}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objEditPaymentPlan.doSubmit();
        objEditPaymentPlan.doTesting();
        //objEditPaymentPlan.testResponse();
        //objEditPaymentPlan.parseResponse(objEditPaymentPlan.responseBody);
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing')) isError  = true;
        }
        System.assertEquals(isError,true);
        Test.stopTest(); 
    }
}