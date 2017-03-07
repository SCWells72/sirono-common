/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-02-2016
 * @PayStaffWSUtillTest Test Class for the Code Covrege of PayStaffWSUtill Class.
 */

@isTest
private class PayStaffWSUtillTest {
    @testSetup static void setupSironoSettings(){
        SironoSettingsUtil.initializeSironoSettings();
    }

    static testMethod void myUnitTest() {
        PayStaffWSUtill.fetchGuarantorContact('');
        PayStaffWSUtill.fetchGuarantorId(null);
        PayStaffWSUtill.fetchChargeGroupIds(PayStaffWSUtill.fetchChargeGroupList(null));
        PayStaffWSUtill.getCSRFToken();
        PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
        PayStaffWSUtill.buildChargeGroupsURL('1,2');
        List<SelectOption> expYearOptions = PayStaffWSUtill.expYearOptions;
        List<SelectOption> expMonthOptions = PayStaffWSUtill.expMonthOptions;

        PayStaffWSUtill.TokenAuthResponse tokenAuthResponse = new PayStaffWSUtill.TokenAuthResponse();
        tokenAuthResponse.token = 'testToken';
    }

    static testMethod void testStatementUrlMap() {
        Test.startTest();
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        //TestUtility.body = '<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        HttpResponse res = PayStaffWSUtill.getStatementUrls('12345');

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

        string str = PayStaffWSUtill.getCSRFToken();
        Test.stopTest();
    }

    @isTest
    static void testConvertToDollars() {
        Decimal inputCents = 150;
        Decimal outputDollars = PayStaffWSUtill.convertToDollars(inputCents);
        System.assert('1.5'.equals(outputDollars.format()), 'Expected 1.5, but got ' + outputDollars);
    }

    @isTest
    static void testConvertToDollars1() {
        string inputCents = '100';
        string dollarAmount = PayStaffWSUtill.convertToDollars(inputCents);
        System.assertEquals('1.00', dollarAmount);
    }
    @isTest
    static void testConvertToCents() {
        String inputDollars = '100';
        String outputCents = PayStaffWSUtill.convertToCents(inputDollars);
        System.assert('10000'.equals(outputCents), 'Expected 10000, but got ' + outputCents);
    }

    @isTest
    static void main() {
        Contact con = new Contact(LastName = 'Sirono', Patient_Id__c = 123456);
        insert con;
        PayStaffWSUtill.fetchPatientId(con);
        PayStaffWSUtill.addNoteWSCallout(null, null);
    }

    @isTest
    static void testChargeGroupByAccountSubStatus() {
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        insert chargeGroup;
        PayStaffWSUtill.fetchChargeGroupListbyaccountsubstatus(guarantorContact);
        Contact objContact = PayStaffWSUtill.fetchPatientContactWithCGConstraints(patientContact.Id);

        System.assertEquals(objContact.Id, patientContact.Id);
    }

}
    /**
     * This method test the logic of Fetch Guarantor Contact with CG Constrains for Add Discount
     * Here CG account substatus is "Preinvoiced" so we get contact with one CG.
     **/
    @isTest
    public static void fetchContactWithCGForDiscount() {        
        // Create Contact record with guarantor record type.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        // Create Contact record with patient record type.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        INSERT chargeGroup;

		// Call fetchGuarantorContactWithCGConstraintsForDiscount method.
        Test.startTest();
        Contact contact = PayStaffWSUtill.fetchGuarantorContactWithCGConstraintsForDiscount(guarantorContact.Id);
        Test.stopTest();
        
        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
    }
    
    /**
     * This method test the logic of Fetch Guarantor Contact with CG Constrains for Add Discount
     * Here CG account substatus is "Bad Debt" so we get only contact details.
     * We can't get any CG record with contact.
     **/
    @isTest
    public static void fetchContactWithoutCGForDiscount() {        
        // Create Contact record with guarantor record type.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        // Create Contact record with patient record type.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        INSERT chargeGroup;

		// Call fetchGuarantorContactWithCGConstraintsForDiscount method.
        Test.startTest();
        Contact contact = PayStaffWSUtill.fetchGuarantorContactWithCGConstraintsForDiscount(guarantorContact.Id);
        Test.stopTest();
        
        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 0);
    }
 }