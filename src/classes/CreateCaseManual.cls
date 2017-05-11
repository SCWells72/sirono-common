/*
* @author Sirono
* @version 1.0.1
* @Date: 08-05-2016
* @description Create a Manual case based on the conditions*
*
* 08-05-2016: Sirono - Tracker # 127400857 For Manual Case Creation
*
* 10-19-2016: Viraj Rana - Tracker # 132104143: Pre-populate manual case fields where necessary.
*/


public with sharing class CreateCaseManual {
  public String guarantorRecordId { get; set; }
  public Boolean chargeGroupsSelected { get; set; }
  public String guarantorId { get; set; }
  public String guarantorName { get; set; }
  public String chargeGroupId { get; set; }
  public List<ChargeGroupWrapper> chargeGroupList { get; set; }
  public Case caseObj { get; set; }
  public String caseType { get; set; }
  public Boolean caseTypeSelected { get; set; }
  public Contact gc { get; set; }
  public String caseNotes { get; set; }
  public Contact guarantorContact { get; set; }
  public Contact patientContact { get; set; }
  public Charge_Group__c chargeGroup = new Charge_Group__c();
  public string coverageJson { get; set; }
  public string transactionJson { get; set; }

  //11-23-2016: Viraj Rana - Tracker # 132104143: Pre-populate manual case fields where necessary.
  //This set is also used whenever we got Coverage record based on Charge Group's "Date Of Service Start" field.
  Set<String> setChargeGroupId = new Set<String>();

    /*
     * Constructor to get the guarantor and charge group details.
    */
  public CreateCaseManual(ApexPages.StandardController sc) {
    chargeGroupsSelected = false;
    chargeGroupList = new List<ChargeGroupWrapper>();
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
          gc = GuarantorDao.getGuarantorFilterCGByAcctSubStatus(guarantorRecordId, Constants.CGConstraintsForCase);
          guarantorId = PayStaffWSUtill.fetchGuarantorId(gc);
        } else if (objContact.RecordType.DeveloperName == 'Patient') {
          gc = PayStaffWSUtill.fetchPatientContactWithCGConstraintsForCase(guarantorRecordId);
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
      chargeGroupId = '';
    }
  }

    /*
    * Cancel the case creation and back to the guarantor record.
    */
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

    /*
    * check charge group is selected or not and show the guarantor details.
    */
  public Pagereference doNext() {
    chargeGroupsSelected = false;

    //validate to see if user have selected Case Type
    chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);

    if (!isEmpty(chargeGroupId)) {
      chargeGroupsSelected = true;
    } else {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.Charge_Groups_Require);
      ApexPages.addMessage(myMsg);
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
          setChargeGroupId.add(cg.cg.id);
        }
      }
      if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
        List<Charge_Group__c> lstChargeGroup = [
            SELECT Id, Guarantor__c, Patient__c
            FROM Charge_Group__c
            WHERE Id IN :setChargeGroupId
            ORDER BY CreatedDate DESC
        ];
        if (lstChargeGroup.size() > 0) {
          chargeGroup = lstChargeGroup[0];
        }
      }

      if (gc.RecordType.DeveloperName == 'Patient') {
        caseObj.Patient__c = gc.id;
        if (chargeGroup != null) {
          caseObj.Guarantor_Information__c = chargeGroup.Guarantor__c;
        }
        guarantorContact = PayStaffWSUtill.fetchContact(caseObj.Guarantor_Information__c);
        patientContact = gc;
      } else if (gc.RecordType.DeveloperName == 'Guarantor') {
        caseObj.Guarantor_Information__c = gc.id;
        if (chargeGroup != null) {
          caseObj.Patient__c = chargeGroup.Patient__c;
        }
        patientContact = PayStaffWSUtill.fetchContact(caseObj.Patient__c);
        guarantorContact = gc;
      }

    } else {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.Case_Type_Require);
      ApexPages.addMessage(myMsg);
    }
  }

  //Create a new case
  public PageReference submit() {
    try {

      //Creating the DMLOptions for "Assign using active assignment rules" checkbox
      if (guarantorContact != null) {
        caseObj.ContactID = guarantorContact.id;
      }
      caseObj.Subject = caseObj.Reason;
      AssignmentRule ar = new AssignmentRule();
      if (AssignmentRuleSecurityContext.SELECT_CONTEXT.actionAllowed()) {
        ar = [
            SELECT Id
            FROM AssignmentRule
            WHERE SobjectType = 'Case' AND Active = true
            LIMIT 1
        ];
      }

      Database.DMLOptions dmlOpts = new Database.DMLOptions();
      dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
      caseObj.setOptions(dmlOpts);

      if (CaseSecurityContext.CREATE_WITH_GT_CONTEXT.actionAllowed()) {
        INSERT caseObj;
      }

      //create case comments
      if (String.isNotBlank(caseNotes)) {
        CaseComment cc = new CaseComment();
        cc.ParentId = caseObj.Id;
        cc.CommentBody = caseNotes;

        if (CaseCommentSecurityContext.CREATE_CONTEXT.actionAllowed()) {
          INSERT cc;
        }
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
        INSERT caseCGs;
      }

      ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
      if (test.isRunningTest()) {

        TestUtility.generateException();
      }

    } catch (Exception e) {
      // Debug error response
      ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + e.getMessage()));
    }
    return null;
  }

  public void refresh() {
    if (Apexpages.currentPage().getParameters().containsKey('reason')) {
      caseObj.Reason = Apexpages.currentPage().getParameters().get('reason');
            
            /* 11-23-2016: Viraj Rana - Tracker # 132104143: Pre-populate manual case fields where necessary.
             * Populating coverage data using the selected Chargegroup with the oldest "Date Of Service Start" field.
            */
      Charge_Group__c cg = new Charge_Group__c();
      if (ChargeGroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
        List<Charge_Group__c> lstChargeGroup = [
            SELECT Id
            FROM Charge_Group__c
            WHERE Id IN :setChargeGroupId
            ORDER BY Date_Of_Service_Start_Date__c
        ];
        if (lstChargeGroup.size() > 0) {
          cg = lstChargeGroup[0];
        }
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
          coverageJson = json.serialize(coverageDetail[0]);
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
          transactionJson = json.serialize(transactionDetail[0]);
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