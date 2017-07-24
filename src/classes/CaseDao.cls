/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * DAO for Case and Case-related SOQL/DML
 */
public with sharing class CaseDao {

    public without sharing class ElevatedPrivilegesHelper {

        public void save(List<Case> cases) {
            INSERT cases;
        }
    }

    public static void insertCaseChargeGroupJunctions(List<Case_Charge_Group_Junction__c> junctions) {
        if (CaseCGJunctionSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT junctions;
        }
    }

}