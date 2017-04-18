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

        // Check system assert for GuarantorUser.
        System.assert(usr.userName.equals('userName'), 'Expected user name equals to "userName" but we got ' + usr.userName);
        // Check system assert for GuarantorContact.
        System.assert(cntct.status.equals('status'), 'Expected status equals to "status" but we got ' + cntct.status);
        // Check system assert for PaymentPlan.
        System.assert(paymentPlan.paymentPlanStanding.equals('paymentPlanStanding'), 'Expected paymentPlanStanding equals to "paymentPlanStanding" but we got ' + paymentPlan.paymentPlanStanding);
        // Check system assert for Guarantor.
        System.assertEquals(guarantor.grtUser, usr, 'Expected Guarantor User set as a user in guarantor.');
    }
}