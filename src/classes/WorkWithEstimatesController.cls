public with sharing class WorkWithEstimatesController {

	@AuraEnabled
    public static List<EstimateWrapper> getAllEstimates(String groupFilter, String additionalFilter) {
		List<EstimateWrapper> allEstimates = new List<EstimateWrapper>();
		User u = [
			SELECT	ContactId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		if (u.ContactId != null) {
			String query = 'SELECT Id, Name, Patient__r.Name, Estimate_ID__c, Patient_Portion__c, '+
							'Date_of_Service__c, Patient__r.Medical_Record_Number__c, Procedure__c, '+
							'Location__c, Encounter_ID__c, Total_Charges__c, Insurance_Discount__c, '+
							'Insurance_Portion__c '+
							'FROM Encounter__c WHERE Guarantor__c = \'' + u.ContactId + '\'';
			List<Encounter__c> listOfEncounters = Database.query(query);
			for (Encounter__c encounter : listOfEncounters) {
				allEstimates.add(
					new EstimateWrapper(
						encounter
					)
				);
			}
		}
		return allEstimates;
	}

	public class EstimateWrapper {
		@AuraEnabled Encounter__c singleEncounter {get;set;}
		@AuraEnabled Decimal insuranceDiscount {get;set;}
		@AuraEnabled Decimal insurancePortion {get;set;}
		
		public EstimateWrapper(Encounter__c singleEncounter) {
			this.singleEncounter = singleEncounter;
			if (singleEncounter.Insurance_Discount__c != null)
				insuranceDiscount = - singleEncounter.Insurance_Discount__c; // TODO update after fields creation
			if (singleEncounter.Insurance_Portion__c != null)
				insurancePortion = - singleEncounter.Insurance_Portion__c; // TODO update after fields creation
		}
	}
}