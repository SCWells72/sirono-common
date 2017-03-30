@isTest
private class EncounterDaoTest {
	/**
     * This method is used to test EncounterDao.getEncounterRecordsById method
     **/
    static testMethod void getEncounterRecordsByIdTest() {
    	// Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, system.today());
        INSERT encounter;

        Test.startTest();
        List<Encounter__c> encounterList = EncounterDao.getEncounterRecordsById('guarantor', guarantorContact.Id);
        // Check that record was selected
        System.assertEquals(encounterList.size(), 1);

        encounterList = EncounterDao.getEncounterRecordsById('encounter', encounter.Id);
        // Check that record was selected
        System.assertEquals(encounterList.size(), 1);

        Test.stopTest();
    }
}