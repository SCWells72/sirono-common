/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class AttachmentController {

    public Attachment attachment {
        get {
            if (attachment == null) {
                attachment = new Attachment();
            }
            return attachment;
        }
        set;
    }

    public PageReference upload() {
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = ApexPages.currentPage().getParameters().get('id');

        if (attachment.ParentId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record for attachment is required'));
            return null;
        }

        try {
            SecurityContext relatedContext = getRelatedSecurityContext();

            if (relatedContext.actionAllowed() && AttachmentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                insert attachment;
            }
        } catch (Exception e) {
            System.debug('caught exception: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error uploading attachment: ' + e.getMessage()));
            return null;
        } finally {
            attachment = new Attachment();
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Attachment uploaded successfully'));

        PageReference pageReference = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        pageReference.setRedirect(true);
        return pageReference;
    }

    public PageReference cancel() {
        PageReference pageReference = new PageReference('/' + ApexPages.currentPage().getParameters().get('id'));
        pageReference.setRedirect(true);
        return pageReference;
    }

    private SecurityContext getRelatedSecurityContext() {

        String objType = getParentObjectType();

        if (objType != null) {
            if (objType.equals(Statement__c.SObjectType.getDescribe().getName())) {
                return StatementSecurityContext.ADD_ATTACHMENT_CONTEXT;
            }

            if (objType.equals(Encounter__c.SObjectType.getDescribe().getName())) {
                return EncounterSecurityContext.ADD_ATTACHMENT_CONTEXT;
            }
        }

        throw new SecurityUtils.SecurityException('Attempt to upload attachment for unsupported object type: ' + objType);
    }

    private String getParentObjectType() {
        String idString = ApexPages.currentPage().getParameters().get('id');
        Id objId = Id.valueOf(idString);

        return objId.getSobjectType().getDescribe().getName();
    }
}