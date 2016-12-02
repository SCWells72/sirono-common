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
        
		return Database.getQueryLocator([
                                            Select 
                                                Id,name from Contact
                                            ]);
											
		/*return Database.getQueryLocator([
                Select
                        Id, Guarantor_Name__c, Plan_Type__c,
                        Execute_on_Day__c, NextPaymentDate__c,
                        Skip_Payment_Until__c
                From Test__c
        ]);*/

    }

    //pass the payment plan list to the method.
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        /*PaymentPlanTriggerHandler.populateNextPaymentDate((List<Test__c>) scope, false);*/
    }

    public void finish(Database.BatchableContext bc) {

    }
}