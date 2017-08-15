/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * DB functionality for PaymentPlans
 * TODO eventually all the PPlan SOQl & DML should be here & then the PaymentPlanSecurityContext can become in innerclass here
 */
public with sharing class PaymentPlanDao extends AbstractDao {

    /**
      * Return the active payment plan for the given guarantorId, null if there is none
      * @param - String guarantorId  The guarantorId of the plan.
      * @return - Payment_Plan__c The active plan.
     */
    public static Payment_Plan__c getActivePaymentPlan(String guarantorId) {

        if (PaymentPlanSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Payment_Plan__c> plans = [
                SELECT Id, Sirono_ID__c, Active__c, Payment_Plan_Standing__c, Plan_Type__c, NextPaymentDate__c, Installment_Amount__c,
                    Installments_Completed__c, Original_Installment_Count__c
                FROM Payment_Plan__c
                WHERE Active__c = TRUE
                AND Sirono_ID__c != NULL
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
            upsert paymentPlans;
        }
    }

    /**
     * Upsert a single payment plan.
     *
     * @param Payment_Plan__c plan - The plan to upsert.
     */
    public static void upsertPlan(Payment_Plan__c plan) {
        upsertPlans(new List<Payment_Plan__c> { plan });
    }

    /**
     * Get Active Payment Plans.
     *
     * @param Id guarantorId - The contact guarantor id associated with the plan.
     * @return List<Payment_Plan__c> - The List containing Active Paymen_Plan__c objects.
     */
    public static List<Payment_Plan__c> getActivePaymentPlanWithMethod(Id guarantorId) {
        List<Payment_Plan__c> plans = new List<Payment_Plan__c>();

        if (PaymentPlanSecurityContext.GUARANTOR_SELECT.actionAllowed() && PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            plans = [
                SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, Installment_Amount__c, CreatedDate,
                    NextPaymentDate__c, Plan_Type__c, Remaining_Installment_Count__c, Execute_On_Day__c, Sirono_ID__c,
                    Payment_Method__c, Payment_Method__r.Sirono_ID__c, Payment_Method__r.Display_Name__c,
                    Payment_Method__r.Card_Type__c, Payment_Method__r.Last_4__c
                FROM Payment_Plan__c
                WHERE Guarantor__c = :guarantorId AND Active__c = TRUE
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
                    NextPaymentDate__c, Plan_Type__c, Remaining_Installment_Count__c, Execute_On_Day__c, Sirono_ID__c, Guarantor__c,
                    Payment_Method__c, Payment_Method__r.Sirono_ID__c, Payment_Method__r.Display_Name__c,
                    Payment_Method__r.Card_Type__c, Payment_Method__r.Last_4__c
                FROM Payment_Plan__c
                WHERE Id = :planId
            ];
        }
        return plans;
    }

    public static void updateAll(List<Payment_Plan__c> plans) {
        if (PaymentPlanSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            update plans;
        }
    }
}