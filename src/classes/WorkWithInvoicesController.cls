//TODO remove without sharing
public without sharing class WorkWithInvoicesController {
	public static final String TRANSACTION_SERVICE_METHOD				= 'Service';
	public static final String SERVICE_DEFAULT_NAME						= 'Unknown';
	public static final String INVOICE_PAID_STATUS						= 'Paid';
	public static final String INVOICE_UNPAID_STATUS					= 'Unpaid';
	
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
			String query = 'SELECT Id, Name, Patient__r.Name, Patient__r.Medical_Record_Number__c, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Invoice_Status__c, '+
							'Due_Date__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Invoiced_Balance__c, '+
							'Guarantor__r.Due_Balance__c, Guarantor__r.Delinquent_Balance__c, Partial_Payment_Plan__c, ' + 
							'Guarantor__r.Payment_Plan_Balance__c, Guarantor__r.Pre_Invoiced_Balance__c, ' +
							'(SELECT Id, Payment_Plan__c, Payment_Plan__r.Active__c, Payment_Plan__r.Installment_Amount__c, ' +
							'Payment_Plan__r.NextPaymentDate__c FROM Charge_Groups__r) ' +
							'FROM Invoice__c WHERE Guarantor__c = \'' + u.ContactId + '\'';
			
			/*Unpaid (Invoice Status = Delinquent, Overdue, Due, or On Payment Plan), 
			Paid (Invoice Status = Paid or Invoice Voided), 
			Overdue (Invoice Status = Overdue), 
			Delinquent (Invoice Status = Delinquent), 
			and On Payment Plan (Invoice Status = On Payment Plan).*/
			if(groupFilter != null && groupFilter != '') {
				if(groupFilter == INVOICE_UNPAID_STATUS){
					query += ' AND Invoice_Status__c IN (\'Delinquent\', \'Overdue\', \'Due\', \'On Payment Plan\')';
				} else if(groupFilter == INVOICE_PAID_STATUS) {
					query += ' AND Invoice_Status__c IN (\'Paid\', \'Invoice Voided\')';
				} else {
					query += ' AND Invoice_Status__c = \'' + groupFilter + '\'';
				}
			}
			
			System.debug('QUERY: ' + query);
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
						Provider__r.Name,
						Account_Type__c,
						External_ID__c,
						Payment_Plan__c,
						Payment_Plan__r.Active__c,
						Payment_Plan__r.Installment_Amount__c,
						Payment_Plan__r.NextPaymentDate__c,
						Sirono_Assigned_Date__c,
						Date_Of_Service_Start_Date__c,
						Date_Of_Service_End_Date__c,
						(
							SELECT 
									Adjustment__r.Name,
									Payment__r.Name,
									Service__r.Name,
									Amount__c,
									Txn_Method__c
							FROM	Transactions__r
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
    public static List<WorkWithEstimatesController.EstimateWrapper> getAllEstimates(String groupFilter, String additionalFilter) {
		return WorkWithEstimatesController.getAllEstimates(groupFilter, additionalFilter);
	}

	@AuraEnabled
	public static List<WorkWithEstimatesController.EstimateWrapper> getEstimate(String invoiceId){
		List<WorkWithEstimatesController.EstimateWrapper> allEstimates = new List<WorkWithEstimatesController.EstimateWrapper>();
		User u = [
			SELECT	ContactId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		if (u.ContactId != null) {
			String query = 'SELECT Id, Name, Patient__r.Name, Estimate_ID__c, Patient_Portion__c, '+
							'Date_of_Service__c, Patient__r.Medical_Record_Number__c, Procedure__c, '+
							'Location__c, Encounter_ID__c, Total_Charges__c, Insurance_Discount__c, '+
							'Insurance_Portion__c, Total_Payments__c, Balance__c, Type__c, Ordering_Physician__c, '+
							'(SELECT Amount__c, Deposit_Date__c FROM Payments__r) '+
							'FROM Encounter__c WHERE Guarantor__c = \'' + u.ContactId + '\'' + ' AND Id =\'' + invoiceId + '\'';
			List<Encounter__c> listOfEncounters = Database.query(query);

			for (Encounter__c encounter : listOfEncounters) {
				allEstimates.add(
					new WorkWithEstimatesController.EstimateWrapper(
						encounter
					)
				);
			}
		}
		return allEstimates;
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
			String query = 'SELECT Id, Name, Patient__r.Name, Patient__r.Medical_Record_Number__c, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Invoice_Status__c, '+
							'Due_Date__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Invoiced_Balance__c, '+
							'Guarantor__r.Due_Balance__c, Guarantor__r.Delinquent_Balance__c, Partial_Payment_Plan__c, ' + 
							'Guarantor__r.Payment_Plan_Balance__c, Guarantor__r.Pre_Invoiced_Balance__c, ' +
							'(SELECT Id, Payment_Plan__c, Payment_Plan__r.Active__c, Payment_Plan__r.Installment_Amount__c, ' +
							'Payment_Plan__r.NextPaymentDate__c FROM Charge_Groups__r) ' +
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
						Provider__r.Name,
						Account_Type__c,
						External_ID__c,
						Payment_Plan__c,
						Payment_Plan__r.Active__c,
						Payment_Plan__r.Installment_Amount__c,
						Payment_Plan__r.NextPaymentDate__c,
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
						),
						(
							SELECT 
									Adjustment__r.Name,
									Payment__r.Name,
									Amount__c,
									Service__r.Name,
									Txn_Method__c
							FROM	Transactions__r
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
		@AuraEnabled Decimal nextPayment {get;set;}
		@AuraEnabled Date nextDate {get;set;}

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
				//if (cGroup.Payment_Plan__c != null && cGroup.Payment_Plan__r.Active__c) {
				if (cGroup.Payment_Plan__c != null) {
					this.nextPayment = cGroup.Payment_Plan__r.Installment_Amount__c;
					this.nextDate = cGroup.Payment_Plan__r.NextPaymentDate__c;
				}
			}
		}
	}

	public class ChargeGroupWrapper {
		@AuraEnabled Charge_Group__c cGroup {get;set;}
		@AuraEnabled Decimal totalCharges {get;set;}
		@AuraEnabled Decimal totalCredits {get;set;}
		@AuraEnabled List<ServiceWrapper> services {get;set;}
		@AuraEnabled List<ServiceWrapper> adjusts {get;set;}

		public ChargeGroupWrapper(Charge_Group__c cGroup) {
			this.cGroup = cGroup;
			totalCharges = 0;
			totalCredits = 0;
			Map<String, ServiceWrapper> adjustMap = new Map<String, ServiceWrapper>();
			Map<String, ServiceWrapper> serviceMap = new Map<String, ServiceWrapper>();
			for(Transaction__c pa : cGroup.Transactions__r) {
				if(pa.Txn_Method__c == TRANSACTION_SERVICE_METHOD) {
					totalCharges += pa.Amount__c;
					addServiceInMap(serviceMap, pa);
				} else {
					totalCredits += pa.Amount__c;
					addServiceInMap(adjustMap, pa);
				}
			}
			this.adjusts = adjustMap.values();
			this.services = serviceMap.values();
		}
		private void addServiceInMap(Map<String, ServiceWrapper> objectMap, Transaction__c pa) {
			String displayName = SERVICE_DEFAULT_NAME;
			if(pa.Adjustment__r.Name != null) {
				displayName = pa.Adjustment__r.Name;
			} else if(pa.Payment__r.Name != null) {
				displayName = pa.Payment__r.Name;
			} else if(pa.Service__r.Name != null) {
				displayName = pa.Service__r.Name;
			}
			displayName = displayName.split('-')[0]; //get Name e.g. Aetna Payment - 1/14/2016  finded(Aetna Payment )
			if(objectMap.containsKey(displayName)) {
				objectMap.get(displayName).Amount += pa.Amount__c;
			} else {
				objectMap.put(displayName, new ServiceWrapper(displayName, pa.Amount__c));
			}
		}
	}

	public class ServiceWrapper {
		@AuraEnabled public String displayName {get;set;}
		@AuraEnabled public Decimal amount {get;set;}
		
		public ServiceWrapper(String displayName, Decimal amount) {
			this.displayName = displayName;
			this.amount = amount;
		}
	}
}