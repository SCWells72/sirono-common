@isTest
private class PaymentServiceTest {
	/**
     * This method is used to test PaymentService.createNewPayment method
     **/
    static testMethod void createNewPaymentTest() {
    	// Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, system.today());
        INSERT encounter;

        Test.startTest();
        PaymentService.createNewPayment('Test Payment', guarantorContact.Id, 123, encounter.Id, System.now(), null);
        
        List<Payment__c> paymentList = [
        	SELECT Id, Name 
        	FROM Payment__c
        ];
        // Check that record was created
        System.assertEquals(paymentList.size(), 1);
        Test.stopTest();
    }
}