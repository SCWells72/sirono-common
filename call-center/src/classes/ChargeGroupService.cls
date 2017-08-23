/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * ChargeGroupService with logic for working with Charge_Group__c object.
 **/
global with sharing class ChargeGroupService extends AbstractService {

    private class ChargeGroupRestClient extends SironoRestClient {

        /**
         * Provides the URL map to the HttpSirono class for looking up urls.
         */
        @TestVisible
        private Map<String, String> getUrls() {
            return RestClientConstants.CHARGE_GROUP_URLS;
        }

        /**
         * Make the call to get a Charge Group.
         *
         * @param String chargeGroupId - The charge group Sirono id.
         * @return HttpResponse - The response from the service.
         */
        private HttpResponse getChargeGroup(String chargeGroupId) {
            return getRequestor()
                .url(RestClientConstants.CHARGEGROUP_KEY, new String[] { chargeGroupId })
                .call();
        }
    }

    /**
     * This method is used to get list of Charge_Group__c objects associated with the given sironoIds.
     *
     * @param List<Decimal> sironoIds - That contains Charge Group's Sirono Ids.
     * @returns List<Charge_Group__c> - That contains CG records based on sironoIds.
     **/
    public static List<Charge_Group__c> getBySironoIds(List<Decimal> sironoIds) {
        return ChargeGroupDao.getBySironoIds(sironoIds);
    }

    /**
     * Get a ChargeGroupJSONParser that results from a call to the Sirono server.
     *
     * @param String cgSironoId - The Sirono Id of the charge group.
     * @return ChargeGroupJSONParser - The parse respose from the server.
     */
    public static ChargeGroupJSONParser.ChargeGroupJSON retrieveBySironoId(String cgSironoId) {
        ChargeGroupRestClient client = new ChargeGroupRestClient();
        HttpResponse res = client.getChargeGroup(cgSironoId);
        ChargeGroupJSONParser.ChargeGroupJSON parsing = ChargeGroupJSONParser.parse(res.getBody());

        return parsing;
    }

    /**
     * Get a Map where the keys are the Sirono Id and the values are the parse responses from the Sirono server.
     *
     * @param List<Decimal> sironoChargeGroupIds - A list of Sirono Charge Group Ids.
     * @return Map<Decimal, ChargeGroupJSONParser> - The map of results.
     */
    public static Map<Decimal, ChargeGroupJSONParser.ChargeGroupJSON> retrieveMapByIds(List<Decimal> sironoChargeGroupIds) {
        Map<Decimal, ChargeGroupJSONParser.ChargeGroupJSON> idMap = new Map<Decimal, ChargeGroupJSONParser.ChargeGroupJSON>();

        for (Decimal cgId : sironoChargeGroupIds) {
            ChargeGroupJSONParser.ChargeGroupJSON parsing = retrieveBySironoId(String.valueOf(cgId));
            idMap.put(cgId, parsing);
        }

        return idMap;
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
    global static List<Charge_Group__c> getCGForInvoiceController(Set<Id> chargeGroupIds, Boolean hasOrderBy) {
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
    global static List<Charge_Group__c> getPayableByInvoiceId(List<String> invoiceIds) {
        return ChargeGroupDao.getPayableByInvoiceId(new Set<String>(invoiceIds));
    }

    /**
     * Update Charge Groups.
     *
     * @param List<Charge_Group__c> chargeGroups - That contains CG records.
     **/
    public static void updateChargeGroups(List<Charge_Group__c> chargeGroups) {
        ChargeGroupDao.updateChargeGroups(chargeGroups);
    }

    /**
     * Get a list of sirono ids for a List of charge groups.
     *
     * @param List<Charge_Group__c> cgs - The list of charge groups.
     * @return List<Decimal> - The list of Sirono ids.
     */
    public static List<Decimal> getSironoIds(List<Charge_Group__c> cgs) {
        List<Decimal> ids = new List<Decimal>();
        for (Charge_Group__c cg : cgs) {
            ids.add(cg.Sirono_Id__c);
        }

        return ids;
    }
}