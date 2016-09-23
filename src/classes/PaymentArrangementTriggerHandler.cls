//Mohan Kumar 2016-08-18: On Create of Payment Arrangement auto close any open Encounter Case existing
public with sharing class PaymentArrangementTriggerHandler {

    public static void closeEncounterCaseFromPaymentArrangement(List<Payment_Arrangement__c> newList) {
        Set<Id> encounterIds = new Set<Id>();
        for (Payment_Arrangement__c pa : newList) {
            if (pa.Encounter__c != null) encounterIds.add(pa.Encounter__c);
        }
        List<Encounter__c> encounterList = [
                Select Id, Cancelled__c, Date_of_Service__c, Patient_Portion__c, Guarantor__c
                From Encounter__c
                Where Id IN :encounterIds
        ];
        CaseUtil.CallCloseEncounterAutoCase(encounterList, true);
    }
}