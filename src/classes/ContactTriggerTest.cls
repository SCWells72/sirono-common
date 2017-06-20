/**
 * This class tests the logic of Contact Trigger and Contact Trigger Handler Class.
 **/

@isTest
public class ContactTriggerTest {

    /**
     * This method checks logic for validate phone number after insert contact record.
     **/
    static testMethod void testAfterInsert() {
        Test.startTest();

        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187745';
        INSERT con;

        Test.stopTest();

        List<Contact> contacts = [SELECT
                Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                CTINumber3__c
        FROM Contact WHERE Id = :con.Id];

        // Verify Home_Phone_Type__c was set
        System.assert(!String.isEmpty(contacts[0].Home_Phone_Type__c), 'Expected Home_Phone_Type__c to be set but was \''+contacts[0].Home_Phone_Type__c+'\'');
    }

    /**
     * This method checks logic for validate phone number after update contact record.
     **/
    static testMethod void testAfterUpdate() {
        Test.startTest();

        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187748';
        INSERT con;

        con.HomePhone = '6157187745';
        con.Home_Phone_Type__c = null;
        UPDATE con;

        Test.stopTest();

        List<Contact> contacts = [SELECT
                Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                CTINumber3__c
        FROM Contact WHERE Id = :con.Id];

        // Verify Home_Phone_Type__c was set
        System.assert(!String.isEmpty(contacts[0].Home_Phone_Type__c), 'Expected Home_Phone_Type__c to be set but was \''+contacts[0].Home_Phone_Type__c+'\'');
    }

    /**
     * This method checks logic for validate provided Other number is Landline.
     **/
    static testMethod void testCTIAssignment_OtherLandlineOnly() {
        // inserting contact record invokes contact trigger
        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187745';
        con.MobilePhone = '';
        con.OtherPhone = '6157186645';

        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        INSERT con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id = :con.Id];

