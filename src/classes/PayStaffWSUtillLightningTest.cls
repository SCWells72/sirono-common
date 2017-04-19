@isTest
private class PayStaffWSUtillLightningTest {
    @testSetup static void setupSironoSettings(){
        Test.startTest();
        SironoSettingsUtil.initializeSironoSettings();
        Test.stopTest();
        
        // Check system assert.
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getValues(UserInfo.getOrganizationId());
        System.assertNotEquals(sironoSettings, null, 'Should have failed due to sironoSettings are null.');
    }

    static testMethod void myUnitTest() {

        Test.startTest();
        PayStaffWSUtillLightning.fetchChargeGroupIds(PayStaffWSUtillLightning.fetchChargeGroupList(null));
        PayStaffWSUtillLightning.getCSRFToken();
        PayStaffWSUtillLightning.getJWTToken(PayStaffWSUtillLightning.un, PayStaffWSUtillLightning.pw);
        PayStaffWSUtillLightning.buildChargeGroupsURL('1,2');

        PayStaffWSUtillLightning.TokenAuthResponse tokenAuthResponse = new PayStaffWSUtillLightning.TokenAuthResponse();
        tokenAuthResponse.token = 'testToken';
        Test.stopTest();
        
        // Check system assert.
        System.assertNotEquals(tokenAuthResponse, null, 'Should have failed due to tokenAuthResponse is null.');
    }

    static testMethod void testStatementUrlMap() {
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        //TestUtility.body = '<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        HttpResponse res = PayStaffWSUtillLightning.getStatementUrls('12345');
        Test.stopTest();

	// Check system assert.
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        System.assertEquals(200, res.getStatusCode());        
    }

    static testMethod void testStatementUrlMap1() {
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.body = 'sirono<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        String str = PayStaffWSUtillLightning.getCSRFToken();
        Test.stopTest();
        
        // Check system assert.
        System.assertNotEquals(str, null, 'Should have failed due to CSRF token is null.');
    }

    @isTest
    static void testConvertToDollars() {
        Test.startTest();
        Decimal inputCents = 150;
        Decimal outputDollars = PayStaffWSUtillLightning.convertToDollars(inputCents);
        Test.stopTest();
        
        // Check system assert.
        System.assert('1.5'.equals(outputDollars.format()), 'Expected 1.5, but got ' + outputDollars);
    }

    @isTest
    static void testConvertToDollars1() {
        Test.startTest();
        String inputCents = '100';
        String dollarAmount = PayStaffWSUtillLightning.convertToDollars(inputCents);
        Test.stopTest();
        
        // Check system assert.
        System.assertEquals('1.00', dollarAmount);
    }

    @isTest
    static void main() {
        Test.startTest();
        Contact con = new Contact(LastName = 'Sirono', Patient_Id__c = 123456);
        INSERT con;
        String patientId = PayStaffWSUtillLightning.fetchPatientId(con);
        PayStaffWSUtillLightning.addNoteWSCallout(null, null);
        Test.stopTest();
        
        // Check system assert.
        System.assertNotEquals(patientId, null, 'Should have failed due to patientId is null.');
    }

    @isTest
    static void testChargeGroupByAccountSubStatus() {
        Test.startTest();
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        INSERT chargeGroup;
        PayStaffWSUtillLightning.fetchChargeGroupListbyaccountsubstatus(guarantorContact);
        Contact objContact = PayStaffWSUtillLightning.fetchPatientContactWithCGConstraints(patientContact.Id);
        Test.stopTest();

	// Check system assert.
        System.assertEquals(objContact.Id, patientContact.Id);
    }

}