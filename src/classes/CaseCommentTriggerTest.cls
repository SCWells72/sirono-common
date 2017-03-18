/**
 * This class is use to test the logic of Case Comment Trigger and Case Comment Trigger Handler Class.
 **/

@isTest
public class CaseCommentTriggerTest {

    /**
     * Coverage the code for the CaseCommentTriggerHandler class and
     * call the afterInsert and checkAndDoAddNoteCallout method
     **/
    @isTest
    static void checkCaseComment() {
        // Get case object record type.
        RecordType rt = [SELECT Id, Name FROM RecordType
        		WHERE sObjectType = 'Case' AND Name = 'Internal Case'];

        // Create case record.
        Case c = new Case(Status = 'New', Origin='Phone', Charge_Group_IDs__c = '1234,1235', recordTypeID=rt.Id);
        INSERT c;

        Test.startTest();
        // Create Case Comment record.
        CaseComment cc = TestUtility.generateCaseComment(c.Id);
        INSERT cc;
        Test.stopTest();

        // Check system assert, Missing required details should trigger an exception.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            if (msg.getDetail().contains('Please provide all details'))
            	isError = true;
        }
        System.assert(isError, 'Missing required details throws an Exception during generate Case Comment process');
    }

    /**
     * Coverage the code for the CaseCommentTriggerHandler class and
     * call the afterInsert and checkAndDoAddNoteCallout method
     **/
    static testMethod void checkCaseCommentAsSystemAdmin() {
        // Get System Administrator Profile.
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        // Create new user with System Administrator Profile.
        User u = new User(Alias = 'standt', Email='admin@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='admin@testorg1212.com');

        // Run as a System Administrator.
        System.runAs(u) {
            // Get case object record type.
            RecordType rt = [SELECT Id, Name FROM RecordType
            		WHERE sObjectType = 'Case' AND Name = 'Internal Case'];

            // Create case record.
            Case c = new Case(Status='New',Origin='Phone',Charge_Group_IDs__c = '1234,1235',recordTypeID=rt.Id);
            INSERT c;

            Test.startTest();
            // Create Case Comment record.
            CaseComment cc = TestUtility.generateCaseComment(c.Id);
            INSERT cc;
            Test.stopTest();

            // Check system assert, arithmatic devide rule violation should trigger an exception.
            List<ApexPages.Message> msgList = ApexPages.getMessages();
	    Boolean isError = false;
	    for (Apexpages.Message msg: msgList) {
	    	if (msg.getDetail().contains('Divide by 0'))
	            isError = true;
	    }
	    System.assert(isError, 'Arithmetic rule violation throws an Exception during generate Case Comment process');
        }
    }

    /**
     * Coverage the code for the CaseCommentTriggerHandler class and
     * call the afterInsert and checkAndDoAddNoteCallout method
     **/
    static testMethod void testCaseChargeGroup() {
       // Create Patient Contact record.
       Contact patientContact = TestUtility.generatePatientContact();
       INSERT patientContact;

       // Create Guarantor Contact record.
       Contact guarantorContact = TestUtility.generateGuarantorContact();
       INSERT guarantorContact;

       // Create Charge Group record.
       Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,patientContact.Id,12345);
       INSERT chargeGroup;

       // Get System Administrator Profile.
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

       // Create new user with System Administrator Profile.
       User u = new User(Alias = 'standt', Email='admin@testorg.com',
       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
       LocaleSidKey='en_US', ProfileId = p.Id,
       TimeZoneSidKey='America/Los_Angeles', UserName='admin@testorg1212.com');
       Test.setMock(HttpCalloutMock.class, new AuthRestClientFailMock());

        // Run as a System Administrator.
       System.runAs(u) {
           // Get case object record type.
           RecordType rt = [SELECT Id, Name FROM RecordType
           			WHERE sObjectType = 'Case' AND Name = 'Internal Case'];

           // Create case record.
           Case c = new Case(Status='New',Origin='Phone',Charge_Group_IDs__c = '1234,1235',recordTypeID=rt.Id);
           INSERT c;

           // Create Case Charge Group record.
           Case_Charge_Group_Junction__c ccg = new Case_Charge_Group_Junction__c(Case__c = c.Id, Charge_Group__c = chargeGroup.Id);
           INSERT ccg;

           Test.startTest();
           // Create Case Comment record.
           CaseComment cc = TestUtility.generateCaseComment(c.Id);
           INSERT cc;
           Test.stopTest();

           // Check System Assert, Exception occures during generate case comment because missing and bad requires.
           List<ApexPages.Message> msgList = ApexPages.getMessages();
	   Boolean isError = false;
	   for (Apexpages.Message msg: msgList) {
	       if (msg.getDetail().contains(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.UNAUTHORIZED)))
	           isError = true;
	   }
	   System.assert(isError, 'JWT Exception during generate Case Comment process.');
        }
    }
}
