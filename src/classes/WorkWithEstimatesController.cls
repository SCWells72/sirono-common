public without sharing class WorkWithEstimatesController {
	//TODO dynamic domain
	public static final String FILE_PREFIX = 'https://c.cs18.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=';

	@AuraEnabled
    public static List<EstimateWrapper> getAllEstimates(String groupFilter, String additionalFilter) {
		String selectedPatients = '';
		if(!String.isBlank(additionalFilter)) {
			selectedPatients += ' AND Patient__c IN (';
			selectedPatients += additionalFilter.removeEnd(',') + ')';
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
							'(SELECT ContentDocument.LatestPublishedVersionId  FROM ContentDocumentLinks ORDER BY SystemModstamp DESC),' +
							'Coverage__c, Coverage__r.Name '+
							'FROM Encounter__c WHERE Guarantor__c = \'' + u.ContactId + '\'' + selectedPatients;

			if (groupFilter != null && groupFilter != '') {
				if (groupFilter == 'Unpaid') {
					query += ' AND Encounter__c.Balance__c > 0 AND Encounter__c.Total_Payments__c = null '; 
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
		List<ContentDocument> tempList = [Select Id From ContentDocument];
		List<ContentVersion> tempVersionList = [Select Id From ContentVersion];
		List<ContentDocumentLink> tempLinkList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :u.ContactId];

		System.debug('tempList' + tempList);
		System.debug('tempLinkList' + tempLinkList);
		System.debug('tempVersionList' + tempVersionList);
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
			if(singleEncounter.Balance__c > 0 && singleEncounter.Total_Payments__c == null){
				status = 'Unpaid';
			} else if ((singleEncounter.Balance__c > 0 && singleEncounter.Total_Payments__c > 0) || singleEncounter.Balance__c <= 0) {
				status = 'Paid';
			}
			this.estimateStatus = status;
			System.debug('singleEncounter.ContentDocumentLinks' + singleEncounter.ContentDocumentLinks);
			if(singleEncounter.ContentDocumentLinks != null && singleEncounter.ContentDocumentLinks.size() > 0) {
				fileUrl = FILE_PREFIX + singleEncounter.ContentDocumentLinks[0].ContentDocument.LatestPublishedVersionId;
			}
		}
	}
}