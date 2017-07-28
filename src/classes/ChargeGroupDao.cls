/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Database actions for Charge_Group__c objects
 * TODO: fix our sharing model
 */
public with sharing class ChargeGroupDao extends AbstractDao {

    /**
     * Return the list of Charge_Group__c objects associated with the given sironoIds
     *
     * @param List<Decimal> sironoIds - That contains Charge Group's Sirono Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on sironoIds.
     **/
    public static List<Charge_Group__c> getBySironoIds(List<Decimal> sironoIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, Sirono_ID__c, Account_Sub_Status__c,
                        Payment_Plan__c, Payment_Plan__r.Sirono_ID__c, Payment_Plan__r.Guarantor__c
                    FROM Charge_Group__c
                    WHERE Sirono_ID__c IN :sironoIds
            ];
        }

        return null;
    }

    /**
     * This method is use to get Billed Charge Groups Count based on Encounter Ids.
     *
     * @param Set<Id> encounterIds - That contains Encounter Ids which are associated in CG(s).
     * @returns List<AggregateResult> - That contains Billed CG Count based on Encounter Ids.
     **/
    public static List<AggregateResult> getBilledCGCountByEncounterIds(Set<Id> encounterIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Encounter__r.Id encounterId, COUNT(Encounter__c) Total
                    FROM Charge_Group__c
                    WHERE Account_Status__c = :Constants.ACCT_STATUS_BILLED
                    AND Encounter__c IN :encounterIds
                    GROUP BY Encounter__r.Id
            ];
        }

        return null;
    }

    /**
     * Return the Charge_Group__c object associated with the given Charge Group Ids.
     *
     * @param Set<Id> chargeGroupIds - That contains Charge Group Ids.
     * @returns Charge_Group__c - That contains latest created CG record.
     **/
    public static Charge_Group__c getCGOrderByCreatedDate(Set<Id> chargeGroupIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Charge_Group__c> chargeGroups = [
                        SELECT Id, Guarantor__c, Patient__c
                        FROM Charge_Group__c
                        WHERE Id IN :chargeGroupIds
                        ORDER BY CreatedDate DESC
            ];
            if (chargeGroups.size() > 0) {
                return chargeGroups.get(0);
            }
        }
        return null;
    }

    /**
     * Return the Charge_Group__c object associated with the given Charge Group Ids.
     *
     * @param Set<Id> chargeGroupIds - That contains Charge Group Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on chargeGroupIds and order by Date_Of_Service_Start_Date__c.
     **/
    public static List<Charge_Group__c> getCGOrderByServiceDate(Set<Id> chargeGroupIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id
                    FROM Charge_Group__c
                    WHERE Id IN :chargeGroupIds
                    ORDER BY Date_Of_Service_Start_Date__c
            ];
        }
        return null;
    }

    /**
     * Return the Charge Group Ids associated with Case_Charge_Group_Junction__c object.
     *
     * @param Id caseId - That contains Case Id.
     * @returns List<String> - That contains CG Ids based on Case_Charge_Group_Junction__c records.
     **/
    public static List<String> getCGIdsFromCaseCGJun(Id caseId) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                CaseCGJunctionSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<String> chargeGroupIds = new List<String>();
            for (Charge_Group__c cg: [SELECT Id, Sirono_ID__c
                            FROM Charge_Group__c
                            WHERE Id IN (SELECT Charge_Group__c
                                FROM Case_Charge_Group_Junction__c
                                WHERE Case__c = :caseId)
            ]) {
                if (cg != null) {
                    chargeGroupIds.add(cg.Sirono_ID__c + '');
                }
            }
            return chargeGroupIds;
        }
        return null;
    }

    /**
     * Return the Charge_Group__c records associated with the given Guarantor Ids and account status equals to 'Billed'.
     *
     * @param Set<Id> guarantorIds - That contains Guarantor Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on guarantorIds and account status equals to 'Billed'.
     **/
    public static List<Charge_Group__c> getCGBasedOnGuarantor(Set<Id> guarantorIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, Guarantor__c, Account_Sub_Status__c
                    FROM Charge_Group__c
                    WHERE Account_Status__c = :Constants.ACCT_STATUS_BILLED
                    AND Guarantor__c = :guarantorIds
            ];
        }
        return null;
    }

    /**
     * Return the Charge_Group__c records associated with the given Encounter Ids.
     *
     * @param Set<Id> encounterIds - That contains Encounter Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on encounterIds.
     **/
    public static List<Charge_Group__c> getCGBasedOnEncounter(Set<Id> encounterIds) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, Encounter__c
                    FROM Charge_Group__c
                    WHERE Encounter__c IN :encounterIds
                    AND Encounter__c != null
            ];
        }
        return null;
    }

    /**
     * Get the list of charge groups assoicated with a particualar payment plan.
     *
     * @param Id planId - The payment plan id.
     * @return List<Charge_Group__c> - Any change groups that are assoicated with the payment plan.
     */
    public static List<Charge_Group__c> getCGForPaymentPlan(Id planId) {
        List<Charge_Group__c> cgs = new List<Charge_Group__c>();
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            cgs = [
                SELECT Id, Sirono_ID__c
                FROM Charge_Group__c
                WHERE Payment_Plan__c = :planId
            ];

        }
        return cgs;
    }

    /**
     * Return the Charge_Group__c records associated with the given Invoices.
     *
     * @param Set<Id> invoiceIds - the Invoice ids.
     * @returns List<Charge_Group__c> - the CG records based on invoiceIds.
     **/
    public static List<Charge_Group__c> getPayableByInvoiceId(Set<String> invoiceIds) {
        if (ChargeGroupSecurityContext.IU_SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, Invoice__c, Balance__c, Active__c, Sirono_ID__c
                    FROM Charge_Group__c
                    WHERE Invoice__c IN :invoiceIds
                    AND Active__c = True
                    AND Balance__c != 0
            ];
        }
        return null;
    }

    /**
     * Return the Charge_Group__c records associated with the given Guarantors and Pre_Collection_Sent__c equals to preCollDate.
     *
     * @param List<Contact> guarantors - That contains list of Contacts.
     * @param Date preCollDate - That contains Pre Collection Date related filter date.
     * @returns List<Charge_Group__c> - That contains CG records based on guarantors and Pre_Collection_Sent__c equals to preCollDate.
     **/
    public static List<Charge_Group__c> getCGBasedOnGuarantorAndPreCollDate(List<Contact> guarantors, Date preCollDate) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, Name, Guarantor__c, Pre_Collection_Sent__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Delinquent_Balance__c
                    FROM Charge_Group__c
                    WHERE Guarantor__c IN :guarantors AND Pre_Collection_Sent__c = :preCollDate
            ];
        }
        return null;
    }

    /**
     * Return the Charge_Group__c records associated with the given Charge Group Ids.
     *
     * @param Set<Id> chargeGroupIds - That contains Charge Group Ids.
     * @param Boolean hasOrderBy - indicates whether or not to order by Post_Date__c
     *  only Order By related changes are there so we use this variable and set order by filter.
     * @returns List<Charge_Group__c> - That contains CG records based on Charge Group Ids.
     **/
	//TODO can both uses of this method work with the cgs ordered?
    public static List<Charge_Group__c> getCGForInvoiceController(Set<Id> chargeGroupIds, Boolean hasOrderBy) {
        String queryString = 'SELECT Id, Name, Balance__c, Active__c, Sirono_ID__c, Location__c, Location__r.Name, Provider__r.Name, Account_Type__c, ';
        queryString += 'External_ID__c, Payment_Plan__c, Payment_Plan__r.Active__c, Payment_Plan__r.Installment_Amount__c, Payment_Plan__r.NextPaymentDate__c, ';
        queryString += 'Sirono_Assigned_Date__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c, ';
            queryString += '(';
                queryString += 'SELECT Adjustment__r.Custom_Name__c, Payment__r.Display_Name__c, Service__r.Display_Name__c, ';
                queryString += 'Amount__c, Txn_Method__c ';
                queryString += 'FROM Transactions__r ';
                queryString += (hasOrderBy) ? 'ORDER BY Post_Date__c' : '';
            queryString += '), ';
            queryString += '(';
                queryString += 'SELECT Id, Name, Coverage__r.Payor__r.Name ';
                queryString += 'FROM Charge_Group_Coverages__r';
            queryString += ') ';
        queryString += 'FROM Charge_Group__c ';
        queryString += 'WHERE Id IN :chargeGroupIds ';
        queryString += (hasOrderBy) ? 'ORDER BY CreatedDate' : '';

        return Database.query(queryString);
    }

    /**
     * Return the Charge_Group__c records associated with the given Guarantor Ids and cgSubStatuses.
     *
     * @param Set<Id> guarantorIds - That contains Guarantor Ids.
     * @param Set<String> cgSubStatuses - That contains CG Sub Statuses.
     * @returns List<Charge_Group__c> - That contains CG records based on guarantorIds and cgSubStatuses.
     **/
    public static List<Charge_Group__c> getByGuarantorAndSubStatus(Set<Id> guarantorIds, Set<String> cgSubStatuses) {
        if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            return [
                    SELECT Id, Guarantor__c, Account_Sub_Status__c
                    FROM Charge_Group__c
                    WHERE Account_Sub_Status__c IN :cgSubStatuses
                    AND Active__c = TRUE
                    AND Guarantor__c IN :guarantorIds
            ];
        }
        return null;
    }

    /**
     * This method is use to update Charge Groups.
     *
     * @param List<Charge_Group__c> chargeGroups - That contains CG records.
     **/
    public static void updateChargeGroups(List<Charge_Group__c> chargeGroups) {
        if (ChargeGroupSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            UPDATE chargeGroups;
        }
    }

    /**
     * This method is use to update Charge Groups with Account Status.
     *
     * @param List<Charge_Group__c> chargeGroups - That contains CG records.
     **/
    public static void updateChargeGroupsWithStatus(List<Charge_Group__c> chargeGroups) {
        if (ChargeGroupSecurityContext.UPDATE_WITH_STATUS_CONTEXT.actionAllowed()) {
            UPDATE chargeGroups;
        }
    }
}