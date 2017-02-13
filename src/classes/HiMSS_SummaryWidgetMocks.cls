@isTest
global class HiMSS_SummaryWidgetMocks implements HttpCalloutMock {
	private static String respBody = '{"newEstimatesCount":3,"grtUser":{"userName":"ruth.a.fiser@gmail.com","password":"test_pw_76","contactId":"0031100001EoYYjAAN"},"grtPaymentPlan":{"planType":"Automatic","paymentPlanStanding":null,"nextPaymentDate":"2017-02-24","isActive":false},"grtInvoice":null,"grtContact":{"status":"Paid","overdueInvoices":0,"outstandingInvoices":0,"invoicedBalance":0.00,"delinquentInvoices":0,"addToPaymentPlan":false}}';
    global HTTPResponse respond(HTTPRequest req) {
		System.assertEquals('GET', req.getMethod());

		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(HiMSS_SummaryWidgetMocks.respBody);
		res.setStatusCode(200);
		res.setStatus('OK');

		return res;
	}
}