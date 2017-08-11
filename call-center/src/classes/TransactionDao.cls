/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class TransactionDao {

    public static void save(List<Transaction__c> transactions) {
        if (TransactionSecurityContext.CREATE_WITH_PAYMENT_CONTEXT.actionAllowed()) {
            insert transactions;
        }
    }
}