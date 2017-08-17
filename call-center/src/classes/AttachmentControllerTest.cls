/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class AttachmentControllerTest {


    @IsTest
    public static void testStatementAttachment() {

        Test.startTest();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Statement__c stmt = TestUtility.generateStatement(guarantorContact.Id);
        stmt.Statement_Date__c = Date.parse('11/22/2015');
        insert stmt;

        ApexPages.currentPage().getParameters().put('id', stmt.Id);
        AttachmentController ac = new AttachmentController();
        ac.attachment.Name = 'Some_Statement.pdf';
        ac.attachment.Body = Blob.valueOf('A pdf of the statement');
        ac.attachment.ContentType = 'application/pdf';

        ac.upload();
        Test.stopTest();

        List<Attachment> attachments = [
            SELECT
                Body,
                BodyLength,
                ContentType,
                CreatedById,
                CreatedDate,
                Description,
                Id,
                IsDeleted,
                IsPrivate,
                LastModifiedById,
                LastModifiedDate,
                Name,
                OwnerId,
                ParentId,
                SystemModstamp
            FROM Attachment
        ];

        System.assertEquals(1, attachments.size());
        Attachment attachment = attachments[0];
        System.assertEquals(attachment.ParentId, stmt.Id, 'Expected attachment to be parented by the statement');
        System.assertEquals(attachment.OwnerId, UserInfo.getUserId(), 'Expected attachment to be owned by the current user');
    }

    @IsTest
    public static void testStatementAttachmentNotAllowed() {

        Test.startTest();
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Statement__c stmt = TestUtility.generateStatement(guarantorContact.Id);
        stmt.Statement_Date__c = Date.parse('11/22/2015');
        insert stmt;

        User readonly = TestUtility.generateReadOnlyUser();
        insert readonly;

        System.runAs(readonly) {
            ApexPages.currentPage().getParameters().put('id', stmt.Id);
            AttachmentController ac = new AttachmentController();
            ac.attachment.Name = 'Some_Statement.pdf';
            ac.attachment.Body = Blob.valueOf('A pdf of the statement');
            ac.attachment.ContentType = 'application/pdf';
            ac.upload();
        }

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(msgList.size(), 1);

        System.assert(msgList[0].getDetail().startsWith('Error uploading attachment'));
    }


    @IsTest
    public static void testEncounterAttachment() {

        Test.startTest();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 4500.00, System.today());
        insert encounter;

        ApexPages.currentPage().getParameters().put('id', encounter.Id);
        AttachmentController ac = new AttachmentController();
        ac.attachment.Name = 'Some_Estimate.pdf';
        ac.attachment.Body = Blob.valueOf('A pdf of the estimate');
        ac.attachment.ContentType = 'application/pdf';

        ac.upload();
        Test.stopTest();

        List<Attachment> attachments = [
            SELECT
                Body,
                BodyLength,
                ContentType,
                CreatedById,
                CreatedDate,
                Description,
                Id,
                IsDeleted,
                IsPrivate,
                LastModifiedById,
                LastModifiedDate,
                Name,
                OwnerId,
                ParentId,
                SystemModstamp
            FROM Attachment
        ];

        System.assertEquals(1, attachments.size());
        Attachment attachment = attachments[0];
        System.assertEquals(attachment.ParentId, encounter.Id, 'Expected attachment to be parented by the encounter');
        System.assertEquals(attachment.OwnerId, UserInfo.getUserId(), 'Expected attachment to be owned by the current user');
    }

    @IsTest
    public static void testCancel() {

        Test.startTest();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 4500.00, System.today());
        insert encounter;

        ApexPages.currentPage().getParameters().put('id', encounter.Id);
        AttachmentController ac = new AttachmentController();
        ac.attachment.Name = 'Some_Estimate.pdf';
        ac.attachment.Body = Blob.valueOf('A pdf of the estimate');
        ac.attachment.ContentType = 'application/pdf';

        PageReference pr = ac.cancel();
        Test.stopTest();

        System.assert(pr.getUrl().endsWith(String.valueOf(encounter.Id)), 'pr.getUrl(): ' + pr.getUrl());
    }

    @IsTest
    public static void testEncounterAttachmentNotAllowed() {

        Test.startTest();
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 4500.00, System.today());
        insert encounter;

        User readonly = TestUtility.generateReadOnlyUser();
        insert readonly;

        System.runAs(readonly) {
            ApexPages.currentPage().getParameters().put('id', encounter.Id);
            AttachmentController ac = new AttachmentController();
            ac.attachment.Name = 'Some_Estimate.pdf';
            ac.attachment.Body = Blob.valueOf('A pdf of the estimate');
            ac.attachment.ContentType = 'application/pdf';
            ac.upload();
        }

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(msgList.size(), 1);

        System.assert(msgList[0].getDetail().contains('does not have Update rights on ' + Encounter__c.SObjectType.getDescribe().getName()), 'Unexpected message: ' + msgList[0].getDetail());
    }

    @IsTest
    public static void testUnsupportedObjType() {

        Test.startTest();
        Campaign cmpn = TestUtility.generateCampaign('Test Campaign');
        insert cmpn;

        User readonly = TestUtility.generateReadOnlyUser();
        insert readonly;

        System.runAs(readonly) {
            ApexPages.currentPage().getParameters().put('id', cmpn.Id);
            AttachmentController ac = new AttachmentController();
            ac.attachment.Name = 'Some.pdf';
            ac.attachment.Body = Blob.valueOf('A pdf');
            ac.attachment.ContentType = 'application/pdf';
            ac.upload();
        }

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(msgList.size(), 1);

        System.assert(msgList[0].getDetail().contains('Attempt to upload attachment for unsupported object type'), 'Unexpected message: ' + msgList[0].getDetail());
    }


    @IsTest
    public static void testNoParentRecord() {

        Test.startTest();
        Campaign cmpn = TestUtility.generateCampaign('Test Campaign');

        User readonly = TestUtility.generateReadOnlyUser();
        insert readonly;

        System.runAs(readonly) {
            ApexPages.currentPage().getParameters().put('id', cmpn.Id);
            AttachmentController ac = new AttachmentController();
            ac.attachment.Name = 'Some.pdf';
            ac.attachment.Body = Blob.valueOf('A pdf');
            ac.attachment.ContentType = 'application/pdf';
            ac.upload();
        }

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(msgList.size(), 1);

        System.assertEquals(msgList[0].getDetail(), 'Record for attachment is required', 'Unexpected message: ' + msgList[0].getDetail());
    }
}