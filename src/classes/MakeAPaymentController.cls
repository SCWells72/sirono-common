public with sharing class MakeAPaymentController { 
	public CardInformation cInfo{get;set;}
	
	public class CardInformation{
		@AuraEnabled
		public String password { get; set; }
		@AuraEnabled
		public string creditCardNumber { get; set; }
		@AuraEnabled
		public string cardHolderName { get; set; }
		@AuraEnabled
		public string expirationDate{get;set;}
		@AuraEnabled
		public string expirationYear { get; set; }
		@AuraEnabled
		public string expirationMonth { get; set; }
		@AuraEnabled
		public string cvv { get; set; }
		@AuraEnabled
		public string amount { get; set; }
		@AuraEnabled
		public string address { get; set; }
		@AuraEnabled
		public string city { get; set; }
		@AuraEnabled
		public string state { get; set; }
		@AuraEnabled
		public string zip { get; set; }

		public CardInformation(){
			this.password = '';
			this.creditCardNumber = '4111111111111111';
			this.cardHolderName = 'Charles Green';
			this.expirationDate = '';
			this.expirationYear = String.ValueOf(Datetime.now().year());
			this.expirationMonth = String.ValueOf(Datetime.now().month()).length() == 1 ? '0'+ String.ValueOf(Datetime.now().month()) :  String.ValueOf(Datetime.now().month());
			this.cvv = '123';
			this.amount = '0';
			this.address = '1221 Congress Ave';
			this.city = 'Austin';
			this.state = 'TX';
			this.zip = '78701';
		}
	}

	@AuraEnabled
	public static CardInformation getCardInformation(){
		return new CardInformation();
	}

	@AuraEnabled
	public static String makeNewPayment(String jsonPayment, String listIds){
		system.debug('jssonPaymen:'+jsonPayment);
		system.debug('listIds' + listIds);
		CardInformation cInfo = (CardInformation)JSON.deserialize(jsonPayment, CardInformation.class);
		system.debug(cInfo);
		List<String> invIds = (List<String>)JSON.deserialize(listIds, List<String>.class);
		system.debug(invIds);
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userInfo.getUserId()];
        Contact guarantor = [SELECT id FROM Contact WHERE id = :currentUser.ContactId];
		ApexPages.StandardController sc = new ApexPages.StandardController(guarantor);
		ProcessPaymentLightning onePayment = new ProcessPaymentLightning(sc, invIds);
		//onePayment.password = cInfo.password;
		onePayment.creditCardNumber = cInfo.creditCardNumber;
		onePayment.cardHolderName = cInfo.cardHolderName;
		onePayment.expirationYear = cInfo.expirationYear.substring(2);
		onePayment.expirationMonth = cInfo.expirationMonth.substring(0,2);
		onePayment.cvv = cInfo.cvv;
		onePayment.amount = cInfo.amount;
		onePayment.address = cInfo.address;
		onePayment.city = cInfo.city;
		onePayment.state = cInfo.state;
		onePayment.zip = cInfo.zip;
		onePayment.doNext();
		return onePayment.submit();
	}

	@AuraEnabled
	public static String makeNewEstimatePayment(String jsonPayment, String estimateId) {
		system.debug('Estimate jssonPaymen:'+jsonPayment);
		System.debug('EstimateId:' + estimateId);
		CardInformation cInfo = (CardInformation)JSON.deserialize(jsonPayment, CardInformation.class);
		system.debug(cInfo);
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userInfo.getUserId()];
        Contact guarantor = [SELECT id FROM Contact WHERE id = :currentUser.ContactId];
		ApexPages.StandardController sc = new ApexPages.StandardController(guarantor);
		PayEstimateLightning onePayment = new PayEstimateLightning(sc, estimateId);
		onePayment.creditCardNumber = cInfo.creditCardNumber;
		onePayment.cardHolderName = cInfo.cardHolderName;
		onePayment.expirationYear = cInfo.expirationYear;
		onePayment.expirationMonth = cInfo.expirationMonth;
		onePayment.cvv = cInfo.cvv;
		onePayment.amount = cInfo.amount;
		onePayment.address = cInfo.address;
		onePayment.city = cInfo.city;
		onePayment.state = cInfo.state;
		onePayment.zip = cInfo.zip;
		onePayment.doNext();
		return onePayment.submit();
	}

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
		outputMap.put('MONTHS', monthsOptions);
		return outputMap;
	}
}