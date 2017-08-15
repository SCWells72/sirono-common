/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

trigger StatementTrigger on Statement__c (after insert) {
    StatementTriggerHandler.afterInsert(Trigger.new);
}