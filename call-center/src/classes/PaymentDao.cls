/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Payment DAO for Payment object SOQL/DML operations
 * TODO fix our sharing model
 */
public with sharing class PaymentDao {
	/**
	 * This method is used to Insert Payment record.
	 * @param List<Payment__c> payments - List of payment record for insert
	 **/
    public static void insertPayment(List<Payment__c> payments) {
        if (PaymentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            insert payments;
        }
    }

    public static void insertPaymentAndTransactions(List<SObject> paymentsAndTransactions) {
        if (PaymentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            // Create the Payment and associated Transactions
            // TODO: Why is this using Database.insert() instead of insert? Because it's heterogenerous?
            Database.insert(paymentsAndTransactions);
        }
    }

    /**
     * This method returns payment record by Id.
     * @param Id paymentId - id of payment record
     **/
    public static Payment__c getPayment(Id paymentId) {
        if (PaymentSecurityContext.DAO_SELECT_CONTEXT.actionAllowed()) {
            try {
                Payment__c payment = [
                    SELECT Id,
                        Amount__c,
                        Deposit_Date__c,
                        Encounter__c,
                        Guarantor__c,
                        Method__c,
                        Name,
                        Payment_Id__c,
                        Sirono_Id__c,
                        Id__c

                    FROM Payment__c
                    WHERE Id = :paymentId
                ];
                return payment;
            } catch (QueryException ex) {
                System.debug('PaymentDao.getPayment: ' + ex.getStackTraceString());
                return null;
            }
        }

        return null;
    }

    /**
     * This method returns payment record by Id.
     * @param Id paymentId - id of payment record
     **/
    public static Payment__c getPaymentBySironoId(Decimal sironoId) {
        if (PaymentSecurityContext.DAO_SELECT_CONTEXT.actionAllowed()) {
            try {
                Payment__c payment = [
                    SELECT Id,
                        Amount__c,
                        Deposit_Date__c,
                        Encounter__c,
                        Guarantor__c,
                        Method__c,
                        Name,
                        Payment_Id__c,
                        Sirono_Id__c,
                        Id__c

                    FROM Payment__c
                    WHERE Sirono_Id__c = :sironoId
                ];
                return payment;
            } catch (QueryException ex) {
                System.debug('PaymentDao.getPaymentBySironoId: ' + ex.getStackTraceString());
                return null;
            }
        }

        return null;
    }

    /**
     * Get the payments for a contact.
     *
     * @param Id contactId
     * @return List<Payment__c> - The list of payments.
     */
    public static List<Payment__c> getPayments(Id contactId) {
        List<Payment__c> payments = new List<Payment__c>();
        if (PaymentSecurityContext.DAO_SELECT_CONTEXT.actionAllowed() &&
            PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            payments = [
                SELECT
                    Id,
                    Method__c,
                    Name,
                    Deposit_Date__c,
                    Payment_Id__c,
                    Payment_Method__r.Last_4__c,
                    Payment_Method__r.Card_Type__c,
                    Processor_Transaction_Id__c,
                    Amount__c
                FROM Payment__c
                WHERE Guarantor__c = :contactId
                ORDER BY Name DESC
                LIMIT 50000
            ];
        }

        return payments;
    }

}