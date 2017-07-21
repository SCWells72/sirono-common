/**
 * Created by swells on 6/26/2017.
 */

public with sharing class StatementTriggerHandler {
    public static void afterInsert(List<Statement__c> statements) {
        checkOverdueBalance(statements);
        checkDelinquentBalance(statements);
    }

    private static void checkOverdueBalance(List<Statement__c> statements) {
        // Only if we're configured to auto-create overdue cases
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();
        if (!sironoCallCenterSettings.Auto_Create_Overdue_Cases__c) {
            return;
        }

        // Group for efficiency
        Set<Id> guarantorIds = new Set<Id>();
        for (Statement__c statement : statements) {
            guarantorIds.add(statement.Guarantor__c);
        }

        if (!guarantorIds.isEmpty()) {
            if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                List<Contact> guarantors = [
                    SELECT Id, Overdue_Balance__c
                    FROM Contact
                    WHERE Id IN :guarantorIds
                    AND Overdue_Balance__c > 0.0
                ];

                List<Case> overdueBalanceCases = new List<Case>();
                for (Contact guarantor : guarantors) {
                    Case overdueBalanceCase = new Case(
                        ContactId = guarantor.Id,
                        Guarantor_Information__c = guarantor.Id,
                        RecordTypeId = RecordTypeUtil.automatedCaseRt,
                        Status = Constants.CASE_STATUS_NEW,
                        Subject = Constants.CASE_SUBJECT_GUARANTOR_OVERDUE,
                        Type = Constants.CASE_TYPE_OVERDUE
                    );
                    overdueBalanceCases.add(overdueBalanceCase);
                }

                if (CaseSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    if (!overdueBalanceCases.isEmpty()) {
                        insert overdueBalanceCases;
                    }
                }
            }
        }
    }

    private static void checkDelinquentBalance(List<Statement__c> statements) {
        // Only if we're configured to auto-create delinquent cases
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();
        if (!sironoCallCenterSettings.Auto_Create_Precollection_Cases__c) {
            return;
        }

        // Group for efficiency
        Set<Id> guarantorIds = new Set<Id>();
        for (Statement__c statement : statements) {
            guarantorIds.add(statement.Guarantor__c);
        }

        if (!guarantorIds.isEmpty()) {
            if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                List<Contact> guarantors = [
                    SELECT Id, Delinquent_Balance__c
                    FROM Contact
                    WHERE Id IN :guarantorIds
                    AND Delinquent_Balance__c > 0.0
                ];

                List<Case> delinquentBalanceCases = new List<Case>();
                for (Contact guarantor : guarantors) {
                    Case delinquentBalanceCase = new Case(
                        ContactId = guarantor.Id,
                        Guarantor_Information__c = guarantor.Id,
                        RecordTypeId = RecordTypeUtil.automatedCaseRt,
                        Status = Constants.CASE_STATUS_NEW,
                        Subject = Constants.CASE_SUBJECT_GUARANTOR_DELINQUENT,
                        Type = Constants.CASE_TYPE_PRECOLLECTIONS
                    );
                    delinquentBalanceCases.add(delinquentBalanceCase);
                }

                if (CaseSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    if (!delinquentBalanceCases.isEmpty()) {
                        insert delinquentBalanceCases;
                    }
                }
            }
        }
    }
}