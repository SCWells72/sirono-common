/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Trigger on CaseComment object
 */
trigger CaseCommentTrigger on CaseComment (after insert) {

    //executes after insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseCommentTriggerHandler.afterInsert(Trigger.new);
    }
}