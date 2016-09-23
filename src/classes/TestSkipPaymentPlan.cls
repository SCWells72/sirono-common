@isTest
private class TestSkipPaymentPlan {

    static testMethod void myUnitTest() {
        Apexpages.currentPage().getParameters().put('guarantorId', '123');
        Apexpages.currentPage().getParameters().put('paymentPlanId', '123');

        SkipPaymentPlan con = new SkipPaymentPlan();
        con.doSubmit();
        con.cancel();
    }

    static testMethod void myUnitTest2() {
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType rt : [Select Id, Name From RecordType Where sObjectType = 'Contact']) {
            rtMap.put(rt.Name, rt.Id);
        }
        Contact g = new Contact();
        g.RecordTypeId = rtMap.get('Guarantor');
        g.LastName = 'G Test';
        g.Profile_Pointer_Id__c = 123;
        insert g;

        test__c t = new test__c();
        t.Guarantor_Name__c = g.Id;
        t.Active__c = true;
        t.Plan_Type__c = 'Automatic';
        insert t;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', t.Id);

        SkipPaymentPlan con = new SkipPaymentPlan();
        con.doSubmit();
        con.cancel();
    }
}