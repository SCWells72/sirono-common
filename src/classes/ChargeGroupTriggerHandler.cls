/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-25-2016
* @description  ChargeGroupTrigger Handler Clas  
*/
//TODO remove without sharing
public without sharing class ChargeGroupTriggerHandler {
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
        Set<Id> paymentPlanIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> encounterIds = new Set<Id>();

        for (Charge_Group__c cg : newList) {
            //If this chargegroup is associated with a paymentPlan, calc the pp balance
            if (cg.Payment_Plan__c != null) {
                paymentPlanIds.add(cg.Payment_Plan__c);
            }

            // If the charge group is associated with an invoice, update the invoice status
            if (cg.Invoice__c != null) {
                invoiceIds.add(cg.Invoice__c);
            }

            if (cg.Encounter__c != null) {
                encounterIds.add(cg.Encounter__c);
            }
        }

        if (paymentPlanIds.size() > 0) {
            Map<Id, Payment_Plan__c> plansToUpdate = PaymentPlanUtil.setBalanceAndCharges(paymentPlanIds);
            if (plansToUpdate.size() > 0) {
                if (PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT.actionAllowed()) {
		    UPDATE plansToUpdate.values();
		}
            }
        }

        if (invoiceIds.size() > 0) {
            InvoiceUtil.updateInvoiceStatusIndex(invoiceIds);
            InvoiceUtil.updateInvoiceBalances(invoiceIds);
            InvoiceUtil.updateAllSubstatusInvoiceField(invoiceIds);
        }

        if(encounterIds.size() > 0) {
            EncounterUtil.setHasChargeGroup(encounterIds);
            EncounterUtil.setBilledCGCount(encounterIds);
        }
    }

    //Static Method that gets invoked after an update event on Charge_Group__c records
    public static void afterUpdate(List<Charge_Group__c> newList, Map<Id, Charge_Group__c> oldMap) {

        //CODE FOR CALL LIST - REMOVE
        Set<ID> contactIds = new Set<ID>();
        //Collect Ids of the PaymentPlans to recalc their balances
        Set<Id> paymentPlanIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> encounterIds = new Set<Id>();
        Set<Id> encounterIdsForCGCount = new Set<Id>();

        for (Charge_Group__c cg : newList) {
            if (cg.Pre_Collection_Sent__c == null && cg.Guarantor__c != null
                    && (oldMap == null || cg.Pre_Collection_Sent__c != oldMap.get(cg.Id).Pre_Collection_Sent__c
                    || cg.Guarantor__c != oldMap.get(cg.Id).Guarantor__c)) {
                contactIds.add(cg.Guarantor__c);
            }

            //If this chargegroup was/is associated with a paymentPlan, recalc the new/old pp balances
            if (cg.Payment_Plan__c != null) {
                paymentPlanIds.add(cg.Payment_Plan__c);
            }
            if (oldMap.get(cg.Id).Payment_Plan__c != null) {
                paymentPlanIds.add(oldMap.get(cg.Id).Payment_Plan__c);
            }

            // If the charge group is associated with an invoice, calculate fields related to the invoice
            if (cg.Invoice__c != null) {
                invoiceIds.add(cg.Invoice__c);
            }
            if (oldMap.get(cg.Id).Invoice__c != null) {
                invoiceIds.add(oldMap.get(cg.Id).Invoice__c);
            }

            // If the Charge_Group is associated with an Encounter, update the Encounter Has_Chargegroup flag
            if (cg.Encounter__c != null) {
                if (oldMap.get(cg.Id).Encounter__c != null) {
                    if (cg.Encounter__c != oldMap.get(cg.Id).Encounter__c) {
                        encounterIds.add(cg.Encounter__c);
                        encounterIds.add(oldMap.get(cg.Id).Encounter__c);

                        encounterIdsForCGCount.add(cg.Encounter__c);
                        encounterIdsForCGCount.add(oldMap.get(cg.Id).Encounter__c);
                    } else {
                        encounterIdsForCGCount.add(cg.Encounter__c);
                    }
                } else {
                    encounterIds.add(cg.Encounter__c);
                    encounterIdsForCGCount.add(cg.Encounter__c);
                }
            } else {
                if (oldMap.get(cg.Id).Encounter__c != null) {
                    encounterIds.add(oldMap.get(cg.Id).Encounter__c);
                    encounterIdsForCGCount.add(oldMap.get(cg.Id).Encounter__c);
                }
            }


        }

        if (contactIds.size() > 0) {
            CallListUtilities.PreCollectionCallListRemoval(contactIds);
        }

        if (paymentPlanIds.size() > 0) {
            Map<Id, Payment_Plan__c> plansToUpdate = PaymentPlanUtil.setBalanceAndCharges(paymentPlanIds);
            if (plansToUpdate.size() > 0) {
                if (PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT.actionAllowed()) {
		    UPDATE plansToUpdate.values();
		}
            }
        }

        if(invoiceIds.size() > 0){
            InvoiceUtil.updateInvoiceStatusIndex(invoiceIds);
            InvoiceUtil.updateInvoiceBalances(invoiceIds);
            InvoiceUtil.updateAllSubstatusInvoiceField(invoiceIds);
        }

        if (encounterIds.size() > 0) {
            EncounterUtil.setHasChargeGroup(encounterIds);
        }

        if (encounterIdsForCGCount.size() > 0) {
            EncounterUtil.setBilledCGCount(encounterIdsForCGCount);
        }
    }

    //Static Method that gets invoked after a delete event on Charge_Group__c records
    public static void afterDelete(List<Charge_Group__c> oldList) {
        Set<Id> paymentPlanIds = new Set<ID>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> encounterIds = new Set<Id>();

        for (Charge_Group__c cg : oldList) {
            //If this chargegroup was associated with a paymentPlan, recalc the pp balance
            if (cg.Payment_Plan__c != null) {
                paymentPlanIds.add(cg.Payment_Plan__c);
            }

            // If the charge group is associated with an invoice, update the invoice status
            if (cg.Invoice__c != null) {
                invoiceIds.add(cg.Invoice__c);
            }

            if (cg.Encounter__c != null) {
                encounterIds.add(cg.Encounter__c);
            }
        }

        if(invoiceIds.size() > 0){
            InvoiceUtil.updateInvoiceStatusIndex(invoiceIds);
            InvoiceUtil.updateInvoiceBalances(invoiceIds);
            InvoiceUtil.updateAllSubstatusInvoiceField(invoiceIds);
        }

        if (encounterIds.size() > 0) {
            EncounterUtil.setHasChargeGroup(encounterIds);
            EncounterUtil.setBilledCGCount(encounterIds);
        }

        if (paymentPlanIds.size() > 0){
            Map<Id, Payment_Plan__c> plansToUpdate = PaymentPlanUtil.setBalanceAndCharges(paymentPlanIds);
            if (plansToUpdate.size() > 0) {
                if (PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT.actionAllowed()) {
		    UPDATE plansToUpdate.values();
		}
            }
        }
    }
}