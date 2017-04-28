/**
 * Payment DAO for Payment object SOQL/DML operations
 */
public class PaymentDao {
	/**
	 * This method is used to Insert Payment record.
	 * @param List<Payment__c> payments - List of payment record for insert
	 **/
    public static void insertPayment(List<Payment__c> payments) {
    	if (PaymentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT payments; 
        }
    }

    /**
     * This method returns payment record by Id.
     * @param Id paymentId - id of payment record
     **/
    public static Payment__c getPayment(Id paymentId) {
        try {
            Payment__c payment = [
                    SELECT  Id,
                            Amount__c,
                            Deposit_Date__c,
                            Encounter__c,
                            Guarantor__c,
                            Method__c,
                            Name,
                            Payment_Id__c 
                    FROM Payment__c 
                    WHERE Id = :paymentId
            ];
            return payment;
        } catch (QueryException ex) {
            return null;
        }
    }
}