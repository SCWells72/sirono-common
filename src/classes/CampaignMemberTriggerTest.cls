/*
* @author Sirono
* @version 1.0.1
* @Date: 05-30-2016
*/

@isTest
private class CampaignMemberTriggerTest {

    static testMethod void myUnitTest() {
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Contact']) {
            rtMap.put(rt.Name, rt.Id);
        }
        Contact g = new Contact();
        g.RecordTypeId = rtMap.get('Guarantor');
        g.LastName = 'G Test';
        g.Profile_Pointer_Id__c = 123;
        insert g;

        Campaign cm = new Campaign(Name = 'Test', isActive = true, Status = 'In Progress', StartDate = System.today());
        insert cm;

        CampaignMember cmm = new CampaignMember(CampaignId = cm.Id, ContactId = g.Id, Status = 'Sent');
        insert cmm;

        List<Task> taskListToInsert = new List<Task>();
        taskListToInsert.add(new Task(WhoId = g.Id, Priority = 'Normal', Status = 'New', CallDisposition = 'Final', Five9__Five9Campaign__c = 'Pre-collection'));
        taskListToInsert.add(new Task(WhoId = g.Id, Priority = 'Normal', Status = 'New', CallDisposition = 'Retry', Five9__Five9Campaign__c = 'Pre-collection'));
        taskListToInsert.add(new Task(WhoId = g.Id, Priority = 'Normal', Status = 'New', CallDisposition = 'Error', Five9__Five9Campaign__c = 'Pre-collection'));
        insert taskListToInsert;

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

}