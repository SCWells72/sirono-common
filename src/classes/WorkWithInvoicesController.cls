//TODO remove without sharing
public without sharing class WorkWithInvoicesController {
	public static final String TRANSACTION_SERVICE_METHOD				= 'Service';
	public static final String SERVICE_DEFAULT_NAME						= 'Unknown';
	public static final String INVOICE_PAID_STATUS						= 'Paid';
	public static final String INVOICE_UNPAID_STATUS					= 'Unpaid';
	public static final String DEFAULT_ORDER							= ' ORDER BY Invoice_Date__c DESC';
	
	@AuraEnabled
    public static List<InvoicesWrapper> getAllInvoices(String groupFilter, String additionalFilter) {
		if(additionalFilter == 'null') {
			return new List<InvoicesWrapper>();
		}
		String selectedPatients = '';
		List<String> additionalFilters = new List<String>();
		if(!String.isBlank(additionalFilter)) {
			additionalFilters = additionalFilter.replace('\'', '').split(',');
			selectedPatients += ' AND Patient__c IN :additionalFilters';
		}
		List<InvoicesWrapper> allInvoices = new List<InvoicesWrapper>();
		User u = [
			SELECT	ContactId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		if (u.ContactId != null) {
			List<Invoice__c> listOfInvoices = new List<Invoice__c>();
			String query = 'SELECT Id, Name, Invoice_Balance__c, Patient__r.Name, Patient__r.Medical_Record_Number__c, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Invoice_Status__c, '+
							'Due_Date__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Add_to_Payment_Plan__c, Guarantor__r.Invoiced_Balance__c, '+
							'Guarantor__r.Due_Balance__c, Guarantor__r.Delinquent_Balance__c, Partial_Payment_Plan__c, ' + 
							'Guarantor__r.Payment_Plan_Balance__c, Guarantor__r.Pre_Invoiced_Balance__c, ' +
							'(SELECT Id, Payment_Plan__c, Payment_Plan__r.Active__c, Payment_Plan__r.Installment_Amount__c, ' +
							'Payment_Plan__r.NextPaymentDate__c FROM Charge_Groups__r) ' +
							'FROM Invoice__c WHERE Guarantor__c = \'' + u.ContactId + '\'' + selectedPatients;
			
			/*Unpaid (Invoice Status = Delinquent, Overdue, Due, or On Payment Plan), 
			Paid (Invoice Status = Paid or Invoice Voided), 
			Overdue (Invoice Status = Overdue), 
			Delinquent (Invoice Status = Delinquent), 
			and On Payment Plan (Invoice Status = On Payment Plan).*/
			if(groupFilter != null && groupFilter != '' && groupFilter != 'All') {
				if(groupFilter == INVOICE_UNPAID_STATUS){
					query += ' AND Invoice_Status__c IN (\'Delinquent\', \'Overdue\', \'Due\', \'On Payment Plan\')';
				} else if(groupFilter == INVOICE_PAID_STATUS) {
					query += ' AND Invoice_Status__c IN (\'Paid\', \'Invoice Voided\')';
				} else {
					query += ' AND Invoice_Status__c = \'' + groupFilter + '\'';
				}
			}

			query += DEFAULT_ORDER;
			
			listOfInvoices = Database.query(query);

			Set<Id> allChargeGroupIds = new Set<Id>();
			
			for(Integer i = 0; i < listOfInvoices.size(); i++) {
				Invoice__c invoice = listOfInvoices[i];
				for(Integer j = 0; j < invoice.Charge_Groups__r.size(); j++) {
					Charge_Group__c cGroup = invoice.Charge_Groups__r[j];
					allChargeGroupIds.add(cGroup.Id);
				}
			}
            		// Get Charge Group List from ChargeGroupService class. Second parameter is use to get the order by result.
            		List<Charge_Group__c> allGroups = ChargeGroupService.getCGForInvoiceController(allChargeGroupIds, true);

			Map<Id,Charge_Group__c> allGroupsMap = new Map<Id,Charge_Group__c>(allGroups);

			for(Integer i = 0; i < listOfInvoices.size(); i++) {
				Invoice__c invoice = listOfInvoices[i];
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
		if(additionalFilter == 'null') {
			return new List<WorkWithEstimatesController.EstimateWrapper>();
		}
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
			String query = 'SELECT Id, Name, Invoice_Balance__c, Patient__r.Name, Patient__r.Medical_Record_Number__c, Sirono_ID__c, Invoice_Date__c, Invoice_Age__c, Invoice_Status__c, '+
							'Due_Date__c, Guarantor__r.Overdue_Balance__c, Guarantor__r.Invoiced_Balance__c, '+
							'Guarantor__r.Due_Balance__c, Guarantor__r.Delinquent_Balance__c, Partial_Payment_Plan__c, ' + 
							'Guarantor__r.Payment_Plan_Balance__c, Guarantor__r.Add_to_Payment_Plan__c, Guarantor__r.Pre_Invoiced_Balance__c, ' +
							'(SELECT Id, Payment_Plan__c, Payment_Plan__r.Active__c, Payment_Plan__r.Installment_Amount__c, ' +
							'Payment_Plan__r.NextPaymentDate__c FROM Charge_Groups__r) ' +
							'FROM Invoice__c WHERE Guarantor__c = \'' + u.ContactId + '\'' + ' AND Id =\'' + invoiceId + '\'';
			listOfInvoices = Database.query(query);

			Set<Id> allChargeGroupIds = new Set<Id>();
			for(Integer i = 0; i < listOfInvoices.size(); i++) {
				Invoice__c invoice = listOfInvoices[i];
				for(Integer j = 0; j < invoice.Charge_Groups__r.size(); j++) {
					Charge_Group__c cGroup = invoice.Charge_Groups__r[j];
					allChargeGroupIds.add(cGroup.Id);
				}
			}
            		// Get Charge Group List from ChargeGroupService class. Second parameter is use to get the order by result.
            		List<Charge_Group__c> allGroups = ChargeGroupService.getCGForInvoiceController(allChargeGroupIds, false);

			Map<Id,Charge_Group__c> allGroupsMap = new Map<Id,Charge_Group__c>(allGroups);
			for(Integer i = 0; i < listOfInvoices.size(); i++) {
				Invoice__c invoice = listOfInvoices[i];
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
		@AuraEnabled 
		public List<ChargeGroupWrapper> allGroups {get;set;}
		@AuraEnabled Decimal nextPayment {get;set;}
		@AuraEnabled Date nextDate {get;set;}

		public InvoicesWrapper(Invoice__c invoice, Map<Id,Charge_Group__c> allGroupsMap) {
			this.singleInvoice = invoice;
			this.balanceDue = 0;
			//this.balanceDue = invoice.Guarantor__r.Due_Balance__c;
			allGroups = new List<ChargeGroupWrapper>();
			for(Integer i = 0; i < invoice.Charge_Groups__r.size(); i++) {
				Charge_Group__c cGroup = invoice.Charge_Groups__r[i];
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
			balanceDue = invoice.Invoice_Balance__c;
		}
	}

	public class ChargeGroupWrapper {
		@AuraEnabled 
		public Charge_Group__c cGroup {get;set;}
		@AuraEnabled Decimal totalCharges {get;set;}
		@AuraEnabled Decimal totalCredits {get;set;}
		@AuraEnabled List<ServiceWrapper> services {get;set;}
		@AuraEnabled List<ServiceWrapper> adjusts {get;set;}
		@AuraEnabled Boolean validPayer {get;set;}

		public ChargeGroupWrapper(Charge_Group__c cGroup) {
			this.cGroup = cGroup;
			totalCharges = 0;
			totalCredits = 0;
			Map<String, ServiceWrapper> adjustMap = new Map<String, ServiceWrapper>();
			Map<String, ServiceWrapper> serviceMap = new Map<String, ServiceWrapper>();
			validPayer = false;
			for(Integer i = 0; i < cGroup.Charge_Group_Coverages__r.size(); i++) {
				Charge_Group_Coverage_Junction__c coverageJunction = cGroup.Charge_Group_Coverages__r[i];
				if(coverageJunction.Coverage__r.Payor__r != null) {
					validPayer = true;
					break;
				}
			}
			for(Integer i = 0; i < cGroup.Transactions__r.size(); i ++) {
				Transaction__c pa = cGroup.Transactions__r[i];
				if(pa.Txn_Method__c == TRANSACTION_SERVICE_METHOD) {
					totalCharges += pa.Amount__c;
					String displayName = getName(pa);
					if(serviceMap.containsKey(displayName)) {
						serviceMap.get(displayName).Amount += pa.Amount__c;
					} else {
						serviceMap.put(displayName, new ServiceWrapper(displayName, pa.Amount__c));
					}
				} else {
					totalCredits += pa.Amount__c;
					String displayName = getName(pa);
					if(adjustMap.containsKey(displayName)) {
						adjustMap.get(displayName).Amount += pa.Amount__c;
					} else {
						adjustMap.put(displayName, new ServiceWrapper(displayName, pa.Amount__c));
					}
				}
			}
			this.adjusts = adjustMap.values();
			this.services = serviceMap.values();
		}
		private String getName(Transaction__c pa) {
			String displayName = SERVICE_DEFAULT_NAME;
			if(pa.Adjustment__r.Custom_Name__c != null) {
				displayName = pa.Adjustment__r.Custom_Name__c;
			} else if(pa.Payment__r.Display_Name__c != null) {
				displayName = pa.Payment__r.Display_Name__c;
			} else if(pa.Service__r.Display_Name__c != null) {
				displayName = pa.Service__r.Display_Name__c;
				displayName = displayName.split('-')[0]; //get Name e.g. Aetna Payment - 1/14/2016  finded(Aetna Payment )
			}
			
			displayName = displayName.replace('- //', '');
			return displayName;
		}
	}

	public class ServiceWrapper {
		@AuraEnabled public String  displayName {get;set;}
		@AuraEnabled public String  serviceDate {get;set;}
		@AuraEnabled public Decimal amount		{get;set;}
		
		public ServiceWrapper(String displayName, Decimal amount) {
			this.amount = amount;
			List<String> nameParts = displayName.split('-');
			this.displayName = nameParts[0];
			this.serviceDate = nameParts.size() > 1 ? nameParts[1] : '';
		}
	}

	@AuraEnabled
	public static List<PatientWrapper> getPatientList() {
		User u = [
				SELECT	ContactId
				FROM	User
				WHERE	Id =: UserInfo.getUserId()
		];
		if(u.ContactId == null) {
			return new List<PatientWrapper>();
		}
		List<Invoice__c> invoiceList = [
											SELECT
													Patient__r.Medical_Record_Number__c,
													Patient__r.Name
											FROM	Invoice__c
											WHERE	Guarantor__c = :u.ContactId
											LIMIT   50000
		];
	    List<PatientWrapper> result = new List<PatientWrapper>();
		for(Integer i = 0; i < invoiceList.size(); i++) {
			result.add(new PatientWrapper(invoiceList[i]));
		}
		return result;
	}

	public class PatientWrapper {
		@AuraEnabled public String MRN  {get;set;}
		@AuraEnabled public String name {get;set;}
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public Boolean isSelected {get;set;}

		public PatientWrapper(Invoice__c invoice) {
			this.name       = invoice.Patient__r.Name;
			this.id         = invoice.Patient__r.Id;
			this.isSelected = true;
			this.MRN        = '';
			if(invoice.Patient__r.Medical_Record_Number__c != null) {
				this.MRN = ' (MRN: ' + invoice.Patient__r.Medical_Record_Number__c + ')';
			}
		}
		public PatientWrapper(Encounter__c estimate) {
			this.name       = estimate.Patient__r.Name;
			this.id         = estimate.Patient__r.Id;
			this.isSelected = true;
			this.MRN        = '';
			if(estimate.Patient__r.Medical_Record_Number__c != null) {
				this.MRN = ' (MRN: ' + estimate.Patient__r.Medical_Record_Number__c + ')';
			}
		}
	}

}