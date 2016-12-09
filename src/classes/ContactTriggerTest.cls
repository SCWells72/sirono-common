/* author Sirono 
   Date 10/31/2016
   @version 1.0.1
   @description class to validate Guarantor phone number Sirono - Tracker #127517419
*/
@isTest
public class ContactTriggerTest {

    @testSetup
    public static void setup() {
        SironoSettingsUtil.generatePhoneNumVerification();
    }

    //Test that phone verification fires on insert
    static testMethod void testAfterInsert() {
        Test.startTest();

        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187745';
        insert con;

        Test.stopTest();

        List<Contact> contacts = [SELECT
                Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                CTINumber3__c
        FROM Contact WHERE Id =: con.Id];

        //Verify Home_Phone_Type__c was set
        System.assert(!String.isEmpty(contacts[0].Home_Phone_Type__c), 'Expected Home_Phone_Type__c to be set but was \''+contacts[0].Home_Phone_Type__c+'\'');
    }
    
    //Test that phone verification fires on update
    static testMethod void testAfterUpdate() {
        Test.startTest();

        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187748';
        insert con;
        
        con.HomePhone = '6157187745';
        con.Home_Phone_Type__c = null;
        update con;

        Test.stopTest();

        List<Contact> contacts = [SELECT
                Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                CTINumber3__c
        FROM Contact WHERE Id =: con.Id];

        //Verify Home_Phone_Type__c was set
        System.assert(!String.isEmpty(contacts[0].Home_Phone_Type__c), 'Expected Home_Phone_Type__c to be set but was \''+contacts[0].Home_Phone_Type__c+'\'');
    }

    //test to verify Other number is Landline.
    static testMethod void testCTIAssignment_OtherLandlineOnly() {
        //inserting contact record invokes contact trigger
        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187745';
        con.MobilePhone = '';
        con.OtherPhone = '6157186645';

        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        insert con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id =: con.Id];
				
