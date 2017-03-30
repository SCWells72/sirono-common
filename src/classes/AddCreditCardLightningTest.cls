@isTest
private class AddCreditCardLightningTest {

    static testMethod void myUnitTestWithoutId() {
        TestUtility objTestUtil = new TestUtility();
        Map<String, Id> rtMap = new Map<String, Id>();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        objAddCreditCard.doNothing();


        List<SelectOption> paymentPlanType = objAddCreditCard.paymentPlanTypeOptions;
        List<SelectOption> expYearOptions = objAddCreditCard.expYearOptions;
        List<SelectOption> expMonthOptions = objAddCreditCard.expMonthOptions;

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        System.assertEquals(msgList.Size(), 0);
    }

    static testMethod void myCheckValidationZipTest() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = '2016';
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.cvv = '';
        objAddCreditCard.zip = '';
        objAddCreditCard.CreatePaymentPlan();
        objAddCreditCard.doTesting();
        objAddCreditCard.fillNameAndAddress();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Zip Code is a required field.')) isError = true;
        }
        System.assertEquals(isError, true);
    }

    static testMethod void myCheckAmountValidationTest() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        insert objCG;

        Transaction__c  transactionObj = TestUtility.generateTransaction(objCG,100,'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Sirono_Settings__c PaymentPlanSettings = new Sirono_Settings__c(SetupOwnerId = userinfo.getProfileId());
        PaymentPlanSettings.Max_Number_Plan_Installments__c = 1;
        PaymentPlanSettings.Min_Installment_Amount__c = 100;
        PaymentPlanSettings.Min_Number_Plan_Installments__c = 1;
        insert PaymentPlanSettings;

        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber= '1234567891113';
        objAddCreditCard.cardHolderName= '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '20';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue= '301';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv= 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();
        objAddCreditCard.getPaymentPlanSettings();
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully')) isError  = true;
        }
        System.assertEquals(isError,false);
    }

    static testMethod void myCheckAmountValidationTest1() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c   objCG = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        insert objCG;

        Transaction__c  transactionObj = TestUtility.generateTransaction(objCG,100,'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Sirono_Settings__c PaymentPlanSettings = new Sirono_Settings__c(SetupOwnerId = userinfo.getProfileId());
        PaymentPlanSettings.Max_Number_Plan_Installments__c = 2;
        PaymentPlanSettings.Min_Installment_Amount__c = 30;
        PaymentPlanSettings.Min_Number_Plan_Installments__c = 1;
        insert PaymentPlanSettings;

        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber= '1234567891113';
        objAddCreditCard.cardHolderName= '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '30';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue= '301';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv= 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();
        objAddCreditCard.getPaymentPlanSettings();
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully')) isError  = true;
        }
        System.assertEquals(isError,false);
    }

    static testMethod void myCheckAmountValidationTest2() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Sirono_ID__c = 2876;
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '-1';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '0';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.CreatePaymentPlan();
        TestUtility.planType = 'promise';
        objAddCreditCard.doTesting();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount must be greater than zero.')) isError = true;
        }
        System.assertEquals(isError, true);
    }

    //Validation Fires.
    static testMethod void myCheckAmountValidationTest3() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.promiseAmount = '0';
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '1';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '0';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();
        objAddCreditCard.CreatePaymentPlan();
        objAddCreditCard.doTesting();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount cannot exceed balance.')) isError = true;
        }
        System.assertEquals(isError, true);

    }

    //No Validation Fire.
    static testMethod void myPassAllValidation() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.planType = 'promise';
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();


        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();
    }

    //Execute the response block for the Promise Type
    static testMethod void myPassAllValidationpromiseType() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        //objCG.Balance__c = 100;
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'promise';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.promiseAmount = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Created Successfully')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();

    }

    //Execute the response block for the Else part
    static testMethod void myPassAllValidationElse() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        //objCG.Balance__c = 100;
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = 'avvbsds';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = '232323';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = '';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();
        objAddCreditCard.CreatePaymentPlan();
        objAddCreditCard.doTesting();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Zip code must be 5 digits.')) isError = true;
        }
        System.assertEquals(isError, true);

    }

    static testMethod void myPassAllValidationFail() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();
        TestUtility.Errorbody = 'Error';

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Error')) isError = true;
        }
        System.assertEquals(isError, false);

        Test.stopTest();
    }

    static testMethod void myPassAllValidationFail1() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        TestUtility.Errorbody = '{"kind":"Payments Exception","errors":{"non_field_errors":["Amount exceeds selected charge groups"]}}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount exceeds selected charge groups')) isError = true;
        }
        System.assertEquals(isError, true);


        Test.stopTest();
    }

    static testMethod void myPassAllValidationFail2() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = '{"kind":"Payments Exception","errors":["Credit card number is invalid.","Merchant account does not support payment instrument."]}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Credit card number is invalid')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();
    }

    static testMethod void myPassAllValidationFail3() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = '{"kind":"Payments Exception","errors":{"chargegroups":["Invalid hyperlink - Object does not exist."],"guarantor":["Invalid hyperlink - Object does not exist."]}}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Invalid hyperlink')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();
    }

    static testMethod void myPassAllValidationFail4() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        insert objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber = '1234567891113';
        objAddCreditCard.cardHolderName = '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue = '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv = 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = '{"kind":"Validation exception","errors":[{"non_field_errors":"Cannot directly change ChargeGroups on an existing plan"}]}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing plan')) isError = true;
        }
        System.assertEquals(isError,true);

        Test.stopTest();
    }

    //Method used to cover code coverage of "non_field_errors" part.
    static testMethod void myPassAllValidationFail5() {
        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c   objCG = TestUtility.generateChargeGroup(guarantorContact.Id,null,121114);
        insert objCG;

        Transaction__c  transactionObj = TestUtility.generateTransaction(objCG,100,'Automatic');
        insert transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        Apexpages.currentPage().getParameters().put('guarantorId',guarantorContact.Id);
        AddCreditCardLightning objAddCreditCard = new AddCreditCardLightning();
        for (ChargeGroupWrapper cg : objAddCreditCard.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddCreditCard.creditCardNumber = '';
        objAddCreditCard.expirationYear = String.valueof(System.today().Year() + 1);
        objAddCreditCard.expirationMonth = '07';
        objAddCreditCard.creditCardNumber= '1234567891113';
        objAddCreditCard.cardHolderName= '1234567891113';
        objAddCreditCard.zip = '07897';
        objAddCreditCard.amount = '100';
        objAddCreditCard.planType = 'auto';
        objAddCreditCard.planValue= '100';
        objAddCreditCard.executeOnDay = '10';
        objAddCreditCard.cvv= 'test';
        objAddCreditCard.state = 'test';
        objAddCreditCard.address = 'test';
        objAddCreditCard.city = 'test';
        objAddCreditCard.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody  = '{"non_field_errors":["Cannot directly change ChargeGroups on an existing plan"]}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddCreditCard.CreatePaymentPlan();

        List<ApexPages.Message> msgList = objAddCreditCard.SironoLightningPageMessagesList;
        boolean isError = false;
        system.debug('msgList : ' + msgList);
        for(Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing plan')) isError  = true;
        }
        System.assertEquals(isError,true);

        Test.stopTest();
    }
}