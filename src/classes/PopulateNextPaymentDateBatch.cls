/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-26-2016
 * @PopulateNextPaymentDateBatch  class.
 * #127404425 : Viraj Rana This batch is used to populate the next payment date
*/


public with sharing class PopulateNextPaymentDateBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

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
                    WHERE Guarantor__c != null
            ]);
        }
        return null;
    }

    //pass the payment plan list to the method.
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        PaymentPlanTriggerHandler.populateNextPaymentDate((List<Payment_Plan__c>) scope, false);
    }

    public void finish(Database.BatchableContext bc) {

    }
}