/**
 * Created by swells on 6/26/2017.
 */

trigger StatementTrigger on Statement__c (after insert) {
    StatementTriggerHandler.afterInsert(Trigger.new);
}