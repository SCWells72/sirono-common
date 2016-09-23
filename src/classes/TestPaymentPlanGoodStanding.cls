@isTest
private class TestPaymentPlanGoodStanding {

    static testMethod void myUnitTest() {
        Apexpages.currentPage().getParameters().put('guarantorId', '123');
        Apexpages.currentPage().getParameters().put('paymentPlanId', '123');

        PaymentPlanGoodStanding con = new PaymentPlanGoodStanding();
        con.doSubmit();
        con.cancel();
    }
}