/*
 * @author Sirono
 * @version 1.0.1
 * @date 08-12-2016
 * @ Utility class for the test class to create a records.
 */

@isTest
Public Class TestUtility {
    Public Static Map<String, Id> rtMap = new Map<String, Id>();
    Public Static String body = '{"token":"bar"}';
    Public Static String responsebody = '{"token":"bar"}';
    Public Static Integer statusCode = 200;
    Public Static Integer statusCode2 = 200;
    Public Static Integer statusCode3 = 200;
    Public Static Integer statusCode4 = 200;
    Public Static String status = 'CREATED';
    public static boolean isTest = false;
    public static boolean setBlank = false;
    public static String errorbody = '' ;
    public static integer currentDay = 22;
    public static integer currentMonth = 12;
    public static integer currentYear = 2017;
    public static boolean hasException = false;
    public static string planType = 'auto';
    public static string errorDate = '2016-05-13';
    public static string delinquentDate = '2016-05-13';

    public static string url = 'http://127.0.0.1:8000/paystaff/api/paymentplan/2876/';
    Public TestUtility() {
        for (RecordType rt : [
                Select Id, Name
                From RecordType
                Where sObjectType = 'Contact'
        ]) {
            rtMap.put(rt.Name, rt.Id);
        }
    }

    // Return Guarantor Contact record        
    Public Static contact generateGuarantorContact() {
        Contact guarantorContact = new Contact();
        guarantorContact.RecordTypeId = RecordTypeUtil.guarantorRt;
        guarantorContact.LastName = 'G Test';
        Integer tempRandom = Integer.valueOf(math.rint(math.random()*1212));
        Integer tempRandom2 = Integer.valueOf(math.rint(math.random()*12));
        Integer randomInt = (tempRandom * tempRandom2) + Integer.valueOf(DateTime.now().getTime());
        //Integer randomInt = DateTime.now().millisecond() + Integer.valueOf(math.rint(math.random()*1000));        
        guarantorContact.Profile_Pointer_Id__c = Decimal.valueOf(randomInt);
        guarantorContact.HomePhone = '111';
        guarantorContact.MobilePhone = '111';
        return guarantorContact;
    }

    // Return Patient Contact record
    Public Static contact generatePatientContact() {
        Contact patientContact = new Contact();
        patientContact.RecordTypeId = RecordTypeUtil.patientRt;
        patientContact.LastName = 'G Test';
        Integer tempRandom = Integer.valueOf(math.rint(math.random()*100));
        Integer tempRandom2 = Integer.valueOf(math.rint(math.random()*123));
        Integer randomInt = (tempRandom * tempRandom2) + Integer.valueOf(DateTime.now().getTime());
        //Integer randomInt = DateTime.now().millisecond() + Integer.valueOf(math.rint(math.random()*100));
        patientContact.Profile_Pointer_Id__c = Decimal.valueOf(randomInt);
        patientContact.HomePhone = '111';
        patientContact.MobilePhone = '111';
        return patientContact;
    }

    // Return charge group record
    Public Static Charge_Group__c generateChargeGroup(String guarantorContactId,
            String patientContactId,
            Decimal chargeGroupExternalId,
            string paymentplanID) {
        Charge_Group__c chargeGroup = new Charge_Group__c();
        chargeGroup.Guarantor_Name__c = guarantorContactId;
        //Ignore the external Id passed in the method parameter and set the dynamic value
        Integer tempRandom = Integer.valueOf(math.rint(math.random()*150));
        Integer tempRandom2 = Integer.valueOf(math.rint(math.random()*500));
        Integer randomInt = (tempRandom * tempRandom2) + Integer.valueOf(DateTime.now().getTime());
        //Integer randomInt = DateTime.now().millisecond() + Integer.valueOf(math.rint(math.random()*1212));
        chargeGroup.Charge_Group_ID__c = Decimal.valueOf(randomInt);
        chargeGroup.Patient_Name__c = patientContactId;
        chargeGroup.Charge_Group_External_ID__c = true;
        //chargeGroup.Balance__c = -100; //can't set amount now that balance is a rollup
        chargeGroup.Reported_Selfpay_Balance__c = 10;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = 'Overdue';
        chargeGroup.Active__c = true;
        chargeGroup.Account_Status__c = 'Billed';
        chargeGroup.Account_Sub_Status__c = 'Preinvoiced';
        chargeGroup.Name = 'Sirono';
        chargeGroup.Payment_Plan__c = paymentplanID;
        return chargeGroup;
    }

    // Return charge group record
    Public Static Charge_Group__c  generateChargeGroupWithExternalId(String guarantorContactId,
            String patientContactId,
            Decimal chargeGroupExternalId) {
        Charge_Group__c cg = new Charge_Group__c();
        cg.Guarantor_Name__c = guarantorContactId;
        cg.Charge_Group_ID__c = chargeGroupExternalId;
        cg.Patient_Name__c = patientContactId;
        cg.Charge_Group_External_ID__c = true;
        //cg.Balance__c = -100; //can't set amount now that balance is a rollup
        cg.Reported_Selfpay_Balance__c = 10;
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Overdue';
        cg.Active__c = true;
        cg.Account_Status__c = 'Billed';
        cg.Account_Sub_Status__c = 'Preinvoiced';

        return cg;
    }
    
    // Return charge group record with external Id from parameter
    Public Static Charge_Group__c  generateChargeGroup(String guarantorContactId,
                                                        String patientContactId,
                                                        Decimal chargeGroupExternalId) {
        Charge_Group__c cg = new Charge_Group__c();
        cg.Guarantor_Name__c = guarantorContactId;
        //Ignore the external Id passed in the method parameter and set the dynamic value
        Integer tempRandom = Integer.valueOf(math.rint(math.random()*505));
        Integer tempRandom2 = Integer.valueOf(math.rint(math.random()*120));
        Integer randomInt = (tempRandom * tempRandom2) + Integer.valueOf(DateTime.now().getTime());
        //Integer randomInt = DateTime.now().millisecond() + Integer.valueOf(math.rint(math.random()*12));
        cg.Charge_Group_ID__c = Decimal.valueOf(randomInt);
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
    
    // Return transaction record
    public static Transaction__c generateTransaction(Charge_Group__c chargeGroup,
            Decimal amount,
            String method) {
        Transaction__c objTransaction = new Transaction__c();
        objTransaction.Amount__c = amount == null ? 0 : amount;
        objTransaction.Charge_Group__c = chargeGroup.Id;
        objTransaction.Credit_Balance__c = amount < 0;
        objTransaction.Fail_Date__c = null;
        objTransaction.Id__c = System.currentTimeMillis();
        objTransaction.Method__c = method;
        objTransaction.Notes__c = 'Test txn';
        objTransaction.Post_Date__c = System.today().addDays('Credit'.equals(method) ? 7 : -7);
        return objTransaction;
    }

    // Return Encounter record
    public static Encounter__c generateEncounter(String guarantorId,
            Decimal patientPortion,
            Date serviceDate) {
        Encounter__c encounter = new Encounter__c(Guarantor__c = guarantorId,
                Patient_Portion__c = patientPortion,
                Date_of_Service__c = serviceDate);
        return encounter;
    }

    // Return Payment Arrangement record
    public static Payment_Arrangement__c generatePaymentArrangement(String encounterId) {
        Payment_Arrangement__c paymentArrangement = new Payment_Arrangement__c(Encounter__c = encounterId);
        return paymentArrangement;
    }

    // Return a new case record    
    public static Case generateCase(String rTypeId, String cType, String gId) {
        Case objCase = new Case();
        objCase.RecordTypeId = rTypeId;
        objCase.Status = 'New';
        objCase.Priority = 'Medium';
        objCase.Type = cType;
        objCase.Origin = 'Email';
        objCase.Subject = cType;
        objCase.Description = 'Test';
        objCase.Guarantor_Information__c = gId;
        return objCase;
    }

    // Return a new Statement record    
    public static Statement__c generateStatement(String contactId) {
        Statement__c stmt = new Statement__c();
        stmt.Statement_Date__c = System.Today();
        stmt.Guarantor__c = contactId;
        return stmt;
    }

    // Return a new campaign record    
    public static Campaign generateCampaign(String name) {
        Campaign objCampaign = New Campaign();
        objCampaign.Name = name;
        objCampaign.IsActive = True;
        return objCampaign;
    }

    // Return a new payment plan record 
    public static test__c generatePaymentPlan(String contactId) {
        test__c paymentPlan = new test__c();
        paymentPlan.Guarantor_Name__c = contactId;
        return paymentPlan;
    }

    // Return a new Invoice record 
    public static Invoice__c generateInvoice(String guarantorId, String patientId) {
        Invoice__c invoice = new Invoice__c();
        invoice.Guarantor_Name__c = guarantorId;
        invoice.Due_Date__c = System.today();
        invoice.Invoice_Date__c = System.today();
        Integer randomInt = DateTime.now().millisecond() + Integer.valueOf(math.rint(math.random()*1313));
        invoice.Invoice_ID__c = Decimal.valueOf(randomInt);
        invoice.Patient__c = patientId;
        return invoice;
    }

    // Return a new Case Comment 
    public static CaseComment generateCaseComment(String parentId) {
        CaseComment cc = new CaseComment();
        cc.CommentBody = 'Test';
        cc.ParentId = parentId;
        return cc;
    }

    // Return test record
    public static test__c generatePaymentPlan(Contact guarantor) {
        test__c paymentPlan = new test__c();
        paymentPlan.Guarantor_Name__c = guarantor.Id;
        paymentPlan.Active__c = true;
        return paymentPlan;
    }

    // Return payment method record 
    public static Payment_Method__c generatePaymentMethod(String guarantorId, String recordTypeID) {
        Payment_Method__c paymentMethod = new Payment_Method__c();
        paymentMethod.Guarantor__c = guarantorId;
        paymentMethod.RecordTypeID = recordTypeID;
        return paymentMethod;
    }

    // return list of charge_group__c records
    public static list<Charge_Group__c> generatechargeGroupList(ID contID) {
        list<Charge_Group__c> lstChargeGroup = new list<Charge_Group__c>();
        for (integer i = 0; i < 20; i++) {
            Charge_Group__c chargeGroup = new Charge_Group__c();
            chargeGroup.name = 'xyz' + i;
            chargeGroup.Guarantor_Name__c = contID;
            lstChargeGroup.add(chargeGroup);
        }
        return lstChargeGroup;
    }

    // return CampaignMember record
    public static CampaignMember generateCampaignMember(ID campaignId, ID guarantorContactId) {
        CampaignMember objcampaignMember = new CampaignMember();
        objcampaignMember.CampaignId = campaignId;
        objcampaignMember.ContactId = guarantorContactId;
        objcampaignMember.Status = 'Sent';
        return objcampaignMember;
    }

    // return Task record
    public static Task generateTask(ID guarantorContactId) {
        Task objTask = new Task();
        objTask.WhoId = guarantorContactId;
        objTask.Priority = 'Normal';
        objTask.Status = 'New';
        objTask.CallDisposition = 'Final';
        objTask.Five9__Five9Campaign__c = 'Pre-collection';
        return objTask;
    }

    // Generate Exception
    public static integer generateException() {
        return 1 / 0;
    }
}