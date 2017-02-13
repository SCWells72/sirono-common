@isTest
private class GuarantorTest {
    static testMethod void guarantorTest() {
    	Test.startTest();
        Guarantor.GuarantorUser usr = new Guarantor.GuarantorUser('userName', 'pswrd', 'contactId');
        Guarantor.GuarantorContact cntct = new Guarantor.GuarantorContact('status', 2, 2, 2, false, 5);
        Guarantor.Invoice invoice = new Guarantor.Invoice(Date.today());
        Guarantor.PaymentPlan paymentPlan = new Guarantor.PaymentPlan(Date.today(), true, 'paymentPlanStanding', 'planType');
        Guarantor guarantor = new Guarantor(usr, cntct, invoice, paymentPlan, 3);
        Test.stopTest();
    }
}