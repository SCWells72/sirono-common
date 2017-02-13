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

    	String firstName = req.params.get('firstName');
    	String lastName = req.params.get('lastName');

    	if (firstName != null && lastName != null) {
    		Guarantor portalGuarantor = HiMSS_SummaryWidgetRESTService.getPortalGuarantor(firstName, lastName);
			if (portalGuarantor != null) {
				res.responseBody = Blob.valueOf(JSON.serialize(portalGuarantor));	
			}
    	}
    }

    public static Guarantor getPortalGuarantor(String firstName, String lastName) {
		Guarantor.GuarantorUser user = HiMSS_SummaryWidgetRESTService.getUser(firstName, lastName);
		if (user != null) {
			Guarantor.GuarantorContact grtContact = HiMSS_SummaryWidgetRESTService.getGrtContact(user.contactId);
			Guarantor.Invoice grtInvoice = HiMSS_SummaryWidgetRESTService.getGuarantorInvoice(user.contactId);
			Guarantor.PaymentPlan grtPaymentPlan = HiMSS_SummaryWidgetRESTService.getGuarantorPaymentPlan(user.contactId);
			Integer newEstimatesCount = HiMSS_SummaryWidgetRESTService.getEstimatesCount(user.contactId);
			return new Guarantor(user, grtContact, grtInvoice, grtPaymentPlan, newEstimatesCount);
		} else {
			return null;
		}
    }

    public static Guarantor.GuarantorUser getUser(String firstName, String lastName) {
    	List<User> usrList = [
    					SELECT 	Id, 
    						   	ContactId,
    						   	UserName,
    						   	Community_Password__c 
    					FROM 	User 
    					WHERE 	FirstName LIKE :firstName.trim() AND
    							LastName  LIKE :lastName.trim() AND
    							Is_Demo_Locked__c = false
    	];
    	return (! usrList.isEmpty()) ? new Guarantor.GuarantorUser(usrList[0].UserName, usrList[0].Community_Password__c,  usrList[0].ContactId) : null;
    }

    public static Guarantor.GuarantorContact getGrtContact(Id contactId) {
    	Contact contact = [
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
							WHERE 	Id = :contactId
		];
		return new Guarantor.GuarantorContact(contact.Guarantor_Status__c, contact.Outstanding_Invoices__c, 
			contact.Overdue_Invoices__c, contact.Delinquent_Invoices__c, contact.Add_to_Payment_Plan__c, contact.Invoiced_Balance__c);
    }

    public static Guarantor.Invoice getGuarantorInvoice(Id contactId) {
    	List<Invoice__c> listInvoices = [
											SELECT
													Id,
													Due_Date__c
											FROM 	Invoice__c
											WHERE 	Guarantor__c = :contactId
												AND Invoice_Status__c = :HiMSS_SummaryWidgetRESTService.DUE_STATUS
											ORDER BY CreatedDate 
											LIMIT 1
		];
		return (! listInvoices.isEmpty()) ? new Guarantor.Invoice(listInvoices[0].Due_Date__c) : null;
    }

    public static Guarantor.PaymentPlan getGuarantorPaymentPlan(Id contactId) {
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
											WHERE	Guarantor__c = :contactId
											ORDER BY Active__c DESC, LastModifiedDate DESC
											LIMIT 1
		];
		return (! paymentPlans.isEmpty()) ? new Guarantor.PaymentPlan(paymentPlans[0].NextPaymentDate__c, paymentPlans[0].Active__c, paymentPlans[0].Payment_Plan_Standing__c, paymentPlans[0].Plan_Type__c) : null;
    }

    public static Integer getEstimatesCount(Id contactId) {
    	Integer newEstimatesCount = [
									SELECT 
											COUNT()
									FROM 	Encounter__c
									WHERE   Guarantor__c = :contactId AND 
											CreatedDate >= :Datetime.now().addDays(-30)
		];
		return newEstimatesCount;
    }
}