public without sharing class PaymentTabsController
{
	@AuraEnabled
	public static Map<String, Map<String, String>> getCardSelectOptions()
	{
		Map<String, Map<String, String>> outputMap = new Map<String, Map<String, String>> ();
		Map<String, String> yearOptions = new Map<String, String>();
		for (SelectOption selection : UIUtils.expYearOptions)
		{
			yearOptions.put(selection.getValue(), selection.getLabel());
		}
		outputMap.put('YEARS', yearOptions);

		Map<String, String> monthsOptions = new Map<String, String>();
		for (SelectOption selection : UIUtils.expMonthOptions)
		{
			monthsOptions.put(selection.getValue(), selection.getLabel());
		}
		outputMap.put('MONTHS', monthsOptions);
		return outputMap;
	}

	@AuraEnabled
	public static String addToPaymentPlan()
	{
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userInfo.getUserId()];
            	Contact guarantor = GuarantorService.getContactById(currentUser.ContactId);
		AddToPaymentPlanLightning addToPlan = new AddToPaymentPlanLightning(guarantor.id);
		return addToPlan.submit();
	}

	@AuraEnabled
	public static GuarantorPaymentInfo getPaymentPlanInfo()
	{
		Contact guarantor = PaymentTabsController.getGuarantatorContact();
		if (guarantor == null)
		{
			return null;
		}

		GuarantorPaymentInfo paymentInfo = new GuarantorPaymentInfo();
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
			System.debug('paymentInfo.creditCards'+paymentInfo.creditCards);
		}
		System.debug('paymentInfo:'+paymentInfo);
		return paymentInfo;
	}

	// Method for add credit card / payment plan creation
	// right now using onlu AUTO plan types
	@AuraEnabled
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
		                     '"cardholder_name":"' + paymentInfo.creditCard.cardHolderName + '",' +
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
		req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/');
		System.debug('RequestData:' + requestData);
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
			// Update the Charge Groups using ChargeGroupService.
        		ChargeGroupService.updateChargeGroups(chargeGroups);
			//@DOTO: waiting for Payment Method API implementatio
			Payment_Method__c paymentMethod = PaymentTabsController.generatePaymentMethod(paymentInfo, paymentPlanObj.Guarantor__c);
			paymentPlanObj.Payment_Method__r = paymentMethod;
			if (paymentInfo.creditCard.isSaved)
			{
				insert paymentMethod;
				paymentPlanObj.Payment_Method__c = paymentMethod.Id;
				update paymentPlanObj;
			}
			return paymentPlanObj;
		}
		System.debug('responseBody:'+responseBody);
		String errorMessage = PaymentTabsController.getErrorMessage(responseBody, res);
		throw new AuraHandledException(errorMessage);
		return paymentPlanObj;
	}

	@AuraEnabled
	public static Payment_Plan__c doEditPaymentMethod(String paymentInfoStr)
	{
		System.debug('paymentInfoStr'+paymentInfoStr);
		PaymentRequestInfo paymentInfo = (PaymentRequestInfo)JSON.deserialize(paymentInfoStr, PaymentRequestInfo.class);
		Payment_Plan__c paymentPlanObj = PaymentTabsController.getPaymentPlanById(paymentInfo.sfId);
		Payment_Method__c paymentMethod = null;
		//@DOTO: waiting for Payment Method API implementation
		if (String.isBlank(paymentInfo.creditCard.sfId))
		{
			paymentMethod = PaymentTabsController.generatePaymentMethod(paymentInfo, paymentPlanObj.Guarantor__c);
			if (paymentInfo.creditCard.isSaved)
			{
				insert paymentMethod;
			}
		}
		else
		{
			paymentMethod = PaymentTabsController.getCreditCard(paymentInfo.creditCard.sfId);
		}
		paymentPlanObj.Payment_Method__r = paymentMethod;

		if (paymentInfo.creditCard.isSaved)
		{
			update paymentPlanObj;
			paymentPlanObj.Payment_Method__c = paymentMethod.Id;
		}
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

		String requestData = '{"csrfmiddlewaretoken":"' + csrfToken + '","plan_type":"auto",' +
		                     '"url": "' + (SironoSettingsUtil.getServerEndpoint() + '/paystaff/api/paymentplan/' + paymentInfo.paymentPlanId + '/') + '",' +
		                     '"active":true,' +
		                     '"installment_amount":' + convertToCents(paymentInfo.planValue) + ',' +
		                     '"execute_on_day":' + paymentInfo.executeOnDay +
		                     '}';

		HttpRequest req = new HttpRequest();
		req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' + paymentInfo.paymentPlanId + '/');
		req.setMethod('POST');
		req.setHeader('X-HTTP-Method-Override', 'PATCH');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setBody(requestData);

		String responseBody = '';
		HttpResponse res = new HttpResponse();
		try
		{
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
			update paymentPlanObj;
			return PaymentTabsController.getPaymentPlanById(paymentPlanObj.Id);
		}

		String errorMessage = PaymentTabsController.getErrorMessage(responseBody, res);
		throw new AuraHandledException(errorMessage);
		return paymentPlanObj;
	}

	@AuraEnabled
	public static void deletePaymentPlan(String sfPaymentPlanId)
	{
		System.debug('deletePaymentPlan');
		Payment_Plan__c paymentPlan = PaymentTabsController.getPaymentPlanById(sfPaymentPlanId);
		String guarantorId = paymentPlan.Guarantor__c;
		String paymentPlanExtId = String.valueOf(paymentPlan.Sirono_ID__c);

		//call Delete PaymentPlan and send the request to end point.
		if (String.isNotBlank(paymentPlanExtId))
		{
			String jwtToken = PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
			String csrfToken = PayStaffWSUtill.getCSRFToken();
			if (csrfToken != null && jwtToken != null)
			{
				PaymentTabsController.doDeletePaymentPlan(csrfToken, jwtToken, guarantorId, paymentPlanExtId);
			}
		}
		else
		{
			throw new AuraHandledException('Payment Plan Id is missing.');
		}
	}

	private static Payment_Method__c generatePaymentMethod(PaymentRequestInfo info, String contactId)
	{
		Date expDate = null;
		if (info.creditCard != null && String.isNotBlank(info.creditCard.expirationMonth) && String.isNotBlank(info.creditCard.expirationYear))
		{
			expDate = Date.newInstance(Integer.valueOf(info.creditCard.expirationYear), Integer.valueOf(info.creditCard.expirationMonth), 1);
		}

		String lastDigits = '';
		if (String.isNotBlank(info.creditCard.creditCardNumber))
		{
			String fullNumber = info.creditCard.creditCardNumber;
			lastDigits = fullNumber.substring(fullNumber.length() - 4, fullNumber.length());
		}

		return new Payment_Method__c (
		           Card_Type__c = 'Visa',
		           Type__c = 'Credit Card',
		           Card_Holder_Name__c = info.creditCard.cardHolderName,
		           Expiration_Date__c = expDate,
		           Guarantor__c = contactId,
		           Last_4__c = lastDigits
		       );
	}

	/*Mohan Kumar 08-02-2016: Ticket # 06638015 -
	 *Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
	 */
	private static void doDeletePaymentPlan(String csrfToken, String jwtToken, String guarantorId, String paymentPlanExtId)
	{
		PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper = PaymentTabsController.callPaymentPlanRequest(csrfToken, jwtToken, guarantorId, paymentPlanExtId);
		HttpRequest req = new HttpRequest();
		req.setMethod('DELETE');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');

		HttpResponse res = new HttpResponse();
		String responseBody;
		try
		{
			res = new Http().send(req);
			responseBody = res.getBody();
			System.debug('responseBody:'+responseBody);
		}
		catch (Exception e)
		{
			throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + ' EXCEPTION:: ' + e.getMessage());
		}

		if (res.getStatusCode() != null && res.getStatusCode() == 204)
		{
			if (objPaymentPlanWrapper != null)
			{
				List<Charge_Group__c> chargeGroups = objPaymentPlanWrapper.chargeGroupRecords;
				objPaymentPlanWrapper = PaymentTabsController.callPaymentPlanRequest(csrfToken, jwtToken, guarantorId, paymentPlanExtId);
				Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
				paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
				paymentPlanObj.Active__c = false;
				paymentPlanObj.Cancellation_Date__c = System.today();

				Boolean hasError = false;
				for (Charge_Group__c cg : chargeGroups)
				{
					hasError = PaymentTabsController.callChargeGroupRequest(String.valueof(cg.Sirono_ID__c), jwtToken, cg);
				}
				if (!hasError)
				{
					update paymentPlanObj;
                    			// Update the Charge Groups using ChargeGroupService.
                    			ChargeGroupService.updateChargeGroupsWithStatus(chargeGroups);
				}
				return;
			}
		}

		throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
	}

	/*
	* 09-22-2016: Viraj Rana - Tracker #129177479
	*  Call the paymentplan Web Service to get the paymentplan information.
	*/
	private static PaymentPlanJSONParsing.PaymentPlanWrapper callPaymentPlanRequest(String csrfToken, String jwtToken, String guarantorId, String paymentPlanExtId)
	{
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');
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
			return PaymentPlanJSONParsing.createPaymentPlanRecord(responseBody, guarantorId, null, null);
		}
		else
		{
			throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
		}
		return null;
	}

	/*
	* 09-22-2016: Viraj Rana - Tracker # 129177479
	* make a Charge group Reqeuest to get the chargeGroupInformation
	*/
	private static Boolean callChargeGroupRequest(String chargeGroupId, String jwtToken, Charge_Group__c cg)
	{
		System.debug('callChargeGroupRequest');
		Boolean hasError = false;
		HttpRequest req = new HttpRequest();
		req.setMethod('GET');
		req.setHeader('Authorization', 'JWT ' + jwtToken);
		req.setHeader('Content-type', 'application/json');
		req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/chargegroups/' + PayStaffWSUtill.trimCommas(chargeGroupId) + '/');
		req.setTimeout(120000);

		String responseBody;
		HttpResponse res = new HttpResponse();
		try
		{
			res = new Http().send(req);
			responseBody = res.getBody();
			System.debug('res:'+res);
			System.debug('responseBody:'+responseBody);
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

	private static List<Charge_Group__c> getChargeGroups(Contact guarantor)
	{
		List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
		////tracker #134300243 fetching charge group list based on account sub status : Preinvoiced, Due, Overdue, Delinquent, or Bad Debt
		//for (ChargeGroupWrapper cgw : PayStaffWSUtill.fetchChargeGroupListByAccSubStatus(guarantor))
		//if (cgw.cg.Active__c && cgw.cg.Balance__c != 0)
		List<WorkWithInvoicesController.InvoicesWrapper> invoicesWithGroups = WorkWithInvoicesController.getAllInvoices(WorkWithInvoicesController.INVOICE_UNPAID_STATUS, '');
		for (WorkWithInvoicesController.InvoicesWrapper invoice : invoicesWithGroups)
		{
			for (WorkWithInvoicesController.ChargeGroupWrapper chargeGroupW : invoice.allGroups)
			{
				if (chargeGroupW.cGroup.Active__c && chargeGroupW.cGroup.Balance__c != 0)
				{
					chargeGroups.add(chargeGroupW.cGroup);
				}
			}
		}
		System.debug('chargeGroups:'+chargeGroups);
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
		// Get Contact details with all active charge groups.
        	return GuarantorService.getGuarantorWithActiveCGForLightning(contactId);
	}

	private static Payment_Plan__c getPaymentPlanById(Id planId)
	{
		List<Payment_Plan__c> plans = [SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, Installment_Amount__c, CreatedDate,
		                               NextPaymentDate__c, Plan_Type__c, Remaining_Installment_Count__c, Execute_on_Day__c, Sirono_ID__c, Guarantor__c,
		                               Payment_Method__c, Payment_Method__r.Sirono_ID__c, Payment_Method__r.Display_Name__c,
		                               Payment_Method__r.Card_Type__c, Payment_Method__r.Last_4__c
		                               FROM Payment_Plan__c
		                               WHERE Id = : planId];
		if (!plans.isEmpty())
		{
			return plans.get(0);
		}
		return null;
	}

	//10-12-2016: Viraj Rana - Tracker #131459561: Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
	private static Payment_Plan__c getPaymentPlan(Id guarantorContactId)
	{
		List<Payment_Plan__c> plans = [SELECT Id, Name, Original_Installment_Count__c, Remaining_Balance__c, Installment_Amount__c, CreatedDate,
		                               NextPaymentDate__c, Plan_Type__c, Remaining_Installment_Count__c, Execute_on_Day__c, Sirono_ID__c,
		                               Payment_Method__c, Payment_Method__r.Sirono_ID__c, Payment_Method__r.Display_Name__c,
		                               Payment_Method__r.Card_Type__c, Payment_Method__r.Last_4__c
		                               FROM Payment_Plan__c
		                               WHERE Guarantor__c = : guarantorContactId and Active__c = true];
		if (!plans.isEmpty())
		{
			return plans.get(0);
		}
		return null;
	}

	private static Payment_Method__c getCreditCard(String cardId)
	{
		List<Payment_Method__c> pMethods = [SELECT Id, Account_Number__c, Card_Holder_Name__c, Card_Type__c, Display_Name__c, Expiration_Date__c, ID__c, Last_4__c,
		                                    Payment_Method_Token__c, Routing_Number__c, Sirono_ID__c, Type__c, Guarantor__c
		                                    FROM Payment_Method__c WHERE Id = : cardId];
		if (!pMethods.isEmpty())
		{
			return pMethods.get(0);
		}
		return null;
	}

	private  static List<MakeAPaymentController.CardInformation> getCreditCards(Id guarantorContactId)
	{
		System.debug('getCreditCards');
		List<MakeAPaymentController.CardInformation> cards = new List<MakeAPaymentController.CardInformation>();
		for (Payment_Method__c pCard : [SELECT Id, Account_Number__c, Card_Holder_Name__c, Card_Type__c, Display_Name__c, Expiration_Date__c, ID__c, Last_4__c,
		                                Payment_Method_Token__c, Routing_Number__c, Sirono_ID__c, Type__c, Guarantor__c
		                                FROM Payment_Method__c WHERE Guarantor__c = : guarantorContactId AND Display_Name__c != null])
		{
			System.debug('getCreditCards element'+pCard);
			cards.add(new MakeAPaymentController.CardInformation(pCard));
		}
		System.debug('cards'+cards);
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

	public class GuarantorPaymentInfo
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
		public List<Charge_Group__c> chargeGroups {get; set;}
		@AuraEnabled
		public List<MakeAPaymentController.CardInformation> creditCards {get; set;}

		public GuarantorPaymentInfo()
		{
			this.guarantor = new Contact();
			this.settings = new Sirono_Settings__c();
			this.hasPaymentPlans = false;
			this.addToPaymentAvail = false;
			this.chargeGroups = new List<Charge_Group__c>();
			this.creditCards = new List<MakeAPaymentController.CardInformation>();
		}
	}

	public class PaymentRequestInfo
	{
		@AuraEnabled
		public String sfId {get; set;}
		@AuraEnabled
		public MakeAPaymentController.CardInformation creditCard {get; set;}
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
			this.creditCard = new MakeAPaymentController.CardInformation();
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
		@AuraEnabled
		public Boolean isSaved {get; set;}

		public CreditCardInfo()
		{
			this.isSaved = false;
			this.cardholderName = '';
			this.creditCardNumber = '';
			this.expirationYear = String.valueOf(Datetime.now().year());
			this.expirationMonth = String.valueOf(Datetime.now().month()).length() == 1 ? '0'+ String.valueOf(Datetime.now().month()) :  String.valueOf(Datetime.now().month());
			this.cvv = '';
			this.address = '';
			this.city = '';
			this.state = '';
			this.zip = '';
		}
		public CreditCardInfo(Payment_Method__c card)
		{
			this.sfId = card.Id;
			this.cardholderName = card.Card_Holder_Name__c;
			this.cardType = card.Card_Type__c;
			this.displayName = card.Display_Name__c;
			this.creditCardNumber = '****-****-****-' + card.Last_4__c;
			this.isSaved = true;

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