/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Service class interacting with Payment_Method__c objects.
 */
public with sharing class PaymentMethodService extends AbstractService {

    /**
     * Get a list of Payment_Method__c object for a Guarantor.
     *
     * @param Id guarantorid - The Guarantor Id.
     * @return List<Payment_Method__c> - The list of payment methods associated with the Guarantor.
     */
    public static List<Payment_Method__c> getPaymentMethods(Id guarantorId) {
        return PaymentMethodDao.getPaymentMethods(guarantorId);
    }

    /**
     * Get a credit card by id.
     *
     * @param String cardId - The credit card id.
     * @return Payment_Method__c - The credit card Payment_Method__c object.
     */
    public static Payment_Method__c getCreditCard(String cardId) {
        List<Payment_Method__C> cards = PaymentMethodDao.getCreditCard(cardId);
        return (!cards.isEmpty()) ? cards[0] : null;
    }

    /**
     * Generate a Payment_Method__c object and return it without persisting it.
     *
     * @param PaymentPlanInformation info - A PaymentPlanInformation object containing the payment method data.
     * @param String guarantorId - The guarantorId.
     * @return Payment_Method__c - The generated Payment_Method__c object.
     */
    public static Payment_Method__c generatePaymentMethod(PaymentPlanInformation info, String guarantorId) {
        Date expDate = getPaymentMethodExpiration(info.expirationMonth, info.expirationYear);
        String lastFour = getLastFour(info.creditCardNumber);

        //TODO: Visa should not be hardcoded
        return PaymentMethodDao.generatePaymentMethod('Visa', Constants.CREDIT_CARD, info.cardholderName, expDate, guarantorId, lastFour);
    }

    /**
     * Get the expiration date used for Payment_Method__c objects.
     *
     * @param String expirationMonth - The month of expiration.
     * @param String expirationYear - The year of expiration.
     * @return Date - The expiration date.
     */
    public static Date getPaymentMethodExpiration(String expirationMonth, String expirationYear) {
        Date expDate = null;
        if (String.isNotBlank(expirationMonth) && String.isNotBlank(expirationYear)) {
            expDate = Date.newInstance(Integer.valueOf(expirationYear), Integer.valueOf(expirationMonth), 1);
        }
        return expDate;
    }

    /**
     * Get the last for digit of a credit card number.
     *
     * @param String ccNumber - The credit card number.
     * @return String - The last four digits of the credit card value.
     */
    public static String getLastFour(String ccNumber) {
        String lastFour = '';
        if (String.isNotBlank(ccNumber) && ccNumber.length() >= 4) {
            lastFour = ccNumber.substring(ccNumber.length() - 4, ccNumber.length());
        }
        return lastFour;
    }
}