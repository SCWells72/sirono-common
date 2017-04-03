@isTest
private class PayStaffWSUtillLightningTest {
    @testSetup static void setupSironoSettings(){
        SironoSettingsUtil.initializeSironoSettings();
    }

    static testMethod void myUnitTest() {

        PayStaffWSUtillLightning.fetchChargeGroupIds(PayStaffWSUtillLightning.fetchChargeGroupList(null));
        PayStaffWSUtillLightning.getCSRFToken();
        PayStaffWSUtillLightning.getJWTToken(PayStaffWSUtillLightning.un, PayStaffWSUtillLightning.pw);
        PayStaffWSUtillLightning.buildChargeGroupsURL('1,2');
        List<SelectOption> expYearOptions = PayStaffWSUtillLightning.expYearOptions;
        List<SelectOption> expMonthOptions = PayStaffWSUtillLightning.expMonthOptions;

        PayStaffWSUtillLightning.TokenAuthResponse tokenAuthResponse = new PayStaffWSUtillLightning.TokenAuthResponse();
        tokenAuthResponse.token = 'testToken';
    }

    static testMethod void testStatementUrlMap() {
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        //TestUtility.body = '<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        HttpResponse res = PayStaffWSUtillLightning.getStatementUrls('12345');

        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        System.assertEquals(200, res.getStatusCode());
        Test.stopTest();
    }

    static testMethod void testStatementUrlMap1() {
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.body = 'sirono<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        string str = PayStaffWSUtillLightning.getCSRFToken();
        Test.stopTest();
    }

    @isTest
    static void testConvertToDollars() {
        Decimal inputCents = 150;
        Decimal outputDollars = PayStaffWSUtillLightning.convertToDollars(inputCents);
        System.assert('1.5'.equals(outputDollars.format()), 'Expected 1.5, but got ' + outputDollars);
    }

    @isTest
    static void testConvertToDollars1() {
        string inputCents = '100';
        string dollarAmount = PayStaffWSUtillLightning.convertToDollars(inputCents);
        System.assertEquals('1.00', dollarAmount);
    }
    @isTest
    static void testConvertToCents() {
        String inputDollars = '100';
        String outputCents = PayStaffWSUtillLightning.convertToCents(inputDollars);
        System.assert('10000'.equals(outputCents), 'Expected 10000, but got ' + outputCents);
    }

    @isTest
    static void main() {
        Contact con = new Contact(LastName = 'Sirono', Patient_Id__c = 123456);
        insert con;
        PayStaffWSUtillLightning.fetchPatientId(con);
        PayStaffWSUtillLightning.addNoteWSCallout(null, null);
    }

    @isTest
    static void testChargeGroupByAccountSubStatus() {
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        insert chargeGroup;
        PayStaffWSUtillLightning.fetchChargeGroupListbyaccountsubstatus(guarantorContact);
        Contact objContact = PayStaffWSUtillLightning.fetchPatientContactWithCGConstraints(patientContact.Id);

        System.assertEquals(objContact.Id, patientContact.Id);
    }

}