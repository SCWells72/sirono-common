public without sharing class WorkWithEstimatesController {
	//TODO dynamic domain
	public static final String FILE_PREFIX = '/guarantor/servlet/servlet.FileDownload?file=';

	@AuraEnabled
    public static List<EstimateWrapper> getAllEstimates(String groupFilter, String additionalFilter) {
		String selectedPatients = '';
		if(!String.isBlank(additionalFilter)) {
			List<String> additionalFilters = additionalFilter.split(',');
			selectedPatients += ' AND Patient__c IN :additionalFilters';
		}
		List<EstimateWrapper> allEstimates = new List<EstimateWrapper>();
		User u = [
			SELECT	ContactId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		if (u.ContactId != null) {
			String query = 'SELECT (SELECT Amount__c, Deposit_Date__c FROM Payments__r), Id, Name, Patient__r.Name, Estimate_ID__c, Patient_Portion__c, '+
							'Date_of_Service__c, Patient__r.Medical_Record_Number__c, Procedure__c, '+
							'Location__c, Encounter_ID__c, Total_Charges__c, Insurance_Discount__c, '+
							'Insurance_Portion__c, Total_Payments__c, Balance__c, Type__c, Ordering_Physician__c, '+
							'(SELECT Id  FROM Attachments ORDER BY CreatedDate DESC LIMIT 1),' +
							'Coverage__c, Coverage__r.Name '+
							'FROM Encounter__c WHERE Guarantor__c = \'' + u.ContactId + '\'' + selectedPatients;

			if (groupFilter != null && groupFilter != '') {
				if (groupFilter == 'Unpaid') {
					query += ' AND Encounter__c.Balance__c > 0 AND (Encounter__c.Total_Payments__c = null OR Encounter__c.Total_Payments__c = 0) '; 
				}
				if (groupFilter == 'Paid') {
					query += ' AND ((Encounter__c.Balance__c > 0 AND Encounter__c.Total_Payments__c > 0 ) OR Encounter__c.Balance__c <= 0) ';
				}
			}
			System.debug('Soql query: ' + query);
			System.debug('groupFilter: ' + groupFilter);
			
			List<Encounter__c> listOfEncounters = Database.query(query);
			System.debug('listOfEncounters :' + listOfEncounters);
			for (Encounter__c encounter : listOfEncounters) {
				EstimateWrapper estimate = new EstimateWrapper(encounter);
				allEstimates.add(estimate);
			}
		}
		return allEstimates;
	}

	@AuraEnabled
	public static List<WorkWithInvoicesController.PatientWrapper> getPatientList() {
		List<WorkWithInvoicesController.PatientWrapper> result = new List<WorkWithInvoicesController.PatientWrapper>();
		User u = [
				SELECT	ContactId
				FROM	User
				WHERE	Id =: UserInfo.getUserId()
		];
		if(u.ContactId == null) {
			return new List<WorkWithInvoicesController.PatientWrapper>();
		}
		List<Encounter__c> estimateList = [
											SELECT
													Patient__r.Medical_Record_Number__c,
													Patient__r.Name
											FROM	Encounter__c
											WHERE	Guarantor__c = :u.ContactId
											LIMIT   50000
		];
		for(Integer i = 0; i < estimateList.size(); i++) {
			result.add(new WorkWithInvoicesController.PatientWrapper(estimateList[i]));
		}
		return result;
	}

	public class EstimateWrapper {
		@AuraEnabled Encounter__c singleEncounter {get;set;}
		@AuraEnabled Decimal	  insuranceDiscount {get;set;}
		@AuraEnabled Decimal	  insurancePortion {get;set;}
		@AuraEnabled String		  estimateStatus {get;set;}
		@AuraEnabled String		  fileUrl {get;set;}
		
		public EstimateWrapper(Encounter__c singleEncounter) {
			this.singleEncounter = singleEncounter;
			if (singleEncounter.Insurance_Discount__c != null)
				insuranceDiscount = - singleEncounter.Insurance_Discount__c; // TODO update after fields creation
			if (singleEncounter.Insurance_Portion__c != null)
				insurancePortion = - singleEncounter.Insurance_Portion__c; // TODO update after fields creation
			String status = '';
			if(singleEncounter.Balance__c > 0 && (singleEncounter.Total_Payments__c == null || singleEncounter.Total_Payments__c == 0)){
				status = 'Unpaid';
			} else if ((singleEncounter.Balance__c > 0 && singleEncounter.Total_Payments__c > 0) || singleEncounter.Balance__c <= 0) {
				status = 'Paid';
			}
			this.estimateStatus = status;
			if(singleEncounter.Attachments != null && singleEncounter.Attachments.size() > 0) {
				fileUrl = FILE_PREFIX + singleEncounter.Attachments[0].Id;
			}
		}
	}
}