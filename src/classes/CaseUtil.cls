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
      Method for getting the list of the statement and pass it into the method.
    */
    public static void callEarlyOutAutoCase() {
        if (StatementSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            List<Statement__c> statement = [
                    SELECT Id, Guarantor__c
                    FROM Statement__c
                    WHERE Statement_Date__c = :System.today()
            ];
            createEarlyOutAutoCase(statement);
        }
    }

    /*
    * Method for Create Early Out Auto Case and Add the Campaign member to Campaign.
    */
    public static void createEarlyOutAutoCase(List<Statement__c> statement) {
        Set<String> setContact = new Set<String>();
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        List<Group> lstGroup = new List<Group>();

        for (Statement__c objStatement : statement) {
            setContact.add(objStatement.Guarantor__c);
        }

        mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(setContact, Overdue_Bal_GT));

        if (mapContact.size() > 0) {
            Map<Id, Id> mapComplianceContact = new Map<Id, Id>();
            if (GroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                lstGroup = [
                        SELECT Id
                        FROM Group
                        WHERE Name = 'Automated Cases'
                        AND Type = 'Queue'
                ];
            }

            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Case objCase: [
                        SELECT Id, Guarantor_Information__c
                        FROM Case
                        WHERE Reason = 'Compliance Issue' AND
                        Guarantor_Information__c IN :mapContact.keyset()
                        AND IsClosed = false
                ]) {
                    mapComplianceContact.Put(objCase.Guarantor_Information__c, objCase.id);
                }
            }

            Map<Id, Case> mapContactCase = new Map<Id, Case>();
            Map<String, String> mapCampaignName = new Map<String, String>();
            Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
            Map<String,CampaignMember> mapUpdateCampaignMembers = new Map<String,CampaignMember>();
            
            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'Early-out', 'Early-out M'
            });
            string earlyOut = mapCampaignMapping.get('Early-out');
            string earlyOutMobile = mapCampaignMapping.get('Early-out M');

            if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                    CmpnMemberSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Campaign objCampaign: [
                        SELECT Id, Name, (
                                SELECT Id, ContactId
                                FROM CampaignMembers
                                WHERE ContactId IN :mapContact.keyset()
                        )
                        FROM Campaign
                        WHERE Name = :earlyOut OR Name = :earlyOutMobile
                ]) {
                    mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                    mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                    for (CampaignMember objCM: objCampaign.CampaignMembers) {
                        mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                        mapUpdateCampaignMembers.put(objCM.ContactId + '-' + objCampaign.Name, objCM);
                    }
                }
            }

            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
            List<CampaignMember> lstUpdateCampaignMember = new List<CampaignMember>();
            List<RecordType> rt = new List<RecordType>();
            if (RecordTypeSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                rt = [
                        SELECT Id
                        FROM RecordType
                        WHERE SobjectType = 'Case'
                        AND DeveloperName = 'Automated_Cases'
                ];
            }

            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                //Check Any Early Out Case is exist if exist the closed it and creted new one.
                List<Case> lstEarlyOutCases = [
                        SELECT Id, Type
                        FROM Case
                        WHERE Type = 'Early Out'
                        AND Guarantor_Information__c IN :mapContact.keyset()
                        AND Guarantor_Information__c NOT IN :mapComplianceContact.keyset()
                        AND IsClosed = false
                ];
                for (Case objCase: lstEarlyOutCases) {
                    objCase.Status = 'Closed';
                    objCase.Reason = 'Closed - Automated';
                }
                executeRemoveCampaignTrigger = false;
                if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                    UPDATE lstEarlyOutCases;
                }
            }

            //Create a new Case
            for (String strContactId : mapContact.Keyset()) {
                if (!mapComplianceContact.Containskey(strContactId)) {
                    Contact objContact = mapContact.get(strContactId);
                    Case objCase = new Case();
                    objCase.Guarantor_Information__c = objContact.Id;
                    objCase.ContactId = objContact.Id;
                    objCase.Type = 'Early Out';
                    objCase.Status = 'New';
                    objCase.Subject = 'Early Out';
                    objCase.RecordTypeID = rt[0].Id;
                    if (lstGroup.size() > 0) {
                        objCase.ownerId = lstGroup[0].Id;
                    }
                    mapContactCase.Put(objContact.Id, objCase);

                    //Add CampaignMember
                    if (objContact.HomePhone != null || objContact.OtherPhone != null) {
                        if (mapCampaignName.containsKey(earlyOut)) {
                    	    if (mapCampaignMembers.get(earlyOut).contains(objContact.Id)) {
                                CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id + '-' + earlyOut);
                                lstUpdateCampaignMember.add(cm);
                    	    } else {
                                CampaignMember cm = new CampaignMember();
                                cm.CampaignId = mapCampaignName.get(earlyOut);
                                cm.ContactId = objContact.Id;
                                lstCampaignMember.add(cm);
                    	    }
                        }
                    }
                    if (objContact.MobilePhone != null) {
                        if (mapCampaignName.containsKey(earlyOutMobile)) {
                            if (mapCampaignMembers.get(earlyOutMobile).contains(objContact.Id)) {
                                CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id + '-' + earlyOutMobile);
                                lstUpdateCampaignMember.add(cm);
                            } else {
                                CampaignMember cm = New CampaignMember();
	                        cm.CampaignId = mapCampaignName.get(earlyOutMobile);
	                        cm.ContactId = objContact.Id;
	                        lstCampaignMember.add(cm);
                            }
                        }                        
                    }
                }
            }
            
            if (mapContactCase.size() > 0) {
                if (SecurityUtils.verify(CaseSecurityContext.CREATE_WITH_GT_CONTEXT)) {
                    INSERT mapContactCase.values();
                }

                //Insert the Case Charge Group
                List<Case_Charge_Group_Junction__c> lstCCG = new List<Case_Charge_Group_Junction__c>();
                for (Charge_Group__c cg: ChargeGroupService.getCGBasedOnGuarantor(mapContactCase.keyset())) {
                    if (mapContactCase.Containskey(cg.Guarantor__c)) {
                        Case objCase = mapContactCase.get(cg.Guarantor__c);
                        Case_Charge_Group_Junction__c ccg = new Case_Charge_Group_Junction__c();
                        ccg.Case__c = objCase.Id;
                        ccg.Charge_Group__c = cg.Id;
                        lstCCG.add(ccg);
                    }
                }
                if (CaseCGJunctionSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    INSERT lstCCG;
                }
            }

            // Assign Case Id in Campaign Member.
            if (lstCampaignMember.size() > 0) {
                for (CampaignMember cm : lstCampaignMember) {
                    if (mapContactCase.Containskey(cm.ContactId)) {
                        Case objCase = mapContactCase.get(cm.ContactId);
                        cm.Case_ID__c = objCase.Id;
                    }
                }
                /* Set createCaseInTrigger flag to false to prevent CampaignMemberTrigger
                 * from creating a case with "Call List Case" record type.
                */
                createCaseInTrigger = false;
                if (CmpnMemberSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    INSERT lstCampaignMember;
                }
                createCaseInTrigger = true;
            }

            // Update Case Id in Old Campaign Member.
            if (lstUpdateCampaignMember.size() > 0) {
                for (CampaignMember cm : lstUpdateCampaignMember) {
                    if (mapContactCase.Containskey(cm.ContactId)) {
                        Case objCase = mapContactCase.get(cm.ContactId);
                        cm.Case_ID__c = objCase.Id;
                    }
                }
                if (SecurityUtils.verify(CmpnMemberSecurityContext.UPDATE_CONTEXT)) {
                    UPDATE lstUpdateCampaignMember;
                }
            }
        }
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
    public static void callCloseEarlyOutAutoCase(List<Statement__c> lstStatement) {
        Set<String> setContact = new Set<String>();
        for (Statement__c objStatement : lstStatement) {
            setContact.add(objStatement.Guarantor__c);
        }
        closeEarlyOutAutoCase(setContact);
    }

    /*
    * Close the Early Out Auto Cases associated with these guarantors and remove the from the Early Out campaigns
    */
    Public Static void closeEarlyOutAutoCase(Set<String> setContact) {

        Map<Id, Contact> mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(setContact, Overdue_Bal_LT));

        if (mapContact.size() > 0) {
            List<Case> earlyOutCases = new List<Case>();
            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                earlyOutCases = [
                        SELECT Id, Status, Reason, Guarantor_Information__c
                        FROM Case
                        WHERE Type = 'Early Out' AND
                        Guarantor_Information__c IN :mapContact.keyset()
                        AND IsClosed = false
                ];
            }
            Set<Id> setContactWithEarlyOutCase = new Set<Id>();
            for (Case objCase: earlyOutCases) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
                setContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            executeRemoveCampaignTrigger = false;
            if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                UPDATE earlyOutCases;
            }

            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'Early-out', 'Early-out M'
            });

            deleteCampaignMembers(setContactWithEarlyOutCase, mapCampaignMapping.values());
        }
    }

    /*
    * 08-12-2016: Sirono - Tracker # 127517035 For Precollections Case Creation
    * Method for Create Pre-Collection Auto Case and Add the Campaign member to Campaign.
    */
    public static void callPrecollectionsAutoCase() {
        if (StatementSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            List<Statement__c> lstStatement = [SELECT Id, Guarantor__c FROM Statement__c WHERE Statement_Date__c = :System.today()];
            createPrecollectionsAutoCase(lstStatement);
        }
    }

    /*
    * 08-12-2016: Sirono - Tracker # 127517035 For Precollections Case Creation
    * Method for Create Pre-Collection Auto Case and Add the Campaign member to Campaign.
    * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Delinquent_Balance__c = '< 0' to '> 0'" in condition.
    */
    public Static void createPrecollectionsAutoCase(List<Statement__c> lstStatement) {
        Set<String> setContact = new Set<String>();
        Map<Id, Contact> mapContact = new Map<Id, Contact>();
        List<Group> lstGroup = new List<Group>();

        for (Statement__c objStatement : lstStatement) {
            setContact.add(objStatement.Guarantor__c);
        }

        mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(setContact, Delinquent_Bal_GT));

        if (mapContact.size() > 0) {
            Map<Id, Id> mapComplianceContact = new Map<Id, Id>();
            if (GroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
                lstGroup = [
                        SELECT Id
                        FROM Group
                        WHERE Name = 'Automated Cases'
                        AND Type = 'Queue'
                ];
            }

            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Case objCase: [
                        SELECT Id, Guarantor_Information__c
                        FROM Case
                        WHERE Reason = 'Compliance Issue'
                        AND Guarantor_Information__c IN :mapContact.keyset()
                        AND IsClosed = false
                ]) {
                    mapComplianceContact.Put(objCase.Guarantor_Information__c, objCase.id);
                }
            }

            Map<Id, Case> mapContactCase = new Map<Id, Case>();
            Map<String, String> mapCampaignName = new Map<String, String>();
            Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
            Map<String,CampaignMember> mapUpdateCampaignMembers = new Map<String,CampaignMember>();
            
            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'PreCollections', 'PreCollections M'
            });
            String preCollection = mapCampaignMapping.get('PreCollections');
            String preCollectionMobile = mapCampaignMapping.get('PreCollections M');

            if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                    CmpnMemberSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Campaign objCampaign: [
                        SELECT Id, Name, (
                                SELECT Id, ContactId
                                FROM CampaignMembers
                                WHERE ContactId IN :mapContact.keyset()
                        )
                        FROM Campaign
                        WHERE Name = :preCollection
                        OR Name = :preCollectionMobile
                ]) {
                    mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                    mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                    for (CampaignMember objCM : objCampaign.CampaignMembers) {
                        mapCampaignMembers.get(objCampaign.Name).add(objCM.ContactId);
                        mapUpdateCampaignMembers.put(objCM.ContactId + '-' + objCampaign.Name, objCM);
                    }
                }
            }

            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
            List<CampaignMember> lstUpdateCampaignMember = new List<CampaignMember>();
            List<RecordType> rt = new List<RecordType>();
            if (RecordTypeSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                rt = [
                        SELECT Id
                        FROM RecordType
                        WHERE SobjectType = 'Case'
                        AND DeveloperName = 'Automated_Cases'
                ];
            }

            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                //Check if any Early Out Case exists; if so, the close it and create a new one
                List<Case> lstCloseCases = [
                        SELECT Id, Type
                        FROM Case
                        WHERE Type = 'Precollections'
                        AND Guarantor_Information__c IN :mapContact.keyset()
                        AND Guarantor_Information__c NOT IN :mapComplianceContact.keyset()
                        AND IsClosed = false
                ];
                for (Case objCase: lstCloseCases) {
                    objCase.Status = 'Closed';
                    objCase.Reason = 'Closed - Automated';
                }
                executeRemoveCampaignTrigger = false;
                if (SecurityUtils.verify(CaseSecurityContext.UPDATE_CONTEXT)) {
                    UPDATE lstCloseCases;
                }
            }

            //Create a new Case
            for (String strContactId : mapContact.Keyset()) {
                if (!mapComplianceContact.Containskey(strContactId)) {
                    Contact objContact = mapContact.get(strContactId);
                    Case objCase = new Case();
                    objCase.Guarantor_Information__c = objContact.Id;
                    objCase.ContactId = objContact.Id;
                    objCase.Type = 'Precollections';
                    objCase.Status = 'New';
                    objCase.Subject = 'Precollections';
                    objCase.RecordTypeID = rt[0].Id;
                    if (lstGroup.size() > 0) {
                        objCase.ownerId = lstGroup[0].Id;
                    }
                    mapContactCase.Put(objContact.Id, objCase);

                    //Add CampaignMember
                    if (objContact.HomePhone != null || objContact.OtherPhone != null) {
                        if (mapCampaignName.containsKey(preCollection)) {
                            if (mapCampaignMembers.get(preCollection).contains(objContact.Id)) {
                                CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id + '-' + preCollection);                            
                                lstUpdateCampaignMember.add(cm);
                            } else {
                                CampaignMember cm = New CampaignMember();
	                        cm.CampaignId = mapCampaignName.get(preCollection);
	                        cm.ContactId = objContact.Id;
	                        lstCampaignMember.add(cm);
                            }
                    	}
                    }
                    if (objContact.MobilePhone != null) {
                        if (mapCampaignName.containsKey(preCollectionMobile)) {
                            if (mapCampaignMembers.get(preCollectionMobile).contains(objContact.Id)) {
                                CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id  + '-' + preCollectionMobile);
                                lstUpdateCampaignMember.add(cm);
                            } else {
                                CampaignMember cm = New CampaignMember();
	                        cm.CampaignId = mapCampaignName.get(preCollectionMobile);
	                        cm.ContactId = objContact.Id;
	                        lstCampaignMember.add(cm);
                            }
                    	}
                    }
                }
            }
            
            if (mapContactCase.size() > 0) {
                if (CaseSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    INSERT mapContactCase.values();
                }

                //Insert the Case Charge Group
                List<Case_Charge_Group_Junction__c> lstCCG = new List<Case_Charge_Group_Junction__c>();
                for (Charge_Group__c cg: ChargeGroupService.getCGBasedOnGuarantor(mapContactCase.keyset())) {
                    if (mapContactCase.Containskey(cg.Guarantor__c)) {
                        Case objCase = mapContactCase.get(cg.Guarantor__c);
                        Case_Charge_Group_Junction__c ccg = new Case_Charge_Group_Junction__c();
                        ccg.Case__c = objCase.Id;
                        ccg.Charge_Group__c = cg.Id;
                        lstCCG.add(ccg);
                    }
                }
                if (CaseCGJunctionSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    INSERT lstCCG;
                }
            }

            // 11-25-2016 Viraj Rana: #133707065: Case to Call Activiy
            // Assign Case Id in Campaign Member.
            if (lstCampaignMember.size() > 0) {                
                for (CampaignMember cm : lstCampaignMember) {
                    if (mapContactCase.Containskey(cm.ContactId)) {
                        Case objCase = mapContactCase.get(cm.ContactId);
                        cm.Case_ID__c = objCase.Id;
                    }
                }
                /* 11-29-2016 Viraj Rana: Set flag variable false. This variable is used in Campaign Member Trigger.
                 * If this variable is true than Trigger also create one case with "Call List Case" record type.
                 * To control of it we set it false.
                */
                createCaseInTrigger = false;
                if (CmpnMemberSecurityContext.CREATE_CONTEXT.actionAllowed()) {
                    INSERT lstCampaignMember;
                }
                createCaseInTrigger = true;
            }
            
            //11-25-2016: Viraj Rana - Update Case Id in Old Campaign Member.
            if (lstUpdateCampaignMember.size() > 0) {                
                for (CampaignMember cm : lstUpdateCampaignMember) {
                    if (mapContactCase.Containskey(cm.ContactId)) {
                        Case objCase = mapContactCase.get(cm.ContactId);
                        cm.Case_ID__c = objCase.Id;
                    }
                }
                if (CmpnMemberSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                    UPDATE lstUpdateCampaignMember;
                }
            }
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
    public static void callClosePrecollectionsAutoCase(List<Statement__c> lstStatement) {
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
                        WHERE Type = 'Precollections'
                        AND Guarantor_Information__c IN :mapContact.keyset()
                        AND IsClosed = false
                ];
            }
            Set<Id> setContactWithEarlyOutCase = new Set<Id>();
            for (Case objCase: precollections) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
                setContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            executeRemoveCampaignTrigger = false;
            if (SecurityUtils.verify(CaseSecurityContext.UPDATE_CONTEXT)) {
                UPDATE precollections;
            }

            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'PreCollections', 'PreCollections M'
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
                        WHERE Name = 'Automated Cases'
                        AND Type = 'Queue'
                ];
            }

            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Case objCase: [
                        SELECT Id, Guarantor_Information__c
                        FROM Case
                        WHERE Reason = 'Compliance Issue'
                        AND Guarantor_Information__c IN :mapContact.keyset()
                        AND IsClosed = false
                ]) {
                    mapComplianceContact.Put(objCase.Guarantor_Information__c, objCase.id);
                }
            }

            Map<Id, Case> mapContactCase = new Map<Id, Case>();
            Map<String, String> mapCampaignName = new Map<String, String>();
            Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
            Map<String,CampaignMember> mapUpdateCampaignMembers = new Map<String,CampaignMember>();
            
            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'PreService', 'PreService M'
            });
            String preService = mapCampaignMapping.get('PreService');
            String preServiceMobile = mapCampaignMapping.get('PreService M');

            if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                    CmpnMemberSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                for (Campaign objCampaign: [
                        SELECT Id, Name, (
                                SELECT Id, ContactId
                                FROM CampaignMembers
                                WHERE ContactId IN :mapContact.keyset()
                        )
                        FROM Campaign
                        WHERE IsActive = true
                        AND (Name = :preService OR Name = :preServiceMobile)
                ]) {
                    mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                    mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                    for (CampaignMember objCM: objCampaign.CampaignMembers) {
                        mapCampaignMembers.get(objCampaign.Name).add(objCM.ContactId);
                        mapUpdateCampaignMembers.put(objCM.ContactId + '-' + objCampaign.Name, objCM);
                    }
                }
            }

            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
            List<CampaignMember> lstUpdateCampaignMember = new List<CampaignMember>();
            List<RecordType> rt = new List<RecordType>();
            if (RecordTypeSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                rt = [
                        SELECT Id
                        FROM RecordType
                        WHERE SobjectType = 'Case'
                        AND DeveloperName = 'Automated_Cases'
                ];
            }

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
                    objCase.Type = 'Encounter';
                    objCase.Status = 'New';
                    objCase.Subject = 'Encounter';
                    objCase.RecordTypeID = rt[0].Id;
                    if (lstGroup.size() > 0) {
                        objCase.ownerId = lstGroup[0].Id;
                    }
                    mapContactCase.Put(objContact.Id, objCase);

                    //Add CampaignMember
                    if (objContact.HomePhone != null || objContact.OtherPhone != null) {
                        if (mapCampaignName.containsKey(preService)) {
                            if (mapCampaignMembers.get(preService).contains(objContact.Id)) {
                                CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id + '-' + preService);                            
                                lstUpdateCampaignMember.add(cm);
                            } else {
                                CampaignMember cm = New CampaignMember();
	                        cm.CampaignId = mapCampaignName.get(preService);
	                        cm.ContactId = objContact.Id;
	                        lstCampaignMember.add(cm);
                            }
                    	}
                    }
                    if (objContact.MobilePhone != null) {
                        if (mapCampaignName.containsKey(preServiceMobile)) {
                            if (mapCampaignMembers.get(preServiceMobile).contains(objContact.Id)) {
                                CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id  + '-' + preServiceMobile);
                                lstUpdateCampaignMember.add(cm);
                            } else {
                                CampaignMember cm = New CampaignMember();
	                        cm.CampaignId = mapCampaignName.get(preServiceMobile);
	                        cm.ContactId = objContact.Id;
	                        lstCampaignMember.add(cm);
                            }
                    	}
                    }
                }
            }
            if (mapContactCase.size() > 0) {
                if (CaseSecurityContext.CU_CREATE_WITH_ENCOUNTER_CONTEXT.actionAllowed()) {
	            INSERT mapContactCase.values();
		}
            }

            // Assign Case Id in Campaign Member.
            if (lstCampaignMember.size() > 0) {                
                for (CampaignMember cm : lstCampaignMember) {
                    if (mapContactCase.Containskey(cm.ContactId)) {
                        Case objCase = mapContactCase.get(cm.ContactId);
                        cm.Case_ID__c = objCase.Id;
                    }
                }
                /* 11-29-2016 Viraj Rana: Set flag variable false. This variable is used in Campaign Member Trigger.
                 * If this variable is true than Trigger also create one case with "Call List Case" record type.
                 * To control of it we set it false.
                */
                createCaseInTrigger = false;
                if (CmpnMemberSecurityContext.CREATE_CONTEXT.actionAllowed()) {
	            INSERT lstCampaignMember;
		}
                createCaseInTrigger = true;
            }
            
            //11-29-2016: Viraj Rana - Update Case Id in Old Campaign Member.
            if (lstUpdateCampaignMember.size() > 0) {                
                for (CampaignMember cm : lstUpdateCampaignMember) {
                    if (mapContactCase.Containskey(cm.ContactId)) {
                        Case objCase = mapContactCase.get(cm.ContactId);
                        cm.Case_ID__c = objCase.Id;
                    }
                }
                if (CmpnMemberSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
	            UPDATE lstUpdateCampaignMember;
		}
            }
        }
    }
    
    /*
    * Close Encounter Auto Case and remove from the PreService campaigns
    */
    Public Static void callCloseEncounterAutoCase(List<Encounter__c> lstEncounter, Boolean fromPaymentMethod) {
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
    Public Static void closeEncounterAutoCase(Set<String> setEncounterIds,
            Set<String> setContact, Boolean skipEncounterCaseUpdate) {
        if (!skipEncounterCaseUpdate) {
            List<Case> encounterCase = new List<Case>();
            if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
                encounterCase = [
                        SELECT Id, Status, Reason, Guarantor_Information__c
                        FROM Case
                        WHERE Type = 'Encounter'
                        AND Guarantor_Information__c IN :setContact
                        AND Encounter__c IN :setEncounterIds
                ];
            }
            for (Case objCase: encounterCase) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
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
                    WHERE Type = 'Encounter' AND IsClosed = false
                    AND Guarantor_Information__c IN :setContact
            ];
            for (Case c: openEncounterCases) {
                contactWithoutOpenEncounters.add(c.Guarantor_Information__c);
            }
        }

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'PreService', 'PreService M'
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
    Public static void createDelinquentPaymentCase(Set<Id> contactIds) {
        List<Group> lstGroup = new List<Group>();
        List<RecordType> rt = new List<RecordType>();
        if (GroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            lstGroup = [SELECT Id
                        FROM Group
                        WHERE Name = 'Automated Cases'
                        AND Type = 'Queue'
            ];
        }
        if (RecordTypeSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            rt = [SELECT Id
                  FROM RecordType
                  WHERE SobjectType = 'Case'
                  AND DeveloperName = 'Automated_Cases'
            ];
        }
        Map<String, Case> mapContactCase = new Map<String, Case>();
        Map<String, String> mapCampaignName = new Map<String, String>();
        Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
        Map<String, CampaignMember> mapUpdateCampaignMembers = new Map<String, CampaignMember>();

        if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            for (Case objCase: [
                    SELECT Id, Guarantor_Information__c
                    FROM Case
                    WHERE Guarantor_Information__c IN :contactIds
                    AND (Type = 'Delinquent Payment Plans' OR Reason = 'Compliance Issue')
                    AND IsClosed = false
            ]) {
                contactIds.Remove(objCase.Guarantor_Information__c);
            }
        }

        Map<Id, Contact> mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(contactIds, null));

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'Delinquent', 'Delinquent M'
        });
        string delinquent = mapCampaignMapping.get('Delinquent');
        string delinquentMobile = mapCampaignMapping.get('Delinquent M');

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                CmpnMemberSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            for (Campaign objCampaign: [
                    SELECT Id, Name, (
                            SELECT Id, ContactId
                            FROM CampaignMembers
                            WHERE ContactId IN :contactIds
                    )
                    FROM Campaign
                    WHERE Name = :delinquent
                    OR Name = :delinquentMobile
            ]) {
                mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                for (CampaignMember objCM: objCampaign.CampaignMembers) {
                    mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                    mapUpdateCampaignMembers.put(objCM.ContactId + '-' + objCampaign.Name, objCM);
                }
            }
        }

        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        List<CampaignMember> lstUpdateCampaignMember = new List<CampaignMember>();
        
        for (String strContactId : mapContact.keyset()) {
            Contact objContact = mapContact.get(strContactId);

            Case objCase = new Case();
            objCase.Guarantor_Information__c = strContactId;
            objCase.ContactId = strContactId;
            objCase.Type = 'Delinquent Payment Plans';
            objCase.Status = 'New';
            objCase.Subject = 'Delinquent Payment Plans';
            objCase.RecordTypeID = rt[0].Id;
            if (lstGroup.size() > 0) {
                objCase.ownerId = lstGroup[0].Id;
            }
            mapContactCase.Put(strContactId, objCase);

            //Add CampaignMember
            if (objContact.HomePhone != null || objContact.OtherPhone != null) {
                if (mapCampaignName.containsKey(delinquent)) {
                    if (mapCampaignMembers.get(delinquent).contains(objContact.Id)) {
                        CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id + '-' + delinquent);                            
                    	lstUpdateCampaignMember.add(cm);
                    } else {
                        CampaignMember cm = New CampaignMember();
	                cm.CampaignId = mapCampaignName.get(delinquent);
	                cm.ContactId = objContact.Id;
	                lstCampaignMember.add(cm);
                    }
            	}
            }
            if (objContact.MobilePhone != null) {
                if (mapCampaignName.containsKey(delinquentMobile)) {
                    if (mapCampaignMembers.get(delinquentMobile).contains(objContact.Id)) {
                        CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id  + '-' + delinquentMobile);
                    	lstUpdateCampaignMember.add(cm);
                    } else {
                        CampaignMember cm = New CampaignMember();
	                cm.CampaignId = mapCampaignName.get(delinquentMobile);
	                cm.ContactId = objContact.Id;
	                lstCampaignMember.add(cm);
                    }
            	}
            }
        }
        
        if (CaseSecurityContext.CREATE_WITH_GT_CONTEXT.actionAllowed()) {
            INSERT mapContactCase.Values();
	}

        // Assign CaseId to new CampaignMember.
        if (lstCampaignMember.size() > 0) {                
            for (CampaignMember cm : lstCampaignMember) {
                if (mapContactCase.Containskey(cm.ContactId)) {
                    Case objCase = mapContactCase.get(cm.ContactId);
                    cm.Case_ID__c = objCase.Id;
                }
            }
            /* 11-29-2016 Viraj Rana: Set flag variable false. This variable is used in Campaign Member Trigger.
             * If this variable is true than Trigger also create one case with "Call List Case" record type.
             * To control of it we set it false.
            */
            createCaseInTrigger = false;
            if (CmpnMemberSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            	INSERT lstCampaignMember;
	    }
            createCaseInTrigger = true;
        }
        
        //Update CaseId in old CampaignMember.
        if (lstUpdateCampaignMember.size() > 0) {                
            for (CampaignMember cm : lstUpdateCampaignMember) {
                if (mapContactCase.Containskey(cm.ContactId)) {
                    Case objCase = mapContactCase.get(cm.ContactId);
                    cm.Case_ID__c = objCase.Id;
                }
            }
            if (CmpnMemberSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            	update lstUpdateCampaignMember;
	    }
        }
    }

    /*
    * Method for Create Delinquent Auto Case and Add the Campaign member to Campaign.
    */
    Public static void closeDelinquentPaymentCase(Set<Id> contactIds, Set<Id> paymentPlanID) {

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
                    AND Type = 'Delinquent Payment Plans'
                    AND IsClosed = false
            ];
            contactIds = new Set<Id>();
            for (Case objCase: lstCase) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
                contactIds.add(objCase.Guarantor_Information__c);
            }
            if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
                UPDATE lstCase;
            }
        }

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'Delinquent', 'Delinquent M'
        });

        deleteCampaignMembers(contactIds, mapCampaignMapping.values());
    }

    /*
    * 08-25-2016: Sirono - Tracker # 127517003 For Credit Card Error Case Creation
    * 08-25-2016: Sirono - Tracker # 127517003 For Add Guarantor to the CC Error Call list
    * Method for Create CC Error Auto Case and Add the Campaign member to Campaign.
    */
    Public static void createCCErrorCase(Set<Id> contactIds) {
        Map<String, Case> mapContactCase = new Map<String, Case>();
        Map<String, String> mapCampaignName = new Map<String, String>();
        Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
        Map<String,CampaignMember> mapUpdateCampaignMembers = new Map<String,CampaignMember>();
        List<Group> lstGroup = new List<Group>();
        List<RecordType> rt = new List<RecordType>();
        Map<Id, Contact> mapContact = new Map<Id, Contact>();

        if (CaseSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            for (Case objCase: [
                    SELECT Id, Guarantor_Information__c
                    FROM Case
                    WHERE Guarantor_Information__c IN :contactIds
                    AND (Type = 'CC Error' OR Reason = 'Compliance Issue')
                    AND IsClosed = false
            ]) {
                contactIds.Remove(objCase.Guarantor_Information__c);
            }
        }

        if (GroupSecurityContext.SELECT_CONTEXT.actionAllowed()) {
            lstGroup = [
                    SELECT Id
                    FROM Group
                    WHERE Name = 'Automated Cases' AND Type = 'Queue'
            ];
        }
        if (RecordTypeSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            rt = [
                    SELECT Id
                    FROM RecordType
                    WHERE SobjectType = 'Case' AND DeveloperName = 'Automated_Cases'
            ];
        }
        mapContact = new Map<Id, Contact>(GuarantorService.getGuarantorsByFilter(contactIds, null));

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'CC Error', 'CC Error M'
        });
        string ccError = mapCampaignMapping.get('CC Error');
        string ccErrorMobile = mapCampaignMapping.get('CC Error M');

        if (CampaignSecurityContext.SELECT_CONTEXT.actionAllowed() &&
                CmpnMemberSecurityContext.CU_SELECT_CONTEXT.actionAllowed()) {
            for (Campaign objCampaign: [
                    SELECT Id, Name, (
                            SELECT Id, ContactId
                            FROM CampaignMembers
                            WHERE ContactId IN :contactIds
                    )
                    FROM Campaign
                    WHERE Name = :ccError
                    OR Name = :ccErrorMobile
            ]) {
                mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                for (CampaignMember objCM: objCampaign.CampaignMembers) {
                    mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                    mapUpdateCampaignMembers.put(objCM.ContactId + '-' + objCampaign.Name, objCM);
                }
            }
        }

        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
        List<CampaignMember> lstUpdateCampaignMember = new List<CampaignMember>();
        for (String strContactId : mapContact.keyset()) {
            Contact objContact = mapContact.get(strContactId);

            Case objCase = new Case();
            objCase.Guarantor_Information__c = strContactId;
            objCase.ContactId = strContactId;
            objCase.Type = 'CC Error';
            objCase.Status = 'New';
            objCase.Subject = 'CC Error';
            objCase.RecordTypeID = rt[0].Id;
            if (lstGroup.size() > 0) {
                objCase.ownerId = lstGroup[0].Id;
            }
            mapContactCase.Put(strContactId, objCase);

            //Add CampaignMember
            if (objContact.HomePhone != null || objContact.OtherPhone != null) {
                if (mapCampaignName.containsKey(ccError)) {
                    if (mapCampaignMembers.get(ccError).contains(objContact.Id)) {
                        CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id + '-' + ccError);                            
                    	lstUpdateCampaignMember.add(cm);
                    } else {
                        CampaignMember cm = New CampaignMember();
	                cm.CampaignId = mapCampaignName.get(ccError);
	                cm.ContactId = objContact.Id;
	                lstCampaignMember.add(cm);
                    }
            	}
            }
            if (objContact.MobilePhone != null) {
                if (mapCampaignName.containsKey(ccErrorMobile)) {
                    if (mapCampaignMembers.get(ccErrorMobile).contains(objContact.Id)) {
                        CampaignMember cm = mapUpdateCampaignMembers.get(objContact.Id  + '-' + ccErrorMobile);
                    	lstUpdateCampaignMember.add(cm);
                    } else {
                        CampaignMember cm = New CampaignMember();
	                cm.CampaignId = mapCampaignName.get(ccErrorMobile);
	                cm.ContactId = objContact.Id;
	                lstCampaignMember.add(cm);
                    }
            	}
            }

        }
        if (CaseSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            INSERT mapContactCase.values();
	}
        
        // 11-29-2016 Viraj Rana: #133707065: Case to Call Activiy
        // Assign Case Id in Campaign Member.
        if (lstCampaignMember.size() > 0) {                
            for (CampaignMember cm : lstCampaignMember) {
                if (mapContactCase.Containskey(cm.ContactId)) {
                    Case objCase = mapContactCase.get(cm.ContactId);
                    cm.Case_ID__c = objCase.Id;
                }
            }
            /* 11-29-2016 Viraj Rana: Set flag variable false. This variable is used in Campaign Member Trigger.
             * If this variable is true than Trigger also create one case with "Call List Case" record type.
             * To control of it we set it false.
            */
            createCaseInTrigger = false;
            if (CmpnMemberSecurityContext.CREATE_CONTEXT.actionAllowed()) {
            	INSERT lstCampaignMember;
	    }
            createCaseInTrigger = true;
        }
        
        //11-29-2016: Viraj Rana - Update Case Id in Old Campaign Member.
        if (lstUpdateCampaignMember.size() > 0) {                
            for (CampaignMember cm : lstUpdateCampaignMember) {
                if (mapContactCase.Containskey(cm.ContactId)) {
                    Case objCase = mapContactCase.get(cm.ContactId);
                    cm.Case_ID__c = objCase.Id;
                }
            }
            if (CmpnMemberSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            	UPDATE lstUpdateCampaignMember;
            }
        }
    }

    /*
    * Method for Create CC Error Auto Case and Remove the Campaign member to Campaign.
    */
    Public static void closeCCErrorCase(Set<Id> contactIds, Set<Id> paymentPlanID) {

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
                    AND Type = 'CC Error' AND IsClosed = false
            ];
        }
        contactIds = new Set<Id>();
        for (Case objCase : lstCase) {
            objCase.Status = 'Closed';
            objCase.Reason = 'Closed - Automated';
            contactIds.add(objCase.Guarantor_Information__c);
        }
        if (CaseSecurityContext.UPDATE_CONTEXT.actionAllowed()) {
            UPDATE lstCase;
        }

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'CC Error', 'CC Error M'
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