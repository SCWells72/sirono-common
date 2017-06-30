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

    /**
     * Get a list of payment methods for a Guarantor.
     *
     * @param Id guarantorId - The id associated with the Guarantor contact.
     * @return List<Payment_Method__c> - The payment methods associated with the Guarantor.
     */
    public static List<Payment_Method__c> getPaymentMethods(Id guarantorId) {
        List<Payment_Method__c> paymentMethods = new List<Payment_Method__c>();

        if (PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            paymentMethods = [
                SELECT Id, Account_Number__c, Card_Holder_Name__c, Card_Type__c, Display_Name__c, Expiration_Date__c, ID__c, Last_4__c,
                    Payment_Method_Token__c, Routing_Number__c, Sirono_ID__c, Type__c, Guarantor__c
                FROM Payment_Method__c
                WHERE Guarantor__c = :guarantorId AND Display_Name__c != null
            ];
        }

        return paymentMethods;
    }

    /**
     * Get a list of Payment_Method__c credit cards by id.
     *
     * @param String cardId - The credit card id.
     * @return List<Payment_Method__c> - The cards.
     */
    public static List<Payment_Method__c> getCreditCard(String cardId) {
        List<Payment_Method__c> paymentMethods = new List<Payment_Method__c>();

        if (PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            paymentMethods = [
                SELECT Id, Account_Number__c, Card_Holder_Name__c, Card_Type__c, Display_Name__c, Expiration_Date__c, ID__c, Last_4__c,
                    Payment_Method_Token__c, Routing_Number__c, Sirono_ID__c, Type__c, Guarantor__c
                FROM Payment_Method__c
                WHERE Id = :cardId
            ];
        }
        return paymentMethods;
    }

    /**
     * Get Active Payment Plans.
     *
     * @param Id guarantorId - The contact guarantor id associated with the plan.
     * @return List<Payment_Plan__c> - The List containing Active Paymen_Plan__c objects.
     */
    public static List<Payment_Plan__c> getActivePaymentPlan(Id guarantorId) {
        List<Payment_Plan__c> plans = new List<Payment_Plan__c>();

        if (PaymentPlanSecurityContext.GUARANTOR_SELECT.actionAllowed() && PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            plans = [
                SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, Installment_Amount__c, CreatedDate,
                    NextPaymentDate__c, Plan_Type__c, Remaining_Installment_Count__c, Execute_on_Day__c, Sirono_ID__c,
                    Payment_Method__c, Payment_Method__r.Sirono_ID__c, Payment_Method__r.Display_Name__c,
                    Payment_Method__r.Card_Type__c, Payment_Method__r.Last_4__c
                FROM Payment_Plan__c
                WHERE Guarantor__c = :guarantorId AND Active__c = true
            ];
        }

        return plans;
    }

    /**
     * Get a PaymentPlay by id.
     *
     * @param Id planId - The payment plan Id.
     * @return List<Payment_Plan__c> - The List containing the single payment plan if it was found.
     */
    public static List<Payment_Plan__c> getPaymentPlan(Id planId) {
        List<Payment_Plan__c> plans = new List<Payment_Plan__c>();

        if (PaymentPlanSecurityContext.GUARANTOR_SELECT.actionAllowed() && PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            plans = [
                SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, Installment_Amount__c, CreatedDate,
                    NextPaymentDate__c, Plan_Type__c, Remaining_Installment_Count__c, Execute_on_Day__c, Sirono_ID__c, Guarantor__c,
                    Payment_Method__c, Payment_Method__r.Sirono_ID__c, Payment_Method__r.Display_Name__c,
                    Payment_Method__r.Card_Type__c, Payment_Method__r.Last_4__c
                FROM Payment_Plan__c
                WHERE Id = :planId
            ];
        }
        return plans;
    }
}