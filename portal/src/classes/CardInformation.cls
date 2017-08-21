/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Data associated with a credit card.
 */
public with sharing class CardInformation {
    @AuraEnabled
    public String sfId { get; set; }
    @AuraEnabled
    public String displayName { get; set; }
    @AuraEnabled
    public String cardType { get; set; }
    @AuraEnabled
    public Boolean isSaved { get; set; }
    @AuraEnabled
    public String password { get; set; }
    @AuraEnabled
    public String creditCardNumber { get; set; }
    @AuraEnabled
    public String cardHolderName { get; set; }
    @AuraEnabled
    public String expirationDate { get; set; }
    @AuraEnabled
    public String expirationYear { get; set; }
    @AuraEnabled
    public String expirationMonth { get; set; }
    @AuraEnabled
    public String cvv { get; set; }
    @AuraEnabled
    public String amount {
        get;
        set {
            if (value != null) {
                // Javascript does some crazy things with decimals so we get values like
                // 92.0000000001 or 91.9999999999998 so round to the nearest cent.
                amount = Decimal.valueOf(value).setScale(2).toPlainString();
            } else {
                amount = value;
            }
        }
    }
    @AuraEnabled
    public String address { get; set; }
    @AuraEnabled
    public String city { get; set; }
    @AuraEnabled
    public String state { get; set; }
    @AuraEnabled
    public String zip { get; set; }

    public CardInformation() {
        this.sfId = '';
        this.displayName = '';
        this.cardType = '';
        this.isSaved = true;

        this.password = '';
        this.creditCardNumber = '';
        this.cardHolderName = '';
        this.expirationDate = '';
        this.expirationYear = String.valueOf(Datetime.now().year());
        this.expirationMonth = String.valueOf(Datetime.now().month()).length() == 1 ? '0' + String.valueOf(Datetime.now().month()) : String.valueOf(Datetime.now().month());
        this.cvv = '';
        this.amount = '0';
        this.address = '';
        this.city = '';
        this.state = '';
        this.zip = '';
    }

    public CardInformation(sPRS__Payment_Method__c card) {
        this.sfId = card.Id;
        this.cardHolderName = card.sPRS__Card_Holder_Name__c;
        this.cardType = card.sPRS__Card_Type__c;
        this.displayName = card.sPRS__Display_Name__c;
        this.creditCardNumber = '****-****-****-' + card.sPRS__Last_4__c;
        this.isSaved = true;

        if (card.sPRS__Expiration_Date__c != null) {
            Integer monthKey = card.sPRS__Expiration_Date__c.month();
            Integer yearKey = card.sPRS__Expiration_Date__c.year();
            this.expirationMonth = monthKey > 10 ? String.valueOf(monthKey) : '0' + String.valueOf(monthKey);
            this.expirationYear = String.valueOf(yearKey);
        }
    }
}