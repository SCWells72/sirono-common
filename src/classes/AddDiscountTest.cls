/*
* @author Sirono
* @version 1.0.1
* @Date: 05-16-2016
* @AddDiscount Test Class for the Code Covrege of Add Discount Class.
*/

@isTest
private class AddDiscountTest {

    static testMethod void myUnitTest() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        AddDiscount objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Charge_Group_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert transactionObj;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Charge_Group_ID__c = 124;
        insert chargeGroup;

        objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper cgw :objAddDiscount.chargeGroupList) {
            cgw.isSelected = true;
        }
        objAddDiscount.doNext();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddDiscount.submit();
        msgList = ApexPages.getMessages();
        System.assertEquals(1, msgList.size());
        Test.stopTest();
    }

    static testMethod void submit() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        AddDiscount objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddDiscount.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());
        Test.stopTest();
    }

    static testMethod void exception() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        AddDiscount objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        objAddDiscount.submit();
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(2, msgList.size());


        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Charge_Group_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert transactionObj;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Charge_Group_ID__c = 124;
        insert chargeGroup;

        objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper cgw :objAddDiscount.chargeGroupList) {
            cgw.isSelected = true;
        }
        objAddDiscount.doNext();
        objAddDiscount.submit();
        msgList = ApexPages.getMessages();
        System.assertEquals(4, msgList.size());
    }

    static testMethod void webServiceCallout() {
        TestUtility objTestUtility = new TestUtility();

        Contact guarantorContact = TestUtility.generateguarantorContact();
        insert guarantorContact ;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;

        AddDiscount objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 123);
        chargeGroup.Charge_Group_ID__c = 123;
        insert chargeGroup;

        Transaction__c transactionObj = TestUtility.generateTransaction(chargeGroup, 100, 'Automatic');
        insert transactionObj;

        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 124);
        chargeGroup.Charge_Group_ID__c = 124;
        insert chargeGroup;

        objAddDiscount = new AddDiscount(new ApexPages.StandardController(guarantorContact));
        for (ChargeGroupWrapper cgw :objAddDiscount.chargeGroupList) {
            cgw.isSelected = true;
        }
        objAddDiscount.doNext();
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddDiscount.submit();
        msgList = ApexPages.getMessages();
        System.assertEquals(1, msgList.size());
        Test.stopTest();
    }
}