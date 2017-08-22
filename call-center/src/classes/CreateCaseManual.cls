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
    public Case manualCase { get; set; }
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
        manualCase = new Case();
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

            manualCase.ContactId = gc.Id;

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
        return VisualforceControllerUtil.getRecordPageReference(guarantorRecordId);
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

    //get the Patient and Guarantor information
    public void gotoCaseCreation() {
        if (String.isNotBlank(caseType)) {
            caseTypeSelected = true;
            manualCase.RecordTypeId = getCaseRecordTypeId(caseType);

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
                manualCase.Patient__c = gc.Id;
                if (chargeGroup != null) {
                    manualCase.Guarantor_Information__c = chargeGroup.Guarantor__c;
                }
                guarantorContact = ContactService.getContactDetails(manualCase.Guarantor_Information__c);
                patientContact = gc;
            } else if (gc.RecordType.DeveloperName == 'Guarantor') {
                manualCase.Guarantor_Information__c = gc.Id;
                if (chargeGroup != null) {
                    manualCase.Patient__c = chargeGroup.Patient__c;
                }
                patientContact = ContactService.getContactDetails(manualCase.Patient__c);
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
                manualCase.ContactId = guarantorContact.Id;
            }
            manualCase.Subject = manualCase.Reason;
            // TODO: Restore this when we know what the requirements are for assignment rules
//            AssignmentRule assignmentRule = new AssignmentRule();
//            if (AssignmentRuleSecurityContext.SELECT_CONTEXT.actionAllowed()) {
//                assignmentRule = [
//                    SELECT Id
//                    FROM AssignmentRule
//                    WHERE SobjectType = 'Case' AND Active = TRUE
//                    LIMIT 1
//                ];
//            }
//
//            Database.DMLOptions dmlOpts = new Database.DMLOptions();
//            dmlOpts.AssignmentRuleHeader.assignmentRuleId = assignmentRule.Id;
//            manualCase.setOptions(dmlOpts);

            if (CaseSecurityContext.CREATE_WITH_GT_CONTEXT.actionAllowed()) {
                // TODO: This has to be an upsert because the case has already been created at this point (by the standard controller?)
                upsert manualCase;
            }

            //add selected Charge Groups to Case
            List<Case_Charge_Group_Junction__c> caseChargeGroupJunctions = new List<Case_Charge_Group_Junction__c>();
            for (ChargeGroupWrapper chargeGroupWrapper : chargeGroupList) {
                if (chargeGroupWrapper.isSelected) {
                    Case_Charge_Group_Junction__c caseChargeGroupJunction = new Case_Charge_Group_Junction__c();
                    caseChargeGroupJunction.Case__c = manualCase.Id;
                    caseChargeGroupJunction.Charge_Group__c = chargeGroupWrapper.cg.Id;
                    caseChargeGroupJunctions.add(caseChargeGroupJunction);
                }
            }
            if (CaseCGJunctionSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                insert caseChargeGroupJunctions;
            }

            //create case comments
            if (String.isNotBlank(caseNotes)) {
                CaseComment caseComment = new CaseComment();
                caseComment.ParentId = manualCase.Id;
                caseComment.CommentBody = caseNotes;

                if (CaseCommentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    insert caseComment;
                }
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Created Successfully!'));
            if (Test.isRunningTest()) {

                TestUtility.generateException();
            }
            return VisualforceControllerUtil.getRecordPageReference(guarantorRecordId);
        } catch (Exception e) {
            // Debug error response
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: ' + e.getMessage()));
        }

        return null;
    }

    public void refresh() {
        if (ApexPages.currentPage().getParameters().containsKey('reason')) {
            manualCase.Reason = ApexPages.currentPage().getParameters().get('reason');
            
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
                        Coverage__r.Date_Effective__c, Coverage__r.Subscriber_Name__c, Coverage__r.Subscriber_Id__c
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
                    SELECT Sirono_Id__c, Amount__c
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