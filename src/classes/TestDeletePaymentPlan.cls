@isTest
private class TestDeletePaymentPlan {

    static testMethod void myUnitTest() {
        Apexpages.currentPage().getParameters().put('guarantorId','123');
        Apexpages.currentPage().getParameters().put('paymentPlanId','123');
        
        DeletePaymentPlan con = new DeletePaymentPlan();
        con.doSubmit();
        con.cancel();
    }
}