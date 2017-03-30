/**
 * Payment DAO for Payment object SOQL/DML operations
 */
public class PaymentDao {
	/**
	 * This method is used to Insert Payment record.
	 * @param Payment__c payment - payment record for insert
	 **/
    public static void insertPayment(Payment__c payment) {
    	if (PaymentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT payment; 
        }
    }
}