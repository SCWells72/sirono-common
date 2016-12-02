/*
* @author  Sirono
* @version 1.0.1
* @date    05-05-2016
* @description trigger on CaseComment object that gets invoked after insert event
*/
trigger CaseCommentTrigger on CaseComment (after insert) {

    //executes after insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        //CaseCommentTriggerHandler.afterInsert(Trigger.new);
        CaseCommentTriggerHandler obj = new CaseCommentTriggerHandler();
    }
}