/*
* @author: Sirono
* @version 1.0.1
* @Date: 08-10-2016
* @Util Class for the All Auto Case Creation, Auto Case Closure, Add\Remove the guarantor to the campaign functionality.*
*
* 08-11-2016: Sirono - Tracker # 127398811 For Early-out Cases Creation
* 08-11-2016: Sirono - Tracker # 128031249 For Add Guarantor to the Early-out Campaign
* 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
* 08-11-2016: Sirono - Tracker # 128030957 For Removal from Early-out campaign

* 08-12-2016: Sirono - Tracker # 127517035 For Precollections Case Creation
* 08-12-2016: Sirono - Tracker # 128030543 For Add Guarantor to the Precollections Campaign
* 08-12-2016: Sirono - Tracker # 127517133 For Automatic Precollections Case Closure
* 08-12-2016: Sirono - Tracker # 127517133 For Removal from Precollections campaign

* 08-18-2016: Sirono - Tracker # 127517087 For Encounter Case Creation
* 08-18-2016: Sirono - Tracker # 127517147 For Automatic Encounter Case Closure
* 08-18-2016: Sirono - Tracker # 128457157 For Encounter: Add/Remove Guarantor to the Preservice Call list

* 08-22-2016: Sirono - Tracker # 127401841 For Delinquent Payment Plan Case Creation
* 08-22-2016: Sirono - Tracker # 127517111 For Delinquent Payment Plan Case closure
* 08-22-2016: Sirono - Tracker # 128197107 For Add/Remove Guarantor to the Delinquent Payment Plan Call list

* 08-25-2016: Sirono - Tracker # 127517003 For Credit Card Error Case Creation
* 08-25-2016: Sirono - Tracker # 127517003 For Automatic Credit Card Error Case Closure
* 08-25-2016: Sirono - Tracker # 127517003 For Add/Remove Guarantor to the CC Error Call list
*
* 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases
*/


