@isTest
private class TestCaseTrigger {
    static testMethod void myUnitTest() {
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Case']) {
            rtMap.put(rt.Name, rt.Id);
        }

        Case c = new Case();
        c.RecordTypeId = rtMap.get('Internal Case');
        c.Status = 'New';
        c.Priority = 'Medium';
        c.Type = 'Address Change';
        c.Reason = 'Charge Group';
        c.Origin = 'Email';
        c.Subject = 'Test';
        c.Description = 'Test';
        c.Charge_Group_IDs__c = '1234,1235';
        insert c;

        CaseComment cc = new CaseComment();
        cc.CommentBody = 'Test';
        cc.ParentId = c.Id;
        insert cc;
    }
}