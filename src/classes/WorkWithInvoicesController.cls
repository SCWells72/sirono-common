public with sharing class WorkWithInvoicesController {
	
	@AuraEnabled
    public static List<InvoicesWrapper> getAllInvoices(String groupFilter, String additionalFilter) {
		List<InvoicesWrapper> allInvoices = new List<InvoicesWrapper>();
		User u = [
			SELECT	ContactId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		if (u.ContactId != null) {
			List<Invoice__c> listOfInvoices = new List<Invoice__c>();
			String query = 'SELECT Id, Name, Patient__r.Name, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Invoice_Status__c, '+
							'Due_Date__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Invoiced_Balance__c, '+
							'Guarantor__r.Due_Balance__c, Guarantor__r.Delinquent_Balance__c, Partial_Payment_Plan__c, ' + 
							'Guarantor__r.Payment_Plan_Balance__c, Guarantor__r.Pre_Invoiced_Balance__c, ' +
							'(SELECT Id FROM Charge_Groups__r) ' +
							'FROM Invoice__c WHERE Guarantor__c = \'' + u.ContactId + '\'';
			listOfInvoices = Database.query(query);

			Set<String> allChargeGroupIds = new Set<String>();
			for (Invoice__c invoice : listOfInvoices) {
				for (Charge_Group__c cGroup : invoice.Charge_Groups__r) {
					allChargeGroupIds.add(cGroup.Id);
				}
			}
			List<Charge_Group__c> allGroups = [
				SELECT
						Id,
						Name,
						Balance__c,
						Location__c,
						Location__r.Name,
						External_ID__c,
						Sirono_Assigned_Date__c,
						(
							SELECT
									Id,
									Name,
									Amount__c,
									Post_Date__c
							FROM	Payment_Adjustments__r
						),
						(
							SELECT
									Id,
									Name,
									Amount__c
							FROM	Services__r
						)
				FROM	Charge_Group__c
				WHERE	Id IN: allChargeGroupIds
			];
			Map<Id,Charge_Group__c> allGroupsMap = new Map<Id,Charge_Group__c>(allGroups);

			for (Invoice__c invoice : listOfInvoices) {
				allInvoices.add(
					new InvoicesWrapper(
						invoice,
						allGroupsMap
					)
				);
			}
		}
		return allInvoices;
	}


	@AuraEnabled
    public static List<InvoicesWrapper> getInvoice(String invoiceId) {
		List<InvoicesWrapper> allInvoices = new List<InvoicesWrapper>();
		User u = [
			SELECT	ContactId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		if (u.ContactId != null) {
			List<Invoice__c> listOfInvoices = new List<Invoice__c>();
			String query = 'SELECT Id, Name, Patient__r.Name, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Invoice_Status__c, '+
							'Due_Date__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Invoiced_Balance__c, '+
							'Guarantor__r.Due_Balance__c, Guarantor__r.Delinquent_Balance__c, Partial_Payment_Plan__c, ' + 
							'Guarantor__r.Payment_Plan_Balance__c, Guarantor__r.Pre_Invoiced_Balance__c, ' +
							'(SELECT Id FROM Charge_Groups__r) ' +
							'FROM Invoice__c WHERE Guarantor__c = \'' + u.ContactId + '\'' + ' AND Id =\'' + invoiceId + '\'';
			listOfInvoices = Database.query(query);

			Set<String> allChargeGroupIds = new Set<String>();
			for (Invoice__c invoice : listOfInvoices) {
				for (Charge_Group__c cGroup : invoice.Charge_Groups__r) {
					allChargeGroupIds.add(cGroup.Id);
				}
			}
			List<Charge_Group__c> allGroups = [
				SELECT
						Id,
						Name,
						Balance__c,
						Location__c,
						Location__r.Name,
						External_ID__c,
						Sirono_Assigned_Date__c,
						(
							SELECT
									Id,
									Name,
									Amount__c,
									Post_Date__c
							FROM	Payment_Adjustments__r
						),
						(
							SELECT
									Id,
									Name,
									Amount__c
							FROM	Services__r
						)
				FROM	Charge_Group__c
				WHERE	Id IN: allChargeGroupIds
			];
			Map<Id,Charge_Group__c> allGroupsMap = new Map<Id,Charge_Group__c>(allGroups);

			for (Invoice__c invoice : listOfInvoices) {
				allInvoices.add(
					new InvoicesWrapper(
						invoice,
						allGroupsMap
					)
				);
			}
		}
		return allInvoices;
	}



	public class InvoicesWrapper {
		@AuraEnabled Invoice__c singleInvoice {get;set;}
		@AuraEnabled Decimal balanceDue {get;set;}
		//@AuraEnabled Boolean isPaid {get;set;}
		//@AuraEnabled Boolean isOverdue {get;set;}
		@AuraEnabled List<ChargeGroupWrapper> allGroups {get;set;}

		public InvoicesWrapper(Invoice__c invoice, Map<Id,Charge_Group__c> allGroupsMap) {
			this.singleInvoice = invoice;
			this.balanceDue = 0;
			//this.balanceDue = invoice.Guarantor__r.Due_Balance__c;
			allGroups = new List<ChargeGroupWrapper>();
			for (Charge_Group__c cGroup : invoice.Charge_Groups__r) {
				allGroups.add(
					new ChargeGroupWrapper(
						allGroupsMap.get(cGroup.Id)
					)
				);
				if (allGroupsMap.get(cGroup.Id).Balance__c != null)
					balanceDue += allGroupsMap.get(cGroup.Id).Balance__c;

			}
		}
	}

	public class ChargeGroupWrapper {
		@AuraEnabled Charge_Group__c cGroup {get;set;}
		@AuraEnabled Decimal totalCharges {get;set;}
		@AuraEnabled Decimal totalCredits {get;set;}

		public ChargeGroupWrapper(Charge_Group__c cGroup) {
			this.cGroup = cGroup;
			totalCredits = 0;
			for (Payment_Adjustments__c pa : cGroup.Payment_Adjustments__r) {
				if (pa.Amount__c != null)
					totalCredits += pa.Amount__c;
			}
			totalCharges = 0;
			for (Service__c service : cGroup.Services__r) {
				if (service.Amount__c != null)
					totalCharges += service.Amount__c;
			}
		}
	}
}