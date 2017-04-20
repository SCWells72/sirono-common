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
		//Create instance of AddPaymentPlanLightningController
		AddPaymentPlanLightningController addPaymentPlanInstance = new AddPaymentPlanLightningController(guarantorId);
		//Fill common fields like executeOnDay, cardHolderName, guarantorId
		addPaymentPlanInstance.guarantorId = guarantorId;	    
	    	addPaymentPlanInstance.planType = '';//TODO
	    	addPaymentPlanInstance.planValue = '';//TODO
	    	addPaymentPlanInstance.amount = cInfo.amount;
	    	addPaymentPlanInstance.promiseAmount = cInfo.amount;
	    	addPaymentPlanInstance.executeOnDay = cInfo.executeOnDay;
	    	addPaymentPlanInstance.cardHolderName = cInfo.cardHolderName;
	    	addPaymentPlanInstance.expirationYear = cInfo.expirationYear;
	    	addPaymentPlanInstance.expirationMonth = cInfo.expirationMonth;
	    	addPaymentPlanInstance.creditCardNumber = cInfo.creditCardNumber;
	    	addPaymentPlanInstance.cvv = cInfo.cvv;
	    	addPaymentPlanInstance.state = cInfo.state;
	    	addPaymentPlanInstance.zip = cInfo.zip;
	    	addPaymentPlanInstance.address = cInfo.address;
	    	addPaymentPlanInstance.city = cInfo.city;
	    	//Call methods for creating new payment plan
		
		//fill in ChargeGroups.isSelected
		for (ChargeGroupWrapper cgw: addPaymentPlanInstance.chargeGroupList)
			cgw.isSelected = true; //TODO check which groups are to be selected 
		
		addPaymentPlanInstance.getPaymentPlanSettings();
		return addPaymentPlanInstance.addPaymentPlan();
	}
}