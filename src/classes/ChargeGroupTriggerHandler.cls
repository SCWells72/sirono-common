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
                if (cg.Account_Status__c == Constants.ACCT_STATUS_BILLED) {
                    encounterIds.add(cg.Encounter__c);
                }
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

        if (encounterIds.size() > 0) {
            EncounterUtil.setBilledCGCount(encounterIds);
        }
    }

    //Static Method that gets invoked after an update event on Charge_Group__c records
    public static void afterUpdate(List<Charge_Group__c> newList, Map<Id, Charge_Group__c> oldMap) {

        //CODE FOR CALL LIST - REMOVE
        Set<ID> contactIds = new Set<Id>();
        //Collect Ids of the PaymentPlans to recalc their balances
        Set<Id> paymentPlanIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> encounterIds = new Set<Id>();

        for (Charge_Group__c cg : newList) {
            Charge_Group__c oldCG = oldMap.get(cg.Id);

            if (cg.Pre_Collection_Sent__c == null && cg.Guarantor__c != null
                    && (oldMap == null || cg.Pre_Collection_Sent__c != oldCG.Pre_Collection_Sent__c
                    || cg.Guarantor__c != oldCG.Guarantor__c)) {
                contactIds.add(cg.Guarantor__c);
            }

            //If this chargegroup was/is associated with a paymentPlan, recalc the new/old pp balances
            if (cg.Payment_Plan__c != null) {
                paymentPlanIds.add(cg.Payment_Plan__c);
            }
            if (oldCG.Payment_Plan__c != null) {
                paymentPlanIds.add(oldCG.Payment_Plan__c);
            }

            // If the charge group is associated with an invoice, calculate fields related to the invoice
            if (cg.Invoice__c != null) {
                invoiceIds.add(cg.Invoice__c);
            }
            if (oldCG.Invoice__c != null) {
                invoiceIds.add(oldCG.Invoice__c);
            }

            // If the Charge_Group is associated with an Encounter.
            if (cg.Encounter__c != null) {
                //Both have an encounter
                if (oldCG.Encounter__c != null) {
                    //Did the encounter change?
                    if (cg.Encounter__c != oldCG.Encounter__c) {
                        //Add any that are billed
                        if (cg.Account_Status__c == Constants.ACCT_STATUS_BILLED){
                            encounterIds.add(cg.Encounter__c);
                        }
                        if (oldCG.Account_Status__c == Constants.ACCT_STATUS_BILLED) {
                            encounterIds.add(oldCG.Encounter__c);
                        }
                    } else {
                        //Same encounter, but did the cg status change? And was one BILLED?
                        if (cg.Account_Status__c != oldCG.Account_Status__c &&
                                (cg.Account_Status__c == Constants.ACCT_STATUS_BILLED || oldCG.Account_Status__c == Constants.ACCT_STATUS_BILLED)) {
                            encounterIds.add(cg.Encounter__c);
                        }
                    }
                } else {
                    //Old cg had no encounter - is the new cg billed?
                    if (cg.Account_Status__c == Constants.ACCT_STATUS_BILLED) {
                        encounterIds.add(cg.Encounter__c);
                    }
                }
            } else {
                //New cg is NOT associated with an encounter
                if (oldCG.Encounter__c != null && oldCG.Account_Status__c == Constants.ACCT_STATUS_BILLED) {
                        encounterIds.add(oldCG.Encounter__c);
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

        if (invoiceIds.size() > 0) {
            InvoiceUtil.updateInvoiceStatusIndex(invoiceIds);
            InvoiceUtil.updateInvoiceBalances(invoiceIds);
            InvoiceUtil.updateAllSubstatusInvoiceField(invoiceIds);
        }

        if (encounterIds.size() > 0) {
            EncounterUtil.setBilledCGCount(encounterIds);
        }
    }

    //Static Method that gets invoked after a delete event on Charge_Group__c records
    public static void afterDelete(List<Charge_Group__c> oldList) {
        Set<Id> paymentPlanIds = new Set<ID>();
        Set<Id> invoiceIds = new Set<Id>();
        Set<Id> encounterIdsForBilledCount = new Set<Id>();

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
                if (cg.Account_Status__c == Constants.ACCT_STATUS_BILLED) {
                    encounterIdsForBilledCount.add(cg.Encounter__c);
                }
            }
        }

        if (invoiceIds.size() > 0) {
            InvoiceUtil.updateInvoiceStatusIndex(invoiceIds);
            InvoiceUtil.updateInvoiceBalances(invoiceIds);
            InvoiceUtil.updateAllSubstatusInvoiceField(invoiceIds);
        }

        if (encounterIdsForBilledCount.size() > 0) {
            EncounterUtil.setBilledCGCount(encounterIdsForBilledCount);
        }

        if (paymentPlanIds.size() > 0) {
            Map<Id, Payment_Plan__c> plansToUpdate = PaymentPlanUtil.setBalanceAndCharges(paymentPlanIds);
            if (plansToUpdate.size() > 0) {
                if (PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT.actionAllowed()) {
                    UPDATE plansToUpdate.values();
                }
            }
        }
    }
}