Public Class CaseUtil {
    Public static Boolean executeCampaignMemberTrigger = True;
    Public static Boolean executeRemoveCampaignTrigger = True;

    public CaseUtil() {

    }

    /*
    * 08-11-2016: Sirono - Tracker # 127398811
      Method for getting the list of the statement and pass it into the method.
    */
    Public Static void callEarlyOutAutoCase() {
        List<Statement__c> statement = [
                Select id, Guarantor__c
                From Statement__c
                Where Statement_Date__c = :System.today()
        ];
        createEarlyOutAutoCase(statement);
    }

    /*
    * 08-11-2016: Sirono - Tracker # 127398811
    * 08-11-2016: Sirono - Tracker # 128031249
    * Method for Create Early Out Auto Case and Add the Campaign member to Campaign.
    * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Overdue_Balance__c = '< 0' to '> 0'" in condition.
    */
    Public Static void createEarlyOutAutoCase(List<Statement__c> statement) {
        Set<String> setContact = new Set<String>();

        for (Statement__c objStatement : statement) {
            setContact.add(objStatement.Guarantor__c);
        }
        Map<Id, Contact> mapContact = new map<Id, Contact>(
        [
                Select id, Name, Statement_Preference__c,
                        Overdue_Balance__c, Delinquent_Balance__c,
                        RecordType.DeveloperName,
                        HomePhone, MobilePhone, OtherPhone
                From contact
                Where Id in :setContact
                and Overdue_Balance__c > 0
        ]);

        if (mapContact.size() > 0) {
            Map<Id, Id> mapComplianceContact = new Map<Id, Id>();
            List<Group> lstGroup = [
                    Select Id
                    From Group
                    Where Name = 'Automated Cases'
                    and Type = 'Queue'
            ];

            for (Case objCase : [
                    Select id, Guarantor_Information__c
                    From case
                    Where Reason = 'Compliance Issue' and
                    Guarantor_Information__c In :mapContact.keyset()
                    and IsClosed = false
            ]) {
                mapComplianceContact.Put(objCase.Guarantor_Information__c, objCase.id);
            }

            Map<Id, Case> mapContactCase = new Map<Id, Case>();
            Map<String, String> mapCampaignName = new Map<String, String>();
            Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'Early-out', 'Early-out M'
            });
            string earlyOut = mapCampaignMapping.get('Early-out');
            string earlyOutMobile = mapCampaignMapping.get('Early-out M');

            for (Campaign objCampaign : [
                    Select id, Name, (
                            Select id, ContactId
                            From CampaignMembers
                            Where ContactId in :mapContact.keyset()
                    )
                    From Campaign
                    Where Name = :earlyOut or Name = :earlyOutMobile
            ]) {
                mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                for (CampaignMember objCM : objCampaign.CampaignMembers) {
                    mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                }
            }

            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
            List<RecordType> rt = [
                    Select id
                    From RecordType
                    Where SobjectType = 'Case'
                    and DeveloperName = 'Automated_Cases'
            ];

            //Check Any Early Out Case is exist if exist the closed it and creted new one.
            List<Case> lstEarlyOutCases = [
                    Select id, Type
                    From case
                    Where Type = 'Early Out'
                    and Guarantor_Information__c In :mapContact.keyset()
                    and Guarantor_Information__c not In :mapComplianceContact.keyset()
                    and IsClosed = false
            ];
            for (Case objCase : lstEarlyOutCases) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
            }
            executeRemoveCampaignTrigger = false;
            Update lstEarlyOutCases;

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
                        if (mapCampaignName.Containskey(earlyOut) && !mapCampaignMembers.get(earlyOut).contains(objContact.Id)) {
                            CampaignMember cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get(earlyOut);
                            cm.ContactId = objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                    if (objContact.MobilePhone != null) {
                        if (mapCampaignName.Containskey(earlyOutMobile) && !mapCampaignMembers.get(earlyOutMobile).contains(objContact.Id)) {
                            CampaignMember cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get(earlyOutMobile);
                            cm.ContactId = objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                }
            }
            if (lstCampaignMember.size() > 0) {
                executeCampaignMemberTrigger = false;
                insert lstCampaignMember;
                executeCampaignMemberTrigger = true;
            }
            if (mapContactCase.size() > 0) {
                Insert mapContactCase.values();

                //Insert the Case Charge Group
                List<Case_Charge_Group__c> lstCCG = new List<Case_Charge_Group__c >();
                for (Charge_Group__c cg : [
                        Select id, Guarantor_Name__c
                        From Charge_Group__c
                        Where Account_Status__c = 'Billed'
                        and Guarantor_Name__c = :mapContactCase.keyset()
                ]) {
                    if (mapContactCase.Containskey(cg.Guarantor_Name__c)) {
                        Case objCase = mapContactCase.get(cg.Guarantor_Name__c);
                        Case_Charge_Group__c ccg = new Case_Charge_Group__c();
                        ccg.Case__c = objCase.Id;
                        ccg.Charge_Group__c = cg.Id;
                        lstCCG.add(ccg);
                    }
                }
                insert lstCCG;
            }
        }
    }


    /*
    * 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
    * Method for Close the Early Out Auto Case.
    */
    Public Static void callEarlyOutAutoCaseCloser() {
        List<Statement__c> lstStatement = [
                Select id, Guarantor__c
                From Statement__c
                Where Statement_Date__c = :System.today()
                and Day_only(CreatedDate) != :System.today()
        ];
        callCloseEarlyOutAutoCase(lstStatement);
    }

    /*
    * 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
    * Method for Close the Early Out Auto Case.
    */
    Public Static void callCloseEarlyOutAutoCase(List<Statement__c> lstStatement) {
        Set<String> setContact = new Set<String>();
        for (Statement__c objStatement : lstStatement) {
            setContact.add(objStatement.Guarantor__c);
        }
        closeEarlyOutAutoCase(setContact);
    }

    /*
    * 08-11-2016: Sirono - Tracker # 127517097 For Automatic Early-out Case Closure
    * Method for Close the Early Out Auto Case, Remove the Campaign member to Campaign.
    * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Overdue_Balance__c = '>= 0' to '<= 0'" in condition.
    */
    Public Static void closeEarlyOutAutoCase(Set<String> setContact) {

        Map<Id, Contact> mapContact = new map<Id, Contact>(
        [
                Select id, Name, Statement_Preference__c,
                        Overdue_Balance__c, Delinquent_Balance__c,
                        RecordType.DeveloperName,
                        HomePhone, MobilePhone, OtherPhone
                From contact
                Where Id in :setContact
                Or Overdue_Balance__c <= 0
        ]
        );

        if (mapContact.size() > 0) {
            List<Case> earlyOutCase = [
                    Select id, Status, Reason, Guarantor_Information__c
                    From case
                    Where Type = 'Early Out' and
                    Guarantor_Information__c In :mapContact.keyset()
                    and IsClosed = false
            ];
            Set<String> setContactWithEarlyOutCase = new Set<String>();
            for (Case objCase : earlyOutCase) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
                setContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            executeRemoveCampaignTrigger = false;
            Update earlyOutCase;

            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'Early-out', 'Early-out M'
            });
            string earlyOut = mapCampaignMapping.get('Early-out');
            string earlyOutMobile = mapCampaignMapping.get('Early-out M');

            Delete [
                    Select id, ContactId
                    From CampaignMember
                    Where (Campaign.Name = :earlyOut or Campaign.Name = :earlyOutMobile)
                    and ContactId in :setContactWithEarlyOutCase
            ];
        }
    }

    /*
    * 08-12-2016: Sirono - Tracker # 127517035 For Precollections Case Creation
    * Method for Create Pre-Collection Auto Case and Add the Campaign member to Campaign.
    */
    Public Static void callPrecollectionsAutoCase() {
        List<Statement__c> lstStatement = [Select id, Guarantor__c from Statement__c where Statement_Date__c = :System.today()];
        createPrecollectionsAutoCase(lstStatement);
    }

    /*
    * 08-12-2016: Sirono - Tracker # 127517035 For Precollections Case Creation
    * Method for Create Pre-Collection Auto Case and Add the Campaign member to Campaign.
    * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Delinquent_Balance__c = '< 0' to '> 0'" in condition.
    */
    Public Static void createPrecollectionsAutoCase(List<Statement__c> lstStatement) {
        Set<String> setContact = new Set<String>();

        for (Statement__c objStatement : lstStatement) {
            setContact.add(objStatement.Guarantor__c);
        }

        Map<Id, Contact> mapContact = new map<Id, Contact>(
        [
                Select id, Name, Statement_Preference__c,
                        Overdue_Balance__c,
                        Delinquent_Balance__c,
                        RecordType.DeveloperName,
                        HomePhone, MobilePhone,
                        OtherPhone
                From contact
                Where Id in :setContact
                and Delinquent_Balance__c > 0
        ]);

        if (mapContact.size() > 0) {
            Map<Id, Id> mapComplianceContact = new Map<Id, Id>();
            List<Group> lstGroup = [
                    Select Id
                    From Group
                    Where Name = 'Automated Cases'
                    and Type = 'Queue'
            ];

            for (Case objCase : [
                    Select id, Guarantor_Information__c
                    From case
                    Where Reason = 'Compliance Issue'
                    and Guarantor_Information__c In :mapContact.keyset()
                    and IsClosed = false
            ]) {
                mapComplianceContact.Put(objCase.Guarantor_Information__c, objCase.id);
            }

            Map<Id, Case> mapContactCase = new Map<Id, Case>();
            Map<String, String> mapCampaignName = new Map<String, String>();
            Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'PreCollections', 'PreCollections M'
            });
            string preCollection = mapCampaignMapping.get('PreCollections');
            string preCollectionMobile = mapCampaignMapping.get('PreCollections M');

            for (Campaign objCampaign : [
                    Select id, Name, (
                            Select id, ContactId
                            From CampaignMembers
                            Where ContactId in :mapContact.keyset()
                    )
                    From Campaign
                    Where Name = :preCollection
                    or Name = :preCollectionMobile
            ]) {
                mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                for (CampaignMember objCM : objCampaign.CampaignMembers) {
                    mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                }
            }

            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
            List<RecordType> rt = [
                    Select id
                    From RecordType
                    Where SobjectType = 'Case'
                    and DeveloperName = 'Automated_Cases'
            ];

            //Check Any Early Out Case is exist if exist the closed it and creted new one.
            List<Case> lstCloseCases = [
                    Select id, Type
                    From case
                    Where Type = 'Precollections'
                    and Guarantor_Information__c In :mapContact.keyset()
                    and Guarantor_Information__c not In :mapComplianceContact.keyset()
                    and IsClosed = false
            ];
            for (Case objCase : lstCloseCases) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
            }
            executeRemoveCampaignTrigger = false;
            Update lstCloseCases;

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
                        if (mapCampaignName.Containskey(preCollection) && !mapCampaignMembers.get(preCollection).contains(objContact.Id)) {
                            CampaignMember cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get(preCollection);
                            cm.ContactId = objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                    if (objContact.MobilePhone != null) {
                        if (mapCampaignName.Containskey(preCollectionMobile) && !mapCampaignMembers.get(preCollectionMobile).contains(objContact.Id)) {
                            CampaignMember cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get(preCollectionMobile);
                            cm.ContactId = objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                }
            }
            if (lstCampaignMember.size() > 0) {
                executeCampaignMemberTrigger = false;
                insert lstCampaignMember;
                executeCampaignMemberTrigger = true;
            }
            if (mapContactCase.size() > 0) {
                Insert mapContactCase.values();

                //Insert the Case Charge Group
                List<Case_Charge_Group__c> lstCCG = new List<Case_Charge_Group__c >();
                for (Charge_Group__c cg : [
                        Select id, Guarantor_Name__c
                        From Charge_Group__c
                        Where Account_Status__c = 'Billed'
                        and Guarantor_Name__c = :mapContactCase.keyset()
                ]) {
                    if (mapContactCase.Containskey(cg.Guarantor_Name__c)) {
                        Case objCase = mapContactCase.get(cg.Guarantor_Name__c);
                        Case_Charge_Group__c ccg = new Case_Charge_Group__c();
                        ccg.Case__c = objCase.Id;
                        ccg.Charge_Group__c = cg.Id;
                        lstCCG.add(ccg);
                    }
                }
                insert lstCCG;
            }
        }
    }

    /*
    * 08-12-2016: Sirono - Tracker # 127517133 For Automatic Precollections Case Closure
    * 08-12-2016: Sirono - Tracker # 127517133 For Removal from Precollections campaign.
    * Method for Close Pre-Collection Auto Case and Remove the Campaign member from Campaign.
    */
    Public Static void callPrecollectionsAutoCaseCloser() {
        List<Statement__c> lstStatement = [
                Select id, Guarantor__c
                From Statement__c
                Where Statement_Date__c = :System.today()
                and Day_only(CreatedDate) != :System.today()
        ];
        callClosePrecollectionsAutoCase(lstStatement);
    }

    /*
    * 08-12-2016: Sirono - Tracker # 127517133 For Automatic Precollections Case Closure
    * 08-12-2016: Sirono - Tracker # 127517133 For Removal from Precollections campaign.
    * Method for Close Pre-Collection Auto Case and Remove the Campaign member from Campaign.
    */
    Public Static void callClosePrecollectionsAutoCase(List<Statement__c> lstStatement) {
        Set<String> setContact = new Set<String>();
        for (Statement__c objStatement : lstStatement) {
            setContact.add(objStatement.Guarantor__c);
        }
        closePrecollectionsAutoCase(setContact);
    }

    /*
    * 08-12-2016: Sirono - Tracker # 127517133 For Automatic Precollections Case Closure
    * 08-12-2016: Sirono - Tracker # 127517133 For Removal from Precollections campaign.
    * Method for Close Pre-Collection Auto Case and Remove the Campaign member from Campaign.
    * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Delinquent_Balance__c = '>= 0' to '< 0'" in condition.
    */
    Public Static void closePrecollectionsAutoCase(Set<String> setContact) {
        Map<Id, Contact> mapContact = new map<Id, Contact>(
        [
                Select id, Name,
                        Statement_Preference__c,
                        Overdue_Balance__c,
                        Delinquent_Balance__c,
                        RecordType.DeveloperName, HomePhone,
                        MobilePhone, OtherPhone
                From contact
                Where Id in :setContact
                Or Delinquent_Balance__c < 0
        ]
        );
        if (mapContact.size() > 0) {
            List<Case> precollections = [
                    Select id, Status, Reason, Guarantor_Information__c
                    From case
                    Where Type = 'Precollections'
                    and Guarantor_Information__c In :mapContact.keyset()
                    and IsClosed = false
            ];
            Set<String> setContactWithEarlyOutCase = new Set<String>();
            for (Case objCase : precollections) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
                setContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            executeRemoveCampaignTrigger = false;
            Update precollections;

            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'PreCollections', 'PreCollections M'
            });
            string preCollection = mapCampaignMapping.get('PreCollections');
            string preCollectionMobile = mapCampaignMapping.get('PreCollections M');

            Delete [
                    Select id, ContactId
                    From CampaignMember
                    Where (Campaign.Name = :preCollection or Campaign.Name = :preCollectionMobile)
                    and ContactId in :setContactWithEarlyOutCase
            ];
        }
    }

    /*
    * 08-18-2016: Sirono - Tracker # 127517035 For Precollections Case Creation
    * Method for Create Encounter Auto Case and Add the Campaign member to Campaign.
    * 10-19-2016: Viraj - Tracker # 132105543: Revisit negative balances in cases. Change "Patient_Portion__c = '< 0' to '> 0'" in condition.
    */
    Public Static void createEncounterAutoCase(List<Encounter__c> lstEncounter) {
        Set<String> setContact = new Set<String>();

        for (Encounter__c obj : lstEncounter) {
            //10-19-2016: Viraj - Tracker # 132105543 Change "Patient_Portion__c = '< 0' to '> 0'" in condition.
            if (obj.Patient_Portion__c > 0 && obj.Date_of_Service__c >= Date.today()) {
                if (obj.Guarantor__c != null) {
                    setContact.add(obj.Guarantor__c);
                }
            }
        }
        Map<Id, Contact> mapContact = new map<Id, Contact>(
        [
                Select id, Name,
                        Statement_Preference__c, Overdue_Balance__c,
                        Delinquent_Balance__c,
                        RecordType.DeveloperName, HomePhone,
                        MobilePhone, OtherPhone
                From contact
                Where Id in :setContact
        ]
        );
        if (mapContact.size() > 0) {
            Map<Id, Id> mapComplianceContact = new Map<Id, Id>();
            List<Group> lstGroup = [
                    Select Id
                    From Group
                    Where Name = 'Automated Cases'
                    and Type = 'Queue'
            ];

            for (Case objCase : [
                    Select id, Guarantor_Information__c
                    From case
                    Where Reason = 'Compliance Issue'
                    and Guarantor_Information__c In :mapContact.keyset()
                    and IsClosed = false
            ]) {
                mapComplianceContact.Put(objCase.Guarantor_Information__c, objCase.id);
            }

            Map<Id, Case> mapContactCase = new Map<Id, Case>();
            Map<String, String> mapCampaignName = new Map<String, String>();
            Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();
            Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                    'PreService', 'PreService M'
            });
            string preService = mapCampaignMapping.get('PreService');
            string preServiceMobile = mapCampaignMapping.get('PreService M');

            for (Campaign objCampaign : [
                    Select id, Name, (
                            Select id, ContactId
                            From CampaignMembers
                            where ContactId in :mapContact.keyset()
                    )
                    From Campaign
                    Where IsActive = true
                    and (Name = :preService or Name = :preServiceMobile)
            ]) {
                mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
                for (CampaignMember objCM : objCampaign.CampaignMembers) {
                    mapCampaignMembers.get(objCampaign.Name).add(objCM.ContactId);
                }
            }


            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
            List<RecordType> rt = [
                    Select id
                    From RecordType
                    Where SobjectType = 'Case'
                    and DeveloperName = 'Automated_Cases'
            ];

            //Create a new Case
            for (Encounter__c obj : lstEncounter) {
                String strContactId;
                //10-19-2016: Viraj - Tracker # 132105543 Change "Patient_Portion__c = '< 0' to '> 0'" in condition.
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
                        if (mapCampaignName.Containskey(preService) && !mapCampaignMembers.get(preService).contains(objContact.Id)) {
                            CampaignMember cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get(preService);
                            cm.ContactId = objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                    if (objContact.MobilePhone != null) {
                        if (mapCampaignName.Containskey(preServiceMobile) && !mapCampaignMembers.get(preServiceMobile).contains(objContact.Id)) {
                            CampaignMember cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get(preServiceMobile);
                            cm.ContactId = objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                }
            }
            if (mapContactCase.size() > 0) {
                Insert mapContactCase.values();
            }
            if (lstCampaignMember.size() > 0) {
                executeCampaignMemberTrigger = false;
                insert lstCampaignMember;
                executeCampaignMemberTrigger = true;
            }
        }
    }
	
	/*
    * 08-18-2016: Sirono - Tracker # 127517147 For Automatic Encounter Case Closure
    * 08-18-2016: Sirono - Tracker # 128457157 Add/Remove Guarantor to the Preservice Call list
    * Method for Close Encounter Auto Case and Remove the Campaign member from Campaign.
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
    * 08-18-2016: Sirono - Tracker # 127517147 For Automatic Encounter Case Closure
    * 08-18-2016: Sirono - Tracker # 128457157 Add/Remove Guarantor to the Preservice Call list
    * Method for Close Encounter Auto Case and Remove the Campaign member from Campaign.
    */
    Public Static void closeEncounterAutoCase(Set<String> setEncounterIds,
            Set<String> setContact, Boolean skipEncounterCaseUpdate) {
        if (!skipEncounterCaseUpdate) {
            List<Case> encounterCase = [
                    Select id, Status, Reason, Guarantor_Information__c
                    From case
                    Where Type = 'Encounter'
                    and Guarantor_Information__c In :setContact
                    and Encounter__c IN :setEncounterIds
            ];
            for (Case objCase : encounterCase) {
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
            }
            executeRemoveCampaignTrigger = false;
            Update encounterCase;
        }

        Set<String> contactWithoutOpenEncounters = new Set<String>();
        List<Case> openEncounterCases = [
                Select Id, Guarantor_Information__c
                From Case
                Where Type = 'Encounter' and IsClosed = false
                and Guarantor_Information__c IN :setContact
        ];
        for (Case c : openEncounterCases) {
            contactWithoutOpenEncounters.add(c.Guarantor_Information__c);
        }

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'PreService', 'PreService M'
        });
        string preService = mapCampaignMapping.get('PreService');
        string preServiceMobile = mapCampaignMapping.get('PreService M');

        Delete [
                Select id, ContactId
                From CampaignMember
                Where Campaign.IsActive = true
                and (Campaign.Name = :preService or Campaign.Name = :preServiceMobile)
                and ContactId in :setContact and ContactId not in :contactWithoutOpenEncounters
        ];
    }

    /*
    * 08-22-2016: Sirono - Tracker # 127401841 For Delinquent Payment Plan Case Creation
    * 08-22-2016: Sirono - Tracker # 128197107 For Add Guarantor to the Delinquent Payment Plan Call list
    * Method for Create Delinquent Auto Case and Add the Campaign member to Campaign.
    */
    Public static void createDelinquentPaymentCase(Set<Id> contactIds) {
        List<Group> lstGroup = [select Id from Group where Name = 'Automated Cases' and Type = 'Queue'];
        List<RecordType> rt = [Select id from RecordType where SobjectType = 'Case' and DeveloperName = 'Automated_Cases'];
        Map<String, Case> mapContactCase = new Map<String, Case>();
        Map<String, String> mapCampaignName = new Map<String, String>();
        Map<String, Set<String>> mapCampaignMembers = new Map<String, Set<String>>();

        for (Case objCase : [
                Select id, Guarantor_Information__c
                From Case
                Where Guarantor_Information__c in :contactIds
                and (Type = 'Delinquent Payment Plans' Or Reason = 'Compliance Issue')
                and IsClosed = false
        ]) {
            contactIds.Remove(objCase.Guarantor_Information__c);
        }

        Map<Id, Contact> mapContact = new map<Id, Contact>(
        [
                Select id, Name,
                        Statement_Preference__c, Overdue_Balance__c,
                        Delinquent_Balance__c,
                        RecordType.DeveloperName, HomePhone,
                        MobilePhone, OtherPhone
                From contact
                where Id in :contactIds
        ]
        );

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'Delinquent', 'Delinquent M'
        });
        string delinquent = mapCampaignMapping.get('Delinquent');
        string delinquentMobile = mapCampaignMapping.get('Delinquent M');

        for (Campaign objCampaign : [
                Select id, Name, (
                        Select id, ContactId
                        From CampaignMembers
                        Where ContactId in :contactIds
                )
                From Campaign
                Where Name = :delinquent
                or Name = :delinquentMobile
        ]) {
            mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
            mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
            for (CampaignMember objCM : objCampaign.CampaignMembers) {
                mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
            }
        }

        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
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
                if (mapCampaignName.Containskey(delinquent)
                        && !mapCampaignMembers.get(delinquent).contains(objContact.Id)) {
                    CampaignMember cm = New CampaignMember();
                    cm.CampaignId = mapCampaignName.get(delinquent);
                    cm.ContactId = objContact.Id;
                    lstCampaignMember.add(cm);
                }
            }
            if (objContact.MobilePhone != null) {
                if (mapCampaignName.Containskey(delinquentMobile)
                        && !mapCampaignMembers.get(delinquentMobile).contains(objContact.Id)) {
                    CampaignMember cm = New CampaignMember();
                    cm.CampaignId = mapCampaignName.get(delinquentMobile);
                    cm.ContactId = objContact.Id;
                    lstCampaignMember.add(cm);
                }
            }
        }
        if (lstCampaignMember.size() > 0) {
            executeCampaignMemberTrigger = false;
            insert lstCampaignMember;
            executeCampaignMemberTrigger = true;
        }

        Insert mapContactCase.Values();
    }

    /*
    * 08-22-2016: Sirono - Tracker # 127401841 For Close Delinquent Payment Plan Case
    * 08-22-2016: Sirono - Tracker # 128197107 For Remove Guarantor to the Delinquent Payment Plan Call list
    * Method for Create Delinquent Auto Case and Add the Campaign member to Campaign.
    */
    Public static void closeDelinquentPaymentCase(Set<Id> contactIds, Set<Id> paymentPlanID) {

        if (!paymentPlanID.IsEmpty()) {
            For (test__c test: [
                    Select id, Guarantor_Name__c
                    From test__c
                    Where Id not in :paymentPlanID
                    and Guarantor_Name__c in :contactIds
                    and active__c = true
                    and Delinquent__c = true
            ]) {
                contactIds.remove(test.Guarantor_Name__c);
            }
        }

        List<Case> lstCase = [
                Select id, Guarantor_Information__c
                From Case
                Where Guarantor_Information__c in :contactIds
                and Type = 'Delinquent Payment Plans'
                and IsClosed = false
        ];
        contactIds = new Set<Id>();
        for (Case objCase : lstCase) {
            objCase.Status = 'Closed';
            objCase.Reason = 'Closed - Automated';
            contactIds.add(objCase.Guarantor_Information__c);
        }
        Update lstCase;

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'Delinquent', 'Delinquent M'
        });
        string delinquent = mapCampaignMapping.get('Delinquent');
        string delinquentMobile = mapCampaignMapping.get('Delinquent M');

        Delete [
                Select id, ContactId
                From CampaignMember
                Where (Campaign.Name = :delinquent or Campaign.Name = :delinquentMobile)
                and ContactId in :contactIds
        ];
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

        for (Case objCase : [
                Select id, Guarantor_Information__c
                From Case
                where Guarantor_Information__c in :contactIds
                and (Type = 'CC Error' Or Reason = 'Compliance Issue')
                and IsClosed = false
        ]) {
            contactIds.Remove(objCase.Guarantor_Information__c);
        }

        List<Group> lstGroup = [
                Select Id
                From Group
                Where Name = 'Automated Cases' and Type = 'Queue'
        ];
        List<RecordType> rt = [
                Select id
                From RecordType
                Where SobjectType = 'Case' and DeveloperName = 'Automated_Cases'
        ];
        Map<Id, Contact> mapContact = new map<Id, Contact>([
                Select id, Name, RecordType.DeveloperName, HomePhone, MobilePhone, OtherPhone
                from contact
                where Id in :contactIds
        ]);
        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'CC Error', 'CC Error M'
        });
        string ccError = mapCampaignMapping.get('CC Error');
        string ccErrorMobile = mapCampaignMapping.get('CC Error M');

        for (Campaign objCampaign : [
                Select id, Name, (
                        Select id, ContactId
                        From CampaignMembers
                        Where ContactId in :contactIds
                )
                From Campaign
                Where Name = :ccError
                or Name = :ccErrorMobile
        ]) {
            mapCampaignName.Put(objCampaign.Name, objCampaign.Id);
            mapCampaignMembers.Put(objCampaign.Name, New Set<String>());
            for (CampaignMember objCM : objCampaign.CampaignMembers) {
                mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
            }
        }

        List<CampaignMember> lstCampaignMember = new List<CampaignMember>();
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
                if (mapCampaignName.Containskey(ccError) && !mapCampaignMembers.get(ccError).contains(objContact.Id)) {
                    CampaignMember cm = New CampaignMember();
                    cm.CampaignId = mapCampaignName.get(ccError);
                    cm.ContactId = objContact.Id;
                    lstCampaignMember.add(cm);
                }
            }
            if (objContact.MobilePhone != null) {
                if (mapCampaignName.Containskey(ccErrorMobile) && !mapCampaignMembers.get(ccErrorMobile).contains(objContact.Id)) {
                    CampaignMember cm = New CampaignMember();
                    cm.CampaignId = mapCampaignName.get(ccErrorMobile);
                    cm.ContactId = objContact.Id;
                    lstCampaignMember.add(cm);
                }
            }

        }
        if (lstCampaignMember.size() > 0) {
            executeCampaignMemberTrigger = false;
            insert lstCampaignMember;
            executeCampaignMemberTrigger = true;
        }
        Insert mapContactCase.Values();
    }

    /*
    * 08-26-2016: Sirono - Tracker # 127517121 For Automatic Credit Card Error Case Closure
    * 08-26-2016: Sirono - Tracker # 127517003 For Remove Guarantor to the CC Error Call list
    * Method for Create CC Error Auto Case and Remove the Campaign member to Campaign.
    */
    Public static void closeCCErrorCase(Set<Id> contactIds, Set<Id> paymentPlanID) {

        if (!paymentPlanID.IsEmpty()) {
            for (test__c test: [
                    Select id, Guarantor_Name__c
                    From test__c
                    Where Id not in :paymentPlanID
                    and Guarantor_Name__c in :contactIds
                    and active__c = true
                    and Has_Error__c = true
                    and Payable_Amount__c <= -100
            ]) {
                contactIds.remove(test.Guarantor_Name__c);
            }
        }

        List<Case> lstCase = [
                Select id, Guarantor_Information__c
                From Case
                Where Guarantor_Information__c in :contactIds
                and Type = 'CC Error' and IsClosed = false
        ];
        contactIds = new Set<Id>();
        for (Case objCase : lstCase) {
            objCase.Status = 'Closed';
            objCase.Reason = 'Closed - Automated';
            contactIds.add(objCase.Guarantor_Information__c);
        }
        Update lstCase;

        Map<String, String> mapCampaignMapping = campaignMapping(new Set<String>{
                'CC Error', 'CC Error M'
        });
        string ccError = mapCampaignMapping.get('CC Error');
        string ccErrorMobile = mapCampaignMapping.get('CC Error M');

        Delete [
                Select id, ContactId
                From CampaignMember
                Where (Campaign.Name = :ccError or Campaign.Name = :ccErrorMobile )
                and ContactId in :contactIds
        ];
    }

    //Get the Campaign Mappings from the meta data.
    public static Map<String, String> campaignMapping(Set<String> campaignName) {
        Map<String, String> mapCampaignMapping = new Map<String, String>();

        for (Campaign_Mapping__mdt objCM : [
                Select MasterLabel, Salesforce_Campaign_Name__c
                From Campaign_Mapping__mdt
                Where MasterLabel in :campaignName
        ]) {
            mapCampaignMapping.put(objCM.MasterLabel, objCM.Salesforce_Campaign_Name__c);
        }
        return mapCampaignMapping;
    }
}