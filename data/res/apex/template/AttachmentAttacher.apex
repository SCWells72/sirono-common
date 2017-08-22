/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/*
 * After we load Encounters, we need at attach estimate PDFs. This anon script does just that. It does, however,
 * require that the HIMSS Estimate PDF be uploaded into the org as a static resource. Probably should not package that,
 * though.
 */

// Get all encounters for the Chucks that have been loaded into the org.
List<sPRS__Encounter__c> encounters = [
    SELECT id, sPRS__Encounter_ID__c 
    FROM sPRS__Encounter__c
    WHERE sPRS__Guarantor__r.sPRS__Guarantor_Id__c >= 200000
];

StaticResource estimate = [
    SELECT Id, Body
    FROM StaticResource
    WHERE Name = 'HIMSS_Estimate'
    LIMIT 1
];

List<Attachment> attachments = new List<Attachment>();

// Make sure the estimate attachment was found - if not, no use making the attchment.
if (estimate != null) {
    for (sPRS__Encounter__c encounter: encounters) {
        Attachment attachment = new Attachment();

        attachment.ParentId = encounter.Id;
        attachment.Name = encounter.sPRS__Encounter_ID__c;
        attachment.ContentType = 'pdf';
        attachment.body = estimate.Body;

        attachments.add(attachment);
    }
}

insert attachments;