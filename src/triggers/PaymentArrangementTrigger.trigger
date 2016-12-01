/*
* @author Sirono 
* @version 1.0.1
* @date: 08-18-2016
* @PaymentArrangementTrigger used when arrange the payment is created.
*
* Mohan Kumar 08-18-2016: On Create of Payment Arrangement auto close any open Encounter Case existing
*/

trigger PaymentArrangementTrigger on Payment_Arrangement__c (after insert) {

    //invoked after an insert event 
    //PaymentArrangementTriggerHandler.closeEncounterCaseFromPaymentArrangement(trigger.new);
    PaymentArrangementTriggerHandler obj = new PaymentArrangementTriggerHandler();
}