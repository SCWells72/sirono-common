/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class PopulateNextPaymentDateBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PopulateNextPaymentDateBatch(), 1000);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (PaymentPlanSecurityContext.CTH_SELECT_CONTEXT.actionAllowed()) {
            return Database.getQueryLocator([
                SELECT
                    Id, Guarantor__c, Plan_Type__c,
                    Execute_on_Day__c, NextPaymentDate__c,
                    Skip_Payment_Until__c
                FROM Payment_Plan__c
                WHERE Guarantor__c != NULL
            ]);
        }
        return null;
    }

    //pass the payment plan list to the method.
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        PaymentPlanTriggerHandler.populateNextPaymentDate((List<Payment_Plan__c>) scope, false);
    }

    public void finish(Database.BatchableContext bc) {

    }
}