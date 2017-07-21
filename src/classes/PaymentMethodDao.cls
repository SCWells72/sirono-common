/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * The Payment_Method__c DAO.
 */
public without sharing class PaymentMethodDao {

    /**
     * Get a list of payment methods for a Guarantor.
     *
     * @param Id guarantorId - The id associated with the Guarantor contact.
     * @return List<Payment_Method__c> - The payment methods associated with the Guarantor.
     */
    public static List<Payment_Method__c> getPaymentMethods(Id guarantorId) {
        List<Payment_Method__c> paymentMethods = new List<Payment_Method__c>();

        if (PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            paymentMethods = [
                SELECT Id, Account_Number__c, Card_Holder_Name__c, Card_Type__c, Display_Name__c, Expiration_Date__c, ID__c, Last_4__c,
                    Payment_Method_Token__c, Routing_Number__c, Sirono_ID__c, Type__c, Guarantor__c
                FROM Payment_Method__c
                WHERE Guarantor__c = :guarantorId AND Display_Name__c != null
            ];
        }

        return paymentMethods;
    }

    /**
     * Get a list of Payment_Method__c credit cards by id.
     *
     * @param String cardId - The credit card id.
     * @return List<Payment_Method__c> - The cards.
     */
    public static List<Payment_Method__c> getCreditCard(String cardId) {
        List<Payment_Method__c> paymentMethods = new List<Payment_Method__c>();

        if (PaymentMethodSecurityContext.GUARANTOR_SELECT.actionAllowed()) {
            paymentMethods = [
                SELECT Id, Account_Number__c, Card_Holder_Name__c, Card_Type__c, Display_Name__c, Expiration_Date__c, ID__c, Last_4__c,
                    Payment_Method_Token__c, Routing_Number__c, Sirono_ID__c, Type__c, Guarantor__c
                FROM Payment_Method__c
                WHERE Id = :cardId
            ];
        }
        return paymentMethods;
    }

    /**
     * Generate a Payment_Method__c object.
     *
     * @param String cardType - The credit card type.
     * @param String paymentType - The payment type.
     * @param String cardholderName - The credit card holder name.
     * @param Date expDate - The expireation date.
     * @param String guarantorId - The guarantor id.
     * @param String lastFour - The last four digits of the credit card.
     * @return Payment_Method__c - The Payment Method object.
     */
    public static Payment_Method__c generatePaymentMethod(String cardType, String paymentType, String cardholderName, Date expDate,
        String guarantorId, String lastFour) {
        return new Payment_Method__c(
            Card_Type__c = cardType,
            Type__c = paymentType,
            Card_Holder_Name__c = cardHolderName,
            Expiration_Date__c = expDate,
            Guarantor__c = guarantorId,
            Last_4__c = lastFour
        );
    }

    /**
     * Insert a Payment_Method__c object.
     * @param Payment_Method__c payMethod - A Payment Method object.
     */
    public static void insertPaymentMethod(Payment_Method__c payMethod) {
        //TODO INSERT SecurityContext
        INSERT payMethod;
    }

}