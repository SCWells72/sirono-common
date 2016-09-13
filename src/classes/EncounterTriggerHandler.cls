public with sharing class EncounterTriggerHandler {
	public static void beforeInsert(List<Encounter__c> newList){
		prePopulateFields(newList, null);
	}
	
	public static void afterInsert(List<Encounter__c> newList){
		checkCallListRemove(newList, null);
		CaseUtil.CreateEncounterAutoCase(newList);
	}
	
	public static void beforeUpdate(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap){
		prePopulateFields(newList, oldMap);
	}
	
	public static void afterUpdate(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap){
		checkCallListRemove(newList, oldMap);
		CaseUtil.CallCloseEncounterAutoCase(newList, false);
	}
	
	private static void prePopulateFields(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap){
		// IDENTIFY THE PATIENTS FOR WHICH WE NEED TO FIND GUARANTORS
		Map<Id, Id> patientToGuarantorMap = new Map<Id, Id>();
		for(Encounter__c e : newList){
			if(e.Patient__c != null 
				&& (oldMap == null || (e.Patient__c != oldMap.get(e.Id).Patient__c) || e.Guarantor__c == null)){
				patientToGuarantorMap.put(e.Patient__c, null);
			}
		}
		
		if(patientToGuarantorMap.size() > 0){
			// FIND THE MATCHED GUARANTOR THROUGH CHARGE GROUP
			for(Charge_Group__c cg : [Select Id, Patient_Name__c, Guarantor_Name__c, Date_Of_Service_Start_Date__c 
				From Charge_Group__c Where Patient_Name__c IN :patientToGuarantorMap.keySet() 
					ORDER BY Patient_Name__c, Date_Of_Service_Start_Date__c]){
				patientToGuarantorMap.put(cg.Patient_Name__c, cg.Guarantor_Name__c);
			}
			
			//IDENTIFY HOW MANY PATIENTS DON"T HAVE ANY GUARANTORS
			Map<Id, Contact> guarantorsToCreate = new Map<Id, Contact>();
			for(Id keyId : patientToGuarantorMap.keySet()){
				if(patientToGuarantorMap.get(keyId) == null){
					guarantorsToCreate.put(keyId, null);
				}
			}
			
			//FETCH PATIENT INFO AND CREATE A GUARANTOR
			if(guarantorsToCreate.keySet().size() > 0){
				Id guarantorRecordTypeId = null;
				for(RecordType rt : [Select Id From RecordType Where sObjectType = 'Contact' AND DeveloperName = 'Guarantor']){
					guarantorRecordTypeId = rt.Id;
				}
				
				for(Contact pataient : [Select Id, FirstName, LastName, Birthdate, HomePhone, MobilePhone, 
					Phone, Email, Gender__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, 
					OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry
						From Contact Where Id IN :guarantorsToCreate.keySet()]){
					Contact newGuarantor = new Contact();
					newGuarantor.RecordTypeId = guarantorRecordTypeId;
					newGuarantor.FirstName = pataient.FirstName;
					newGuarantor.LastName = pataient.LastName;
					newGuarantor.Birthdate = pataient.Birthdate;
					newGuarantor.HomePhone = pataient.HomePhone;
					newGuarantor.MobilePhone = pataient.MobilePhone;
					newGuarantor.Phone = pataient.Phone;
					newGuarantor.Email = pataient.Email;
					newGuarantor.Gender__c = pataient.Gender__c;
					newGuarantor.MailingStreet = pataient.MailingStreet;
					newGuarantor.MailingCity = pataient.MailingCity;
					newGuarantor.MailingState = pataient.MailingState;
					newGuarantor.MailingPostalCode = pataient.MailingPostalCode;
					newGuarantor.MailingCountry = pataient.MailingCountry;
					newGuarantor.OtherStreet = pataient.OtherStreet;
					newGuarantor.OtherCity = pataient.OtherCity;
					newGuarantor.OtherState = pataient.OtherState;
					newGuarantor.OtherPostalCode = pataient.OtherPostalCode;
					newGuarantor.OtherCountry = pataient.OtherCountry;
					guarantorsToCreate.put(pataient.Id, newGuarantor);
				}
				insert guarantorsToCreate.values();
			}
			
			//POPULATE GUARANTOR ON ENCOUNTER
			for(Encounter__c e : newList){
				if(e.Patient__c != null 
					&& (oldMap == null || (e.Patient__c != oldMap.get(e.Id).Patient__c) || e.Guarantor__c == null)){
					if(patientToGuarantorMap.containsKey(e.Patient__c) && patientToGuarantorMap.get(e.Patient__c) != null){
						e.Guarantor__c = patientToGuarantorMap.get(e.Patient__c);
					}else if(guarantorsToCreate.containsKey(e.Patient__c) && guarantorsToCreate.get(e.Patient__c) != null){
						e.Guarantor__c = guarantorsToCreate.get(e.Patient__c).Id;
					}
				}
			}
		}
	}
	
	private static void checkCallListRemove(List<Encounter__c> newList, Map<Id, Encounter__c> oldMap){
		Set<Id> contactIds = new Set<Id>();
		for(Encounter__c e : newList){
			if(e.Liability__c > 100 && e.Date_of_Service__c == System.Today() 
			&& e.Cancelled__c && e.Patient__c != null &&
			(oldMap == null || e.Liability__c != oldMap.get(e.Id).Liability__c
				|| e.Date_of_Service__c != oldMap.get(e.Id).Date_of_Service__c
				|| e.Cancelled__c != oldMap.get(e.Id).Cancelled__c
				|| e.Guarantor__c != oldMap.get(e.Id).Guarantor__c)){
				contactIds.add(e.Guarantor__c);	
			}
		}
		
		if(contactIds.size() > 0){
			CallListUtilities.PreServiceCallListRemoval(contactIds);
		}
	}
}