/**
 * ChargeGroupService with logic for working with Charge_Group__c object.
 **/

public class ChargeGroupService extends AbstractService {

    /**
     * This method is use to get list of Charge_Group__c objects associated with the given sironoIds.
     *
     * @param List<Decimal> sironoIds - That contains Charge Group's Sirono Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on sironoIds.
     **/
    public static List<Charge_Group__c> getBySironoIds(List<Decimal> sironoIds) {
        return ChargeGroupDao.getBySironoIds(sironoIds);
    }

    /**
     * This method is use to get Billed Charge Groups Count based on Encounter Ids.
     *
     * @param Set<Id> encounterIds - That contains Encounter Ids which are associated in CG(s).
     * @returns List<AggregateResult> - That contains Billed CG Count based on Encounter Ids.
     **/
    public static List<AggregateResult> getBilledCGCountByEncounterIds(Set<Id> encounterIds) {
        return ChargeGroupDao.getBilledCGCountByEncounterIds(encounterIds);
    }

    /**
     * This method is use to get latest created CG record based on Charge Group Ids.
     *
     * @param Set<Id> chargeGroupIds - That contains Charge Group Ids.
     * @returns Charge_Group__c - That contains latest created CG record.
     **/
    public static Charge_Group__c getCGOrderByCreatedDate(Set<Id> chargeGroupIds) {
        return ChargeGroupDao.getCGOrderByCreatedDate(chargeGroupIds);
    }

    /**
     * This method is use to get CG record that have Oldest Date_Of_Service_Start_Date__c based on Charge Group Ids.
     *
     * @param Set<Id> chargeGroupIds - That contains Charge Group Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on setChargeGroupIds and order by Date_Of_Service_Start_Date__c.
     **/
    public static List<Charge_Group__c> getCGOrderByServiceDate(Set<Id> chargeGroupIds) {
        return ChargeGroupDao.getCGOrderByServiceDate(chargeGroupIds);
    }

    /**
     * This method is use to get Charge Group Ids associated with Case_Charge_Group_Junction__c object.
     *
     * @param Id caseId - That contains Case Id.
     * @returns List<String> - That contains CG Ids based on Case_Charge_Group_Junction__c records.
     **/
    public static List<String> getCGIdsFromCaseCGJun(Id caseId) {
        return ChargeGroupDao.getCGIdsFromCaseCGJun(caseId);
    }

    /**
     * This method is use to get Charge_Group__c records associated with the given Guarantor Ids and account status equals to 'Billed'
     *
     * @param Set<Id> guarantorIds - That contains Guarantor Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on setGuarantorIds and account status equals to 'Billed'.
     **/
    public static List<Charge_Group__c> getCGBasedOnGuarantor(Set<Id> guarantorIds) {
        return ChargeGroupDao.getCGBasedOnGuarantor(guarantorIds);
    }

    /**
     * This method is use to get Charge_Group__c records associated with the given Encounter Ids.
     *
     * @param Set<Id> encounterIds - That contains Encounter Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on encounterIds.
     **/
    public static List<Charge_Group__c> getCGBasedOnEncounter(Set<Id> encounterIds) {
        return ChargeGroupDao.getCGBasedOnEncounter(encounterIds);
    }

    /**
     * This method is use to get Charge_Group__c records associated with the given Guarantors and Pre_Collection_Sent__c equals to preCollDate.
     *
     * @param List<Contact> guarantors - That contains list of Contacts.
     * @param Date preCollDate - That contains Pre Collection Date related filter date.
     * @returns List<Charge_Group__c> - That contains CG records based on guarantors and Pre_Collection_Sent__c equals to preCollDate.
     **/
    public static List<Charge_Group__c> getCGBasedOnGuarantorAndPreCollDate(List<Contact> guarantors, Date preCollDate) {
        return ChargeGroupDao.getCGBasedOnGuarantorAndPreCollDate(guarantors, preCollDate);
    }

    /**
     * This method is use to get Charge_Group__c records associated with the given Charge Group Ids.
     *
     * @param Set<Id> chargeGroupIds - That contains Charge Group Ids.
     * @param Boolean hasOrderBy - indicate whether or not to order the cgs by Post_Date__c
     *  only Order By related changes are there so we use this variable and set order by filter.
     * @returns List<Charge_Group__c> - That contains CG records based on Charge Group Ids.
     **/
    public static List<Charge_Group__c> getCGForInvoiceController(Set<Id> chargeGroupIds, Boolean hasOrderBy) {
        return ChargeGroupDao.getCGForInvoiceController(chargeGroupIds, hasOrderBy);
    }

    /**
     * Get Charge_Group__c by the given Invoice Ids.
     *
     * @param Set<Id> invoiceIds - That contains Charge Group Ids.
     * @param Boolean hasOrderBy - indicate whether or not to order the cgs by Post_Date__c
     *  only Order By related changes are there so we use this variable and set order by filter.
     * @returns List<Charge_Group__c> - That contains CG records based on Charge Group Ids.
     **/
    public static List<Charge_Group__c> getPayableByInvoiceId(List<String> invoiceIds) {
        return ChargeGroupDao.getPayableByInvoiceId(new Set<String>(invoiceIds));
    }

    /**
     * This method is use to update Charge Groups.
     *
     * @param List<Charge_Group__c> chargeGroups - That contains CG records.
     **/
    public static void updateChargeGroups(List<Charge_Group__c> chargeGroups) {
        ChargeGroupDao.updateChargeGroups(chargeGroups);
    }

    /**
     * This method is use to update Charge Groups with Account Status.
     *
     * @param List<Charge_Group__c> chargeGroups - That contains CG records.
     **/
    public static void updateChargeGroupsWithStatus(List<Charge_Group__c> chargeGroups) {
        ChargeGroupDao.updateChargeGroupsWithStatus(chargeGroups);
    }
}