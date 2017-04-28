/**
 * DB functionality for PaymentPlans
 * TODO eventually all the PPlan SOQl & DML should be here & then the PaymentPlanSecurityContext can become in innerclass here
 */

public with sharing class PaymentPlanDao extends AbstractDao{

    /**
      * Return the active payment plan for the given guarantorId, null if there is none
      * @param - String guarantorId  The guarantorId of the plan.
      * @return - Payment_Plan__c The active plan.
     */
    public static Payment_Plan__c getActivePaymentPlan(String guarantorId) {

        if (PaymentPlanSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Payment_Plan__c> plans = [
                    SELECT Id, Sirono_ID__c, Active__c
                    FROM Payment_Plan__c
                    WHERE Active__c = true
                    AND Sirono_ID__c != null
                    AND Guarantor__c = :guarantorId
                    LIMIT 1
            ];

            if (plans.size() > 0) {
                return plans.get(0);
            }
        }

        return null;
    }

    /**
     * Return the Payment_Plan__c with the given Sirono_ID__c
     * @param - String sirionoId The sironoId of the plan
     * @return Payment_Plan__c The requested plan
     */
    public static Payment_Plan__c getPaymentPlanBySironoId(String sironoId) {
        return getPaymentPlanBySironoId(Decimal.valueOf(sironoId));
    }

    /**
     * Return the Payment_Plan__c with the given Sirono_ID__c
     * @param - Decimal sironoId The sironoId of the plan
     * @return Payment_Plan__c The requested plan
     */
    public static Payment_Plan__c getPaymentPlanBySironoId(Decimal sironoId) {

        if (PaymentPlanSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Payment_Plan__c> plans = [
                    SELECT Id, Sirono_ID__c, Active__c
                    FROM Payment_Plan__c
                    WHERE Sirono_ID__c = :sironoId
                    LIMIT 1
            ];

            if (plans.size() > 0) {
                return plans.get(0);
            }
        }

        return null;
    }

    /**
     * Upsert the given list of Payment_Plan__c objects
     * @param - Payment_Plan__c the plans to be upserted
     */
    public static void upsertPlans(List<Payment_Plan__c> paymentPlans) {
        if (PaymentPlanSecurityContext.UPSERT_CONTEXT.actionAllowed()) {
            UPSERT paymentPlans;
        }
    }
}