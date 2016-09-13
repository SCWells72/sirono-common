@isTest
private class TestEncounterTrigger {

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
    	p.LastName = 'P Test';
    	insert p;
    	
    	Contact g2 = new Contact();
    	g2.RecordTypeId = rtMap.get('Guarantor');
    	g2.LastName = 'G Test';
    	g2.Profile_Pointer_Id__c = 1234;
    	g2.Guarantor__c = g.Id;
    	insert g2;
    	
    	
    	Encounter__c e = new Encounter__c();
    	e.Patient__c = p.Id;
    	e.Liability__c = 200;
    	e.Date_of_Service__c = System.Today();
    	e.Cancelled__c = true;
    	e.Patient_Portion__c = 100;
    	insert e;
    	
    	e.Liability__c = 300;
    	update e;
    }

}