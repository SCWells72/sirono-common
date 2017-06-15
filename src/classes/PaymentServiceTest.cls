@isTest
public class PaymentServiceTest {
	/**
     * This method is used to test PaymentService.createNewPayment method
     **/
    @IsTest
    static void createNewPaymentTest() {
    	// Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Test.startTest();
        PaymentService.createNewPayment(guarantorContact.Id, 123, encounter.Id, System.now(), null);
        
        List<Payment__c> paymentList = [
        	SELECT Id, Name 
        	FROM Payment__c
        ];
        // Check that record was created
        System.assertEquals(paymentList.size(), 1);
        Test.stopTest();
    }

    @IsTest
    public static void payChargeGroupsBuildRequestBodyTest {

        PaymentRequest pmtRequest = new PaymentRequest();
        pmtRequest.creditCardNumber = '';
        pmtRequest.cardHolderName = cInfo.cardHolderName;
        pmtRequest.expirationYear = cInfo.expirationYear.substring(2);
        pmtRequest.expirationMonth = cInfo.expirationMonth.substring(0,2);
        pmtRequest.cvv = cInfo.cvv;
        pmtRequest.amount = cInfo.amount;
        pmtRequest.address = cInfo.address;
        pmtRequest.city = cInfo.city;
        pmtRequest.state = cInfo.state;
        pmtRequest.zip = cInfo.zip;
    }
}