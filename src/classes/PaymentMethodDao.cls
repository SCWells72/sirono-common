/**
 * Created by gbockus on 6/29/17.
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

}