@isTest
private class TestAddNote {
    static testMethod void myUnitTest() {
        Map<String, Id> rtMap = new Map<String, Id>();
    	for(RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Contact']){
    		rtMap.put(rt.Name, rt.Id);
    	}
    	Contact g = new Contact();
    	g.RecordTypeId = rtMap.get('Guarantor');
    	g.LastName = 'G Test';
    	g.Profile_Pointer_Id__c = 123;
    	insert g;
    	
    	Contact p = new Contact();
    	p.RecordTypeId = rtMap.get('Patient');
    	p.LastName = 'G Test';
    	insert p;
    	
    	test__c t = new test__c();
    	t.Guarantor_Name__c = g.Id;
    	insert t;
    	
    	AddNote conOb = new AddNote(new ApexPages.StandardController(t));
    	conOb.chargegroupId = 'test';
    	conOb.noteText = 'test class';
    	conOb.doSubmit();
    }
}