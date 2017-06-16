/**
 * Payment DAO for Payment object SOQL/DML operations
 */
//TODO fix our sharing model
public without sharing class PaymentDao {
	/**
	 * This method is used to Insert Payment record.
	 * @param List<Payment__c> payments - List of payment record for insert
	 **/
    public static void insertPayment(List<Payment__c> payments) {
    	if (PaymentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT payments; 
        }
    }

    public static void insertPaymentAndTransactions(List<SObject> paymentsAndTransactions) {
        if (PaymentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            // Create the Payment and associated Transactions
            Database.SaveResult[] results = Database.insert(paymentsAndTransactions);
        }
    }

    /**
     * This method returns payment record by Id.
     * @param Id paymentId - id of payment record
     **/
    public static Payment__c getPayment(Id paymentId) {
        if (PaymentSecurityContext.DAO_SELECT_CONTEXT.actionAllowed()) {
            try {
                Payment__c payment = [
                        SELECT Id,
                                Amount__c,
                                Deposit_Date__c,
                                Encounter__c,
                                Guarantor__c,
                                Method__c,
                                Name,
                                Payment_Id__c,
                                Sirono_ID__c,
                                Id__c

                        FROM Payment__c
                        WHERE Id = :paymentId
                ];
                return payment;
            } catch (QueryException ex) {
                System.debug('PaymentDao.getPayment: '+ex.getStackTraceString());
                return null;
            }
        }

        return null;
    }

    /**
     * This method returns payment record by Id.
     * @param Id paymentId - id of payment record
     **/
    public static Payment__c getPaymentBySironoId(Decimal sironoId) {
        if (PaymentSecurityContext.DAO_SELECT_CONTEXT.actionAllowed()) {
            try {
                Payment__c payment = [
                        SELECT Id,
                                Amount__c,
                                Deposit_Date__c,
                                Encounter__c,
                                Guarantor__c,
                                Method__c,
                                Name,
                                Payment_Id__c,
                                Sirono_ID__c,
                                Id__c

                        FROM Payment__c
                        WHERE Sirono_ID__c = :sironoId
                ];
                return payment;
            } catch (QueryException ex) {
                System.debug('PaymentDao.getPaymentBySironoId: '+ex.getStackTraceString());
                return null;
            }
        }

        return null;
    }
}