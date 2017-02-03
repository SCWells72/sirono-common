public with sharing class PaymentTabsController
{
	@AuraEnabled
	public static Map<String, Map<String, String>> getCardSelectOptions()
	{
		Map<String, Map<String, String>> outputMap = new Map<String, Map<String, String>> ();
		Map<String, String> yearOptions = new Map<String, String>();
		for (SelectOption selection : PayStaffWSUtill.expYearOptions)
		{
			yearOptions.put(selection.getValue(), selection.getLabel());
		}
		outputMap.put('YEARS', yearOptions);

		Map<String, String> monthsOptions = new Map<String, String>();
		for (SelectOption selection : PayStaffWSUtill.expMonthOptions)
		{
			monthsOptions.put(selection.getValue(), selection.getLabel());
		}
		outputMap.put('MONTHS', yearOptions);
		return outputMap;
	}

	@AuraEnabled
	public static GurarantatorPaymentInfo getPaymentPlanInfo()
	{
		Contact guarantor = PaymentTabsController.getGuarantatorContact();
		if (guarantor == null)
		{
			return null;
		}

		GurarantatorPaymentInfo paymentInfo = new GurarantatorPaymentInfo();
		paymentInfo.guarantor = guarantor;
		paymentInfo.addToPaymentAvail = guarantor.Add_to_Payment_Plan__c;
		paymentInfo.sironoId = PayStaffWSUtill.fetchGuarantorId(guarantor);
		paymentInfo.chargeGroups = PaymentTabsController.getChargeGroups(guarantor);
		paymentInfo.settings = PaymentTabsController.getPaymentPlanSettings();

		paymentInfo.paymentPlan = PaymentTabsController.getPaymentPlan(guarantor.Id);
		//Tracker #131459561: Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
		paymentInfo.hasPaymentPlans = paymentInfo.paymentPlan != null;
		if (paymentInfo.hasPaymentPlans)
		{
			paymentInfo.creditCards = PaymentTabsController.getCreditCards(guarantor.Id);
		}
		return paymentInfo;
	}

	@AuraEnabled
	// Method for add credit card / payment plan creation
	// right now using onlu AUTO plan types
	public static Payment_Plan__c createPaymentPlan(String paymentInfoStr)
	{
		Payment_Plan__c paymentPlanObj = null;
		PaymentRequestInfo paymentInfo = (PaymentRequestInfo)JSON.deserialize(paymentInfoStr, PaymentRequestInfo.class);
		String jwtToken = PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
		String csrfToken = PayStaffWSUtill.getCSRFToken();
		if (csrfToken == null || jwtToken == null)
		{
			return paymentPlanObj;
		}

		String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '","plan_type":"auto",' +
		                     '"plan_value":32772,' +
		                     '"installment_amount":' + convertToCents(paymentInfo.planValue) + ',' +
		                     '"execute_on_day":' + String.valueOf(paymentInfo.executeOnDay) + ',' +
		                     '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(paymentInfo.chargeGroupId) + ',' +
		                     '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + paymentInfo.sironoId + '/",' +
		                     '"active":true,' +
		                     '"credit_card":{' +
		                     '"method":"credit",' +
		                     '"cardholder_name":"' + paymentInfo.creditCard.cardholderName + '",' +
		                     '"expiration_year":"' + paymentInfo.creditCard.expirationYear + '",' +
		                     '"expiration_month":"' + paymentInfo.creditCard.expirationMonth + '",' +
		                     '"number":"' + paymentInfo.creditCard.creditCardNumber + '",' +
		                     '"cvv":"' + paymentInfo.creditCard.cvv + '",' +
		                     '"state":"' + paymentInfo.creditCard.state + '",' +
		                     '"zipcode":"' + paymentInfo.creditCard.zip + '",' +
		                     '"address_1":"' + paymentInfo.creditCard.address + '",' +
		                     '"city":"' + paymentInfo.creditCard.city + '"' +
		                     '}}';

		HttpRequest req = new HttpRequest();
		req.setMethod('POST');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/');
		req.setBody(requestData);

		String responseBody = '';
		HttpResponse res = new HttpResponse();
		try
		{
			System.debug(req.getBody());
			res = new Http().send(req);
			responseBody = res.getBody();
		}
		catch (Exception e)
		{
			System.debug('e: ' + e.getMessage() + '\n' + e.getStackTraceString());
			throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage());
		}

		if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED') && res.getStatusCode() == 201)
		{
			System.debug('e Response: ' + responseBody);
			/*
			* 08-17-2016: Sirono - Tracker # 127940071
			*  parse the Response and create a payment plan record.
			*/
			PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(responseBody, paymentInfo.contactId, null, paymentInfo.chargeGroupId);
			paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
			paymentPlanObj.Name = String.valueof(paymentPlanObj.Sirono_ID__c);
			upsert paymentPlanObj;


			List<Charge_Group__c> chargeGroups = objPaymentPlanWrapper.chargeGroupRecords;
			for (Charge_Group__c cg : chargeGroups)
			{
				cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
				cg.Payment_Plan__c = paymentPlanObj.Id;
			}
			update chargeGroups;
			return paymentPlanObj;
		}

		String errorMessage = PaymentTabsController.getErrorMessage(responseBody, res);
		System.debug('e errorMessage: ' + errorMessage);
		throw new AuraHandledException(errorMessage);
		return paymentPlanObj;
	}

	@AuraEnabled
	//Send an request to end point
	public static Payment_Plan__c doEditPaymentPlan(String paymentInfoStr)
	{
		Payment_Plan__c paymentPlanObj = null;
		PaymentRequestInfo paymentInfo = (PaymentRequestInfo)JSON.deserialize(paymentInfoStr, PaymentRequestInfo.class);
		String jwtToken = PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
		String csrfToken = PayStaffWSUtill.getCSRFToken();
		if (csrfToken == null || jwtToken == null || String.isBlank(paymentInfo.sfId))
		{
			return paymentPlanObj;
		}

		Payment_Plan__c plan = [SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, Next_Payment_Date__c,
		                        Plan_Type__c, Remaining_Installment_Count__c, Execute_on_Day__c, Sirono_ID__c, Guarantor__c
		                        FROM Payment_Plan__c
		                        Where id = : paymentInfo.sfId];

		Integer originalInstallments = plan.Original_Installment_Count__c != null ? Integer.valueOf(plan.Original_Installment_Count__c) : 0;
		Integer remainingInstallments = plan.Remaining_Installment_Count__c != null ? Integer.valueOf(plan.Remaining_Installment_Count__c) : 0;

		List<ChargeGroupWrapper> chargeGroupList = new List<ChargeGroupWrapper>();
		Contact guarantor = PaymentTabsController.fetchGuarantorContact(plan.Guarantor__c);
		for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupList(guarantor))
		{
			if (cgw.cg.Active__c && cgw.cg.Balance__c != 0 && cgw.cg.Account_Sub_Status__c == Constants.ACCT_SUBSTATUS_PAYMENT_PLAN)
			{
				cgw.isSelected = true;
				chargeGroupList.add(cgw);
			}
		}
		String chargeGroupId = PayStaffWSUtill.fetchChargeGroupIds(chargeGroupList);

		String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '","plan_type":"auto",' +
		                     '"url": "' + (SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + plan.Sirono_ID__c + '/') + '",' +
		                     '"active":true,' +
		                     '"installment_amount":' + convertToCents(paymentInfo.planValue) + ',' +
		                     '"number_installments":' + paymentInfo.totalInstallments + ',' +
		                     '"plan_value":32772,' +
		                     '"payable_amount":' + convertToCents(plan.Remaining_Balance__c) + ',' +
		                     '"execute_on_day":' + paymentInfo.executeOnDay + ',' +
		                     '"guarantor":"' + SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/guarantors/' + paymentInfo.sironoId + '/",' +
		                     '"next_payment_date": "' + String.valueOf(plan.Next_Payment_Date__c) + '",' +
		                     '"installments_paid": ' + String.valueOf(originalInstallments - remainingInstallments) + ',' +
		                     '"installments_total": ' + String.valueOf(originalInstallments) + ',' +
		                     '"chargegroups": ' + PayStaffWSUtill.buildChargeGroupsURL(chargeGroupId) + ',' +
		                     '"credit_card":{' +
		                     '"method":"credit",' +
		                     '"cardholder_name":"' + paymentInfo.creditCard.cardholderName + '",' +
		                     '"expiration_year":"' + paymentInfo.creditCard.expirationYear + '",' +
		                     '"expiration_month":"' + paymentInfo.creditCard.expirationMonth + '",' +
		                     '"number":"' + paymentInfo.creditCard.creditCardNumber + '",' +
		                     '"cvv":"' + paymentInfo.creditCard.cvv + '",' +
		                     '"state":"' + paymentInfo.creditCard.state + '",' +
		                     '"zipcode":"' + paymentInfo.creditCard.zip + '",' +
		                     '"address_1":"' + paymentInfo.creditCard.address + '",' +
		                     '"city":"' + paymentInfo.creditCard.city + '"' +
		                     '}}';

		HttpRequest req = new HttpRequest();
		req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + plan.Sirono_ID__c + '/');
		req.setMethod('PUT');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setBody(requestData);

		String responseBody = '';
		HttpResponse res = new HttpResponse();
		try
		{
			System.debug(req.getBody());
			res = new Http().send(req);
			responseBody = res.getBody();
		}
		catch (Exception e)
		{
			throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage());
		}

		if (res.getStatusCode() != null && res.getStatusCode() == 200)
		{
			PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(responseBody, paymentInfo.contactId, null, paymentInfo.chargeGroupId);
			paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
			upsert paymentPlanObj;
			return paymentPlanObj;
		}

		String errorMessage = PaymentTabsController.getErrorMessage(responseBody, res);
		throw new AuraHandledException(errorMessage);
		return paymentPlanObj;
	}

	@AuraEnabled
	public static void deletePaymentPlan(String sfPaymentPlanId)
	{
		Payment_Plan__c paymentPlan = [SELECT Id, Sirono_ID__c, Guarantor__c FROM Payment_Plan__c WHERE Id = : sfPaymentPlanId];
		String guarantorId = paymentPlan.Guarantor__c;
		String paymentPlanExtId = String.valueOf(paymentPlan.Sirono_ID__c);

		//call Delete PaymentPlan and send the request to end point.
		if (String.isNotBlank(paymentPlanExtId))
		{
			String jwtToken = PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
			String csrfToken = PayStaffWSUtill.getCSRFToken();
			if (csrfToken != null && jwtToken != null)
			{
				callPaymentPlanRequest(csrfToken, jwtToken, guarantorId, paymentPlanExtId);
			}
		}
		else
		{
			throw new AuraHandledException('Payment Plan Id is missing.');
		}
	}

	//private static Payment_Method__c generatePaymentMethod(PaymentRequestInfo info, String accountId) {
	//	Date expDate = null;
	//	if (info.creditCard != null && String.isNotBlank(info.creditCard.expirationMonth) &&
	//		String.isNotBlank(info.creditCard.expirationYear)) {
	//		expDate = Date.newInstance(Integer.valueOf(info.creditCard.expirationYear), Integer.valueOf(info.creditCard.expirationMonth), 1);
	//	}

	//	return new Payment_Method__c (
	//		Card_Type__c = null,
	//		Card_Holder_Name__c = info.creditCard.cardholderName,
	//		Expiration_Date__c = expDate,
	//		Guarantor__c = accountId
	//	);
	//}

	/*
	* 09-22-2016: Viraj Rana - Tracker #129177479
	*  Call the paymentplan Web Service to get the paymentplan information.
	*/
	private static void callPaymentPlanRequest(String csrfToken, String jwtToken, String guarantorId, String paymentPlanExtId)
	{
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');
		req.setTimeout(120000);

		String responseBody;
		HttpResponse res = new HttpResponse();
		try
		{
			res = new Http().send(req);
			responseBody = res.getBody();
		}
		catch (Exception e)
		{
			throw new AuraHandledException('ERROR: ' + e.getMessage());
		}
		if (res.getStatusCode() != null && res.getStatusCode() == 200)
		{
			/*
			* 09-22-2016: Viraj Rana - Tracker # 129177479
			* parse the Payment Plan JSON and Make a new request to get the charge group detailsyment Plan
			*/
			PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(responseBody, guarantorId, null, null);
			Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
			paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
			paymentPlanObj.Active__c = false;
			paymentPlanObj.Cancellation_Date__c = System.today();
			List<Charge_Group__c> chargeGroups = objPaymentPlanWrapper.chargeGroupRecords;

			doDeletePaymentPlan(csrfToken, jwtToken, paymentPlanExtId, paymentPlanObj, chargeGroups);
		}
		else
		{
			throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
		}
	}

	/*Mohan Kumar 08-02-2016: Ticket # 06638015 -
	 *Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
	 */
	private static void doDeletePaymentPlan(String csrfToken, String jwtToken, String paymentPlanExtId, Payment_Plan__c paymentPlanObj, List<Charge_Group__c> chargeGroups)
	{
		HttpRequest req = new HttpRequest();
		req.setMethod('DELETE');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');

		HttpResponse res = new HttpResponse();
		String responseBody;
		try
		{
			res = new Http().send(req);
			responseBody = res.getBody();
		}
		catch (Exception e)
		{
			throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + ' EXCEPTION:: ' + e.getMessage());
		}

		if (res.getStatusCode() != null && res.getStatusCode() == 204)
		{
			Boolean hasError = false;
			for (Charge_Group__c cg : chargeGroups)
			{
				hasError = callChargeGroupRequest(String.valueof(cg.Sirono_ID__c), jwtToken, cg);
			}
			if (!hasError)
			{
				update paymentPlanObj;
				update chargeGroups;
			}
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Payment plan was successfully cancelled.'));
		}
		else
		{
			throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
		}
	}

	/*
	* 09-22-2016: Viraj Rana - Tracker # 129177479
	* make a Charge group Reqeuest to get the chargeGroupInformation
	*/
	private static Boolean callChargeGroupRequest(String chargeGroupId, String jwtToken, Charge_Group__c cg)
	{
		Boolean hasError = false;
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/chargegroups/' + PayStaffWSUtill.trimCommas(chargeGroupId) + '/');
		req.setTimeout(120000);

		String responseBody;
		HttpResponse res = new HttpResponse();
		try
		{
			res = new Http().send(req);
			responseBody = res.getBody();
		}
		catch (Exception e)
		{
			throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + ' EXCEPTION:: ' + e.getMessage());
		}
		if (res.getStatusCode() != null && res.getStatusCode() == 200)
		{
			/*
			* 09-22-2016: Viraj Rana - Tracker # 129177479
			* parse the chargroup json and update the sub status
			* 10-12-2016: Viraj Rana - Tracker # 129177479
			* Update the Account_Sub_Status__c and Account_Status__c.
			*/
			ChargeGroupJSONParsing objChargeGroup = ChargeGroupJSONParsing.parse(responseBody);
			cg.Account_Sub_Status__c = objChargeGroup.account_sub_status;
			cg.Account_Status__c = objChargeGroup.account_status;
			cg.Payment_Plan__c = null;
		}
		else
		{
			hasError = true;
			throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
		}
		return hasError;
	}

	private static String getErrorMessage(String responseBody, HttpResponse res)
	{
		String errorMessage = '';
		if (responseBody.contains('non_field_errors') && responseBody.contains('Validation exception'))
		{
			JSONParser parser = JSON.createParser(responseBody);
			WrapperErrorArray wrpPaymentPlanobj = (WrapperErrorArray) parser.readValueAs(WrapperErrorArray .class);
			if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.size() > 0)
			{
				for (WrapperErrorArray.Errors obj : wrpPaymentPlanobj.errors)
				{
					errorMessage += '\n' + obj.non_field_errors;
				}
			}
		}
		else if (responseBody.contains('non_field_errors') && responseBody.contains('Payments Exception'))
		{
			JSONParser parser = JSON.createParser(responseBody);
			WrapperError wrpPaymentPlanobj = (WrapperError) parser.readValueAs(WrapperError.class);
			if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.non_field_errors.size() > 0)
			{
				for (String strMessage : wrpPaymentPlanobj.errors.non_field_errors)
				{
					errorMessage += '\n' + strMessage;
				}
			}
		}
		else if (responseBody.contains('kind') && !responseBody.contains('chargegroups'))
		{
			JSONParser parser = JSON.createParser(responseBody);
			WrapperListError wrpobj = (WrapperListError) parser.readValueAs(WrapperListError.class);
			if (wrpobj != null && wrpobj.errors.size() > 0)
			{
				for (String strMessage : wrpobj.errors)
				{
					errorMessage += '\n' + strMessage;
				}
			}
		}
		//else if (responseBody.contains('kind') && responseBody.contains('chargegroups'))
		//{
		//	errorMessage += '\n' + 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody;
		//}
		else if (responseBody.contains('non_field_errors'))
		{
			JSONParser parser = JSON.createParser(responseBody);
			WrapperNonFieldErrorArray wrpPaymentPlanobj  = (WrapperNonFieldErrorArray)parser.readValueAs(WrapperNonFieldErrorArray.class);
			if (wrpPaymentPlanobj  != null && wrpPaymentPlanobj.non_field_errors.size() > 0)
			{
				for (String strMessage : wrpPaymentPlanobj.non_field_errors)
				{
					errorMessage += '\n' + strMessage;
				}
			}
		}
		else
		{
			errorMessage += '\n' +  'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody;
		}
		return errorMessage;
	}

	private static List<ChargeGroup> getChargeGroups(Contact guarantor)
	{
		List<ChargeGroup> chargeGroups = new List<ChargeGroup>();
		//tracker #134300243 fetching charge group list based on account sub status : Preinvoiced, Due, Overdue, Delinquent, or Bad Debt
		for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupListByAccSubStatus(guarantor))
		{
			if (cgw.cg.Active__c && cgw.cg.Balance__c != 0)
			{
				chargeGroups.add( new ChargeGroup(cgw) );
			}
		}
		return chargeGroups;
	}

	/*11-17-2016: Viraj Rana - Tracker #127404553
	 *It is used to get Payment Plan Setting.
	 *It is called in VF page,
	 *becuase of whenever profile is "Operations Manager or System Administrator" at that we need to create new custom setting for it.
	 *If we create using class than we can't send Web Request after insert so we use this method using VF page.
	*/
	private static Sirono_Settings__c getPaymentPlanSettings()
	{
		return SironoSettingsUtil.getPaymentPlanSettings();
	}

	//get the Guarantor contact with charge groups
	private static Contact fetchGuarantorContact(String contactId)
	{
		Contact ob = null;
		for (Contact c : [
		            Select Id, FirstName, MiddleName, LastName, Suffix, Birthdate, Medical_Record_Number__c, Name,
		            Profile_Pointer_Id__c, MailingStreet, Add_to_Payment_Plan__c, Non_Payment_Plan_Invoices__c,
		            MailingCity, MailingState, MailingPostalCode, (
		                Select Id, Name, Sirono_ID__c, Guarantor__c, Guarantor__r.Name,
		                External_ID__c, Active__c, Reported_Insurance_Balance__c, Reported_Prebill_Balance__c,
		                Reported_Selfpay_Balance__c, Patient__c, Patient__r.Name,
		                Account_Type__c, Date_Of_Service_Start_Date__c, Date_Of_Service_End_Date__c,
		                Balance__c, Invoice__c, Invoice__r.Name, Invoice__r.Invoice_Date__c, Account_Status__c,
		                Provider__c, Provider__r.Name, Location__c, Location__r.Name, Account_Sub_Status__c
		                From Charge_Groups__r
		                Where Sirono_ID__c != null AND Active__c = true
		            )
		            From Contact
		            Where Id = :contactId
		        ])
		{
			ob = c;
		}
		return ob;
	}

	////10-12-2016: Viraj Rana - Tracker #131459561: Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
	private static Payment_Plan__c getPaymentPlan(Id guarantorContactId)
	{
		List<Payment_Plan__c> plans = [SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, Installment_Amount__c, CreatedDate,
		                               Next_Payment_Date__c, Plan_Type__c, Remaining_Installment_Count__c, Execute_on_Day__c, Sirono_ID__c,
		                               Payment_Method__c, Payment_Method__r.Sirono_ID__c, Payment_Method__r.Display_Name__c
		                               FROM Payment_Plan__c
		                               WHERE Guarantor__c = : guarantorContactId and Active__c = true
		                              ];
		if (!plans.isEmpty())
		{
			return plans.get(0);
		}
		return null;
	}

	private  static List<CreditCardInfo> getCreditCards(Id guarantorContactId)
	{
		List<CreditCardInfo> cards = new List<CreditCardInfo>();
		for (Payment_Method__c pCard : [SELECT Id, Account_Number__c, Card_Holder_Name__c, Card_Type__c, Display_Name__c, Expiration_Date__c, ID__c, Last_4__c,
		                                Payment_Method_Token__c, Routing_Number__c, Sirono_ID__c, Type__c
		                                FROM Payment_Method__c WHERE Guarantor__c = : guarantorContactId])
		{
			cards.add(new CreditCardInfo(pCard));
		}
		return cards;
	}

	private static String convertToCents(Decimal amount)
	{
		return amount != null ? String.valueOf(amount.setScale(2) * 100) : '';
	}

	private static Contact getGuarantatorContact()
	{
		User theUser = [SELECT Id, ContactId FROM User WHERE Id = : UserInfo.getUserId()];
		if (theUser.ContactId == null)
		{
			return null;
		}
		return PaymentTabsController.fetchGuarantorContact(theUser.ContactId);
	}

	public class GurarantatorPaymentInfo
	{
		@AuraEnabled
		public Payment_Plan__c paymentPlan {get; set;}
		@AuraEnabled
		public Boolean addToPaymentAvail {get; set;}
		@AuraEnabled
		public Contact guarantor {get; set;}
		@AuraEnabled
		public String sironoId {get; set;}
		@AuraEnabled
		public Sirono_Settings__c settings {get; set;}
		@AuraEnabled
		public Boolean hasPaymentPlans {get; set;}
		@AuraEnabled
		public List<ChargeGroup> chargeGroups {get; set;}
		@AuraEnabled
		public List<CreditCardInfo> creditCards {get; set;}

		public GurarantatorPaymentInfo()
		{
			this.guarantor = new Contact();
			this.settings = new Sirono_Settings__c();
			this.hasPaymentPlans = false;
			this.addToPaymentAvail = false;
			this.chargeGroups = new List<ChargeGroup>();
			this.creditCards = new List<CreditCardInfo>();
		}
	}

	public class ChargeGroup
	{
		@AuraEnabled
		public Charge_Group__c cg {get; set;}
		@AuraEnabled
		public Boolean isSelected {get; set;}

		public ChargeGroup() {}
		public ChargeGroup(ChargeGroupWrapper wrapper)
		{
			this.cg = wrapper.cg;
			this.isSelected = wrapper.isSelected;
		}
	}

	public class PaymentRequestInfo
	{
		@AuraEnabled
		public String sfId {get; set;}
		@AuraEnabled
		public CreditCardInfo creditCard {get; set;}
		@AuraEnabled
		public String paymentPlanId {get; set;}
		@AuraEnabled
		public Decimal totalAmount {get; set;}

		@AuraEnabled
		public Integer totalInstallments {get; set;}
		@AuraEnabled
		public Decimal planValue {get; set;}
		@AuraEnabled
		public Integer executeOnDay {get; set;}

		@AuraEnabled
		public String chargeGroupId {get; set;}
		@AuraEnabled
		public String sironoId {get; set;}
		@AuraEnabled
		public String contactId {get; set;}

		public PaymentRequestInfo()
		{
			this.creditCard = new CreditCardInfo();
		}
	}

	public class CreditCardInfo
	{
		@AuraEnabled
		public String sfId {get; set;}
		@AuraEnabled
		public String displayName {get; set;}
		@AuraEnabled
		public String cardType {get; set;}
		@AuraEnabled
		public String cardholderName {get; set;}
		@AuraEnabled
		public String expirationYear {get; set;}
		@AuraEnabled
		public String expirationMonth {get; set;}
		@AuraEnabled
		public String creditCardNumber {get; set;}
		@AuraEnabled
		public String cvv {get; set;}
		@AuraEnabled
		public String city {get; set;}
		@AuraEnabled
		public String state {get; set;}
		@AuraEnabled
		public String zip {get; set;}
		@AuraEnabled
		public String address {get; set;}

		public CreditCardInfo() {}
		public CreditCardInfo(Payment_Method__c card)
		{
			this.sfId = card.Id;
			this.cardholderName = card.Card_Holder_Name__c;
			this.cardType = card.Card_Type__c;
			this.displayName = card.Display_Name__c;

			if (card.Expiration_Date__c != null)
			{
				Integer monthKey = card.Expiration_Date__c.month();
				Integer yearKey = card.Expiration_Date__c.year();
				this.expirationMonth = monthKey > 10 ? String.valueOf(monthKey) : '0' + String.valueOf(monthKey);
				this.expirationYear = String.valueOf(yearKey);
			}
		}
	}
}