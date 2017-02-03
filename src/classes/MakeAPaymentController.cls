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
		public string expirationYear { get{if(expirationDate != null && expirationDate.length() == 5) { return expirationDate.substring(3,5);}else return '';} set; }
		//@AuraEnabled
		public string expirationMonth { get{if(expirationDate != null && expirationDate.length() == 5) { return expirationDate.substring(0,2);}else return '';} set; }
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
			this.creditCardNumber = '';
			this.cardHolderName = '';
			this.expirationDate = '';
			this.expirationYear = '';
			this.expirationMonth = '';
			this.cvv = '';
			this.amount = '50';
			this.address = '';
			this.city = '';
			this.state = '';
			this.zip = '';
		}
	}

	@AuraEnabled
	public static CardInformation getCardInformation(){
		return new CardInformation();
	}

	@AuraEnabled
	public static String makeNewPayment(String jsonPayment){
		system.debug('jssonPaymen:'+jsonPayment);
		CardInformation cInfo = (CardInformation)JSON.deserialize(jsonPayment, CardInformation.class);
		system.debug(cInfo);
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userInfo.getUserId()];
        Contact guarantor = [SELECT id FROM Contact WHERE id = :currentUser.ContactId];
		ApexPages.StandardController sc = new ApexPages.StandardController(guarantor);
		ProcessPaymentLightning onePayment = new ProcessPaymentLightning(sc);
		//onePayment.password = cInfo.password;
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
}