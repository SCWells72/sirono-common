/*
* @author 
* @version 1.0.1
* @description 
* @date:  05-05-2016
* Sirono : 08-22-2016: 128608667 - to remove the Guarantor from the Early Out, Precollections, 
* Pre-Service Campaign when Auto cases are closed manually
*/


trigger CaseTrigger on Case (after insert, after update) {
	CaseTriggerHandler obj = new CaseTriggerHandler();
/*
    //executes after insert operation
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseTriggerHandler.afterInsert(Trigger.new);
    }

    //Mohan Kumar 08-22-2016: 128608667 - to remove the Guarantor from the Early Out, Precollections, 
    //Pre-Service Campaign when Auto cases are closed manually
    if (Trigger.isAfter && Trigger.isUpdate) {
        CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }*/
}