@isTest
private class EncounterDaoTest {
    public static final String GUARANTOR_CONTACT_ONE = 'guarantorContact1';
    public static final String GUARANTOR_CONTACT_TWO = 'guarantorContact2';
    public static final String GUARANTOR_CONTACT_THREE = 'guarantorContact3';

    @TestSetup
    public static void setup() {
        // Create Guarantor Contact records.
        Contact guarantorContact1 = TestUtility.generateGuarantorContactByName(GUARANTOR_CONTACT_ONE);
        Contact guarantorContact2 = TestUtility.generateGuarantorContactByName(GUARANTOR_CONTACT_TWO);
        Contact guarantorContact3 = TestUtility.generateGuarantorContactByName(GUARANTOR_CONTACT_THREE);
        List<Contact> guarantorContactList = new List<Contact>{guarantorContact1, guarantorContact2, guarantorContact3};
        INSERT guarantorContactList;

        // Create Encounter record.
        Encounter__c encounter1 = TestUtility.generateEncounter(guarantorContact1.Id, 500, System.today());
        Encounter__c encounter2 = TestUtility.generateEncounter(guarantorContact2.Id, 1000, System.today());
        List<Encounter__c> encounterList = new List<Encounter__c>{encounter1, encounter2};
        INSERT encounterList;

        // Check system asserts.
        System.assertEquals(encounterList[0].Guarantor__c, guarantorContact1.Id, 'Expected ' + encounterList[0].Guarantor__c + ' but we got ' + guarantorContact1.Id);
        System.assertEquals(GUARANTOR_CONTACT_ONE, guarantorContactList[0].LastName, 'Expected guarantor name is ' + GUARANTOR_CONTACT_ONE + ' but we got ' + guarantorContactList[0].LastName);
    }

    /**
     * This method is used to test EncounterDao.getEncounterRecordsById method with Guarantor Id
     **/
    static testMethod void getEncounterRecordsByGuarantorIdTest() {
        Test.startTest();
        Contact guarantorContact1 = [SELECT Id FROM Contact WHERE Name = :GUARANTOR_CONTACT_ONE LIMIT 1];
        List<Encounter__c> encounterList = EncounterDao.getEncounterRecordsById(EncounterDao.IdType.GUARANTOR, guarantorContact1.Id);
        // Check that record was selected
        System.assertEquals(encounterList.size(), 1);
        // Check that correct encounter was selected
        System.assertEquals(encounterList[0].Patient_Portion__c, 500);

        Contact guarantorContact3 = [SELECT Id FROM Contact WHERE Name = :GUARANTOR_CONTACT_THREE LIMIT 1];
        encounterList = EncounterDao.getEncounterRecordsById(EncounterDao.IdType.GUARANTOR, guarantorContact3.Id);
        // Check that Encounter List is empty
        System.assertEquals(encounterList.size(), 0);

        Test.stopTest();
    }

    /**
     * This method is used to test EncounterDao.getEncounterRecordsById method with Encounter Id
     **/
    static testMethod void getEncounterRecordsByEncounterIdTest() {
        Test.startTest();
        Encounter__c encounter2 = [SELECT Id FROM Encounter__c WHERE Patient_Portion__c = 1000 LIMIT 1];
        List<Encounter__c> encounterList = EncounterDao.getEncounterRecordsById(EncounterDao.IdType.ENCOUNTER, encounter2.Id);
        // Check that record was selected
        System.assertEquals(encounterList.size(), 1);
        // Check that correct encounter was selected
        System.assertEquals(encounterList[0].Patient_Portion__c, 1000);
        Test.stopTest();
    }

    /**
     * This method checks logic for Update Billed_Charge_Group_Count__c field.
     **/
    @isTest
    public static void testUpdateBilledCGCount() {
        Contact guarantorContact = [SELECT Id FROM Contact WHERE Name = :GUARANTOR_CONTACT_ONE LIMIT 1];
        List<Encounter__c> encounterList = [SELECT Id, Billed_Charge_Group_Count__c FROM Encounter__c WHERE Guarantor__c = :guarantorContact.Id];

        Test.startTest();
        // Insert CG record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1214);
        chargeGroup.Encounter__c = encounterList[0].Id;
        INSERT chargeGroup;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(0, encounterList[0].Billed_Charge_Group_Count__c, 'Bill_Charge_Group should have defaulted to 0 but we got ' + encounterList[0].Billed_Charge_Group_Count__c);
        encounterList = [SELECT Id, Billed_Charge_Group_Count__c FROM Encounter__c WHERE Guarantor__c = :guarantorContact.Id];
        System.assertEquals(1, encounterList[0].Billed_Charge_Group_Count__c, 'Expected Billed_Charge_Group_Count__c to be 1 but we got ' + encounterList[0].Billed_Charge_Group_Count__c);
    }

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @isTest
    static void checkAccessRightsForRead() {
        List<EncounterSecurityContext> allContexts = new List<EncounterSecurityContext>{EncounterSecurityContext.SELECT_CONTEXT,
                EncounterSecurityContext.CLU_SELECT_CONTEXT, EncounterSecurityContext.EU_SELECT_CONTEXT,
                EncounterSecurityContext.EU_SELECT_CONTEXT_AGG, EncounterSecurityContext.PSS_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (EncounterSecurityContext context: allContexts) {
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