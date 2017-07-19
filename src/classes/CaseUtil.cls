/**
 * @Util Class for the All Auto Case Creation, Auto Case Closure, Add\Remove the guarantor to the campaign functionality.*
 **/

public class CaseUtil {
    public static Boolean executeCampaignMemberTrigger = True;
    public static Boolean executeRemoveCampaignTrigger = True;

    public static Boolean createCaseInTrigger = true;

    // Final variables for Contact Query filter.
    public static final String Delinquent_Bal_GT = 'Delinquent_Bal_GT';
    public static final String Delinquent_Bal_LT = 'Delinquent_Bal_LT';
    public static final String Overdue_Bal_GT = 'Overdue_Bal_GT';
    public static final String Overdue_Bal_LT = 'Overdue_Bal_LT';

    // Create instant of CmpnMemberSecurityContext class. It is use to check Delete access on Object.
    public static CmpnMemberSecurityContext cmpnMemSecurityContext = new CmpnMemberSecurityContext();

    public CaseUtil() {

    }

    /*
    * Close the Early Out Auto Case.
    */
    public static void callEarlyOutAutoCaseCloser() {
        if (StatementSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            List<Statement__c> lstStatement = [
                SELECT Id, Guarantor__c
                FROM Statement__c
                WHERE Statement_Date__c = :System.today()
                and Day_only(CreatedDate) != :System.today()
            ];
            callCloseEarlyOutAutoCase(lstStatement);
        }
    }

    /*
    * Close Early Out Auto Cases created for the guarantors associated with these statements.
    */
    @TestVisible
    private static void callCloseEarlyOutAutoCase(List<Statement__c> lstStatement) {
        Set<String> setContact = new Set<String>();
        for (Statement__c objStatement : lstStatement) {
            setContact.add(objStatement.Guarantor__c);
        }
        closeEarlyOutAutoCase(setContact);
    }

    /*
    * Close the Early Out Auto Cases associated with these guarantors and remove the from the Early Out campaigns
    */
    public static void closeEarlyOutAutoCase(Set<String> setContact) {

        Map<Id, Contact> mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(setContact, Overdue_Bal_LT));

