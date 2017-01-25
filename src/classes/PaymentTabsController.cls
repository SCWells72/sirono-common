public with sharing class PaymentTabsController
{
	@AuraEnabled
	public Map<String, Map<String, String>> getCardSelectOptions()
	{
		Map<String, Map<String, String>> outputMap = new Map<String, Map<String, String>> ();
		Map<String, String> yearOptions = new Map<String, String>();
		for (SelectOption selection : PayStaffWSUtill.expYearOptions)
		{
			yearOptions.put(selection.getValue(), selection.getLabel());
		}
		outputMap.put('YEAR', yearOptions);

		Map<String, String> monthsOptions = new Map<String, String>();
		for (SelectOption selection : PayStaffWSUtill.expMonthOptions)
		{
			monthsOptions.put(selection.getValue(), selection.getLabel());
		}
		outputMap.put('MONTH', yearOptions);
		return outputMap;
	}

	@AuraEnabled
	public static GurarantatorPaymentnfo getPaymentPlanInfo()
	{
		Contact guarantor = PaymentTabsController.getGuarantatorContact();
		if (guarantor == null)
		{
			return null;
		}

		GurarantatorPaymentnfo paymentInfo = new GurarantatorPaymentnfo();
		paymentInfo.guarantor = guarantor;
		paymentInfo.sironoId = PayStaffWSUtill.fetchGuarantorId(guarantor);
		paymentInfo.chargeGroups = PaymentTabsController.getChargeGroups(guarantor);
		paymentInfo.settings = PaymentTabsController.getPaymentPlanSettings();
		//Tracker #131459561: Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
		paymentInfo.hasPaymentPlans = PaymentTabsController.checkPaymentPlanExist(guarantor.Id);
		return paymentInfo;
	}

	@AuraEnabled
	// Method for add credit card / payment plan creation
	public static void createPaymentPlan(PaymentRequestInfo paymentInfo)
	{
		// right now using onlu AUTO plan types
		String PLAN_TYPE = 'auto';
		String jwtToken = PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
		String csrfToken = PayStaffWSUtill.getCSRFToken();
		if (csrfToken == null || jwtToken == null)
		{
			return;
		}

		String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '","plan_type":"' + PLAN_TYPE + '",' +
		                     '"plan_value":32772,' +
		                     '"installment_amount":' + PayStaffWSUtill.convertToCents(paymentInfo.planValue) + ',' +
		                     '"execute_on_day":' + paymentInfo.executeOnDay + ',' +
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
		                     '}' + '}';

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
			throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody + ' EXCEPTION:: ' + e.getMessage());
		}

		if (res.getStatus() != null && res.getStatus().trim().equalsIgnoreCase('CREATED') && res.getStatusCode() == 201)
		{
			/*
			* 08-17-2016: Sirono - Tracker # 127940071
			*  parse the Response and create a payment plan record.
			*/
			PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper = PaymentPlanJSONParsing.createPaymentPlanRecord(responseBody, paymentInfo.contactId, null, paymentInfo.chargeGroupId);
			Payment_Plan__c paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
			paymentPlanObj.Name = String.valueof(paymentPlanObj.Sirono_ID__c);
			upsert paymentPlanObj;

			List<Charge_Group__c> chargeGroups = objPaymentPlanWrapper.chargeGroupRecords;
			for (Charge_Group__c cg : chargeGroups)
			{
				cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
				cg.Payment_Plan__c = paymentPlanObj.Id;
			}
			update chargeGroups;
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO, 'Created Successfully!'));
			return;
		}

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
		else if (responseBody.contains('kind') && responseBody.contains('chargegroups'))
		{
			throw new AuraHandledException( 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
		}
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
		throw new AuraHandledException(errorMessage);
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

	//10-12-2016: Viraj Rana - Tracker #131459561: Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
	private static Boolean checkPaymentPlanExist(Id guarantorContactId)
	{
		Integer countPP = [SELECT COUNT() FROM Payment_Plan__c WHERE Guarantor__c = : guarantorContactId and Active__c = true];
		return countPP > 0;
	}

	private static Contact getGuarantatorContact()
	{
		User theUser = [SELECT Id, ContactId FROM User WHERE Id = : UserInfo.getUserId()];
		if (theUser.ContactId == null)
		{
			return null;
		}
		return PayStaffWSUtill.fetchGuarantorContact(theUser.ContactId);
	}

	public class GurarantatorPaymentnfo
	{
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

		public GurarantatorPaymentnfo()
		{
			this.guarantor = new Contact();
			this.settings = new Sirono_Settings__c();
			this.hasPaymentPlans = false;
			this.chargeGroups = new List<ChargeGroup>();
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
		public CreditCardInfo creditCard {get; set;}
		@AuraEnabled
		public String totalAmount {get; set;}
		@AuraEnabled
		public String planValue {get; set;}
		@AuraEnabled
		public String executeOnDay {get; set;}
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
	}
}