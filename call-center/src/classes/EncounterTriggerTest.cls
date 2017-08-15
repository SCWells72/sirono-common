/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test class for EncounterTriggerHandler.
 */
@IsTest
private class EncounterTriggerTest {

    static testMethod void myUnitTest() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Contact guarantorContact2 = TestUtility.generateGuarantorContact();
        guarantorContact2.LastName = 'G Test';
        guarantorContact2.Profile_Pointer_Id__c = 1234;
        guarantorContact2.Guarantor__c = guarantorContact.Id;
        insert guarantorContact2;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 100, System.today());
        encounter.Patient__c = patientContact.Id;
        encounter.Liability__c = 200;
        encounter.Cancelled__c = true;
        insert encounter;

        encounter.Liability__c = 300;
        update encounter;

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    static testMethod void myUnitTest1() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Contact guarantorContact2 = TestUtility.generateGuarantorContact();
        guarantorContact2.LastName = 'G Test';
        guarantorContact2.Profile_Pointer_Id__c = 1234;
        guarantorContact2.Guarantor__c = guarantorContact.Id;
        insert guarantorContact2;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 100);
        insert chargeGroup;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 100, System.today());
        encounter.Patient__c = patientContact.Id;
        encounter.Liability__c = 200;
        encounter.Cancelled__c = true;
        insert encounter;

        encounter.Liability__c = 500;
        encounter.Cancelled__c = true;
        encounter.Date_Of_Service__c = System.today() - 3;
        encounter.Guarantor__c = guarantorContact2.Id;
        update encounter;

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    //Viraj Rana 09-15-2016 : Improve the code coverage of EncounterTriggerHandler
    static testMethod void myUnitTest2() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        List<Contact> lstContact = [SELECT Id FROM Contact];
        System.assertEquals(1, lstContact.size());

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 100, System.today());
        encounter.Patient__c = patientContact.Id;
        encounter.Liability__c = 200;
        encounter.Cancelled__c = true;
        insert encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 100);
        insert chargeGroup;

        lstContact = [SELECT Id FROM Contact];
        System.assertEquals(2, lstContact.size());
        encounter.Liability__c = 300;
        encounter.Guarantor__c = null ;
        update encounter;

        lstContact = [SELECT Id FROM Contact];
        System.assertEquals(2, lstContact.size());
    }

    //Viraj Rana 09-15-2016 : Improve the code coverage of EncounterTriggerHandler
    static testMethod void checkCallListRemove() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Contact guarantorContact2 = TestUtility.generateGuarantorContact();
        guarantorContact2.LastName = 'G Test';
        guarantorContact2.Profile_Pointer_Id__c = 1234;
        guarantorContact2.Guarantor__c = guarantorContact.Id;
        insert guarantorContact2;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 100, System.today());
        encounter.Patient__c = patientContact.Id;
        encounter.Liability__c = 200;
        encounter.Cancelled__c = true;
        insert encounter;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 100);
        insert chargeGroup;

        encounter.Guarantor__c = guarantorContact2.Id;
        update encounter;

        List<CampaignMember> lstCamp = [
            SELECT Id, ContactId, CampaignId
            FROM CampaignMember
            WHERE ContactId = :guarantorContact2.Id
        ];
        System.assertEquals(0, lstCamp.size());
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @IsTest
    static void checkAccessRights() {
        List<EncounterSecurityContext> allContexts = new List<EncounterSecurityContext> { EncounterSecurityContext.UPDATE_CONTEXT };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (EncounterSecurityContext context : allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}