/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */


public void attachEncounters() {
    List<Encounter__c> encounterList = [
        SELECT Id, Encounter_Id__c
        FROM Encounter__c
        WHERE Encounter_Id__c = 'EN-20170224-1'
    ];

    List<Attachment> attachmentList = new List<Attachment>();

    for (Encounter__c enc: encounterList) {
        Attachment attachment = new Attachment();

        attachment.ParentId = enc.Id;
        attachment.Name = enc.Encounter_Id__c;
        attachment.Body = Blob.valueOf('./res/attachments/HIMSS_Estimate_v2.pdf');
        attachment.ContentType = 'file';

        attachmentList.add(attachment);
    }

    if (attachmentList.size() > 0) {
        insert attachmentList;
    }
}

public void attachStatements() {
    Map<String, String> paymentAttachmentMap = new Map<String, String>();



}

public void attachPayments() {

}

attachEncounters();
attachStatements();
attachPayments();
