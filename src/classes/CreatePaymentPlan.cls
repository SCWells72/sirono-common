public with sharing class CreatePaymentPlan { 
	
	@AuraEnabled
	public CardInformation cInfo{get;set;}
	
	@AuraEnabled
	public Id guarantorId{get;set;}
	
	public class CardInformation{
		@AuraEnabled
		public String username { get; set; }
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
		@AuraEnabled
		public string expirationMonth { get{if(expirationDate != null && expirationDate.length() == 5) { return expirationDate.substring(0,2);}else return '';} set; }
		@AuraEnabled
		public string cvv { get; set; }
		@AuraEnabled
		public string amount { get; set; } //will be used as promise to pay as well if the scenario exists
		@AuraEnabled
		public string address { get; set; }
		@AuraEnabled
		public string city { get; set; }
		@AuraEnabled
		public string state { get; set; }
		@AuraEnabled
		public string zip { get; set; }
		@AuraEnabled
		public string executeOnDay{get;set;}
		


		public CardInformation(){
			this.username = '';
			this.password = '';
			this.creditCardNumber = '';
			this.cardHolderName = '';
			this.expirationDate = '';
			this.expirationYear = '';
			this.expirationMonth = '';
			this.cvv = '';
			this.amount = '';
			this.address = '';
			this.city = '';
			this.state = '';
			this.zip = '';
			this.executeOnDay = '';
		}
	}

	@AuraEnabled
	public static CardInformation getCardInformation(){
		return new CardInformation();
	}

	@AuraEnabled
	public static String createPaymentPlan(String jsonPayment, Id guarantorId){
		system.debug('jsonPayment:'+jsonPayment);
		CardInformation cInfo = (CardInformation)JSON.deserialize(jsonPayment, CardInformation.class);
		//Create instance of AddCreditCard
		AddCreditCardLightning addCreditCardInstance = new AddCreditCardLightning();
		//Fill common fields like executeOnDay, cardHolderName, guarantorId
		addCreditCardInstance.username = cInfo.username;
	    addCreditCardInstance.password = cInfo.password;
	    addCreditCardInstance.guarantorId = guarantorId;	    
	    addCreditCardInstance.planType = '';//TODO
	    addCreditCardInstance.planValue = '';//TODO
	    addCreditCardInstance.amount = cInfo.amount;
	    addCreditCardInstance.promiseAmount = cInfo.amount;
	    addCreditCardInstance.executeOnDay = cInfo.executeOnDay;
	    addCreditCardInstance.cardHolderName = cInfo.cardHolderName;
	    addCreditCardInstance.expirationYear = cInfo.expirationYear;
	    addCreditCardInstance.expirationMonth = cInfo.expirationMonth;
	    addCreditCardInstance.creditCardNumber = cInfo.creditCardNumber;
	    addCreditCardInstance.cvv = cInfo.cvv;
	    addCreditCardInstance.state = cInfo.state;
	    addCreditCardInstance.zip = cInfo.zip;
	    addCreditCardInstance.address = cInfo.address;
	    addCreditCardInstance.city = cInfo.city;
	    addCreditCardInstance.dctotalAmount = 0;
	    addCreditCardInstance.getPaymentPlanSettings();
		//Call methods for creating new payment plan
		
		//fill in ChargeGroups.isSelected
		//getPaymentPlanSettings() and doSubmit();
		
		return null;
	}
}