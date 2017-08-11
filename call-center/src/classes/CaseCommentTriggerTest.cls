/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use to test the logic of Case Comment Trigger and Case Comment Trigger Handler Class.
 **/
@IsTest
public class CaseCommentTriggerTest {
    // TODO: Does this belong in Constants?
    private static final String INTERNAL_CASE_NAME = 'Internal Case';

    @TestSetup
    private static void setup() {
        Contact guarantor = TestUtility.generateGuarantorContact();
        Contact patientContact = TestUtility.generatePatientContact();
        insert new Contact[] { guarantor, patientContact };

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(
            guarantor.Id,
            patientContact.Id,
            200.0
        );
        insert chargeGroup;
    }

    private static RecordType getInternalCaseRecordType() {
        RecordType internalCaseRecordType = [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = :Case.SObjectType.getDescribe().getName()
            AND Name = :INTERNAL_CASE_NAME
        ];
        return internalCaseRecordType;
    }

    /**
     * Coverage the code for the CaseCommentTriggerHandler class and
     * call the afterInsert and checkAndDoAddNoteCallout method
     **/
    @IsTest
    static void checkCaseComment() {
        Case testCase = new Case(
            Status = Constants.CASE_STATUS_NEW,
            Origin = Constants.CASE_ORIGIN_PHONE,
            RecordTypeId = getInternalCaseRecordType().Id
        );
        insert testCase;

        Test.startTest();
        // Create Case Comment record.
        CaseComment caseComment = TestUtility.generateCaseComment(testCase.Id);
        insert caseComment;
        Test.stopTest();

        // Check system assert, Missing required details should trigger an exception.
        List<ApexPages.Message> messages = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message message : messages) {
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
        System.runAs(TestUtility.getAdminUser()) {
            // Create case record.
            Case testCase = new Case(
                Status = Constants.CASE_STATUS_NEW,
                Origin = Constants.CASE_ORIGIN_PHONE,
                RecordTypeId = getInternalCaseRecordType().Id
            );
            insert testCase;

            Test.startTest();
            CaseComment caseComment = TestUtility.generateCaseComment(testCase.Id);
            insert caseComment;
            Test.stopTest();

            // Check system assert, arithmatic devide rule violation should trigger an exception.
            List<ApexPages.Message> messages = ApexPages.getMessages();
            Boolean isError = false;
            for (ApexPages.Message message : messages) {
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
     *
     * TODO: What exactly is this testing since it's explicitly creating a case/charge group junction?
     **/
    static testMethod void testCaseChargeGroup() {
        Test.setMock(HttpCalloutMock.class, new AuthRestClientFailMock());

        System.runAs(TestUtility.getAdminUser()) {
            Case testCase = new Case(
                Status = Constants.CASE_STATUS_NEW,
                Origin = Constants.CASE_ORIGIN_PHONE,
                RecordTypeId = getInternalCaseRecordType().Id
            );
            insert testCase;

            // Explicitly associate the case with a charge group
            Charge_Group__c chargeGroup = [SELECT Id FROM Charge_Group__c LIMIT 1];
            Case_Charge_Group_Junction__c caseChargeGroupJunction = new Case_Charge_Group_Junction__c(
                Case__c = testCase.Id,
                Charge_Group__c = chargeGroup.Id
            );
            insert caseChargeGroupJunction;

            Test.startTest();
            CaseComment caseComment = TestUtility.generateCaseComment(testCase.Id);
            insert caseComment;
            Test.stopTest();

            // Check System Assert, Exception occures during generate case comment because missing and bad requires.
            List<ApexPages.Message> messages = ApexPages.getMessages();
            Boolean isError = false;
            for (ApexPages.Message message : messages) {
                String messageDetail = message.getDetail();
                if (messageDetail.contains(TestUtility.JSON_ERROR_BODIES.get(TestUtility.JSON_BODY_TYPE.UNAUTHORIZED))) {
                    isError = true;
                }
            }
            System.assert(isError, 'JWT Exception during generate Case Comment process.');
        }
    }
}
