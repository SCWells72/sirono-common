/**
 * Payment Service with logic for working with Payment__c object.
 */
public class PaymentService extends AbstractService {
    // Constant variable.
    public static final String PAYMENTNAME = 'Payment';

    /**
     * This method is used to Create/Insert Payment record based on Encounter, Contact and Amount.
     * @param String paymentName - name of the payment
     * @param String guarantorRecordId - id of the guarantor record
     * @param Decimal amount - payment amount
     * @param String selectedEncounterId - id of the encounter record
     * @param Datetime depositeDate - payment deposite date
     * @param String paymentMethod - payment method
     **/
    public static String createNewPayment(String guarantorRecordId, Decimal amount, String selectedEncounterId, Datetime depositeDate, String paymentMethod) {
        // Initialize new Payment record
        Payment__c payment = new Payment__c(
            Name = PAYMENTNAME,
            Guarantor__c = guarantorRecordId,
            Amount__c = amount,
            Encounter__c = selectedEncounterId,
            Deposit_Date__c = depositeDate,
            Method__c = paymentMethod
        );
        // Insert new Payment record
        List<Payment__c> payments = PaymentDao.insertPayment(new List<Payment__c>{payment});
        if (payments[0].Id != null) {
            Payment__c dbPayment = [SELECT Payment_Id__c FROM Payment__c WHERE Id = :payments[0].Id];
            return dbPayment.Payment_Id__c;
        }
        return null;
    }
}