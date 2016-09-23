trigger CaseTrigger on Case (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseTriggerHandler.afterInsert(Trigger.new);
    }

    //Mohan Kumar 2016-08-22: 128608667 - to remove the Guarantor from the Early Out, Precollections,
    //Pre-Service Campaign when Auto cases are closed manually
    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}