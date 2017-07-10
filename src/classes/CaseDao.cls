/**
 * DAO for Case and Case-related SOQL/DML
 */

public with sharing class CaseDao {

    public static void insertCaseChargeGroupJunctions(List<Case_Charge_Group_Junction__c> junctions) {
        if (CaseCGJunctionSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT junctions;
        }
    }

}