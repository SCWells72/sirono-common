@isTest
private class TestAddToPaymentPlan {

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

        Contact p = new Contact();
        p.RecordTypeId = rtMap.get('Patient');
        p.LastName = 'G Test';
        insert p;

        test__c t = new test__c();
        t.Guarantor_Name__c = g.Id;
        t.Active__c = true;
        insert t;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', t.Id);
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        ppCon.submit();

        Invoice__c i = new Invoice__c();
        i.Guarantor_Name__c = g.Id;
        i.Due_Date__c = System.today();
        i.Invoice_Date__c = System.today();
        i.Invoice_ID__c = 123;
        i.Patient__c = p.Id;
        insert i;

        Charge_Group__c cg = new Charge_Group__c();
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Patient_Name__c = p.Id;
        cg.Guarantor_Name__c = g.Id;
        cg.Charge_Group_ID__c = 123;
        cg.Charge_Group_External_ID__c = true;
        insert cg;
        cg = new Charge_Group__c();
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Patient_Name__c = p.Id;
        cg.Guarantor_Name__c = g.Id;
        cg.Charge_Group_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        Apexpages.currentPage().getParameters().put('paymentPlanId', t.Id);
        ppCon = new AddToPaymentPlan();
        for (ChargeGroupWrapper cgw :ppCon.chrageGroupList) {
            cgw.isSelected = true;
        }
        ppCon.doNext();
        ppCon.submit();
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

        Contact p = new Contact();
        p.RecordTypeId = rtMap.get('Patient');
        p.LastName = 'G Test';
        insert p;

        test__c t = new test__c();
        t.Guarantor_Name__c = g.Id;
        t.Active__c = true;
        insert t;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        AddToPaymentPlan ppCon = new AddToPaymentPlan();
        ppCon.submit();

        Invoice__c i = new Invoice__c();
        i.Guarantor_Name__c = g.Id;
        i.Due_Date__c = System.today();
        i.Invoice_Date__c = System.today();
        i.Invoice_ID__c = 123;
        i.Patient__c = p.Id;
        insert i;

        Charge_Group__c cg = new Charge_Group__c();
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Patient_Name__c = p.Id;
        cg.Guarantor_Name__c = g.Id;
        cg.Charge_Group_ID__c = 123;
        cg.Charge_Group_External_ID__c = true;
        insert cg;
        cg = new Charge_Group__c();
        cg.Invoice__c = i.id;
        cg.Payment_Plan__c = t.Id;
        cg.Patient_Name__c = p.Id;
        cg.Guarantor_Name__c = g.Id;
        cg.Charge_Group_ID__c = 124;
        cg.Charge_Group_External_ID__c = true;
        insert cg;

        Apexpages.currentPage().getParameters().put('guarantorId', g.Id);
        ppCon = new AddToPaymentPlan();
        for (ChargeGroupWrapper cgw :ppCon.chrageGroupList) {
            cgw.isSelected = true;
        }
        ppCon.doNext();
        ppCon.submit();
    }
}