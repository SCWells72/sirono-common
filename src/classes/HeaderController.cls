public with sharing class HeaderController {
	public static String WARNING_MESSAGE 	    = 'Your account has overdue invoices. Please pay the balance now or set up a payment plan to avoid becoming delinquent.\n If you have any questions about the bill, please contact the Customer Service Center at (925)-231-2502.';
	public static String DELINQUENT_MESSAGE     = 'This account has delinquent invoices. Delinquent invoices will be sent to a collection agency if payment arrangements are not made within the next 30 days. Please pay the balance now or set up a payment plan.'; 
	public static String PASTDUE_MESSAGE        = ' We have not received your latest payment plan installment. Please pay your previous installment amount now or pay your account in full to avoid payment plan cancellation.'; 
	public static String PASTDUE_MANUAL_MESSAGE = ' We have not received your latest payment plan installment. Please pay your previous installment amount now or pay your account in full to avoid payment plan cancellation. If you have any questions about the bill, call the Customer Service Center at (925)-231-2502.';
	public static String ERROR_MESSAGE		    = ' Your latest payment plan installment failed. Please update your payment method or pay your previous installment amount now to keep your account current.';
	public static String DUE_STATUS  	  	    = 'Due';
	public static String OVERDUE_STATUS  	    = 'Overdue';
	public static String DELINQUENT_STATUS      = 'Delinquent';
	public static String PAYMENT_PLAN_STATUS    = 'On Payment Plan';
	public static String PLAN_STANDING_ERROR    = 'In Error';
	public static String PLAN_STANDING_GOOD     = 'Good standing';

	@AuraEnabled
	public static GuarantorWrapper getAllHeaderInfo() {
		return new GuarantorWrapper(UserInfo.getUserId());
	}

	@AuraEnabled
	public static User getUserInfo() {
		return 	[
					SELECT 
							Id,
							Contact.FirstName,
							Contact.Profile_Pointer_ID__c 
							FROM User
							WHERE Id = :UserInfo.getUserId()
				];
	}

	public class GuarantorWrapper {
		@AuraEnabled public Contact contact 				{get;set;}
		@AuraEnabled public Invoice__c invoiceOverdue 		{get;set;}
		@AuraEnabled public String messageInfo 				{get;set;}
		@AuraEnabled public String pastDueMessage 			{get;set;}
		@AuraEnabled public Payment_Plan__c paymentPlan 	{get;set;}
		@AuraEnabled public Integer newEstimatesCount	 	{get;set;}
		@AuraEnabled public Boolean version2 				{get;set;}
		@AuraEnabled public Boolean version3 				{get;set;}
		@AuraEnabled public Boolean version4 				{get;set;}
		@AuraEnabled public Boolean isInstallAmountView 	{get;set;}

		public GuarantorWrapper(Id userId) {
			this.messageInfo = '';
			this.invoiceOverdue = new Invoice__c();
			User user = [SELECT Id, ContactId FROM User WHERE Id = :userId];
			if(user.ContactId != null) {
				this.contact = [
									SELECT 
											Id,
											FirstName,
											Guarantor__c,
											Guarantor_Status__c,
											Invoiced_Balance__c,
											Overdue_Invoices__c,
											Outstanding_Invoices__c,
											Delinquent_Invoices__c,
											Add_to_Payment_Plan__c
									FROM 	Contact
									WHERE 	Id = :user.ContactId
				];

				List<Invoice__c> listInvoices = [
													SELECT
															Id,
															Due_Date__c
													FROM 	Invoice__c
													WHERE 	Guarantor__c = :contact.Id
														AND Invoice_Status__c = :DUE_STATUS
													ORDER BY CreatedDate 
													LIMIT 1
				];
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
													WHERE	Guarantor__c = :user.ContactId
													ORDER BY Active__c DESC, LastModifiedDate DESC
													LIMIT 1
				];

				this.newEstimatesCount = [
											SELECT 
													COUNT()
											FROM 	Encounter__c
											WHERE   Guarantor__c = :user.ContactId AND 
													CreatedDate >= :Datetime.now().addDays(-30)
				];

				if(listInvoices.size() > 0 && listInvoices[0] != null) {
					this.invoiceOverdue = listInvoices[0];
				}
				if(paymentPlans.size() > 0 && paymentPlans[0] != null) {
					this.paymentPlan = paymentPlans[0];
				}
				if(contact.Guarantor_Status__c == OVERDUE_STATUS) {
					this.messageInfo = WARNING_MESSAGE;
				} else if(contact.Guarantor_Status__c == DELINQUENT_STATUS) {
					this.messageInfo = DELINQUENT_MESSAGE;
				}
				if(paymentPlan.Active__c && paymentPlan.Payment_Plan_Standing__c == 'Past Due' && paymentPlan.Plan_Type__c == 'Automatic') {
					this.messageInfo += PASTDUE_MESSAGE;
				}
				if(paymentPlan.Active__c && paymentPlan.Payment_Plan_Standing__c == 'Past Due' && paymentPlan.Plan_Type__c == 'Manual') {
					this.messageInfo += PASTDUE_MANUAL_MESSAGE;
				}
				if(paymentPlan.Active__c && paymentPlan.Plan_Type__c == 'Automatic' && paymentPlan.Payment_Plan_Standing__c == 'In Error') {
					this.messageInfo += ERROR_MESSAGE;
				}

				this.version2 = ((this.contact.Guarantor_Status__c == 'Due' || this.contact.Guarantor_Status__c == 'Overdue' 
					|| this.contact.Guarantor_Status__c == 'Delinquent') && this.contact.Add_to_Payment_Plan__c == false) ? true : false;
				this.version3 = ((((this.contact.Guarantor_Status__c == 'Due' || this.contact.Guarantor_Status__c == 'Overdue' 
					|| this.contact.Guarantor_Status__c == 'Delinquent') && this.contact.Add_to_Payment_Plan__c == true) 
						|| this.contact.Guarantor_Status__c == 'On Payment Plan') && (this.paymentPlan != null && this.paymentPlan.Payment_Plan_Standing__c == 'Good Standing')) ? true : false;
				this.version4 = ((((this.contact.Guarantor_Status__c == 'Due' || this.contact.Guarantor_Status__c == 'Overdue' 
					|| this.contact.Guarantor_Status__c == 'Delinquent') && this.contact.Add_to_Payment_Plan__c == true) 
						|| this.contact.Guarantor_Status__c == 'On Payment Plan') && (this.paymentPlan != null && this.paymentPlan.Payment_Plan_Standing__c != 'Good Standing')) ? true : false;
				this.isInstallAmountView = (((this.contact.Guarantor_Status__c == 'Due' || this.contact.Guarantor_Status__c == 'Overdue' || this.contact.Guarantor_Status__c == 'Delinquent') 
					&& this.contact.Add_to_Payment_Plan__c == true) || this.contact.Guarantor_Status__c == 'On Payment Plan') ? true : false;
			}
		}
	}
}