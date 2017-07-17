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
        Contact guarantor = TestUtility.generateGuarantorContact();
        insert guarantor;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantor.Id, patientContact.Id, 200.0);
        insert chargeGroup;

        // Get case object record type.
        RecordType internalCaseRecordTYpe = [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = 'Case'
            AND Name = 'Internal Case'
        ];

        // Create case record.
        Case testCase = new Case(
            Status = 'New',
            Origin = 'Phone',
            RecordTypeId = internalCaseRecordTYpe.Id
        );
        INSERT testCase;

        Test.startTest();
        // Create Case Comment record.
        CaseComment caseComment = TestUtility.generateCaseComment(testCase.Id);
        INSERT caseComment;
        Test.stopTest();

        // Check system assert, Missing required details should trigger an exception.
        List<ApexPages.Message> messages = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message message: messages) {
            String messageDetail = message.getDetail();
            if (messageDetail.contains('Please provide all details')) {
                isError = true;
            }
        }
        System.assert(isError, 'Missing required details throws an Exception during generate Case Comment process');
    }

    /**
     * Coverage the code for the CaseCommentTriggerHandler class and
     * call the afterInsert and checkAndDoAddNoteCallout method
     **/
    static testMethod void checkCaseCommentAsSystemAdmin() {
        // Get System Administrator Profile.
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        // Create new user with System Administrator Profile.
        User adminUser = new User(
            Alias = 'standt',
            Email = 'admin@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'admin@testorg1212.com'
        );

        // Run as a System Administrator.
        System.runAs(adminUser) {
            Contact guarantor = TestUtility.generateGuarantorContact();
            insert guarantor;

            Contact patientContact = TestUtility.generatePatientContact();
            insert patientContact;

            Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantor.Id, patientContact.Id, 200.0);
            insert chargeGroup;

            // Get case object record type.
            RecordType internalCaseRecordType = [
                SELECT Id, Name
                FROM RecordType
                WHERE sObjectType = :Case.SObjectType.getDescribe().getName()
                AND Name = 'Internal Case'
            ];

            // Create case record.
            Case testCase = new Case(
                Status = 'New',
                Origin = 'Phone',
                RecordTypeId = internalCaseRecordType.Id
            );
            INSERT testCase;

            Test.startTest();
            CaseComment caseComment = TestUtility.generateCaseComment(testCase.Id);
            INSERT caseComment;
            Test.stopTest();

            // Check system assert, arithmatic devide rule violation should trigger an exception.
            List<ApexPages.Message> messages = ApexPages.getMessages();
            Boolean isError = false;
            for (Apexpages.Message message: messages) {
                String messageDetail = message.getDetail();
                if (messageDetail.contains('Divide by 0')) {
                    isError = true;
                }
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
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        INSERT chargeGroup;

        // Get System Administrator Profile.
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        // Create new user with System Administrator Profile.
        User adminUser = new User(
            Alias = 'standt',
            Email = 'admin@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'admin@testorg1212.com');

        Test.setMock(HttpCalloutMock.class, new AuthRestClientFailMock());

        // Run as a System Administrator.
        System.runAs(adminUser) {
            // Get case object record type.
            RecordType internalCaseRecordType = [
                SELECT Id, Name
                FROM RecordType
                WHERE sObjectType = :Case.SObjectType.getDescribe().getName()
                AND Name = 'Internal Case'
            ];

            // Create case record.
            Case c = new Case(
                Status = 'New',
                Origin = 'Phone',
                RecordTypeId = internalCaseRecordType.Id
            );
            INSERT c;

            // Create Case Charge Group record.
            // TODO: Is this explicitly required?
            Case_Charge_Group_Junction__c caseChargeGroupJunction = new Case_Charge_Group_Junction__c(
                Case__c = c.Id,
                Charge_Group__c = chargeGroup.Id
            );
            INSERT caseChargeGroupJunction;

            Test.startTest();
            // Create Case Comment record.
            CaseComment caseComment = TestUtility.generateCaseComment(c.Id);
            INSERT caseComment;
            Test.stopTest();

            // Check System Assert, Exception occures during generate case comment because missing and bad requires.
            List<ApexPages.Message> messages = ApexPages.getMessages();
            Boolean isError = false;
            for (Apexpages.Message message: messages) {
                String messageDetail = message.getDetail();
                if (messageDetail.contains(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.UNAUTHORIZED))) {
                    isError = true;
                }
            }
            System.assert(isError, 'JWT Exception during generate Case Comment process.');
        }
    }
}
