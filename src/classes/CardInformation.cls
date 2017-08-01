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
    public String amount { get; set; }
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

    public CardInformation(Payment_Method__c card) {
        this.sfId = card.Id;
        this.cardHolderName = card.Card_Holder_Name__c;
        this.cardType = card.Card_Type__c;
        this.displayName = card.Display_Name__c;
        this.creditCardNumber = '****-****-****-' + card.Last_4__c;
        this.isSaved = true;

        if (card.Expiration_Date__c != null) {
            Integer monthKey = card.Expiration_Date__c.month();
            Integer yearKey = card.Expiration_Date__c.year();
            this.expirationMonth = monthKey > 10 ? String.valueOf(monthKey) : '0' + String.valueOf(monthKey);
            this.expirationYear = String.valueOf(yearKey);
        }
    }
}