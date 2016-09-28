/*
* @author Sirono
* @version 1.0.1
* @Date: 05-12-2016
* @ Unit class  for the CreateAdjustment class.     
* Do the code coverage for the CreateAdjustment class with TestUtil method.
*/

@isTest
private class CreateAdjustmentTest {

//    static testMethod void myUnitTest() {
//        TestUtility objUtility = new TestUtility();
//
//        Contact guarantorContact = TestUtility.generateGuarantorContact();
//        insert guarantorContact;
//
//        Contact patientContact = TestUtility.generatePatientContact();
//        insert patientContact;
//
//        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
//        paymentPlan.active__c = true;
//        paymentPlan.Delinquent__c = true;
//        insert paymentPlan;
//
//        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
//        objCreateAdjustment.submit();
//
//        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
//        insert invoice;
//
//        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
//        chargeGroup.Invoice__c = invoice.id;
//        chargeGroup.Payment_Plan__c = paymentPlan.Id;
//        chargeGroup.Charge_Group_External_ID__c = true;
//        insert chargeGroup;
//
//        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
//        chargeGroup.Invoice__c = invoice.id;
//        chargeGroup.Payment_Plan__c = paymentPlan.Id;
//        chargeGroup.Charge_Group_ID__c = 124;
//        chargeGroup.Charge_Group_External_ID__c = true;
//        insert chargeGroup;
//
//        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
//        for (ChargeGroupWrapper objChargeGroupWrapper : objCreateAdjustment.chrageGroupList) {
//            objChargeGroupWrapper.isSelected = true;
//        }
//        objCreateAdjustment.doNext();
//        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
//        objCreateAdjustment.submit();
//
//        List<ApexPages.Message> msgList = ApexPages.getMessages();
//        System.assertEquals(2, msgList.size());
//    }
//
//    //Coverage the code for the Endpoint Request method.
//    static testMethod void callEndpointRequestMethod() {
//        TestUtility objUtility = new TestUtility();
//
//        Contact guarantorContact = TestUtility.generateGuarantorContact();
//        insert guarantorContact;
//
//        Contact patientContact = TestUtility.generatePatientContact();
//        insert patientContact;
//
//        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.id);
//        paymentPlan.active__c = true;
//        paymentPlan.Delinquent__c = true;
//        insert paymentPlan;
//
//        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
//
//        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
//        insert invoice;
//
//        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
//        chargeGroup.Invoice__c = invoice.id;
//        chargeGroup.Payment_Plan__c = paymentPlan.Id;
//        chargeGroup.Charge_Group_External_ID__c = true;
//        insert chargeGroup;
//
//        chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
//        chargeGroup.Invoice__c = invoice.id;
//        chargeGroup.Payment_Plan__c = paymentPlan.Id;
//        chargeGroup.Charge_Group_ID__c = 124;
//        chargeGroup.Charge_Group_External_ID__c = true;
//        insert chargeGroup;
//
//        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
//        for (ChargeGroupWrapper objChargeGroupWrapper : objCreateAdjustment.chrageGroupList) {
//            objChargeGroupWrapper.isSelected = true;
//            objCreateAdjustment.chargegroupId = objChargeGroupWrapper.cg.ID;
//        }
//        objCreateAdjustment.amount = '10';
//        objCreateAdjustment.adjustmentTypeSelected = 'Auto';
//        objCreateAdjustment.doNext();
//        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
//        objCreateAdjustment.submit();
//        List<ApexPages.Message> msgList = ApexPages.getMessages();
//        System.assertEquals(2, msgList.size());
//    }
//
//    //Coverage the code for the Endpoint Request method.
//    static testMethod void submit() {
//        TestUtility objTestUtility = new TestUtility();
//
//        Contact g = TestUtility.generateguarantorContact();
//        insert g;
//
//        Contact p = TestUtility.generatePatientContact();
//        insert p;
//
//        test__c t = TestUtility.generatePaymentPlan(g.Id);
//        t.Active__c = true;
//        insert t;
//
//        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
//        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
//        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
//        objCreateAdjustment.submit();
//
//        Invoice__c i = TestUtility.generateInvoice(g.Id, p.Id);
//        insert i;
//
//        Charge_Group__c cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
//        cg.Invoice__c = i.id;
//        cg.Payment_Plan__c = t.Id;
//        cg.Charge_Group_External_ID__c = true;
//        insert cg;
//
//        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
//        insert transactionObj;
//
//        cg = TestUtility.generateChargeGroup(g.Id, null, 121114);
//        cg.Invoice__c = i.id;
//        cg.Payment_Plan__c = t.Id;
//        cg.Charge_Group_ID__c = 124;
//        cg.Charge_Group_External_ID__c = true;
//        insert cg;
//
//
//        transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
//        insert transactionObj;
//
//        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
//        Apexpages.currentPage().getParameters().put('paymentPlanExtId', '121212');
//        objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
//        for (ChargeGroupWrapper cgw : objCreateAdjustment.chrageGroupList) {
//            cgw.isSelected = true;
//        }
//        objCreateAdjustment.doNext();
//
//        Test.startTest();
//        TestUtility.status = 'CREATED';
//        TestUtility.statusCode = 201;
//        objCreateAdjustment.amount = '10';
//        objCreateAdjustment.adjustmentTypeSelected = 'DIS';
//        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
//        objCreateAdjustment.submit();
//        List<ApexPages.Message> msgList = ApexPages.getMessages();
//        System.assertEquals(3, msgList.size());
//
//        Test.stopTest();
//    }
//
//    public static testMethod void testRunAs() {
//        // Setup test data
//        // This code runs as the system user
//        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
//        User u = new User(Alias = 'standt', Email = 'standarduser@testorg.com',
//                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
//                LocaleSidKey = 'en_US', ProfileId = p.Id,
//                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@testorg1212.com');
//
//        System.runAs(u) {
//            Contact g = TestUtility.generateguarantorContact();
//            insert g;
//
//            CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(g));
//        }
//    }
}