        // Check System assert, CTINumber3__c number is populated same as other phone.
        System.assertEquals(con.OtherPhone, lstContact[0].CTINumber3__c, 'CTINumber3__c is not populated as other phone.');
    }

    /**
     * This method checks logic for validate provided Mobile number is Landline.
     **/
    static testMethod void testCTIAssignment_MobileLandlineElse() {
        // inserting contact record invokes contact trigger
        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '6157187745';
        con.MobilePhone = '6157187745';
        con.OtherPhone = '';

        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        INSERT con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id = :con.Id];

	// Check System assert, CTINumber3__c number is populated same as MobilePhone.
        System.assertEquals(con.MobilePhone, lstContact[0].CTINumber3__c, 'CTINumber3__c is not populated as MobilePhone.');
    }

    /**
     * This method checks logic for validate provided Other number is Mobile.
     **/
    static testMethod void testCTIAssignment_OtherMobileOnly() {
        // inserting contact record invokes contact trigger
        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '';
        con.MobilePhone = '';
        con.OtherPhone = '6157187745';

        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseMobile();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        INSERT con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id = :con.Id];

	// Check System assert, CTINumber2__c number is populated same as other phone.
        System.assertEquals(con.OtherPhone, lstContact[0].CTINumber2__c, 'CTINumber2__c is not populated as other phone.');
    }

    /**
     * This method checks logic for validate provided number is invalid.
     **/
    static testMethod void testInvalidNumberVerify() {

        Contact con = TestUtility.generateGuarantorContact();
        con.HomePhone = '12312345645645645'; //too long
        con.MobilePhone = '123'; //too short
        con.OtherPhone = '1234567890'; //not a real number
        
        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseInvalid();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        INSERT con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id = :con.Id];

	// Check system asserts.
        System.assertEquals(lstContact[0].Home_Phone_Type__c, NumVerifyValidator.INVALID, 'Provided number is not Invalid type');
        System.assertEquals(lstContact[0].Mobile_Phone_Type__c, NumVerifyValidator.INVALID, 'Provided number is not Invalid type');
        System.assertEquals(lstContact[0].Other_Phone_Type__c, NumVerifyValidator.INVALID, 'Provided number is not Invalid type');
    }

    /**
     * This method checks logic for Non Guarantor Contact.
     **/
    static testMethod void testNonGuarantor_HomeLandline() {
        // Generate Patient Contact
        Contact con = TestUtility.generatePatientContact();
        con.HomePhone = '6157187745';
        con.MobilePhone = '';
        con.OtherPhone = '';
        
        Test.startTest();
        TestUtility.statusCode = 200;
        TestUtility.body = PhoneNumberCalloutResponseBody.responseLandline();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        INSERT con;
        Test.stopTest();

        List<Contact> lstContact = [SELECT
                                  Id, OtherPhone, MobilePhone, HomePhone, Home_Phone_Type__c,
                                  Mobile_Phone_Type__c, Other_Phone_Type__c, CTINumber1__c, CTINumber2__c,
                                  CTINumber3__c
                                  FROM Contact WHERE Id = :con.Id];

    	// Check system assert.
    	// All conditions we follow to generate CTINumber1__c based on HomePhone.
    	// But Contact is not Guarantor that's why CTINumber1__c becomes null.
        System.assertEquals(lstContact[0].CTINumber1__c, null, 'CTINumber1__c should be null because of non-guarantor contact');
    }

    /**
     * This method checks logic for CTIAssignment for Home and Landline.
     **/
    @isTest
    static void testCTIAssignment_HomeLandlineOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(HomePhone=phoneNumber, Home_Phone_Type__c=NumVerifyValidator.LANDLINE);

        Test.startTest();
        ContactTriggerHandler.setCTINumbers(contact);
        Test.stopTest();
        
        // Check system asserts.
        System.assert(phoneNumber.equals(contact.CTINumber1__c), 'Expected CTINumber1 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber2__c), 'Expected CTINumber2 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }

    /**
     * This method checks logic for CTIAssignment for Home and Mobile.
     **/
    @isTest
    static void testCTIAssignment_HomeMobileOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(HomePhone=phoneNumber, Home_Phone_Type__c=NumVerifyValidator.MOBILE);

        Test.startTest();
        ContactTriggerHandler.setCTINumbers(contact);
        Test.stopTest();
        
        // Check system asserts.
        System.assert(phoneNumber.equals(contact.CTINumber2__c), 'Expected CTINumber2 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber1__c), 'Expected CTINumber1 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }

    /**
     * This method checks logic for CTIAssignment for Mobile and Landline.
     **/
    @isTest
    static void testCTIAssignment_MobileLandlineOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(MobilePhone=phoneNumber, Mobile_Phone_Type__c=NumVerifyValidator.LANDLINE);

        Test.startTest();
        ContactTriggerHandler.setCTINumbers(contact);
        Test.stopTest();
        
        // Check system asserts.
        System.assert(phoneNumber.equals(contact.CTINumber1__c), 'Expected CTINumber1 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber2__c), 'Expected CTINumber2 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }

    /**
     * This method checks logic for CTIAssignment for Mobile.
     **/
    @isTest
    static void testCTIAssignment_MobileMobileOnly() {
        String phoneNumber = '5128823456';
        Contact contact = new Contact(MobilePhone=phoneNumber, Mobile_Phone_Type__c=NumVerifyValidator.MOBILE);

        Test.startTest();
        ContactTriggerHandler.setCTINumbers(contact);
        Test.stopTest();
        
        // Check system asserts.
        System.assert(phoneNumber.equals(contact.CTINumber2__c), 'Expected CTINumber2 to be 5128823456');
        System.assert(String.isEmpty(contact.CTINumber1__c), 'Expected CTINumber1 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
    }

    /**
     * This method checks logic for CTIAssignment for All Landline numbers.
     **/
    @isTest
    static void testCTIAssignment_AllNumbersLandlineOnly() {
        String homePhone = '5128823456';
        string mobilePhone = '5128823444';
        string otherPhone = '4528321232';
        Contact contact = new Contact(HomePhone = homePhone, Home_Phone_Type__c = NumVerifyValidator.LANDLINE,
        			MobilePhone = mobilePhone, Mobile_Phone_Type__c = NumVerifyValidator.LANDLINE,
        			OtherPhone = otherPhone, Other_Phone_Type__c = NumVerifyValidator.LANDLINE);

        Test.startTest();
        ContactTriggerHandler.setCTINumbers(contact);
        Test.stopTest();
        
        // Check system asserts.
        System.assert(homePhone.equals(contact.CTINumber1__c), 'Expected CTINumber1 to be 5128823456');
        System.assert(otherPhone.equals(contact.CTINumber3__c), 'Expected CTINumber3 to be 4528321232');
        System.assert(String.isEmpty(contact.CTINumber2__c), 'Expected CTINumber2 to be empty');
        //mobile number is not assign in any CTI number bz of Mobile_Phone_Type__c is LANDLINE
        //but CTINumber1 and CTINumber3 is not empty.
    }

    /**
     * This method checks logic for CTIAssignment for All Mobile numbers.
     **/
    @isTest
    static void testCTIAssignment_AllNumbersMobileOnly() {
        String homePhone = '5128823456';
        string mobilePhone = '5128823444';
        string otherPhone = '4528321232';
        Contact contact = new Contact(HomePhone = homePhone, Home_Phone_Type__c = NumVerifyValidator.MOBILE,
        			MobilePhone = mobilePhone, Mobile_Phone_Type__c = NumVerifyValidator.MOBILE,
        			OtherPhone = otherPhone, Other_Phone_Type__c = NumVerifyValidator.MOBILE);

        Test.startTest();
        ContactTriggerHandler.setCTINumbers(contact);
        Test.stopTest();
        
        // Check system asserts.
        System.assert(mobilePhone.equals(contact.CTINumber2__c), 'Expected CTINumber2 to be 5128823444');
        System.assert(String.isEmpty(contact.CTINumber1__c), 'Expected CTINumber1 to be empty');
        System.assert(String.isEmpty(contact.CTINumber3__c), 'Expected CTINumber3 to be empty');
        // Homephone and Otherphone is not assign in any CTI number bz Home_Phone_Type__c and Other_Phone_Type__c are MOBILE
        // and CTINumber2 is not empty.
    }

    @IsTest
    static void valueChangedTest(){
        System.assert(!ContactTriggerHandler.valueChanged(null, null), 'Expected valueChanged to be false but was true');
        System.assert(!ContactTriggerHandler.valueChanged('12345', '12345'), 'Expected valueChanged to be false but was true');
        System.assert(ContactTriggerHandler.valueChanged(null, '12345'), 'Expected valueChanged to be true but was false');
        System.assert(ContactTriggerHandler.valueChanged('12345', null), 'Expected valueChanged to be true but was false');
        System.assert(ContactTriggerHandler.valueChanged('12345', '123456'), 'Expected valueChanged to be true but was false');
        System.assert(ContactTriggerHandler.valueChanged('123456', '12345'), 'Expected valueChanged to be true but was false');
    }
}