@isTest
private class TestAddCreditCard {

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
        
        Apexpages.currentPage().getParameters().put('guarantorId',g.Id);
        AddCreditCard conOb = new AddCreditCard();
        conOb.chargegroupId = 'test';
        conOb.planType = 'test';
        conOb.planValue = 'test';
        conOb.amount = 'test';
        conOb.executeOnDay = 'test';
        conOb.cardHolderName = 'test';
        conOb.expirationYear = 'test';
        conOb.expirationMonth = 'test';
        conOb.creditCardNumber = 'test';
        conOb.CVV = 'test';
        conOb.state = 'test';
        conOb.zip = 'test';
        conOb.address = 'test';
        conOb.city = 'test';
        conOb.doSubmit();
        conOb.TestResponse();
        conOb.ParseResponse(conOb.responseBody);
        
    }
}