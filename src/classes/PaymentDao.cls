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
}