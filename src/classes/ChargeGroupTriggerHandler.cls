/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-25-2016
* @description  ChargeGroupTrigger Handler Clas  
*/
public with sharing class ChargeGroupTriggerHandler {
    private static Boolean isTriggerProcessed;

    //Static Method that returns a boolean member variable
    public static Boolean getIsTriggerProcessed() {
        if (isTriggerProcessed == null) {
            isTriggerProcessed = false;
        }
        return isTriggerProcessed;
    }

    //Static Method that sets a boolean member variable
    public static void setIsTriggerProcessed(Boolean flag) {
        isTriggerProcessed = flag;
    }

    //Static Method that gets invoked after an insert event on Charge_Group__c records
    public static void afterInsert(List<Charge_Group__c> newList) {
        Set<Id> planIds = new Set<Id>();

        for (Charge_Group__c cg : newList) {
            //If this chargegroup is associated with a paymentPlan, calc the pp balance
            if (cg.Payment_Plan__c != null) {
                planIds.add(cg.Payment_Plan__c);
            }
        }

        if (planIds.size() > 0) {
            PaymentPlanUtil.updateBalances(planIds);
        }
    }

    //Static Method that gets invoked after an update event on Charge_Group__c records
    public static void afterUpdate(List<Charge_Group__c> newList, Map<Id, Charge_Group__c> oldMap) {

        //CODE FOR CALL LIST - REMOVE
        Set<ID> contactIds = new Set<ID>();
        //Collect Ids of the PaymentPlans to recalc their balances
        Set<Id> planIds = new Set<Id>();

        for (Charge_Group__c cg : newList) {
            if (cg.Pre_Collection_Sent__c == null && cg.Guarantor__c != null
                    && (oldMap == null || cg.Pre_Collection_Sent__c != oldMap.get(cg.Id).Pre_Collection_Sent__c
                    || cg.Guarantor__c != oldMap.get(cg.Id).Guarantor__c)) {
                contactIds.add(cg.Guarantor__c);
            }

            //If this chargegroup was/is associated with a paymentPlan, recalc the new/old pp balances
            if (cg.Payment_Plan__c != null) {
                planIds.add(cg.Payment_Plan__c);
            }
            if (oldMap.get(cg.Id).Payment_Plan__c != null) {
                planIds.add(oldMap.get(cg.Id).Payment_Plan__c);
            }
        }

        if (contactIds.size() > 0) {
            CallListUtilities.PreCollectionCallListRemoval(contactIds);
        }

        if (planIds.size() > 0) {
            PaymentPlanUtil.updateBalances(planIds);
        }
    }

    //Static Method that gets invoked after a delete event on Charge_Group__c records
    public static void afterDelete(List<Charge_Group__c> oldList) {
        Set<ID> paymentPlanIds = new Set<ID>();

        for (Charge_Group__c cg : oldList) {
            //If this chargegroup was associated with a paymentPlan, recalc the pp balance
            if (cg.Payment_Plan__c != null) {
                paymentPlanIds.add(cg.Payment_Plan__c);
            }
        }

        PaymentPlanUtil.updateBalances(paymentPlanIds);
    }
}