        if (mapContact.size() > 0) {
            List<Case> earlyOutCases = new List<Case>();
            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                earlyOutCases = [
                    SELECT Id, Status, Reason, Guarantor_Information__c
                    FROM Case
                    WHERE Type = :Constants.CASE_TYPE_OVERDUE AND
                    Guarantor_Information__c IN :mapContact.keyset()
                    AND IsClosed = false
                ];
            }
            Set<Id> setContactWithEarlyOutCase = new Set<Id>();
            for (Case objCase: earlyOutCases) {
                objCase.Status = Constants.CASE_STATUS_CLOSED;
                objCase.Reason = Constants.CASE_REASON_CLOSED_AUTOMATED;
                setContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            executeRemoveCampaignTrigger = false;
            if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                UPDATE earlyOutCases;
            }

            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String> {
                Constants.CAMPAIGN_NAME_OVERDUE, Constants.CAMPAIGN_NAME_OVERDUE_M
            });

            deleteCampaignMembers(setContactWithEarlyOutCase, mapCampaignMapping.values());
        }
    }

    /*
    * Call the Pre-Collection Auto Case closer for all guarantors associated with today's statements.
    */
    public static void callPrecollectionsAutoCaseCloser() {
        if (StatementSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            List<Statement__c> lstStatement = [
                SELECT Id, Guarantor__c
                FROM Statement__c
                WHERE Statement_Date__c = :System.today()
                AND Day_only(CreatedDate) != :System.today()
            ];
            callClosePrecollectionsAutoCase(lstStatement);
        }
    }

    /*
    *  Close Pre-Collection Auto Cases and Remove the Campaign member from Campaign for all the guarantors
    *  associated with this list of statements
    */
    @TestVisible
    private static void callClosePrecollectionsAutoCase(List<Statement__c> lstStatement) {
        Set<String> setContact = new Set<String>();
        for (Statement__c objStatement : lstStatement) {
            setContact.add(objStatement.Guarantor__c);
        }
        closePrecollectionsAutoCase(setContact);
    }

    /*
    * Close Pre-Collection Auto Case for the given list of guarantors. Also remove them from the Precollections
    * Campaign.
    */
    public static void closePrecollectionsAutoCase(Set<String> setContact) {
        Map<Id, Contact> mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(setContact, Delinquent_Bal_LT));

        if (mapContact.size() > 0) {
            List<Case> precollections = new List<Case>();
            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                precollections = [
                    SELECT Id, Status, Reason, Guarantor_Information__c
                    FROM Case
                    WHERE Type = :Constants.CASE_TYPE_PRECOLLECTIONS
                    AND Guarantor_Information__c IN :mapContact.keyset()
                    AND IsClosed = false
                ];
            }
            Set<Id> setContactWithEarlyOutCase = new Set<Id>();
            for (Case objCase: precollections) {
                objCase.Status = Constants.CASE_STATUS_CLOSED;
                objCase.Reason = Constants.CASE_REASON_CLOSED_AUTOMATED;
                setContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            executeRemoveCampaignTrigger = false;
            if (SecurityUtils.verify(CaseSecurityContext.UPDATE_CONTEXT)) {
                UPDATE precollections;
            }

            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String> {
                Constants.CAMPAIGN_NAME_PRECOLLECTIONS, Constants.CAMPAIGN_NAME_PRECOLLECTIONS_M
            });

            deleteCampaignMembers(setContactWithEarlyOutCase, mapCampaignMapping.values());
        }
    }

    /*
    * Create Encounter Auto Case and add them to the Preservice campaigns
    */
    public static void createEncounterAutoCase(List<Encounter__c> lstEncounter) {
        Set<String> setContact = new Set<String>();
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        List<Group> lstGroup = new List<Group>();

        for (Encounter__c obj : lstEncounter) {
            if (obj.Patient_Portion__c > 0 && obj.Date_of_Service__c >= Date.today()) {
                if (obj.Guarantor__c != null) {
                    setContact.add(obj.Guarantor__c);
                }
            }
        }
        mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(setContact, null));

        if (mapContact.size() > 0) {
            Map<Id, Id> mapComplianceContact = new Map<Id, Id>();
            if (GroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                lstGroup = [
                    SELECT Id
                    FROM Group
                    WHERE Name = :Constants.RECORD_TYPE_AUTOMATED_CASES
                    AND Type = :Constants.GROUP_TYPE_QUEUE
                ];
            }

            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Case objCase: [
                    SELECT Id, Guarantor_Information__c
                    FROM Case
                    WHERE Reason = :Constants.CASE_REASON_COMPLIANCE_ISSUE
                    AND Guarantor_Information__c IN :mapContact.keyset()
                    AND IsClosed = false
                ]) {
                    mapComplianceContact.Put(objCase.Guarantor_Information__c, objCase.id);
                }
            }

            Map<Id, Case> mapContactCase = new Map<Id, Case>();

            //Create a new Case
            for (Encounter__c obj : lstEncounter) {
                String strContactId;
                if (obj.Patient_Portion__c > 0 && obj.Date_of_Service__c >= Date.today()) {
                    if (obj.Guarantor__c != null) strContactId = obj.Guarantor__c;
                }
                if (strContactId != null && !mapComplianceContact.Containskey(strContactId)) {
                    Contact objContact = mapContact.get(strContactId);
                    Case objCase = new Case();
                    objCase.Guarantor_Information__c = objContact.Id;
                    objCase.ContactId = objContact.Id;
                    objCase.Encounter__c = obj.Id;
                    objCase.Type = Constants.CASE_TYPE_ENCOUNTER;
                    objCase.Status = Constants.CASE_STATUS_NEW;
                    objCase.Subject = Constants.CASE_SUBJECT_ENCOUNTER;
                    objCase.RecordTypeID = RecordTypeUtil.automatedCaseRt;
                    if (lstGroup.size() > 0) {
                        objCase.ownerId = lstGroup[0].Id;
                    }
                    mapContactCase.Put(objContact.Id, objCase);
                }
            }
            if (mapContactCase.size() > 0) {
                if (CaseSecurityContext.CU_CREATE_WITH_ENCOUNTER_CONTEXT.actionAllowed()) {
                    INSERT mapContactCase.values();
                }
            }
        }
    }
    
    /*
    * Close Encounter Auto Case and remove from the PreService campaigns
    */
    public static void callCloseEncounterAutoCase(List<Encounter__c> lstEncounter, Boolean fromPaymentMethod) {
        Set<String> setContact = new Set<String>();
        Set<String> setEncounterIds = new Set<String>();
        for (Encounter__c obj : lstEncounter) {
            if (obj.Cancelled__c || obj.Date_of_Service__c < Date.today()
                || obj.Patient_Portion__c == 0 || fromPaymentMethod) {
                if (obj.Guarantor__c != null) {
                    setContact.add(obj.Guarantor__c);
                    setEncounterIds.add(obj.Id);
                }
            }
        }
        closeEncounterAutoCase(setEncounterIds, setContact, false);
    }

    /*
    *  Close Encounter Auto Case for the given Encounter Ids and remove their guarantors from the PreService Campaigns
    */
    private static void closeEncounterAutoCase(Set<String> setEncounterIds,
        Set<String> setContact, Boolean skipEncounterCaseUpdate) {
        if (!skipEncounterCaseUpdate) {
            List<Case> encounterCase = new List<Case>();
            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                encounterCase = [
                    SELECT Id, Status, Reason, Guarantor_Information__c
                    FROM Case
                    WHERE Type = :Constants.CASE_TYPE_ENCOUNTER
                    AND Guarantor_Information__c IN :setContact
                    AND Encounter__c IN :setEncounterIds
                ];
            }
            for (Case objCase: encounterCase) {
                objCase.Status = Constants.CASE_STATUS_CLOSED;
                objCase.Reason = Constants.CASE_REASON_CLOSED_AUTOMATED;
            }
            executeRemoveCampaignTrigger = false;
            if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                UPDATE encounterCase;
            }
        }

        Set<String> contactWithoutOpenEncounters = new Set<String>();
        if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            List<Case> openEncounterCases = [
                SELECT Id, Guarantor_Information__c
                FROM Case
                WHERE Type = :Constants.CASE_TYPE_ENCOUNTER
                AND IsClosed = false
                AND Guarantor_Information__c IN :setContact
            ];
            for (Case c: openEncounterCases) {
                contactWithoutOpenEncounters.add(c.Guarantor_Information__c);
            }
        }

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_PRESERVICE, Constants.CAMPAIGN_NAME_PRESERVICE_M
        });

        if (cmpnMemSecurityContext.deleteActionAllowed()) {
            if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                DELETE [
                    SELECT Id, ContactId
                    FROM CampaignMember
                    WHERE Campaign.IsActive = true
                    AND Campaign.Name IN :mapCampaignMapping.values()
                    AND ContactId IN :setContact AND ContactId NOT IN :contactWithoutOpenEncounters
                ];
            }
        }
    }

    /*
    * Method for Create Delinquent Auto Case and Add the Campaign member to Campaign.
    */
    public static void createDelinquentPaymentCase(Set<Id> contactIds) {
        List<Group> lstGroup = new List<Group>();
        if (GroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            lstGroup = [
                SELECT Id
                FROM Group
                WHERE Name = :Constants.RECORD_TYPE_AUTOMATED_CASES
                AND Type = :Constants.GROUP_TYPE_QUEUE
            ];
        }
        Map<String, Case> mapContactCase = new Map<String, Case>();

        if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            for (Case objCase: [
                SELECT Id, Guarantor_Information__c
                FROM Case
                WHERE Guarantor_Information__c IN :contactIds
                AND (Type = :Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS OR Reason = :Constants.CASE_REASON_COMPLIANCE_ISSUE)
                AND IsClosed = false
            ]) {
                contactIds.Remove(objCase.Guarantor_Information__c);
            }
        }

        Map<Id, Contact> mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(contactIds, null));

        for (String strContactId : mapContact.keyset()) {
            Contact objContact = mapContact.get(strContactId);

            Case objCase = new Case();
            objCase.Guarantor_Information__c = strContactId;
            objCase.ContactId = strContactId;
            objCase.Type = Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS;
            objCase.Status = Constants.CASE_STATUS_NEW;
            objCase.Subject = Constants.CASE_SUBJECT_PAST_DUE_PAYMENT_PLANS;
            objCase.RecordTypeID = RecordTypeUtil.automatedCaseRt;
            if (lstGroup.size() > 0) {
                objCase.ownerId = lstGroup[0].Id;
            }
            mapContactCase.Put(strContactId, objCase);
        }

        if (CaseSecurityContext.CREATE_WITH_GT_CONTEXT.actionAllowed()) {
            INSERT mapContactCase.Values();
        }
    }

    /*
    * Method for Create Delinquent Auto Case and Add the Campaign member to Campaign.
    */
    public static void closeDelinquentPaymentCase(Set<Id> contactIds, Set<Id> paymentPlanID) {

        if (!paymentPlanID.IsEmpty()) {
            if (PaymentPlanSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Payment_Plan__c test: [
                    SELECT Id, Guarantor__c
                    FROM Payment_Plan__c
                    WHERE Id NOT IN :paymentPlanID
                    AND Guarantor__c IN :contactIds
                    AND active__c = true
                    AND Delinquent__c = true
                ]) {
                    contactIds.remove(test.Guarantor__c);
                }
            }
        }

        if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            List<Case> lstCase = [
                SELECT Id, Guarantor_Information__c
                FROM Case
                WHERE Guarantor_Information__c IN :contactIds
                AND Type = :Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS
                AND IsClosed = false
            ];
            contactIds = new Set<Id>();
            for (Case objCase: lstCase) {
                objCase.Status = Constants.CASE_STATUS_CLOSED;
                objCase.Reason = Constants.CASE_REASON_CLOSED_AUTOMATED;
                contactIds.add(objCase.Guarantor_Information__c);
            }
            if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                UPDATE lstCase;
            }
        }

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_PAST_DUE, Constants.CAMPAIGN_NAME_PAST_DUE_M
        });

        deleteCampaignMembers(contactIds, mapCampaignMapping.values());
    }

    /*
    * 08-25-2016: Sirono - Tracker # 127517003 For Credit Card Error Case Creation
    * 08-25-2016: Sirono - Tracker # 127517003 For Add Guarantor to the CC Error Call list
    * Method for Create CC Error Auto Case and Add the Campaign member to Campaign.
    */
    public static void createCCErrorCase(Set<Id> contactIds) {
        Map<String, Case> mapContactCase = new Map<String, Case>();
        List<Group> lstGroup = new List<Group>();
        Map<Id, Contact> mapContact = new Map<Id, Contact>();

        if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            for (Case objCase: [
                SELECT Id, Guarantor_Information__c
                FROM Case
                WHERE Guarantor_Information__c IN :contactIds
                AND (Type = :Constants.CASE_TYPE_PAYMENT_PLAN_ERROR OR Reason = :Constants.CASE_REASON_COMPLIANCE_ISSUE)
                AND IsClosed = false
            ]) {
                contactIds.Remove(objCase.Guarantor_Information__c);
            }
        }

        if (GroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            lstGroup = [
                SELECT Id
                FROM Group
                WHERE Name = :Constants.RECORD_TYPE_AUTOMATED_CASES
                AND Type = :Constants.GROUP_TYPE_QUEUE
            ];
        }
        mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(contactIds, null));
        for (String strContactId : mapContact.keyset()) {
            Contact objContact = mapContact.get(strContactId);

            Case objCase = new Case();
            objCase.Guarantor_Information__c = strContactId;
            objCase.ContactId = strContactId;
            objCase.Type = Constants.CASE_TYPE_PAYMENT_PLAN_ERROR;
            objCase.Status = Constants.CASE_STATUS_NEW;
            objCase.Subject = Constants.CASE_SUBJECT_PAYMENT_PLAN_ERROR;
            objCase.RecordTypeID = RecordTypeUtil.automatedCaseRt;
            if (lstGroup.size() > 0) {
                objCase.ownerId = lstGroup[0].Id;
            }
            mapContactCase.Put(strContactId, objCase);
        }
        if (CaseSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT mapContactCase.values();
        }
    }

    /*
    * Method for Create CC Error Auto Case and Remove the Campaign member to Campaign.
    */
    public static void closePaymentPlanErrorCase(Set<Id> contactIds, Set<Id> paymentPlanID) {

        if (!paymentPlanID.IsEmpty()) {
            if (PaymentPlanSecurityContext.SELECT_CONTEXT_FOR_CLOSE.actionAllowed()) {
                for (Payment_Plan__c test: [
                    SELECT Id,Guarantor__c
                    FROM Payment_Plan__c
                    WHERE Id NOT IN :paymentPlanID
                    AND Guarantor__c IN :contactIds
                    AND active__c = true
                    AND Has_Error__c = true
                    AND Remaining_Balance__c <= -100
                ]) {
                    contactIds.remove(test.Guarantor__c);
                }
            }
        }

        List<Case> lstCase = new List<Case>();
        if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            lstCase = [
                SELECT Id, Guarantor_Information__c
                FROM Case
                WHERE Guarantor_Information__c IN :contactIds
                AND Type = :Constants.CASE_TYPE_PAYMENT_PLAN_ERROR AND IsClosed = false
            ];
        }
        contactIds = new Set<Id>();
        for (Case objCase : lstCase) {
            objCase.Status = Constants.CASE_STATUS_CLOSED;
            objCase.Reason = Constants.CASE_REASON_CLOSED_AUTOMATED;
            contactIds.add(objCase.Guarantor_Information__c);
        }
        if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            UPDATE lstCase;
        }

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String> {
            Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR, Constants.CAMPAIGN_NAME_PAYMENT_PLAN_ERROR_M
        });

        deleteCampaignMembers(contactIds, mapCampaignMapping.values());
    }

    /**
     * This method is use to delete Campaign Member.
     **/
    private static void deleteCampaignMembers(Set<Id> contactIds, List<String> cmpnNames) {
        if (cmpnMemSecurityContext.deleteActionAllowed()) {
            if (CmpnMemberSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                DELETE [
                    SELECT Id, ContactId
                    FROM CampaignMember
                    WHERE Campaign.Name IN :cmpnNames
                    AND ContactId IN :contactIds
                ];
            }
        }
    }

    //Get the Campaign Mappings from the meta data.
    public static Map<String, String> campaignMapping(Set<String> campaignName) {
        Map<String, String> mapCampaignMapping = new Map<String, String>();

        if (CampaignMappingMdtSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            for (Campaign_Mapping__mdt objCM: [
                SELECT MasterLabel, Salesforce_Campaign_Name__c
                FROM Campaign_Mapping__mdt
                WHERE MasterLabel IN :campaignName
            ]) {
                mapCampaignMapping.put(objCM.MasterLabel, objCM.Salesforce_Campaign_Name__c);
            }
        }
        return mapCampaignMapping;
    }
}