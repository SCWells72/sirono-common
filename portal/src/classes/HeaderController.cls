/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Controller for the Lightning Header that loads information about the user.
 */
public with sharing class HeaderController {

    public static String WARNING_MESSAGE = 'Your account has overdue invoices. Please pay the balance now or set up a payment plan to avoid becoming delinquent.\n If you have any questions about the bill, please contact the Customer Service Center at ' + Label.Customer_Service_Center_Phone + '.';
    public static String DELINQUENT_MESSAGE = 'This account has delinquent invoices. Delinquent invoices will be sent to a collection agency if payment arrangements are not made within the next 30 days. Please pay the balance now or set up a payment plan.';
    public static String PASTDUE_MESSAGE = ' We have not received your latest payment plan installment. Please pay your previous installment amount now or pay your account in full to avoid payment plan cancellation.';
    public static String PASTDUE_MANUAL_MESSAGE = ' If you have any questions about the bill, call the Customer Service Center at ' + Label.Customer_Service_Center_Phone + '.';
    public static String ERROR_MESSAGE = ' Your latest payment plan installment failed. Please update your payment method or pay your previous installment amount now to keep your account current.';

    /**
     * Gather all information reqiured for loading the portal.
     *
     * @returns HeaderWrapper - A populated HeaderWrapper.
     */
    @AuraEnabled
    public static HeaderWrapper getAllHeaderInfo() {
        UserWrapper user = getUserInfo();
        Contact contact;
        List<Invoice__c> invoices = new List<Invoice__c>();
        Payment_Plan__c paymentPlan = new Payment_Plan__c();
        Integer estimateCount = null;

        if (user.contactId != null) {
            contact = GuarantorService.getContactsForLightning(new Set<Id> {
                user.contactId
            })[0];
            invoices = InvoiceService.getByStatus(user.contactId, PortalConstants.DUE);
            paymentPlan = PaymentPlanService.getActivePaymentPlan(user.contactId);
            estimateCount = EncounterService.getCountByDate(user.contactId, Datetime.now().addDays(-30));
        }

        Invoice__c invoice = (invoices.size() > 0) ? invoices[0] : new Invoice__c();

        HeaderWrapper hWrapper = new HeaderWrapper(contact, invoice, paymentPlan, estimateCount);

        // If contact was found for the user check on states and error messages.
        if (user.contactId != null) {
            hWrapper.messageInfo = getMessageInfo(hWrapper);
            hWrapper.balanceNoPaymentPlan = hasBalanceAndNotAddPaymentPlan(hWrapper);
            hWrapper.balanceHasPaymentPlan = hasPaymentPlanInGoodStanding(hWrapper);
            hWrapper.balanceDueOrError = balanceDueOrError(hWrapper);
            hWrapper.isInstallAmountView = onPaymentPlan(hWrapper);
        }

        return hWrapper;
    }

    /**
     * Get the UserWrapper for the current user.
     *
     * @returns UserWrappper - The UserWrapper for the current user.
     */
    @AuraEnabled
    public static UserWrapper getUserInfo() {
        return UserService.getCurrentUser();
    }

    /**
     * Populate the message info based on the HeaderWrapper status.
     *
     * @returns String - The string with messages related to any detected error conditions.
     */
    @TestVisible
    private static String getMessageInfo(HeaderWrapper headerWrapper) {
        String messageInfo = '';

        // Guanator overdue or delinquent check.
        if (headerWrapper.getGuarantorStatus() == PortalConstants.GUARANTOR_STATUS_OVERDUE) {
            messageInfo = WARNING_MESSAGE;
        } else if (headerWrapper.getGuarantorStatus() == PortalConstants.GUARANTOR_STATUS_DELINQUENT) {
            messageInfo = DELINQUENT_MESSAGE;
        }

        if (headerWrapper.hasPaymentPlan() && headerWrapper.getPaymentPlanStanding() == PortalConstants.PAST_DUE) {

            messageInfo += PASTDUE_MESSAGE;
            if (headerWrapper.getPaymentPlanType() == PortalConstants.MANUAL) { // Manual Past Due
                messageInfo += PASTDUE_MANUAL_MESSAGE;
            }
        }

        // Case of an automatic payment plan with an in error Standing.
        if (headerWrapper.getPaymentPlanActive() && headerWrapper.getPaymentPlanType() == PortalConstants.AUTOMATIC
            && headerWrapper.getPaymentPlanStanding() == PortalConstants.IN_ERROR) {
            messageInfo += ERROR_MESSAGE;
        }

        return messageInfo;
    }

    /**
     * Check for the state where the user has a balance but no add to payment plan.
     *
     * @returns Boolean - True if condition is met, false otherwise.
     */
    @TestVisible
    private static Boolean hasBalanceAndNotAddPaymentPlan(HeaderWrapper headerWrapper) {
        return hasBalance(headerWrapper) && !headerWrapper.hasAddToPaymentPlan();
    }

  /**
   * Check for the state where the user has a balance and add to payment plan.
   *
   * @returns Boolean - True if condition is met, false otherwise.
   */
    @TestVisible
    private static Boolean hasBalanceAndAddPaymentPlan(HeaderWrapper headerWrapper) {
        return hasBalance(headerWrapper) && headerWrapper.hasAddToPaymentPlan();
    }

  /**
     * User has a balance and is on a payment plan in good standing.
     *
     * @returns Boolean - True if condition is met.
     */
    @TestVisible
    private static Boolean hasPaymentPlanInGoodStanding(HeaderWrapper headerWrapper) {
        return hasBalanceAndAddPaymentPlan(headerWrapper)
            && headerWrapper.hasPaymentPlan()
            && headerWrapper.getPaymentPlanStanding() == PortalConstants.PLANTYPE_GOOD_STANDING;
    }

    /**
     * Check for the state where the user has a balance and a payment plan in good standing.
     *
     * @returns Boolean - True if condition is met, false otherwise.
     */
    @TestVisible
    private static Boolean balanceDueOrError(HeaderWrapper headerWrapper) {
        return onPaymentPlan(headerWrapper)
            || (headerWrapper.hasPaymentPlan() && headerWrapper.getPaymentPlanStanding() != PortalConstants.PLANTYPE_GOOD_STANDING);
    }

  /**
   * Is the user on a payment plan.
   *
   * @returns Boolean - True if the users is on
   */
    @TestVisible
    private static Boolean onPaymentPlan(HeaderWrapper headerWrapper) {
        return hasBalanceAndAddPaymentPlan(headerWrapper) || headerWrapper.getGuarantorStatus() == PortalConstants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
    }

  /**
   * Utiltiy to deteremine if the HeaderWrapper data indicates that the user has an owned balance.
   *
   * @params HeaderWrapper headerWrapper - The headerWrapper.
   * @returns Boolean - True is the user is in a state that indicates having a balance that is in in the State indicating
   * it should be paid.
   */
    private static Boolean hasBalance(HeaderWrapper headerWrapper) {
        return PortalConstants.GuarantorStatusOverdue.contains(headerWrapper.getGuarantorStatus());
    }

}