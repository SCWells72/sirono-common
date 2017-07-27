/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Create a Manual case based on the conditions
 */
public with sharing class CreateCaseManual {
    public String guarantorRecordId { get; set; }
    public Boolean chargeGroupsSelected { get; set; }
    public String guarantorId { get; set; }
    public String guarantorName { get; set; }
    public String[] chargeGroupIds { get; set; }
    public List<ChargeGroupWrapper> chargeGroupList { get; set; }
    public Case caseObj { get; set; }
    public String caseType { get; set; }
    public Boolean caseTypeSelected { get; set; }
    public Contact gc { get; set; }
    public String caseNotes { get; set; }
    public Contact guarantorContact { get; set; }
    public Contact patientContact { get; set; }
    public Charge_Group__c chargeGroup = new Charge_Group__c();
    public String coverageJson { get; set; }
    public String transactionJson { get; set; }

    //11-23-2016: Viraj Rana - Tracker # 132104143: Pre-populate manual case fields where necessary.
    //This set is also used whenever we got Coverage record based on Charge Group's "Date Of Service Start" field.
    Set<Id> setChargeGroupId = new Set<Id>();

    /*
     * Constructor to get the guarantor and charge group details.
    */
    public CreateCaseManual(ApexPages.StandardController sc) {
        chargeGroupsSelected = false;
        chargeGroupList = new List<ChargeGroupWrapper>();
        guarantorName = '';
        caseObj = new Case();
        caseTypeSelected = false;
        patientContact = new Contact();
        guarantorContact = new Contact();
        guarantorRecordId = sc.getId();

        if (ApexPages.currentPage().getParameters().containsKey('guarantorId')) {
            guarantorRecordId = ApexPages.currentPage().getParameters().get('guarantorId');
        }
        if (guarantorRecordId != null) {
            Contact objContact = ContactService.getContactDetails(guarantorRecordId);
            if (objContact != null) {
                if (objContact.RecordType.DeveloperName == 'Guarantor') {
                    gc = GuarantorService.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId, Constants.CGConstraintsForCase);
                    guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
                } else if (objContact.RecordType.DeveloperName == 'Patient') {
                    gc = PatientService.getPatientFilterCGByAcctSubStatus(guarantorRecordId, Constants.CGConstraintsForCase);
                    guarantorId = PayStaffWSUtill.fetchPatientId(gc);
                }
            }

            guarantorName = GuarantorService.buildGuarantorDetailString(gc);

            caseObj.ContactId = gc.Id;

            for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(gc, objContact.RecordType.DeveloperName)) {
                if (cgw.cg.Active__c && cgw.cg.Balance__c != 0) {
                    chargeGroupList.add(cgw);
                }
            }
            chargeGroupIds = new String[] {};
        }
    }

    /*
    * Cancel the case creation and back to the guarantor record.
    */
    public PageReference cancel() {
        PageReference pg = null;
        if (!isEmpty(guarantorRecordId)) {
            pg = new PageReference('/' + guarantorRecordId);
        } else {
            pg = new PageReference('/home/home.jsp');
        }
        pg.setRedirect(true);
        return pg;
    }

    /*
    * check charge group is selected or not and show the guarantor details.
    */
    public PageReference doNext() {
        chargeGroupsSelected = false;
        chargeGroupIds = ChargeGroupWrapper.getSelectedChargeGroupIds(chargeGroupList);

        if (!chargeGroupIds.isEmpty()) {
            chargeGroupsSelected = true;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Charge_Groups_Require));
        }
        return null;
    }

    //get the case record type
    private String getCaseRecordTypeId(String rtName) {
        Schema.DescribeSObjectResult optySobj = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> rtMapByName = optySobj.getRecordTypeInfosByName();
        return rtMapByName.get(rtName).getRecordTypeId();
    }

    //check pass string is empty or not
    private Boolean isEmpty(String str) {
        return (str == null || str.trim().equals(''));
    }

    //get the Patient and Guarantor information
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

            for (ChargeGroupWrapper cg : chargeGroupList) {
                if (cg.isSelected) {
                    setChargeGroupId.add(cg.cg.Id);
                }
            }

            chargeGroup = ChargeGroupService.getCGOrderByCreatedDate(setChargeGroupId);

            if (gc.RecordType.DeveloperName == 'Patient') {
                caseObj.Patient__c = gc.Id;
                if (chargeGroup != null) {
                    caseObj.Guarantor_Information__c = chargeGroup.Guarantor__c;
                }
                guarantorContact = ContactService.getContactDetails(caseObj.Guarantor_Information__c);
                patientContact = gc;
            } else if (gc.RecordType.DeveloperName == 'Guarantor') {
                caseObj.Guarantor_Information__c = gc.Id;
                if (chargeGroup != null) {
                    caseObj.Patient__c = chargeGroup.Patient__c;
                }
                patientContact = ContactService.getContactDetails(caseObj.Patient__c);
                guarantorContact = gc;
            }

        } else {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.Case_Type_Require);
            ApexPages.addMessage(myMsg);
        }
    }

    //Create a new case
    public PageReference submit() {
        try {

            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            if (guarantorContact != null) {
                caseObj.ContactId = guarantorContact.Id;
            }
            caseObj.Subject = caseObj.Reason;
            AssignmentRule ar = new AssignmentRule();
            if (AssignmentRuleSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                ar = [
                    SELECT Id
                    FROM AssignmentRule
                    WHERE SobjectType = 'Case' AND Active = TRUE
                    LIMIT 1
                ];
            }

            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.AssignmentRuleHeader.assignmentRuleId = ar.Id;
            caseObj.setOptions(dmlOpts);

            if (CaseSecurityContext.CREATE_WITH_GT_CONTEXT.actionAllowed()) {
                insert caseObj;
            }

            //add selected Charge Groups to Case
            List<Case_Charge_Group_Junction__c> caseCGs = new List<Case_Charge_Group_Junction__c>();
            for (ChargeGroupWrapper cg : chargeGroupList) {
                if (cg.isSelected) {
                    Case_Charge_Group_Junction__c ccg = new Case_Charge_Group_Junction__c();
                    ccg.Case__c = caseObj.Id;
                    ccg.Charge_Group__c = cg.cg.Id;
                    caseCGs.add(ccg);
                }
            }
            if (CaseCGJunctionSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                insert caseCGs;
            }

            //create case comments
            if (String.isNotBlank(caseNotes)) {
                CaseComment cc = new CaseComment();
                cc.ParentId = caseObj.Id;
                cc.CommentBody = caseNotes;

                if (CaseCommentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    insert cc;
                }
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Created Successfully!'));
            if (Test.isRunningTest()) {

                TestUtility.generateException();
            }

        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + e.getMessage()));
        }
        return null;
    }

    public void refresh() {
        if (ApexPages.currentPage().getParameters().containsKey('reason')) {
            caseObj.Reason = ApexPages.currentPage().getParameters().get('reason');
            
      /* 11-23-2016: Viraj Rana - Tracker # 132104143: Pre-populate manual case fields where necessary.
       * Populating coverage data using the selected Chargegroup with the oldest "Date Of Service Start" field.
       */
            Charge_Group__c cg = new Charge_Group__c();
            List<Charge_Group__c> lstChargeGroup = ChargeGroupService.getCGOrderByServiceDate(setChargeGroupId);
            if (lstChargeGroup.size() > 0) {
                cg = lstChargeGroup[0];
            }

            /* 10-19-2016: Viraj Rana - Tracker # 132104143: Pre-populate manual case fields where necessary.
             * Get Coverage detail based on Selected Charge Group.
             */
            if (CGCoverageJunctionSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                List<Charge_Group_Coverage_Junction__c> coverageDetail = [
                    SELECT Coverage__c, Coverage__r.Payor__c, Coverage__r.Payor__r.Name, Coverage__r.Plan_Name__c,
                        Coverage__r.Date_Effective__c, Coverage__r.Subscriber_Name__c, Coverage__r.Subscriber_ID__c
                    FROM Charge_Group_Coverage_Junction__c
                    WHERE Charge_Group__c = :cg.Id
                    ORDER BY LastModifiedDate DESC
                    LIMIT 1
                ];
                if (coverageDetail.size() > 0) {
                    coverageJson = JSON.serialize(coverageDetail[0]);
                }
            }

            //Get Transaction detail based on Selected Charge Group.
            if (TransactionSecurityContext.CCM_SELECT_CONTEXT.actionAllowed()) {
                List<Transaction__c> transactionDetail = [
                    SELECT Sirono_ID__c, Amount__c
                    FROM Transaction__c
                    WHERE Charge_Group__c = :chargeGroup.Id
                    ORDER BY LastModifiedDate DESC
                    LIMIT 1
                ];

                if (transactionDetail.size() > 0) {
                    transactionJson = JSON.serialize(transactionDetail[0]);
                }
            }
        }
    }
    
    /*public PageReference redirect(){

      //Write your logic here and redirect
      PageReference retURL = new PageReference('/' + guarantorRecordId);
      retURL.setRedirect(true);
      return retURL;
     }*/
}