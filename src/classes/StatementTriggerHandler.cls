/**
 * Created by swells on 6/26/2017.
 */

public with sharing class StatementTriggerHandler {
    public static void afterInsert(List<Statement__c> statements) {
        checkOverdueBalance(statements);
        checkDelinquentBalance(statements);
    }

    private static void checkOverdueBalance(List<Statement__c> statements) {
        // Group for efficiency
        Set<Id> guarantorIds = new Set<Id>();
        for (Statement__c statement : statements) {
            guarantorIds.add(statement.Guarantor__c);
        }

        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Contact> guarantors = [
                SELECT Id, Overdue_Balance__c
                FROM Contact
                WHERE Overdue_Balance__c > 0.0
            ];
            if (!guarantors.isEmpty()) {
                List<Case> overdueBalanceCases = new List<Case>();

                Contact guarantor = guarantors[0];
                for (Statement__c statement : statements) {
                    Case overdueBalanceCase = new Case(
                        BusinessHoursId = SironoSettingsUtil.getBusinessHoursId(),
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
        // Group for efficiency
        Set<Id> guarantorIds = new Set<Id>();
        for (Statement__c statement : statements) {
            guarantorIds.add(statement.Guarantor__c);
        }

        if (ContactSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            List<Contact> guarantors = [
                SELECT Id, Delinquent_Balance__c
                FROM Contact
                WHERE Delinquent_Balance__c > 0.0
            ];
            if (!guarantors.isEmpty()) {
                List<Case> delinquentBalanceCases = new List<Case>();

                Contact guarantor = guarantors[0];
                for (Statement__c statement : statements) {
                    Case delinquentBalanceCase = new Case(
                        BusinessHoursId = SironoSettingsUtil.getBusinessHoursId(),
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