        //Check System assert for Other Phone.
        System.assertEquals(con.OtherPhone, lstContact[0].CTINumber3__c);
    }
    
    //test to verify Mobile number is Landline.
    static testMethod void testCTIAssignment_MobileLandlineElse() {
        //inserting contact record invokes contact trigger
        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187745';
        con.MobilePhone = '6157187745';
        con.OtherPhone = '';

        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        insert con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id =: con.Id];

        System.assertEquals(con.MobilePhone, lstContact[0].CTINumber3__c);
    }
    
    //test to verify Other number is Mobile.
    static testMethod void testCTIAssignment_OtherMobileOnly() {
        //inserting contact record invokes contact trigger
        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '';
        con.MobilePhone = '';
        con.OtherPhone = '6157187745';

        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseMobile();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        insert con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id =: con.Id];

        System.assertEquals(con.OtherPhone, lstContact[0].CTINumber2__c);
    }
    
    //test to verify an invalid number.
    static testMethod void testInvalidNumberVerify() {

        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '12312345645645645'; //too long
        con.MobilePhone = '123'; //too short
        con.OtherPhone = '1234567890'; //not a real number
        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseInvalid();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        insert con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id =: con.Id];

        System.assertEquals(lstContact[0].Home_Phone_Type__c, NumVerifyValidator.INVALID);
        System.assertEquals(lstContact[0].Mobile_Phone_Type__c, NumVerifyValidator.INVALID);
        System.assertEquals(lstContact[0].Other_Phone_Type__c, NumVerifyValidator.INVALID);
    }
    
    //test for Non Guarantor Contact.
    static testMethod void testNonGuarantor_HomeLandline() {
        //Generate Patient Contact
        Contact con = TestUtility.generatePatientContact();
        con.HomePhone = '6157187745';
        con.MobilePhone = '';
        con.OtherPhone = '';
        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        insert con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id =: con.Id];

	//Check system assert.
	//All conditions we follow to generate CTINumber1__c based on HomePhone.
	//But Contact is not Guarantor that's why CTINumber1__c becomes null.
        System.assertEquals(lstContact[0].CTINumber1__c, null);
    }

    @isTest
    static void testCTIAssignment_HomeLandlineOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(HomePhone=phoneNumber, Home_Phone_Type__c=NumVerifyValidator.LANDLINE);

        ContactTriggerHandler.setCTINumbers(contact);
        System.assert(phoneNumber.equals(contact.CTINumber1__c), 'Expected CTINumber1 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber2__c), 'Expected CTINumber2 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }

    @isTest
    static void testCTIAssignment_HomeMobileOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(HomePhone=phoneNumber, Home_Phone_Type__c=NumVerifyValidator.MOBILE);

        ContactTriggerHandler.setCTINumbers(contact);
        System.assert(phoneNumber.equals(contact.CTINumber2__c), 'Expected CTINumber2 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber1__c), 'Expected CTINumber1 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }

    @isTest
    static void testCTIAssignment_MobileLandlineOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(MobilePhone=phoneNumber, Mobile_Phone_Type__c=NumVerifyValidator.LANDLINE);

        ContactTriggerHandler.setCTINumbers(contact);
        System.assert(phoneNumber.equals(contact.CTINumber1__c), 'Expected CTINumber1 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber2__c), 'Expected CTINumber2 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }

    @isTest
    static void testCTIAssignment_MobileMobileOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(MobilePhone=phoneNumber, Mobile_Phone_Type__c=NumVerifyValidator.MOBILE);

        ContactTriggerHandler.setCTINumbers(contact);
        System.assert(phoneNumber.equals(contact.CTINumber2__c), 'Expected CTINumber2 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber1__c), 'Expected CTINumber1 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }
    
    @isTest
    static void testCTIAssignment_AllNumbersLandlineOnly() {
        String homePhone = '5128823456';
        string mobilePhone = '5128823444';
        string otherPhone = '4528321232';
        Contact contact = new Contact(HomePhone = homePhone, Home_Phone_Type__c = NumVerifyValidator.LANDLINE,
        			MobilePhone = mobilePhone, Mobile_Phone_Type__c = NumVerifyValidator.LANDLINE,
        			OtherPhone = otherPhone, Other_Phone_Type__c = NumVerifyValidator.LANDLINE);

        ContactTriggerHandler.setCTINumbers(contact);
        System.assert(homePhone.equals(contact.CTINumber1__c), 'Expected CTINumber1 to be 5128823456');
        System.assert(otherPhone.equals(contact.CTINumber3__c), 'Expected CTINumber3 to be 4528321232');
        System.assert(String.isEmpty(contact.CTINumber2__c), 'Expected CTINumber2 to be empty');
        //mobile number is not assign in any CTI number bz of Mobile_Phone_Type__c is LANDLINE
        //but CTINumber1 and CTINumber3 is not empty.
    }
    
    @isTest
    static void testCTIAssignment_AllNumbersMobileOnly() {
        String homePhone = '5128823456';
        string mobilePhone = '5128823444';
        string otherPhone = '4528321232';
        Contact contact = new Contact(HomePhone = homePhone, Home_Phone_Type__c = NumVerifyValidator.MOBILE,
        			MobilePhone = mobilePhone, Mobile_Phone_Type__c = NumVerifyValidator.MOBILE,
        			OtherPhone = otherPhone, Other_Phone_Type__c = NumVerifyValidator.MOBILE);

        ContactTriggerHandler.setCTINumbers(contact);
        System.assert(mobilePhone.equals(contact.CTINumber2__c), 'Expected CTINumber2 to be 5128823444');
        System.assert(String.isEmpty(contact.CTINumber1__c), 'Expected CTINumber1 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
        //Homephone and Otherphone is not assign in any CTI number bz of Home_Phone_Type__c and Other_Phone_Type__c are MOBILE
        //and CTINumber2 is not empty.
    }
}