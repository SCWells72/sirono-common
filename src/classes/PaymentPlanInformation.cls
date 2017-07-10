/**
 * Payment Plan Info class.
 * It is use to set all parameters which are pass or set in web request to create/edit Payment Plan.
 **/

public with sharing class PaymentPlanInformation {
    @AuraEnabled
    public String planType {get; set;}
    @AuraEnabled
    public String planValue {get; set;}
    @AuraEnabled
    public String amount {get; set;}
    @AuraEnabled
    public String executeOnDay {get; set;}
    @AuraEnabled
    public List<String> chargeGroupIds {get; set;}
    @AuraEnabled
    public String guarantorId {get; set;}
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
    public String state {get; set;}
    @AuraEnabled
    public String zip {get; set;}
    @AuraEnabled
    public String address {get; set;}
    @AuraEnabled
    public String city {get; set;}

    public PaymentPlanInformation() {}
    public PaymentPlanInformation(Map<String, Object> ppInfoMap) {
        
        this.planType = getStringValueFromMap(ppInfoMap, 'planType');
        this.planValue = getStringValueFromMap(ppInfoMap, 'planValue');
        this.amount = getStringValueFromMap(ppInfoMap, 'amount');
        this.executeOnDay = getStringValueFromMap(ppInfoMap, 'executeOnDay');
        String cgString = getStringValueFromMap(ppInfoMap, 'chargeGroupIds');
        this.chargeGroupIds = cgString.split(',');
        this.guarantorId = getStringValueFromMap(ppInfoMap, 'guarantorId');
        this.cardholderName = getStringValueFromMap(ppInfoMap, 'cardHolderName');
        this.expirationYear = getStringValueFromMap(ppInfoMap, 'expirationYear');
        this.expirationMonth = getStringValueFromMap(ppInfoMap, 'expirationMonth');
        this.creditCardNumber = getStringValueFromMap(ppInfoMap, 'creditCardNumber');
        this.cvv = getStringValueFromMap(ppInfoMap, 'cvv');
        this.state = getStringValueFromMap(ppInfoMap, 'state');
        this.zip = getStringValueFromMap(ppInfoMap, 'zip');
        this.address = getStringValueFromMap(ppInfoMap, 'address');
        this.city = getStringValueFromMap(ppInfoMap, 'city');
    }
    
    private String getStringValueFromMap(Map<String, Object> objMap, String key) {
        String str = '';
        if (objMap.containsKey(key)) {
            str = String.valueOf(objMap.get(key));
        }
        return str;
    }
}