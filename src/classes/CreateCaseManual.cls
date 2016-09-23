public with sharing class CreateCaseManual {
    public String guarantorRecordId {get; set;}
    public Boolean chargeGroupsSelected {get; set;}

    public String guarantorId {get; set;}
    public String guarantorName {get; set;}
    public String chargegroupId {get; set;}
    public List<ChargeGroupWrapper> chrageGroupList {get; set;}

    public Case caseObj {get; set;}
    public String caseType {get; set;}
    public Boolean caseTypeSelected {get; set;}
    public Contact gc {get; set;}
    public String caseNotes {get; set;}
    Public Contact guarantorContact {get; set;}
    Public Contact patientContact {get; set;}
    Private Charge_Group__c ChargeGroup = new Charge_Group__c();
    public CreateCaseManual(ApexPages.StandardController sc) {
        chargeGroupsSelected = false;
        chrageGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        caseObj = new Case();
        caseTypeSelected = false;
        patientContact = new contact();
        guarantorContact = new contact();
        guarantorRecordId = sc.getId();
        if (Apexpages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = Apexpages.currentPage().getParameters().get('guarantorId');
        }
        if (guarantorRecordId != null) {
            Contact objContact = PayStaffWSUtill.fetchContact(guarantorRecordId);
            if (objContact != null) {
                if (objContact.RecordType.DeveloperName == 'Guarantor') {
                    gc = PayStaffWSUtill.fetchGuarantorContactWithCGConstraints(guarantorRecordId);
                    guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
                } else if (objContact.RecordType.DeveloperName == 'Patient') {
                    gc = PayStaffWSUtill.fetchPatientContactWithCGConstraints(guarantorRecordId);
                    guarantorId = PayStaffWSUtill.fetchPatientId(gc);
                }
            }

            guarantorName = PayStaffWSUtill.fetchGuarantorName(gc);

            caseObj.ContactId = gc.Id;

            for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc, objContact.RecordType.DeveloperName)) {
                if (cgw.cg.Active__c && cgw.cg.Reported_Selfpay_Balance__c != 0) {
                    chrageGroupList.add(cgw);
                }
            }
            chargegroupId = '';
        }
    }

    public Pagereference cancel() {
        Pagereference pg = null;
        if (!isEmpty(guarantorRecordId)) {
            pg = new Pagereference('/' + guarantorRecordId);
        } else {
            pg = new Pagereference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
    }

    public Pagereference doNext() {
        chargeGroupsSelected = false;
        //validate to see if user have selected Case Type
        chargegroupId = PayStaffWSUtill.fetchChargeGroupIds(chrageGroupList);

        if (!isEmpty(chargegroupId)) {
            chargeGroupsSelected = true;
        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.Charge_Groups_Require);
            ApexPages.addMessage(myMsg);
        }
        return null;
    }

    private String getCaseRecordTypeId(String rtName) {
        Schema.DescribeSObjectResult optySobj = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> rtMapByName = optySobj.getRecordTypeInfosByName();
        return rtMapByName.get(rtName).getRecordTypeId();
    }

    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    public void gotoCaseCreation() {
        if (String.isNotBlank(caseType)) {
            caseTypeSelected = true;
            caseObj.RecordTypeId = getCaseRecordTypeId(caseType);


            //Check Charge Group is Selected
            if (caseType != 'General') {
                doNext();
            } else {
                chargeGroupsSelected = true;
            }


            Set<String> setChargeGroupId = new Set<String>();
            for (ChargeGroupWrapper cg : chrageGroupList) {
                if (cg.isSelected) {
                    setChargeGroupId.add(cg.cg.id);
                }
            }
            List<Charge_Group__c> lstChargeGroup = [Select id, Guarantor_Name__c, Patient_Name__c from Charge_Group__c where Id in :setChargeGroupId order by CreatedDate desc];
            if (lstChargeGroup.size() > 0) {
                ChargeGroup = lstChargeGroup[0];
            }

            if (gc.RecordType.DeveloperName == 'Patient') {
                caseObj.Patient__c = gc.id;
                if (ChargeGroup != null) {
                    caseObj.Guarantor_Information__c = ChargeGroup.Guarantor_Name__c;
                }
                guarantorContact = PayStaffWSUtill.fetchContact(caseObj.Guarantor_Information__c);
                patientContact = gc;
            } else if (gc.RecordType.DeveloperName == 'Guarantor') {
                caseObj.Guarantor_Information__c = gc.id;
                if (ChargeGroup != null) {
                    caseObj.Patient__c = ChargeGroup.Patient_Name__c;
                }
                patientContact = PayStaffWSUtill.fetchContact(caseObj.Patient__c);

                guarantorContact = gc;
            }

        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.Case_Type_Require);
            ApexPages.addMessage(myMsg);
        }

    }

    public PageReference submit() {
        try {
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            if (guarantorContact != null) {
                caseObj.ContactID = guarantorContact.id;
            }
            caseObj.Subject = caseObj.Reason;
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
            caseObj.setOptions(dmlOpts);
            upsert caseObj;

            //create case comments
            if (String.isNotBlank(caseNotes)) {
                CaseComment cc = new CaseComment();
                cc.ParentId = caseObj.Id;
                cc.CommentBody = caseNotes;
                upsert cc;
            }

            //add selected Charge Groups to Case
            List<Case_Charge_Group__c> caseCGs = new List<Case_Charge_Group__c>();
            for (ChargeGroupWrapper cg : chrageGroupList) {
                if (cg.isSelected) {
                    Case_Charge_Group__c ccg = new Case_Charge_Group__c();
                    ccg.Case__c = caseObj.Id;
                    ccg.Charge_Group__c = cg.cg.Id;
                    caseCGs.add(ccg);
                }
            }
            upsert caseCGs;
            return cancel();
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
        }
        return null;
    }

}