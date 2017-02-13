@isTest
private class HiMSS_SummaryWidgetCtrlTest {
    static testMethod void getGuarantorInfoTest() {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new HiMSS_SummaryWidgetMocks());
   		HiMSS_SummaryWidgetCtrl.GuarantorWrapper gwRecord = HiMSS_SummaryWidgetCtrl.getAllHeaderInfo();

   		System.assert(gwRecord.grtUser.username == 'ruth.a.fiser@gmail.com', 'Incorrect username');
   		System.assert(gwRecord.grtUser.password == 'test_pw_76', 'Incorrect user password');
   		System.assert(gwRecord.newEstimatesCount == 3, 'Incorrect new estimates count');
   		System.assert(gwRecord.paymentPlan.planType == 'Automatic', 'Incorrect payment plan planType');
   		System.assert(gwRecord.invoiceOverdue == null, 'Incorrect invoice');
   		System.assert(gwRecord.contact.status == 'Paid', 'Incorrect contact status');

      Test.stopTest();
    }
}