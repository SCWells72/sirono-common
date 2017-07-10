/**
 * PaymentTabsController used by various Lightning components.
 */
public without sharing class PaymentTabsController {

    public static final String ADD_SUCCESS = 'Added Successfully!';
    public static final String NO_PPLAN_MSG = 'No active Payment Plan exist for this Guarantor. Please click Cancel to go previous page.';

    /**
     * Get the Map used to populate the credit card expiration month and year fields.
     *
     * @returns Map<String, Map<String, String>> - The expiration data valid values.
     */
    @AuraEnabled
    public static Map<String, Map<String, String>> getCardSelectOptions() {
        return UIUtils.getCardDateOptions();
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
        paymentInfo.addToPaymentAvail = guarantor.Add_to_Payment_Plan__c;
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
    public static Payment_Plan__c createPaymentPlan(Map<String, Object> ppInfoMap, Boolean isCreditCardSaved) {
        PaymentPlanInformation ppInfo = new PaymentPlanInformation(ppInfoMap);
        UserWrapper user = UserService.getCurrentUser();
        Payment_Plan__c paymentPlanObj = PaymentPlanService.addPaymentPlanWithPaymentMethod(ppInfo, isCreditCardSaved, user.contactId);
        return paymentPlanObj;
    }

    /**
     * Edit the current payment method on a payment plan.
     *
     * @param Map<String, Object> ppInfoMap - A map containing info about the payment plan and credit card.
     */
    @AuraEnabled
    public static Payment_Plan__c doEditPaymentMethod(Map<String, Object> ppInfoMap, Boolean isCreditCardSaved) {
        String planId = ppInfoMap.containsKey('id') ? String.valueOf(ppInfoMap.get('id')) : '';
        String creditCardId = ppInfoMap.containsKey('creditCardId') ? String.valueOf(ppInfoMap.get('creditCardId')) : '';

        if (String.isBlank(planId)) {
            throw new AuraHandledException('Payment Plan id must be provided.');
        }

        PaymentPlanInformation ppInfo = new PaymentPlanInformation(ppInfoMap);


        return PaymentPlanService.addPaymentMethod(planId, creditCardId, ppInfo, isCreditCardSaved);
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
        String sironoPaymentPlanId = ppInfoMap.containsKey('sironoPaymentPlanId') ? String.valueOf(ppInfoMap.get('sironoPaymentPlanId')) : '';

        if (String.isBlank(sironoPaymentPlanId)) {
            throw new AuraHandledException('sironoPaymentPlanId must be provided.');
        }
        try {
            paymentPlan = PaymentPlanService.updatePaymentPlanTerms(sironoPaymentPlanId, planInfo);
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return paymentPlan;

    }

    @AuraEnabled
    public static void deletePaymentPlan(String sfPaymentPlanId) {
        System.debug('deletePaymentPlan');
        Payment_Plan__c paymentPlan = PaymentPlanService.getPaymentPlan(sfPaymentPlanId);
        String guarantorId = paymentPlan.Guarantor__c;
        String paymentPlanExtId = String.valueOf(paymentPlan.Sirono_ID__c);

        //call Delete PaymentPlan and send the request to end point.
        if (String.isNotBlank(paymentPlanExtId)) {
            String jwtToken = PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
            String csrfToken = PayStaffWSUtill.getCSRFToken();
            if (csrfToken != null && jwtToken != null) {
                PaymentTabsController.doDeletePaymentPlan(csrfToken, jwtToken, guarantorId, paymentPlanExtId);
            }
        } else {
            throw new AuraHandledException('Payment Plan Id is missing.');
        }
    }

    /*Mohan Kumar 08-02-2016: Ticket # 06638015 -
     *Updated the request parameter value to send the Sirono External ID and NOT salesforce record Id.
     */
    private static void doDeletePaymentPlan(String csrfToken, String jwtToken, String guarantorId, String paymentPlanExtId) {
        PaymentPlanJSONParsing.PaymentPlanWrapper objPaymentPlanWrapper = PaymentTabsController.callPaymentPlanRequest(csrfToken, jwtToken, guarantorId, paymentPlanExtId);
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');

        HttpResponse res = new HttpResponse();
        String responseBody;
        try {
            res = new Http().send(req);
            responseBody = res.getBody();
            System.debug('responseBody:' + responseBody);
        } catch (Exception e) {
            throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + ' EXCEPTION:: ' + e.getMessage());
        }

        if (res.getStatusCode() != null && res.getStatusCode() == 204) {
            if (objPaymentPlanWrapper != null) {
                List<Charge_Group__c> chargeGroups = objPaymentPlanWrapper.chargeGroupRecords;
                objPaymentPlanWrapper = PaymentTabsController.callPaymentPlanRequest(csrfToken, jwtToken, guarantorId, paymentPlanExtId);
                Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
                paymentPlanObj = objPaymentPlanWrapper.paymentPlanRecord;
                paymentPlanObj.Active__c = false;
                paymentPlanObj.Cancellation_Date__c = System.today();

                Boolean hasError = false;
                for (Charge_Group__c cg : chargeGroups) {
                    hasError = PaymentTabsController.callChargeGroupRequest(String.valueof(cg.Sirono_ID__c), jwtToken, cg);
                }
                if (!hasError) {
                    UPDATE paymentPlanObj;
                    // Update the Charge Groups using ChargeGroupService.
                    ChargeGroupService.updateChargeGroupsWithStatus(chargeGroups);
                }
                return;
            }
        }

        throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
    }

    /*
    * 09-22-2016: Viraj Rana - Tracker #129177479
    *  Call the paymentplan Web Service to get the paymentplan information.
    */
    private static PaymentPlanJSONParsing.PaymentPlanWrapper callPaymentPlanRequest(String csrfToken, String jwtToken, String guarantorId, String paymentPlanExtId) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/paymentplan/' + PayStaffWSUtill.trimCommas(paymentPlanExtId) + '/');
        req.setTimeout(120000);

        String responseBody;
        HttpResponse res = new HttpResponse();
        try {
            res = new Http().send(req);
            responseBody = res.getBody();
        } catch (Exception e) {
            throw new AuraHandledException('ERROR: ' + e.getMessage());
        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            /*
            * 09-22-2016: Viraj Rana - Tracker # 129177479
            * parse the Payment Plan JSON and Make a new request to get the charge group detailsyment Plan
            */
            return PaymentPlanJSONParsing.createPaymentPlanRecord(responseBody, guarantorId, null, null);
        } else {
            throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
        }
        return null;
    }

    /*
    * 09-22-2016: Viraj Rana - Tracker # 129177479
    * make a Charge group Reqeuest to get the chargeGroupInformation
    */
    private static Boolean callChargeGroupRequest(String chargeGroupId, String jwtToken, Charge_Group__c cg) {
        System.debug('callChargeGroupRequest');
        Boolean hasError = false;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Authorization', 'JWT ' + jwtToken);
        req.setHeader('Content-type', 'application/json');
        req.setEndpoint(RestClientConstants.SIRONO_BASE_URL + '/paystaff/api/chargegroups/' + PayStaffWSUtill.trimCommas(chargeGroupId) + '/');
        req.setTimeout(120000);

        String responseBody;
        HttpResponse res = new HttpResponse();
        try {
            res = new Http().send(req);
            responseBody = res.getBody();
            System.debug('res:' + res);
            System.debug('responseBody:' + responseBody);
        } catch (Exception e) {
            throw new AuraHandledException('PROCESS PAYMENT EXCEPTION RESPONSE : ' + res.toString() + ' EXCEPTION:: ' + e.getMessage());
        }
        if (res.getStatusCode() != null && res.getStatusCode() == 200) {
            /*
            * 09-22-2016: Viraj Rana - Tracker # 129177479
            * parse the chargroup json and UPDATE the sub status
            * 10-12-2016: Viraj Rana - Tracker # 129177479
            * Update the Account_Sub_Status__c and Account_Status__c.
            */
            ChargeGroupJSONParsing objChargeGroup = ChargeGroupJSONParsing.parse(responseBody);
            cg.Account_Sub_Status__c = objChargeGroup.account_sub_status;
            cg.Account_Status__c = objChargeGroup.account_status;
            cg.Payment_Plan__c = null;
        } else {
            hasError = true;
            throw new AuraHandledException('RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody);
        }
        return hasError;
    }

    private static String getErrorMessage(String responseBody, HttpResponse res) {
        String errorMessage = '';
        if (responseBody.contains('non_field_errors') && responseBody.contains('Validation exception')) {
            JSONParser parser = JSON.createParser(responseBody);
            WrapperErrorArray wrpPaymentPlanobj = (WrapperErrorArray) parser.readValueAs(WrapperErrorArray .class);
            if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.size() > 0) {
                for (WrapperErrorArray.Errors obj : wrpPaymentPlanobj.errors) {
                    errorMessage += '\n' + obj.non_field_errors;
                }
            }
        } else if (responseBody.contains('non_field_errors') && responseBody.contains('Payments Exception')) {
            JSONParser parser = JSON.createParser(responseBody);
            WrapperError wrpPaymentPlanobj = (WrapperError) parser.readValueAs(WrapperError.class);
            if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.errors.non_field_errors.size() > 0) {
                for (String strMessage : wrpPaymentPlanobj.errors.non_field_errors) {
                    errorMessage += '\n' + strMessage;
                }
            }
        } else if (responseBody.contains('kind') && !responseBody.contains('chargegroups')) {
            JSONParser parser = JSON.createParser(responseBody);
            WrapperListError wrpobj = (WrapperListError) parser.readValueAs(WrapperListError.class);
            if (wrpobj != null && wrpobj.errors.size() > 0) {
                for (String strMessage : wrpobj.errors) {
                    errorMessage += '\n' + strMessage;
                }
            }
        }
        //else if (responseBody.contains('kind') && responseBody.contains('chargegroups'))
        //{
        //	errorMessage += '\n' + 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody;
        //}
        else if (responseBody.contains('non_field_errors')) {
            JSONParser parser = JSON.createParser(responseBody);
            WrapperNonFieldErrorArray wrpPaymentPlanobj = (WrapperNonFieldErrorArray) parser.readValueAs(WrapperNonFieldErrorArray.class);
            if (wrpPaymentPlanobj != null && wrpPaymentPlanobj.non_field_errors.size() > 0) {
                for (String strMessage : wrpPaymentPlanobj.non_field_errors) {
                    errorMessage += '\n' + strMessage;
                }
            }
        } else {
            errorMessage += '\n' + 'RESPONSE : ' + res.toString() + '  RESPONSE BODY::' + responseBody;
        }
        return errorMessage;
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

        if (user.contactId != null) {
            List<Charge_Group__c> allGroups = InvoiceService.getInvoicedChargeGroups(contactId, Constants.INVOICE_UNPAID_STATUSES, new List<String>());

            for (Charge_Group__c chgGroup: allGroups) {
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
     * @return List<MakeAPaymnetController.CardInformation> - The card objects.
     */
    @TestVisible
    private static List<MakeAPaymentController.CardInformation> getCreditCards(Id guarantorContactId) {

        List<MakeAPaymentController.CardInformation> cards = new List<MakeAPaymentController.CardInformation>();
        for (Payment_Method__c pCard: PaymentMethodService.getPaymentMethods(guarantorContactId)) {
            cards.add(new MakeAPaymentController.CardInformation(pCard));
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
        public List<MakeAPaymentController.CardInformation> creditCards {
            get;
            set;
        }

        public GuarantorPaymentInfo() {
            this.guarantor = new Contact();
            this.settings = new Sirono_Settings__c();
            this.hasPaymentPlan = false;
            this.addToPaymentAvail = false;
            this.chargeGroups = new List<Charge_Group__c>();
            this.creditCards = new List<MakeAPaymentController.CardInformation>();
        }
    }

    public class PaymentPlanRequestInfo {
        @AuraEnabled
        public String sfId {
            get;
            set;
        }
        @AuraEnabled
        public MakeAPaymentController.CardInformation creditCard {
            get;
            set;
        }
        @AuraEnabled
        public String paymentPlanId {
            get;
            set;
        }
        @AuraEnabled
        public Decimal totalAmount {
            get;
            set;
        }

        @AuraEnabled
        public Integer totalInstallments {
            get;
            set;
        }
        @AuraEnabled
        public Decimal planValue {
            get;
            set;
        }
        @AuraEnabled
        public Integer executeOnDay {
            get;
            set;
        }

        @AuraEnabled
        public String chargeGroupId {
            get;
            set;
        }
        @AuraEnabled
        public String sironoId {
            get;
            set;
        }
        @AuraEnabled
        public String contactId {
            get;
            set;
        }

        public PaymentPlanRequestInfo() {
            this.creditCard = new MakeAPaymentController.CardInformation();
        }
    }

    public class CreditCardInfo {
        @AuraEnabled
        public String sfId {
            get;
            set;
        }
        @AuraEnabled
        public String displayName {
            get;
            set;
        }
        @AuraEnabled
        public String cardType {
            get;
            set;
        }
        @AuraEnabled
        public String cardholderName {
            get;
            set;
        }
        @AuraEnabled
        public String expirationYear {
            get;
            set;
        }
        @AuraEnabled
        public String expirationMonth {
            get;
            set;
        }
        @AuraEnabled
        public String creditCardNumber {
            get;
            set;
        }
        @AuraEnabled
        public String cvv {
            get;
            set;
        }
        @AuraEnabled
        public String city {
            get;
            set;
        }
        @AuraEnabled
        public String state {
            get;
            set;
        }
        @AuraEnabled
        public String zip {
            get;
            set;
        }
        @AuraEnabled
        public String address {
            get;
            set;
        }
        @AuraEnabled
        public Boolean isSaved {
            get;
            set;
        }

        public CreditCardInfo() {
            this.isSaved = false;
            this.cardholderName = '';
            this.creditCardNumber = '';
            this.expirationYear = String.valueOf(Datetime.now().year());
            this.expirationMonth = String.valueOf(Datetime.now().month()).length() == 1 ? '0' + String.valueOf(Datetime.now().month()) : String.valueOf(Datetime.now().month());
            this.cvv = '';
            this.address = '';
            this.city = '';
            this.state = '';
            this.zip = '';
        }
        public CreditCardInfo(Payment_Method__c card) {
            this.sfId = card.Id;
            this.cardholderName = card.Card_Holder_Name__c;
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
}