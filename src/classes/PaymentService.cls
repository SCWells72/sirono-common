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
    public static Payment__c createNewPayment(String guarantorRecordId, Decimal amount, String selectedEncounterId, Datetime depositeDate, String paymentMethod) {
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
        PaymentDao.insertPayment(new List<Payment__c>{payment});
        return PaymentDao.getPayment(payment.Id);
    }
}