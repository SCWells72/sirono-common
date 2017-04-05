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
        Encounter__c selectedEncounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
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

    /**
    * Check all access rights for a read only User using runAs.
    **/
    @isTest
    static void checkAccessRights() {
        List<PaymentSecurityContext> allContexts = new List<PaymentSecurityContext>{PaymentSecurityContext.CREATE_CONTEXT,
            PaymentSecurityContext.PSWU_CREATE_CONTEXT, PaymentSecurityContext.UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentSecurityContext context: allContexts) {
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