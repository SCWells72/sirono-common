@isTest
private class PaymentDaoTest {
	/**
     * This method is used to test PaymentDao.insertPayment method
     **/
    static testMethod void insertPaymentTest() {
    	// Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c selectedEncounter = TestUtility.generateEncounter(guarantorContact.Id, 500, system.today());
        INSERT selectedEncounter;

        Payment__c payment = new Payment__c(
            Name = 'Test Payment',
            Guarantor__c = guarantorContact.Id,
            Amount__c = 123,
            Encounter__c = selectedEncounter.Id,
            Deposit_Date__c = System.now(),
            Method__c = null
        );

        Test.startTest();
        PaymentDao.insertPayment(payment);
        
        List<Payment__c> paymentList = [
        	SELECT Id, Name 
        	FROM Payment__c
        ];
        // Check that record was created
        System.assertEquals(paymentList.size(), 1);
        Test.stopTest();
    }
}