/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * PaymentTabsController used by various Lightning components.
 */
public with sharing class PaymentTabsController {
    /**
     * Get the Map used to populate the credit card expiration month and year fields.
     *
     * @returns Map<String, Map<String, String>> - The expiration data valid values.
     */
    @AuraEnabled
    public static Map<String, Map<String, String>> getCardSelectOptions() {
        return PortalUIUtils.getCardDateOptions();
    }

    /**
     * Get the payment plan information for the current guarantor.
     *
     * @return GuarantorPaymentInfo - a payment info object populated with the uses data.
     */
    @AuraEnabled
    public static GuarantorPaymentInfo getPaymentPlanInfo() {
        Contact guarantor;
        UserWrapper user = UserService.getCurrentUser();

        if (user.contactId != null) {
            guarantor = GuarantorService.getGuarantorWithActiveCGForLightning(user.contactId);
        }

        if (guarantor == null) {
            return null;
        }

        GuarantorPaymentInfo paymentInfo = new GuarantorPaymentInfo();
        paymentInfo.guarantor = guarantor;
        paymentInfo.addToPaymentAvail = guarantor.Add_To_Payment_Plan__c;
        paymentInfo.guarantorSironoId = user.guarantorSironoId;
        paymentInfo.chargeGroups = getChargeGroups(user.contactId);
        paymentInfo.settings = SironoSettingsUtil.getPaymentPlanSettings();
        paymentInfo.paymentPlan = PaymentPlanService.getActivePaymentPlanWithMethod(user.contactId);

        // Prevent creation of multiple active payment plans to check Guarantor has Active payment plan or not.
        paymentInfo.hasPaymentPlan = (paymentInfo.paymentPlan != null);

        if (paymentInfo.hasPaymentPlan) {
            paymentInfo.creditCards = getCreditCards(user.contactId);
        }

        return paymentInfo;
    }

    /**
     * Method for add credit card and payment plan creation. Using only AUTO plan types.
     *
     * @param Map<String, Object> ppInfoMap - A map of the data required to create a PaymentPlanInformation object.
     * @param Boolean isCreditCardSaved - Should the Payment_Method__c generated be saved.
     * @return Payment_Plan__c The newly created payment plan.
     */
    @AuraEnabled
    public static Payment_Plan__c createPaymentPlan(Map<String, Object> ppInfoMap) {
        Payment_Plan__c paymentPlanObj;
        try {
            PaymentPlanInformation ppInfo = new PaymentPlanInformation(ppInfoMap);
            UserWrapper user = UserService.getCurrentUser();
            paymentPlanObj = PaymentPlanService.addPaymentPlanWithPaymentMethod(ppInfo, true, user.contactId);
        } catch(Exception ex) {
            System.debug('Exception caught in createPaymentPlan: ' + ex.getMessage());
            throw LightningUtil.newAuraHandledException('Error encountered creating playment plan.  Please contact support.');
        }

        return paymentPlanObj;
    }

    /**
     * Edit the current payment method on a payment plan.
     *
     * @param Map<String, Object> ppInfoMap - A map containing info about the payment plan and credit card.
     */
    @AuraEnabled
    public static Payment_Plan__c doEditPaymentMethod(Map<String, Object> ppInfoMap) {
        String planId = ppInfoMap.containsKey('id') ? String.valueOf(ppInfoMap.get('id')) : '';
        String creditCardId = ppInfoMap.containsKey('creditCardId') ? String.valueOf(ppInfoMap.get('creditCardId')) : '';

        if (String.isBlank(planId)) {
            throw new AuraHandledException('Payment Plan id must be provided.');
        }

        Payment_Plan__c updatedPlan;

        try {
            PaymentPlanInformation ppInfo = new PaymentPlanInformation(ppInfoMap);
            updatedPlan = PaymentPlanService.addPaymentMethod(planId, creditCardId, ppInfo, true);

        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
            String errMsg = 'Error encountered updating plan payment method. Please contact support';
            AuraHandledException ex = new AuraHandledException(errMsg);
            ex.setMessage(errMsg);
            throw ex;
        }

        return updatedPlan;
    }

    /**
     * Edit the current users payment plan.
     *
     * @param Map<String, Object> ppInfoMap - A map of the data required to create a PaymentPlanInformation object.
     * @return Payment_Plan__c The newly created payment plan.

     */
    @AuraEnabled
    public static Payment_Plan__c doEditPaymentPlan(Map<String, Object> ppInfoMap) {

        Payment_Plan__c paymentPlan = null;
        PaymentPlanInformation planInfo = new PaymentPlanInformation(ppInfoMap);
        String sironoPaymentPlanId = ppInfoMap.containsKey(PaymentPlanInformation.SIRONO_PP_KEY) ? String.valueOf(ppInfoMap.get(PaymentPlanInformation.SIRONO_PP_KEY)) : '';

        if (String.isBlank(sironoPaymentPlanId)) {
            System.debug('sironoPaymentPlanId must be provided.');
            throw new AuraHandledException('An Error has occurred, please contact support.');
        }
        try {
            paymentPlan = PaymentPlanService.updateAutoPaymentPlanTerms(sironoPaymentPlanId, planInfo);
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
            String errMsg = 'Error encountered updating plan. Please contact support';
            AuraHandledException ex = new AuraHandledException(errMsg);
            ex.setMessage(errMsg);
            throw ex;
        }

        return paymentPlan;

    }

    /**
     * Method called from lightning components in order to delete a payment plan.
     *
     * @param String paymentPlanId - The id of the payment plan to delete.
     */
    @AuraEnabled
    public static void deletePaymentPlan(String paymentPlanId) {
        try {
            PaymentPlanService.removePaymentPlan(paymentPlanId);
        } catch (Exception e) {
            System.debug('Error occurred attempting to delete payment plan: ' + e.getMessage());
            String errMsg = 'An error has occurred, please contact support.';
            AuraHandledException ex = new AuraHandledException(errMsg);
            ex.setMessage(errMsg);
            throw ex;
        }
    }

    /**
     * Get the list of invoiced active non-zero balance charge groups for the curernt guarantor user.
     *
     * @param UserWrapper user - The user for which to get the charge groups.
     * @return List<Charge_Group__c> - The list of Charge_Group__c objects.
     */
    @TestVisible
    private static List<Charge_Group__c> getChargeGroups(String contactId) {
        List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();

        if (contactId != null) {
            List<Charge_Group__c> allGroups = InvoiceService.getInvoicedChargeGroups(contactId, PortalConstants.INVOICE_UNPAID_STATUSES, new List<String>());

            for (Charge_Group__c chgGroup : allGroups) {
                if (chgGroup.Active__c && chgGroup.Balance__c != 0) {
                    chargeGroups.add(chgGroup);
                }
            }

        }

        return chargeGroups;
    }

    /**
     * Get the credit cards for the current user.
     *
     * @param Id guarantorContactId - The guarantor id.
     * @return List<CardInformation> - The card objects.
     */
    @TestVisible
    private static List<CardInformation> getCreditCards(Id guarantorContactId) {

        List<CardInformation> cards = new List<CardInformation>();
        for (Payment_Method__c pCard : PaymentMethodService.getPaymentMethods(guarantorContactId)) {
            cards.add(new CardInformation(pCard));
        }

        return cards;
    }

    public class GuarantorPaymentInfo {
        @AuraEnabled
        public Payment_Plan__c paymentPlan {
            get;
            set;
        }
        @AuraEnabled
        public Boolean addToPaymentAvail {
            get;
            set;
        }
        @AuraEnabled
        public Contact guarantor {
            get;
            set;
        }
        @AuraEnabled
        public String guarantorSironoId {
            get;
            set;
        }
        @AuraEnabled
        public Sirono_Settings__c settings {
            get;
            set;
        }
        @AuraEnabled
        public Boolean hasPaymentPlan {
            get;
            set;
        }
        @AuraEnabled
        public List<Charge_Group__c> chargeGroups {
            get;
            set;
        }
        @AuraEnabled
        public List<CardInformation> creditCards {
            get;
            set;
        }

        public GuarantorPaymentInfo() {
            this.guarantor = new Contact();
            this.settings = new Sirono_Settings__c();
            this.hasPaymentPlan = false;
            this.addToPaymentAvail = false;
            this.chargeGroups = new List<Charge_Group__c>();
            this.creditCards = new List<CardInformation>();
        }
    }

}