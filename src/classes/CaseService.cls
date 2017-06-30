/**
 * CaseService with logic for working with Case object.
 **/
 
 public with sharing class CaseService extends AbstractService {

    /**
     * Create Case_Charge_Group_Junction__c for the given cases. The chargegroups that the case should
     * be associated with are based on the case type & the chargegroup substatus. Only associate ACTIVE chargegroups
     *
     * @param caseMap - caseMap - Cases grouped by type
     **/
     public static void createCaseCGJunctions(Map<String, List<Case>> caseMap) {

         List<Case_Charge_Group_Junction__c> caseCGJunctions = new List<Case_Charge_Group_Junction__c>();

         for (String caseType : caseMap.keySet()) {
             Set<Id> contactIds = collectGuarantorIds(caseMap.get(caseType));

             Map<Id, List<Charge_Group__c>> chargeGroups = new Map<Id, List<Charge_Group__c>>();

             for (Charge_Group__c cg: ChargeGroupDao.getByGuarantorAndSubStatus(contactIds, new Set<String>{Constants.CASE_CG_SUBSTATUS.get(caseType)})) {
                 if (chargeGroups.containsKey(cg.Guarantor__c)) {
                     chargeGroups.get(cg.Guarantor__c).add(cg);
                 } else {
                     chargeGroups.put(cg.Guarantor__c, new List<Charge_Group__c>{cg});
                 }
             }

             for (Case objCase: caseMap.get(caseType)) {
                 if (chargeGroups.containsKey(objCase.Guarantor_Information__c)) {
                     for (Charge_Group__c cg: chargeGroups.get(objCase.Guarantor_Information__c)) {
                         if (Constants.CASE_CG_SUBSTATUS.get(objCase.Type).equalsIgnoreCase(cg.Account_Sub_Status__c)) {
                             caseCGJunctions.add(new Case_Charge_Group_Junction__c(Case__c = objCase.Id, Charge_Group__c = cg.Id));
                         }
                     }
                 }
             }
         }

         if (caseCGJunctions.size() > 0) {
            CaseDao.insertCaseChargeGroupJunctions(caseCGJunctions);
         }
     }

     /**
      * Given a list of cases, return a set of the guarantor Id's associated with them
      * @param cases the list of cases
      * @returns the unique guarantorIds associated with these cases
      */
     private static Set<Id> collectGuarantorIds(List<Case> cases) {
         Set<Id> gtIds = new Set<Id>();
         for (Case caseObj : cases) {
             if (caseObj.Guarantor_Information__c != null) {
                 gtIds.add(caseObj.Guarantor_Information__c);
             }
         }
         return gtIds;
     }
 }