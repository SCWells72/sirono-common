//Mohan Kumar 2016-08-18: On Create of Payment Arrangement auto close any open Encounter Case existing
trigger PaymentArrangementTrigger on Payment_Arrangement__c (after insert) {

    PaymentArrangementTriggerHandler.closeEncounterCaseFromPaymentArrangement(trigger.new);
}