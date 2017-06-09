public with sharing class MakeAPaymentController {
    public CardInformation cInfo{get;set;}
    
    public class CardInformation{
        @AuraEnabled
        public String sfId {get; set;}
        @AuraEnabled
        public String displayName {get; set;}
        @AuraEnabled
        public String cardType {get; set;}
        @AuraEnabled
        public Boolean isSaved {get; set;}
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
            this.sfId = '';
            this.displayName = '';
            this.cardType = '';
            this.isSaved = false;

            this.password = '';
            this.creditCardNumber = '';
            this.cardHolderName = '';
            this.expirationDate = '';
            this.expirationYear = String.ValueOf(Datetime.now().year());
            this.expirationMonth = String.ValueOf(Datetime.now().month()).length() == 1 ? '0'+ String.ValueOf(Datetime.now().month()) :  String.ValueOf(Datetime.now().month());
            this.cvv = '';
            this.amount = '0';
            this.address = '';
            this.city = '';
            this.state = '';
            this.zip = '';
        }

        public CardInformation(Payment_Method__c card)
        {
            this.sfId = card.Id;
            this.cardHolderName = card.Card_Holder_Name__c;
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

    @AuraEnabled
    public static CardInformation getCardInformation(){
        return new CardInformation();
    }

    @AuraEnabled
    public static String makeNewPayment(String jsonPayment, String listIds){
        System.debug('jsonPayment: '+jsonPayment);
        System.debug('listIds: ' + listIds);
        CardInformation cInfo = (CardInformation)JSON.deserialize(jsonPayment, CardInformation.class);
        system.debug(cInfo);
        List<String> invIds = (List<String>)JSON.deserialize(listIds, List<String>.class);
        System.debug(invIds);

        Contact guarantor = GuarantorService.getPortalGuarantor(UserInfo.getUserId());

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

        System.debug('Estimate jsonPayment: '+jsonPayment);
        System.debug('EstimateId: ' + estimateId);

        CardInformation cInfo = (CardInformation)JSON.deserialize(jsonPayment, CardInformation.class);
        System.debug(cInfo);

        Contact guarantor = GuarantorService.getPortalGuarantor(UserInfo.getUserId());

        ApexPages.StandardController sc = new ApexPages.StandardController(guarantor);
        PayEstimateLightningController onePayment = new PayEstimateLightningController(sc, estimateId);
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
        outputMap.put('YEARS', PortalUIConstants.yearOptions);
        outputMap.put('MONTHS', PortalUIConstants.expMonthOptions);
        return outputMap;
    }

    @AuraEnabled
    public static List<String> getStates() {
        return PortalUIConstants.states;
    }
}