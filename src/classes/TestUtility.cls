@isTest
Public Class TestUtility{

    public static Contact generateGuarantorContact(){
        Contact g = new Contact();
        g.RecordTypeId = RecordTypeUtil.Guarantor_RT;
        g.LastName = 'G Test';
        g.Profile_Pointer_Id__c = 12345;
        g.HomePhone = '111';
        g.MobilePhone = '111';
        return g;
    }
    
    public static Contact generatePatientContact(){
        Contact g = new Contact();
        g.RecordTypeId = RecordTypeUtil.Patient_RT;
        g.LastName = 'G Test';
        g.Profile_Pointer_Id__c = 123455;
        g.HomePhone = '111';
        g.MobilePhone = '111';
        return g;
    }
    
    public static Charge_Group__c generateChargeGroup(String guarantorContactId, String patientContactId, Decimal chargeGroupExternalId){
        Charge_Group__c cg = new Charge_Group__c();
        cg.Guarantor_Name__c = guarantorContactId;
        cg.Charge_Group_ID__c = chargeGroupExternalId;
        cg.Patient_Name__c = patientContactId;
        cg.Charge_Group_External_ID__c = true;
        //cg.Balance__c = -100; //can't set amount now that balance is a rollup
        cg.Reported_Selfpay_Balance__c = 10;
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c= 'Overdue';
        cg.Active__c = true;
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Preinvoiced';        
                        
        return cg;
    }

    public static Transaction__c generateTransaction(Charge_Group__c cg, Decimal amount, String method) {

        Transaction__c t = new Transaction__c();
        t.Amount__c = amount == null ? 0 : amount;
        t.Charge_Group__c = cg.Id;
        t.Credit_Balance__c = amount < 0;
        t.Fail_Date__c = null;
        t.Id__c = System.currentTimeMillis();
        t.Method__c = method;
        t.Notes__c = 'Test txn';
        t.Post_Date__c = System.today().addDays('Credit'.equals(method) ? 7 : -7);
        return t;
    }

    public static Encounter__c createEncounter(String gId, Decimal patientPortion, Date serviceDate) {
		Encounter__c e = new Encounter__c(Guarantor__c = gId, Patient_Portion__c = patientPortion, Date_of_Service__c = serviceDate);
		return e;
	}
	
	public static Payment_Arrangement__c createPaymentArrangement(String eId) {
		Payment_Arrangement__c pa = new Payment_Arrangement__c(Encounter__c = eId);
		return pa;
	}
	
	public static Case createCase(String rTypeId, String cType, String gId) {
		Case c = new Case();
    	c.RecordTypeId = rTypeId;
    	c.Status = 'New';
    	c.Priority = 'Medium';
    	c.Type = cType;
    	c.Origin = 'Email';
    	c.Subject = cType;
    	c.Description = 'Test';
    	c.Guarantor_Information__c = gId;
    	return c;
	}

    public static test__c GeneratePaymentPlan(Contact guarantor) {
        test__c pp = new test__c();
        pp.Guarantor_Name__c = guarantor.Id;
        pp.Active__c = true;
        return pp;
    }
}