/**
 * Controller for the Lightning Header that loads information about the user.
 */
public with sharing class HeaderController {

  public static String WARNING_MESSAGE = 'Your account has overdue invoices. Please pay the balance now or set up a payment plan to avoid becoming delinquent.\n If you have any questions about the bill, please contact the Customer Service Center at ' + Label.Customer_Service_Center_Phone + '.';
  public static String DELINQUENT_MESSAGE = 'This account has delinquent invoices. Delinquent invoices will be sent to a collection agency if payment arrangements are not made within the next 30 days. Please pay the balance now or set up a payment plan.';
  public static String PASTDUE_MESSAGE = ' We have not received your latest payment plan installment. Please pay your previous installment amount now or pay your account in full to avoid payment plan cancellation.';
  public static String PASTDUE_MANUAL_MESSAGE = ' We have not received your latest payment plan installment. Please pay your previous installment amount now or pay your account in full to avoid payment plan cancellation. If you have any questions about the bill, call the Customer Service Center at ' + Label.Customer_Service_Center_Phone + '.';
  public static String ERROR_MESSAGE = ' Your latest payment plan installment failed. Please update your payment method or pay your previous installment amount now to keep your account current.';

	/**
	 * Gather all information reqiured for loading the portal.
	 *
	 * @returns GuarantorWrapper - A populated GuarantorWrapper.
	 */
  @AuraEnabled
  public static GuarantorWrapper getAllHeaderInfo() {
    UserWrapper user = getUserInfo();
    Contact contact;
    List<Invoice__c> invoices = new List<Invoice__c>();
    Payment_Plan__c paymentPlan = new Payment_Plan__c();
    Integer estimateCount = null;

    if (user.contactId != null) {
      contact = GuarantorService.getContactsForLightning(new Set<Id>{
          user.contactId
      })[0];
      invoices = InvoiceService.getByStatus(user.contactId, Constants.DUE);
      paymentPlan = PaymentPlanService.getActivePaymentPlan(user.contactId);
      estimateCount = EncounterService.getCountByDate(user.contactId, Datetime.now().addDays(-30));
    }

    Invoice__c invoice = (invoices.size() > 0) ? invoices[0] : new Invoice__c();

    Guarantorwrapper gWrapper = new GuarantorWrapper(contact, invoice, paymentPlan, estimateCount);

    // If contact was found for the user check on states and error messages.
    if (user.contactId != null) {
      gWrapper.messageInfo = getMessageInfo(gWrapper);
      gWrapper.balanceNoPaymentPlan = hasBalanceNoPaymentPlan(gWrapper);
      gWrapper.balanceHasPaymentPlan = hasBalanceAndPaymentPlan(gWrapper);
      gWrapper.balanceDueOrError = balanceDueOrError(gWrapper);
      gWrapper.isInstallAmountView = isInstallAmountview(gWrapper);
    }

    return gWrapper;
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
	 * Populate the message info based on the GuarantorWrapper status.
	 *
	 * @returns String - The string with messages related to any detected error conditions.
	 */
  private static String getMessageInfo(GuarantorWrapper guarantorWrapper) {
    String messageInfo;

    // Guanator overdue or delinquent check.
    if (guarantorWrapper.contact.Guarantor_Status__c == Constants.GUARANTOR_STATUS_OVERDUE) {
      messageInfo = WARNING_MESSAGE;
    } else if (guarantorWrapper.contact.Guarantor_Status__c == Constants.GUARANTOR_STATUS_DELINQUENT) {
      messageInfo = DELINQUENT_MESSAGE;
    }

    if (guarantorWrapper.paymentPlan.Active__c && guarantorWrapper.paymentPlan.Payment_Plan_Standing__c == Constants.PAST_DUE) {

      if (guarantorWrapper.paymentPlan.Plan_Type__c == Constants.AUTOMATIC) { // Automatic Past Due
        messageInfo += PASTDUE_MESSAGE;
      } else if (guarantorWrapper.paymentPlan.Plan_Type__c == Constants.MANUAL) { // Manual Past Due
        messageInfo += PASTDUE_MANUAL_MESSAGE;
      }
    }

    // Case of an automatic payment plan with an in error Standing.
    if (guarantorWrapper.paymentPlan.Active__c && guarantorWrapper.paymentPlan.Plan_Type__c == Constants.AUTOMATIC
        && guarantorWrapper.paymentPlan.Payment_Plan_Standing__c == Constants.IN_ERROR) {
      messageInfo += ERROR_MESSAGE;
    }

    return messageInfo;
  }

	/**
	 * Check for the state where the user has a balance but no payment plan.
	 *
	 * @returns Boolean - True if condition is met, false otherwise.
	 */
  private static Boolean hasBalanceNoPaymentPlan(GuarantorWrapper guarantorWrapper) {
    return (Constants.GuarantorStatusOverdue.contains(guarantorWrapper.contact.Guarantor_Status__c)
        && guarantorWrapper.contact.Add_to_Payment_Plan__c == false);
  }

	/**
	 * Check for the state where the user has a balance and a payment plan.
	 *
	 * @returns Boolean - True if condition is met, false otherwise.
	 */
  private static Boolean hasBalanceAndPaymentPlan(GuarantorWrapper guarantorWrapper) {
    return ((isOverdueAndOnPaymentPlan(guarantorWrapper)
        || guarantorWrapper.contact.Guarantor_Status__c == Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN)
        && (guarantorWrapper.paymentPlan != null
        && guarantorWrapper.paymentPlan.Payment_Plan_Standing__c == Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN));
  }

	/**
	 * Check for the state where the user has a balance and a payment plan in good standing.
	 *
	 * @returns Boolean - True if condition is met, false otherwise.
	 */
  private static Boolean balanceDueOrError(GuarantorWrapper guarantorWrapper) {
    return ((isOverdueAndOnPaymentPlan(guarantorWrapper)
        || guarantorWrapper.contact.Guarantor_Status__c == Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN)
        && (guarantorWrapper.paymentPlan != null
        && guarantorWrapper.paymentPlan.Payment_Plan_Standing__c != Constants.PLANTYPE_GOOD_STANDING));
  }

	/**
	 * Show the installment amount view.
	 *
	 * @returns Boolean - True if it should be shown.
	 */
  private static Boolean isInstallAmountView(GuarantorWrapper guarantorWrapper) {
    return isOverdueAndOnPaymentPlan(guarantorWrapper)
        || guarantorWrapper.contact.Guarantor_Status__c == Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
  }

	/**
	 * Is the balance overdue and on a payment plan.
	 *
	 * @return Boolean - True if condition is met.
	 */
  private static Boolean isOverdueAndOnPaymentPlan(GuarantorWrapper guarantorWrapper) {
    return Constants.GuarantorStatusOverdue.contains(guarantorWrapper.contact.Guarantor_Status__c)
        && guarantorWrapper.contact.Add_to_Payment_Plan__c == true;
  }
}