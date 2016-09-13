Public Class CaseUtil{
    Public static Boolean ExecuteCampaignMemberTrigger = True;
    Public static Boolean ExecuteRemoveCampaignTrigger = True;
    
    public CaseUtil() {
        
    }
    
    Public Static void CallEarlyOutAutoCase(){
        List<Statement__c> lstStatement = [Select id,Guarantor__c from Statement__c where Statement_Date__c =: System.today() ];
        CreateEarlyOutAutoCase(lstStatement);
    }

    Public Static void CreateEarlyOutAutoCase(List<Statement__c> lstStatement){
        Set<String> setContact = new Set<String>();
        
        for(Statement__c objStatement : lstStatement){
            setContact.add(objStatement.Guarantor__c); 
        }
        Map<Id,Contact> mapContact = new map<Id,Contact>([Select id,Name,Statement_Preference__c,Overdue_Balance__c,Delinquent_Balance__c,
                                        RecordType.DeveloperName,HomePhone,MobilePhone,OtherPhone
                                      from contact 
                                      where Id in : setContact and Overdue_Balance__c < 0]);
                                  
        if(mapContact.size() > 0){
            Map<Id,Id> mapComplianceContact = new Map<Id,Id>();
            List<Group> lstGroup = [select Id from Group where Name = 'Automated Cases' and Type = 'Queue'];
            
            for(Case objCase : [Select id,Guarantor_Information__c  from case where Reason = 'Compliance Issue' and Guarantor_Information__c In : mapContact.keyset()]){
                mapComplianceContact.Put(objCase.Guarantor_Information__c,objCase.id);       
            }
            
            Map<Id,Case> mapContactCase = new Map<Id,Case>();
            
            
            Map<String,String> mapCampaignName = new Map<String,String>();
            Map<String,Set<String>> mapCampaignMembers = new Map<String,Set<String>>();
            
            for(Campaign  objCampaign : [Select id,Name,
                                        (Select id,ContactId  from CampaignMembers where ContactId in : mapContact.keyset()) 
                                        from Campaign where Name = 'Early Out' or  Name = 'Early Out - Mobile']){
                mapCampaignName.Put(objCampaign.Name,objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>()); 
                for(CampaignMember objCM : objCampaign.CampaignMembers){
                    mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                }
            }
            
            
            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();            
            List<RecordType> RT =[Select id from   RecordType where SobjectType ='Case' and DeveloperName = 'Automated_Cases'];
            
            //Check Any Early Out Case is exist if exist the closed it and creted new one.            
            List<Case> lstEarlyOutCases = [Select id,Type from case where Type = 'Early Out' and Guarantor_Information__c In : mapContact.keyset() and Guarantor_Information__c not In : mapComplianceContact.keyset()];
            for(Case objCase : lstEarlyOutCases){
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
            }
            ExecuteRemoveCampaignTrigger = false;
            Update lstEarlyOutCases;
                
            //Create a new Case
            for(String strContactId : mapContact.Keyset()){
                if(!mapComplianceContact.Containskey(strContactId)){
                    Contact objContact = mapContact.get(strContactId);
                    Case objCase = new Case();
                    objCase.Guarantor_Information__c = objContact.Id;
                    objCase.ContactId = objContact.Id;
                    objCase.Type = 'Early Out';
                    objCase.Status = 'New';
                    objCase.Subject = 'Early Out';
                    objCase.RecordTypeID = RT[0].Id;
                    if(lstGroup.size() > 0){
                        objCase.ownerId = lstGroup[0].Id;
                    }
                    mapContactCase.Put(objContact.Id,objCase); 
                    
                    //Add CampaignMember
                    if(objContact.HomePhone != null ||  objContact.OtherPhone != null){
                        if(mapCampaignName.Containskey('Early Out') && !mapCampaignMembers.get('Early Out').contains(objContact.Id)){
                            CampaignMember  cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get('Early Out');
                            cm.ContactId= objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                    if(objContact.MobilePhone != null){
                        if(mapCampaignName.Containskey('Early Out - Mobile') && !mapCampaignMembers.get('Early Out - Mobile').contains(objContact.Id)){
                            CampaignMember  cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get('Early Out - Mobile');
                            cm.ContactId= objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                }                
            }
            if(lstCampaignMember.size() > 0) {
                ExecuteCampaignMemberTrigger = false;
                insert lstCampaignMember;
                ExecuteCampaignMemberTrigger = true;
            }
            if(mapContactCase.size() > 0){
                Insert mapContactCase.values();
                
                //Insert the Case Charge Group
                List<Case_Charge_Group__c> lstCCG = new List<Case_Charge_Group__c >();
                for(Charge_Group__c  cg : [Select id,Guarantor_Name__c  from Charge_Group__c where Account_Status__c = 'Billed' and Guarantor_Name__c =:mapContactCase.keyset()]){
                    if(mapContactCase.Containskey(cg.Guarantor_Name__c)){
                        Case ObjCase = mapContactCase.get(cg.Guarantor_Name__c);
                        Case_Charge_Group__c ccg = new Case_Charge_Group__c();
                        ccg.Case__c = ObjCase.Id;
                        ccg.Charge_Group__c = cg.Id;

                        lstCCG.add(ccg);
                    }
                }
                insert lstCCG;
            }
        }
    }
    
    
    Public Static void CallEarlyOutAutoCaseCloser(){
        
        List<Statement__c> lstStatement = [Select id,Guarantor__c from Statement__c where Statement_Date__c =: System.today() and Day_only(CreatedDate) !=: System.today()];
        System.debug('lstStatement ' + lstStatement );
        CallCloseEarlyOutAutoCase(lstStatement);
    }
    
    //it will call EarlyOutAutoCase.
    Public Static void CallCloseEarlyOutAutoCase(List<Statement__c> lstStatement){
        Set<String> setContact = new Set<String>();
        for(Statement__c objStatement : lstStatement){
            setContact.add(objStatement.Guarantor__c); 
        }
        CloseEarlyOutAutoCase(setContact);
    }
    
    Public Static void CloseEarlyOutAutoCase(Set<String> SetContact){
        
        Map<Id,Contact> mapContact = new map<Id,Contact>([Select id,Name,Statement_Preference__c,Overdue_Balance__c,Delinquent_Balance__c,
                                        RecordType.DeveloperName,HomePhone,MobilePhone,OtherPhone
                                      from contact 
                                      where Id in : setContact Or Overdue_Balance__c >= 0]);
                                  
        if(mapContact.size() > 0){
            List<Case> EarlyOutCase = [Select id,Status ,Reason,Guarantor_Information__c from case where Type = 'Early Out' and  Guarantor_Information__c In : mapContact.keyset()]; 
            Set<String> SetContactWithEarlyOutCase = new Set<String>();
            for(Case objCase : EarlyOutCase){
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
                SetContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            ExecuteRemoveCampaignTrigger = false;
            Update EarlyOutCase;
            
            Delete [Select id,ContactId  from CampaignMember where (Campaign.Name = 'Early Out' or  Campaign.Name = 'Early Out - Mobile') and ContactId in : SetContactWithEarlyOutCase];
        }
    }
    
    
    
    //Call Method to generate a case for Pre-Collection
    Public Static void CallPrecollectionsAutoCase(){
        List<Statement__c> lstStatement = [Select id,Guarantor__c from Statement__c where Statement_Date__c =: System.today() ];
        CreatePrecollectionsAutoCase(lstStatement);
    }
    
    //Create a case for Pre-Collection
    Public Static void CreatePrecollectionsAutoCase(List<Statement__c> lstStatement){
        Set<String> setContact = new Set<String>();
        
        for(Statement__c objStatement : lstStatement){
            setContact.add(objStatement.Guarantor__c); 
        }
        Map<Id,Contact> mapContact = new map<Id,Contact>([Select id,Name,Statement_Preference__c,Overdue_Balance__c,Delinquent_Balance__c,
                                        RecordType.DeveloperName,HomePhone,MobilePhone,OtherPhone
                                      from contact 
                                      where Id in : setContact and Delinquent_Balance__c < 0]);
                                  
        if(mapContact.size() > 0){
            Map<Id,Id> mapComplianceContact = new Map<Id,Id>();
            List<Group> lstGroup = [select Id from Group where Name = 'Automated Cases' and Type = 'Queue'];
            
            for(Case objCase : [Select id,Guarantor_Information__c  from case where Reason = 'Compliance Issue' and Guarantor_Information__c In : mapContact.keyset()]){
                mapComplianceContact.Put(objCase.Guarantor_Information__c,objCase.id);       
            }
            
            Map<Id,Case> mapContactCase = new Map<Id,Case>();
            
            
            Map<String,String> mapCampaignName = new Map<String,String>();
            Map<String,Set<String>> mapCampaignMembers = new Map<String,Set<String>>();
            
            for(Campaign  objCampaign : [Select id,Name,
                                        (Select id,ContactId  from CampaignMembers where ContactId in : mapContact.keyset()) 
                                        from Campaign where Name = 'Pre-collections' or  Name = 'Pre-collections - Mobile']){
                mapCampaignName.Put(objCampaign.Name,objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>()); 
                for(CampaignMember objCM : objCampaign.CampaignMembers){
                    mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                }
            }
            
            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();            
            List<RecordType> RT =[Select id from   RecordType where SobjectType ='Case' and DeveloperName = 'Automated_Cases'];
            
            //Check Any Early Out Case is exist if exist the closed it and creted new one.            
            List<Case> lstCloseCases = [Select id,Type from case where Type = 'Precollections' and Guarantor_Information__c In : mapContact.keyset() and Guarantor_Information__c not In : mapComplianceContact.keyset()];
            for(Case objCase : lstCloseCases){
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
            }
            ExecuteRemoveCampaignTrigger = false;
            Update lstCloseCases;
                
            //Create a new Case
            for(String strContactId : mapContact.Keyset()){
                if(!mapComplianceContact.Containskey(strContactId)){
                    Contact objContact = mapContact.get(strContactId);
                    Case objCase = new Case();
                    objCase.Guarantor_Information__c = objContact.Id;
                    objCase.ContactId = objContact.Id;
                    objCase.Type = 'Precollections';
                    objCase.Status = 'New';
                    objCase.Subject = 'Precollections';
                    objCase.RecordTypeID = RT[0].Id;
                    if(lstGroup.size() > 0){
                        objCase.ownerId = lstGroup[0].Id;
                    }
                    mapContactCase.Put(objContact.Id,objCase); 
                    
                    //Add CampaignMember
                    if(objContact.HomePhone != null ||  objContact.OtherPhone != null){
                        if(mapCampaignName.Containskey('Pre-collections') && !mapCampaignMembers.get('Pre-collections').contains(objContact.Id)){
                            CampaignMember  cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get('Pre-collections');
                            cm.ContactId= objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                    if(objContact.MobilePhone != null){
                        if(mapCampaignName.Containskey('Pre-collections - Mobile') && !mapCampaignMembers.get('Pre-collections - Mobile').contains(objContact.Id)){
                            CampaignMember  cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get('Pre-collections - Mobile');
                            cm.ContactId= objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                }                
            }
            if(lstCampaignMember.size() > 0) {
                ExecuteCampaignMemberTrigger = false;
                insert lstCampaignMember;
                ExecuteCampaignMemberTrigger = true;
            }
            if(mapContactCase.size() > 0){
                Insert mapContactCase.values();
                
                //Insert the Case Charge Group
                List<Case_Charge_Group__c> lstCCG = new List<Case_Charge_Group__c >();
                for(Charge_Group__c  cg : [Select id,Guarantor_Name__c  from Charge_Group__c where Account_Status__c = 'Billed' and Guarantor_Name__c =:mapContactCase.keyset()]){
                    if(mapContactCase.Containskey(cg.Guarantor_Name__c)){
                        Case ObjCase = mapContactCase.get(cg.Guarantor_Name__c);
                        Case_Charge_Group__c ccg = new Case_Charge_Group__c();
                        ccg.Case__c = ObjCase.Id;
                        ccg.Charge_Group__c = cg.Id;

                        lstCCG.add(ccg);
                    }
                }
                insert lstCCG;
            }
        }
    }
    
    
    Public Static void CallPrecollectionsAutoCaseCloser(){
        List<Statement__c> lstStatement = [Select id,Guarantor__c from Statement__c where Statement_Date__c =: System.today() and  Day_only(CreatedDate) !=: System.today()];
        CallClosePrecollectionsAutoCase(lstStatement);
    }
    
    //it will call Pre-collectionsAutoCase close
    Public Static void CallClosePrecollectionsAutoCase(List<Statement__c> lstStatement){
        Set<String> setContact = new Set<String>();
        for(Statement__c objStatement : lstStatement){
            setContact.add(objStatement.Guarantor__c); 
        }
        ClosePrecollectionsAutoCase(setContact);
    }
    
    //It will close the case of pre-collection
    Public Static void ClosePrecollectionsAutoCase(Set<String> SetContact){
        
        Map<Id,Contact> mapContact = new map<Id,Contact>([Select id,Name,Statement_Preference__c,Overdue_Balance__c,Delinquent_Balance__c,
                                        RecordType.DeveloperName,HomePhone,MobilePhone,OtherPhone
                                      from contact 
                                      where Id in : setContact Or Delinquent_Balance__c >= 0]);
                                  
        if(mapContact.size() > 0){
            List<Case> EarlyOutCase = [Select id,Status ,Reason,Guarantor_Information__c from case where Type = 'Precollections' and  Guarantor_Information__c In : mapContact.keyset()]; 
            Set<String> SetContactWithEarlyOutCase = new Set<String>();
            for(Case objCase : EarlyOutCase){
                objCase.Status = 'Closed';
                objCase.Reason = 'Closed - Automated';
                SetContactWithEarlyOutCase.add(objCase.Guarantor_Information__c);
            }
            ExecuteRemoveCampaignTrigger = false;
            Update EarlyOutCase;
            
            Delete [Select id,ContactId  from CampaignMember where (Campaign.Name = 'Pre-collections' or  Campaign.Name = 'Pre-collections - Mobile') and ContactId in : SetContactWithEarlyOutCase];
        }
    }
    
    //Mohan Kumar 2016-08-18: create Encounter Cases
    Public Static void CreateEncounterAutoCase(List<Encounter__c> lstEncounter){
        Set<String> setContact = new Set<String>();
        
        for(Encounter__c obj : lstEncounter){
            if(obj.Patient_Portion__c < 0 && obj.Date_of_Service__c >= Date.today()) {
            	if(obj.Guarantor__c != null) setContact.add(obj.Guarantor__c);
            } 
        }
        Map<Id,Contact> mapContact = new map<Id,Contact>([Select id,Name,Statement_Preference__c,Overdue_Balance__c,Delinquent_Balance__c,
                                        RecordType.DeveloperName,HomePhone,MobilePhone,OtherPhone
                                      from contact where Id in : setContact]);
                                  
        if(mapContact.size() > 0){
        	Map<Id,Id> mapComplianceContact = new Map<Id,Id>();
        	List<Group> lstGroup = [select Id from Group where Name = 'Automated Cases' and Type = 'Queue'];
        	
            for(Case objCase : [Select id,Guarantor_Information__c  from case where Reason = 'Compliance Issue' and Guarantor_Information__c In : mapContact.keyset()]){
                mapComplianceContact.Put(objCase.Guarantor_Information__c,objCase.id);       
            }
            
            Map<Id,Case> mapContactCase = new Map<Id,Case>();
            
            Map<String,String> mapCampaignName = new Map<String,String>();
            Map<String,Set<String>> mapCampaignMembers = new Map<String,Set<String>>();
            
            for(Campaign  objCampaign : [Select id,Name,
                                        (Select id,ContactId  from CampaignMembers where ContactId in : mapContact.keyset()) 
                                        from Campaign where IsActive = true and (Name = 'Pre-Service' or  Name = 'Pre-Service - Mobile')]){
                mapCampaignName.Put(objCampaign.Name,objCampaign.Id);
                mapCampaignMembers.Put(objCampaign.Name, New Set<String>()); 
                for(CampaignMember objCM : objCampaign.CampaignMembers){
                    mapCampaignMembers.get(objCampaign.Name).Add(objCM.ContactId);
                }
            }
            
            
            List<CampaignMember> lstCampaignMember = new List<CampaignMember>();            
            List<RecordType> RT =[Select id from RecordType where SobjectType ='Case' and DeveloperName = 'Automated_Cases'];
            
            //Create a new Case
            for(Encounter__c obj : lstEncounter){
            	String strContactId;
            	if(obj.Patient_Portion__c < 0 && obj.Date_of_Service__c >= Date.today()) {
            		if(obj.Guarantor__c != null) strContactId = obj.Guarantor__c;
            	}
                if(strContactId != null && !mapComplianceContact.Containskey(strContactId)){
                    Contact objContact = mapContact.get(strContactId);
                    Case objCase = new Case();
                    objCase.Guarantor_Information__c = objContact.Id;
                    objCase.ContactId = objContact.Id;
                    objCase.Encounter__c = obj.Id;
                    objCase.Type = 'Encounter';
                    objCase.Status = 'New';
                    objCase.Subject = 'Encounter';
                    objCase.RecordTypeID = RT[0].Id;
                    if(lstGroup.size() > 0){
                        objCase.ownerId = lstGroup[0].Id;
                    }
                    mapContactCase.Put(objContact.Id,objCase); 
                    
                    //Add CampaignMember
                    if(objContact.HomePhone != null ||  objContact.OtherPhone != null){
                        if(mapCampaignName.Containskey('Pre-Service') && !mapCampaignMembers.get('Pre-Service').contains(objContact.Id)){
                            CampaignMember  cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get('Pre-Service');
                            cm.ContactId= objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                    if(objContact.MobilePhone != null){
                        if(mapCampaignName.Containskey('Pre-Service - Mobile') && !mapCampaignMembers.get('Pre-Service - Mobile').contains(objContact.Id)){
                            CampaignMember  cm = New CampaignMember();
                            cm.CampaignId = mapCampaignName.get('Pre-Service - Mobile');
                            cm.ContactId= objContact.Id;
                            lstCampaignMember.add(cm);
                        }
                    }
                }                
            }
            if(mapContactCase.size() > 0){
                Insert mapContactCase.values();
            }
            if(lstCampaignMember.size() > 0) {
                ExecuteCampaignMemberTrigger = false;
                insert lstCampaignMember;
                ExecuteCampaignMemberTrigger = true;
            }
        }
    }
    
    Public Static void CallCloseEncounterAutoCase(List<Encounter__c> lstEncounter, Boolean fromPaymentMethod){
        Set<String> setContact = new Set<String>();
        Set<String> setEncounterIds = new Set<String>();
        for(Encounter__c obj : lstEncounter){
        	if(obj.Cancelled__c || obj.Date_of_Service__c < Date.today() || obj.Patient_Portion__c == 0 || fromPaymentMethod) {
            	if(obj.Guarantor__c != null) {
            		setContact.add(obj.Guarantor__c);
            		setEncounterIds.add(obj.Id);
            	}
        	} 
        }
        CloseEncounterAutoCase(setEncounterIds, setContact, false);
    }
    
    //It will close the case of Encounter
    Public Static void CloseEncounterAutoCase(Set<String> setEncounterIds, Set<String> SetContact, Boolean skipEncounterCaseUpdate){
        if(!skipEncounterCaseUpdate) {
	        List<Case> encounterCase = [Select id,Status ,Reason,Guarantor_Information__c from case where Type = 'Encounter' 
	        								and  Guarantor_Information__c In : SetContact and Encounter__c IN :setEncounterIds]; 
	        for(Case objCase : encounterCase){
	            objCase.Status = 'Closed';
	            objCase.Reason = 'Closed - Automated';
	        }
	        ExecuteRemoveCampaignTrigger = false;
	        Update encounterCase;
        }
        
        Set<String> contactWithoutOpenEncounters = new Set<String>();
        List<Case> openEncounterCases = [Select Id, Guarantor_Information__c From Case Where Type = 'Encounter' and IsClosed = false 
        									and Guarantor_Information__c IN :SetContact];
        for(Case c : openEncounterCases) {
        	contactWithoutOpenEncounters.add(c.Guarantor_Information__c);
        }
        
        Delete [Select id,ContactId  from CampaignMember where Campaign.IsActive = true 
        					and (Campaign.Name = 'Pre-Service' or  Campaign.Name = 'Pre-Service - Mobile') 
        					and ContactId in : SetContact and ContactId not in : contactWithoutOpenEncounters];
    }
}