/*
 * @author Sirono
 * @version 1.0.1
 * @date: 04-19-2016 
 * @ProcessPaymentTest Test Class for the Code Covrege of ProcessPayment Class.
 *
 * 08-19-2016: Sirono - Tracker # 127324171
 * Improve the code coverage3
 */

@isTest
private class ProcessPaymentTest {

    static testMethod void myUnitTest() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        List<SelectOption> expYearOptions = objProcessPayment.expYearOptions;
        List<SelectOption> expMonthOptions = objProcessPayment.expMonthOptions;
        objProcessPayment.submit();

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.doNext();
        objProcessPayment.creditCardNumber = '123';
        objProcessPayment.cardholderName = '123';
        objProcessPayment.expirationYear = '123';
        objProcessPayment.expirationMonth = '123';
        objProcessPayment.cvv = '123';
        objProcessPayment.amount = '123';
        objProcessPayment.address = '123';
        objProcessPayment.city = '123';
        objProcessPayment.state = '123';
        objProcessPayment.zip = '123';
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(6, msgList.size());
    }

    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     */
    static testMethod void myCheckValidationTest() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        objProcessPayment.submit();

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.doNext();
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = '2016';
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.zip = '07';

        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(10, msgList.size());
    }
    
    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     */
    static testMethod void myCheckAmountValidationTest() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        objProcessPayment.submit();

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.zip = 'avcsc';
        objProcessPayment.cvv = '07897';
        objProcessPayment.cardHolderName = 'test';

        objProcessPayment.doNext();
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(6, msgList.size());
    }
    
    /*
     * 09-05-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     */
    static testMethod void myCheckAmountValidationTest4() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.amount = '0';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(3, msgList.size());
    }

    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     */
    static testMethod void myCheckAmountValidationTest1() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        objProcessPayment.fillNameAndAddress();
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '0';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
    }

    static testMethod void myCheckAmountValidationTest3() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '300';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    static testMethod void myCheckAmountValidationTest5() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '0';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    /*
     * 08-19-2016: Sirono - Tracker # 127324171
     * Improve the code coverage
     */
    static testMethod void myCheckAmountValidationTest2() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.guarantorRecordId = '';
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '-1';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
    }

    static testMethod void myCheckAmountValidationTest6() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();

    }

    static testMethod void myCheckAmountValidationTest7() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '77897';
        objProcessPayment.amount = '0';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';
        objProcessPayment.checkCardValidation();
    }

    //Unit Test for the response code.
    static testMethod void CoverResponseCode() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = '{"kind":"Payments Exception","errors":{"non_field_errors":["Amount exceeds selected charge groups"]}}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Amount exceeds selected charge groups')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();

    }


    //Unit Test for the response code.
    static testMethod void CoverResponseCode1() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = '{"kind":"Payments Exception","errors":["Credit card number is invalid.","Merchant account does not support payment instrument."]}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Credit card number is invalid')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();

    }

    //Unit Test for the response code.
    static testMethod void CoverResponseCode2() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = '{"kind":"Payments Exception","errors":{"chargegroups":["Invalid hyperlink - Object does not exist."],"guarantor":["Invalid hyperlink - Object does not exist."]}}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Invalid hyperlink')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();

    }

    //Unit Test for the response code.
    static testMethod void CoverResponseCode3() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;
        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = 'Error';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Error')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();

    }

    //Unit Test for the response code.
    static testMethod void CoverResponseCode4() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 123;
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        ProcessPayment objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));

        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Invoice__c = invoice.id;
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Sub_Status__c = 'Payment Plan';
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert objTransaction;

        objProcessPayment = new ProcessPayment(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper objChargeGroupWrapper : objProcessPayment.chargeGroupList) {
            objChargeGroupWrapper.isSelected = true;
        }
        objProcessPayment.creditCardNumber = '';
        objProcessPayment.expirationYear = String.valueof(System.today().Year() + 1);
        objProcessPayment.expirationMonth = '07';
        objProcessPayment.creditCardNumber = '1234567891113';
        objProcessPayment.cardHolderName = '1234567891113';
        objProcessPayment.zip = '07897';
        objProcessPayment.amount = '10';
        objProcessPayment.cvv = 'test';
        objProcessPayment.state = 'test';
        objProcessPayment.address = 'test';
        objProcessPayment.city = 'test';

        objProcessPayment.doNext();

        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 400;
        TestUtility.Errorbody = '{"kind":"Validation exception","errors":[{"non_field_errors":"Cannot directly change ChargeGroups on an existing plan"}]}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objProcessPayment.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        boolean isError = false;
        for (Apexpages.Message msg : msgList) {
            if (msg.getDetail().contains('Cannot directly change ChargeGroups on an existing plan')) isError = true;
        }
        System.assertEquals(isError, true);

        Test.stopTest();

    }
}