/**********************************************************************
 * 
 *
 * @url: /services/apexrest/rest
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/SummaryWidget/*')
global without sharing class HiMSS_SummaryWidgetRESTService {
	public static String DUE_STATUS = 'Due';

    @HttpGet
    global static void getGuarantor() {
    	RestRequest req = RestContext.request;
    	RestResponse res = RestContext.response;
    	if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

		List<Guarantor> portalGuarantorList = HiMSS_SummaryWidgetRESTService.getPortalGuarantor();
		if (! portalGuarantorList.isEmpty()) {
			res.responseBody = Blob.valueOf(JSON.serialize(portalGuarantorList));	
		}
    }

    public static List<Guarantor> getPortalGuarantor() {
    	List<Guarantor> guarantorList = new List<Guarantor>();
		Map<Id, Guarantor.GuarantorUser> userMap = HiMSS_SummaryWidgetRESTService.getUsers();
		if (! userMap.isEmpty()) {
			Map<Id, Guarantor.GuarantorContact> grtContactMap = HiMSS_SummaryWidgetRESTService.getGrtContact(userMap.keySet());
			Map<Id, Guarantor.Invoice> grtInvoiceMap = HiMSS_SummaryWidgetRESTService.getGuarantorInvoice(userMap.keySet());
			Map<Id, Guarantor.PaymentPlan> grtPaymentPlanMap = HiMSS_SummaryWidgetRESTService.getGuarantorPaymentPlan(userMap.keySet());
			Map<Id, Integer> newEstimatesCountMap = HiMSS_SummaryWidgetRESTService.getEstimatesCount(userMap.keySet());
			
			for (Id contactId : userMap.keySet()) {
				guarantorList.add(new Guarantor(userMap.get(contactId), grtContactMap.get(contactId), 
					grtInvoiceMap.get(contactId), grtPaymentPlanMap.get(contactId), newEstimatesCountMap.get(contactId)));
			}
			return guarantorList;
		} else {
			return null;
		}
    }

    public static Map<Id, Guarantor.GuarantorUser> getUsers() {
    	Map<Id, Guarantor.GuarantorUser> userMap = new Map<Id, Guarantor.GuarantorUser>();
    	List<User> usrList = [
    					SELECT 	Id, 
    						   	ContactId,
    						   	UserName,
    						   	Community_Password__c 
    					FROM 	User 
    					WHERE 	Name = 'Charles Green' AND
    							Is_Demo_Locked__c = false
            					// Id='00511000004rIxJAAU'//AB 2/14 Setting default user
            			ORDER BY CreatedDate ASC
    	];
    	for (User usr : usrList) {
    		userMap.put(usr.ContactId, new Guarantor.GuarantorUser(usr.UserName, usr.Community_Password__c,  usr.ContactId));
    	}

    	return userMap;
    }

    public static Map<Id, Guarantor.GuarantorContact> getGrtContact(Set<Id> contactIds) {
    	Map<Id, Guarantor.GuarantorContact> guarantorContactMap = new Map<Id, Guarantor.GuarantorContact>();
    	Map<Id, Contact> contactMap = new Map<Id, Contact>([
							SELECT 
									Id,
									Guarantor__c,
									Guarantor_Status__c,
									Invoiced_Balance__c,
									Overdue_Invoices__c,
									Outstanding_Invoices__c,
									Delinquent_Invoices__c,
									Add_to_Payment_Plan__c
							FROM 	Contact
							WHERE 	Id IN :contactIds
		]);

		for (Id contactId : contactIds) {
			if (contactMap.containsKey(contactId)) {
				Contact currContact = contactMap.get(contactId);
					guarantorContactMap.put(contactId, new Guarantor.GuarantorContact(currContact.Guarantor_Status__c, currContact.Outstanding_Invoices__c, 
						currContact.Overdue_Invoices__c, currContact.Delinquent_Invoices__c, currContact.Add_to_Payment_Plan__c, currContact.Invoiced_Balance__c));
			} else {
				guarantorContactMap.put(contactId, null);
			}
		}
		return guarantorContactMap;
    }

    public static Map<Id, Guarantor.Invoice> getGuarantorInvoice(Set<Id> contactIds) {
    	Map<Id, Guarantor.Invoice> guarantorInvoiceMap = new Map<Id, Guarantor.Invoice>();
    	List<Invoice__c> listInvoices = [
											SELECT
													Id,
													Due_Date__c, 
													Guarantor__c
											FROM 	Invoice__c
											WHERE 	Guarantor__c IN :contactIds
												AND Invoice_Status__c = :HiMSS_SummaryWidgetRESTService.DUE_STATUS
											ORDER BY CreatedDate 
		];
		Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>();
		for (Invoice__c invoice : listInvoices) {
			if (! invoiceMap.containsKey(invoice.Guarantor__c)) {
				invoiceMap.put(invoice.Guarantor__c, invoice);
			}
		}

		for (Id contactId : contactIds) {
			if (invoiceMap.containsKey(contactId)) {
				guarantorInvoiceMap.put(contactId, new Guarantor.Invoice(invoiceMap.get(contactId).Due_Date__c));
			} else {
				guarantorInvoiceMap.put(contactId, null);
			}
		}
		return guarantorInvoiceMap;
    }

    public static Map<Id, Guarantor.PaymentPlan> getGuarantorPaymentPlan(Set<Id> contactIds) {
    	Map<Id, Guarantor.PaymentPlan> guarantorPaymentPlanMap = new Map<Id, Guarantor.PaymentPlan>();
    	List<Payment_Plan__c> paymentPlans = [
											SELECT
													Id,
													Payment_Plan_Standing__c,
													NextPaymentDate__c,
													Installment_Amount__c,
													Installments_Completed__c,
													Original_Installment_Count__c,
													Active__c,
													Plan_Type__c
											FROM 	Payment_Plan__c
											WHERE	Guarantor__c IN :contactIds
											ORDER BY Active__c DESC, LastModifiedDate DESC
		];
		Map<Id, Payment_Plan__c> paymentPlanMap = new Map<Id, Payment_Plan__c>();
		for (Payment_Plan__c paymentPlan : paymentPlans) {
			if (! paymentPlanMap.containsKey(paymentPlan.Guarantor__c)) {
				paymentPlanMap.put(paymentPlan.Guarantor__c, paymentPlan);
			}
		}

		for (Id contactId : contactIds) {
			if (paymentPlanMap.containsKey(contactId)) {
				Payment_Plan__c pPlan = paymentPlanMap.get(contactId);
				guarantorPaymentPlanMap.put(contactId, new Guarantor.PaymentPlan(pPlan.NextPaymentDate__c, pPlan.Active__c, 
					pPlan.Payment_Plan_Standing__c, pPlan.Plan_Type__c));
			} else {
				guarantorPaymentPlanMap.put(contactId, null);
			}
		}

		return guarantorPaymentPlanMap;
    }

    public static Map<Id, Integer> getEstimatesCount(Set<Id> contactIds) {
    	Map<Id, Integer> estimatesCountMap = new Map<Id, Integer>();
    	AggregateResult[] newEstimatesByGuarantor = [
									SELECT 
											Guarantor__c, COUNT(Id) total
									FROM 	Encounter__c
									WHERE   Guarantor__c IN :contactIds AND 
											CreatedDate >= :Datetime.now().addDays(-30)
									GROUP BY Guarantor__c
		];
		for (AggregateResult ar : newEstimatesByGuarantor)  {
			estimatesCountMap.put((Id) ar.get('Guarantor__c'), (Integer) ar.get('total'));
		}

		return estimatesCountMap;
    }
}