/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * DAO for Adjustments
 **/
public with sharing class AdjustmentDao extends AbstractDao {

    public static void save(List<Adjustment__c> adjustments) {
        if (!adjustments.isEmpty()) {
            if (AdjustmentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                insert adjustments;
            }
        }
    }

    public static void updateAll(List<Adjustment__c> adjustments) {

        if (!adjustments.isEmpty()) {
            if (AdjustmentSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                update adjustments;
            }
        }
    }
}