@isTest
private class TestPayStaffWSUtill {

    static testMethod void myUnitTest() {
    	PayStaffWSUtill.codeCovergae();

    	PayStaffWSUtill.fetchGuarantorContact('');
    	PayStaffWSUtill.fetchGuarantorId(null);
    	PayStaffWSUtill.fetchChargeGroupIds(PayStaffWSUtill.fetchChargeGroupList(null));
    	PayStaffWSUtill.getCSRF_Token();
    	PayStaffWSUtill.getJWT_Token(PayStaffWSUtill.un, PayStaffWSUtill.pw);
    	PayStaffWSUtill.buildChargeGroupsURL('1,2');

    	PayStaffWSUtill.TokenAuthResponse tar = new PayStaffWSUtill.TokenAuthResponse();
       	tar.token = 'testToken';
    }

	@isTest
	static void testStatementUrlMap() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

		HttpResponse res = PayStaffWSUtill.getStatementUrls('12345');

		String contentType = res.getHeader('Content-Type');
		System.assert(contentType == 'application/json');
		System.assertEquals(200, res.getStatusCode());
	}

	@isTest
	static void testConvertToDollars(){
		Decimal inputCents = 150;
		Decimal outputDollars = PayStaffWSUtill.convertToDollars(inputCents);
		System.assert('1.5'.equals(outputDollars.format()), 'Expected 1.5, but got '+outputDollars);
	}

	@isTest
	static void testConvertToCents(){
		String inputDollars = '100.00';
		String outputCents = PayStaffWSUtill.convertToCents(inputDollars);
		System.assert('10000'.equals(outputCents), 'Expected 10000, but got '+outputCents);
	}
}