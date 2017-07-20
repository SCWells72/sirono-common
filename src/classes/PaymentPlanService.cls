/**
 * Aggregate PaymentPlan services - access to/from the Sirono server & SOQL requests
 */

public with sharing class PaymentPlanService extends AbstractService {

    @TestVisible
    private class PaymentPlanRestClient extends SironoRestClient {

        /**
         * Provides the URL map to the HttpSirono class for looking up urls.
         */
        @TestVisible
        private Map<String, String> getUrls() {
            return RestClientConstants.PAYMENT_PLAN_URLS;
        }

        /**
         * Make the call to get a Payment Plan.
         *
         * @param String sironoPlanId - The plan id in Sirono.
         * @return HttpResponse - The response from the service.
         */
        @TestVisible
        private HttpResponse retrievePaymentPlan(String sironoPlanId) {
            return getRequestor()
                .url(RestClientConstants.PAYMENT_PLAN_KEY, new String[] {sironoPlanId})
                .call();
        }

        /**
         * Make the call to add a Payment plan.
         *
         * @param - String planId The sirono id of the payment plan
         * @param - List<String> chargeGroupIds List of sironoIds of the charge groups to add
         * @return - HttpResponse The response to the call.
         */
        @TestVisible
        private HttpResponse addToPlan(String planId, List<String> chargeGroupIds) {

            return postRequestor()
                    .url(RestClientConstants.ADD_CHARGEGROUP_KEY, new String[] {stripCommas(planId)})
                    .body(buildAddToPaymentPlanBody(chargeGroupIds))
                    .call();

        }

        /**
         * Make the call to add a Credit Card/Payment Plan.
         *
         * @param PaymentPlanInformation ppInfo - An object that holds the information required to create a payment plan.
         * @return HttpResponse The response to the call.
         **/
        @TestVisible
        private HttpResponse createPaymentPlan(PaymentPlanInformation ppInfo) {

            return postRequestor()
                    .url(RestClientConstants.ADD_PAYMENTPLAN_KEY, new String[] {})
                    .body(buildCreatePaymentPlanBody(ppInfo))
                    .call();
        }


        /**
         * Make the call to update a Payment plan.
         *
         * @param String sironoPaymentPlanId - The id of the Payment Plan to update.
         * @param PaymentPlanInformation ppInfo - An object that holds the information required to update a payment plan.
         * @return HttpResponse The response to the call.
         **/
        private HttpResponse updatePaymentPlan(String sironoPaymentPlanId, PaymentPlanInformation ppInfo) {

            return patchRequestor()
                .url(RestClientConstants.PAYMENT_PLAN_KEY, new String[] {sironoPaymentPlanId})
                .body(buildUpdatePaymentPlanBody(ppInfo))
                .call();
        }

        @TestVisible
        /**
         * Delete a payment plan in Sirono.
         *
         * @param String sironoPaymentPlanId - The Payment Plan Sirono id.
         * @return HttpResponse - The reponse from the call.
         */
        private HttpResponse deletePaymentPlan(String sironoPaymentPlanId) {

            return deleteRequestor()
                .url(RestClientConstants.PAYMENT_PLAN_KEY, new String[] {sironoPaymentPlanId})
                .call();
        }

        /**
         * Get the payment plan by id from the sirono server.
         *
         * @param - String planId The sirono id for the payment plan.
         * @return - HttpResponse The response to the call.
         */
        @TestVisible
        private HttpResponse getPlan(String planId) {

            return getRequestor()
                    .url(RestClientConstants.PAYMENT_PLAN_KEY, new String[]{stripCommas(planId)})
                    .call();

        }

        /**
         * Build the JSON structure required for the payment plan post.
          *
          * @param - String chargeGroupId  The charge group Id.
          * @return - String The Json payload.
         */
        @TestVisible
        private String buildAddToPaymentPlanBody(List<String> chargeGroupIds) {
            List<String> cgUrls = new List<String>();
            for (String chargeGroupId : chargeGroupIds) {
                cgUrls.add(asChargeGroupURL(chargeGroupId));
            }

            Map<String, Object> rawData = new Map<String,Object>{
                    RestClientConstants.CHARGE_GROUPS => cgUrls,
                    RestClientConstants.CSRF_JSON_KEY => getCsrf()
            };

            String body = JSON.serializePretty(rawData);
            //System.debug('buildAddToPaymentPlanBody: '+body);
            return body;
        }
        
        /**
         * Build the JSON structure required for the Create Payment Plan post.
         *
         * @param PaymentPlanInformation ppInfo - It as an object that holds the information required to create a payment plan.
         * @return String body - The Json payload.
         **/
        @TestVisible
        private String buildCreatePaymentPlanBody(PaymentPlanInformation ppInfo) {
            List<String> cgUrls = new List<String>();
            for (String chargeGroupId: ppInfo.chargeGroupIds) {
                cgUrls.add(asChargeGroupURL(chargeGroupId));
            }
            
            Map<String, Object> rawData = new Map<String,Object>{                    
                    RestClientConstants.CSRF_JSON_KEY => getCsrf(),
                    'plan_type' => ppInfo.planType,
                    'plan_value' => ppInfo.planValue,
                    'installment_amount' => convertToCents(ppInfo.amount),                    
                    RestClientConstants.CHARGE_GROUPS => cgUrls,
                    'guarantor' => asGuarantorURL(ppInfo.guarantorId),
                    'active' => 'true'
            };

            if (ppInfo.planType.trim().equalsIgnoreCase(Constants.PLANTYPE_AUTO)) {
                rawData.put('execute_on_day', ppInfo.executeOnDay);
                rawData.put('credit_card', new Map<String, Object> {
                    'method' => 'credit',
                    'cardholder_name' => ppInfo.cardholderName,
                    'expiration_year' => ppInfo.expirationYear,
                    'expiration_month' => ppInfo.expirationMonth,
                    'number' => ppInfo.creditCardNumber,
                    'cvv' => ppInfo.cvv,
                    'state' => ppInfo.state,
                    'zipcode' => ppInfo.zip,
                    'address_1' => ppInfo.address,
                    'city' => ppInfo.city
                });
            }

            String body = JSON.serializePretty(rawData);
            return body;
        }

        /**
         * Build the JSON structure required for the Update Payment Plan post.
         *
         * @param PaymentPlanInformation ppInfo - It as an object that holds the information required to create a payment plan.
         * @return String body - The Json payload.
         **/
        @TestVisible
        private String buildUpdatePaymentPlanBody(PaymentPlanInformation ppInfo) {
            Map<String, Object> rawData = new Map<String,Object> {
                'plan_type' => ppInfo.planType,
                 RestClientConstants.CSRF_JSON_KEY => getCsrf(),
                'active' => 'true',
                'installment_amount' => convertToCents(ppInfo.amount)
            };

            if (ppInfo.planType.trim().equalsIgnoreCase(Constants.PLANTYPE_AUTO)) {
                rawData.put('execute_on_day', ppInfo.executeOnDay);
            }

            String body = JSON.serializePretty(rawData);
            return body;
        }
    }

    private class PaymentPlanSironoJSON {
        public String url;
        public Boolean active;
        public Integer installment_amount;
        public Integer number_installments;
        public Integer plan_value;
        public String plan_type;
        public Integer payable_amount;
        public Integer execute_on_day;
        public String guarantor;
        public String next_payment_date;
        public Integer installments_paid;
        public Integer installments_total;
        public Credit_Card credit_card;
        public Boolean has_error;
        public String charges_added_since_start;
        public String error_date;
        public List<String> chargegroups;
        public Boolean delinquent;
        public String delinquent_date;
        public List<Encounters> encounters;
        public Integer authorized_amount;
        public String skip_payment_until;
        public String status;
    }

    // This class only exists to be able to parse the Sirono JSON
    private class Encounters {
    }

    // This class only exists to be able to parse the Sirono JSON
    private class Credit_Card {
        public String card_type;
        public String last_4;
    }

    private class PaymentPlanWrapper {
        public List<Charge_Group__c> chargeGroupRecords {get; set;}
        public Payment_Plan__c paymentPlanRecord {get;set;}

        public PaymentPlanWrapper() {
            chargeGroupRecords = new List<Charge_Group__c>();
            paymentPlanRecord = new Payment_Plan__c();
        }
    }

    public class PaymentPlanJSONParser extends AbstractSironoJSONParser {
        @TestVisible
        PaymentPlanService.PaymentPlanJSONParser(String jsonBody) {
            this.json = jsonBody;
            this.objJson = (PaymentPlanSironoJSON) System.JSON.deserialize(json, PaymentPlanSironoJSON.class);
        }

        private String json;
        @TestVisible
        private PaymentPlanSironoJSON objJson;

        private PaymentPlanWrapper parse(List<String> sironoChargeGroupIds) {

            PaymentPlanWrapper objPaymentPlanWrapper = new PaymentPlanWrapper();
            Payment_Plan__c paymentPlanObj = parseAsPaymentPlan();

            Set<Decimal> chargeGroupIdSet = asDecimalSet(sironoChargeGroupIds);

            System.debug('chargeGroupIdSet' + chargeGroupIdSet);
            if (chargeGroupIdSet.isEmpty()) {
                System.debug('objJson.chargegroups' + objJson.chargegroups);
                for (String str : objJson.chargegroups) {
                    String strChargeGroupId = parseSironoId(str, 'chargegroups');
                    if (strChargeGroupId.isNumeric()) {
                        chargeGroupIdSet.add(Decimal.valueOf(strChargeGroupID));
                    }
                }
            }

            System.debug('chargeGroupIdSet' + chargeGroupIdSet);
            //Get SF chargeGroups & link to paymentPlan
            if (!chargeGroupIdSet.isEmpty()) {
                List<Charge_Group__c> chargeGroup = ChargeGroupService.getBySironoIds(new List<Decimal>(chargeGroupIdSet));
                for (Charge_Group__c objCG : chargeGroup) {
                    objCG.Payment_Plan__c = paymentPlanObj.ID;
                }
                objPaymentPlanWrapper.chargeGroupRecords = chargeGroup;
            }

            objPaymentPlanWrapper.paymentPlanRecord = paymentPlanObj;
            return objPaymentPlanWrapper;
        }

        /**
         * Parse the json string including the lookup for any charge gropus that were included as part of the result.
         *
         * @return PaymentPlanWrapper - The wrapper value of the Planment plan found in the json including any
         * charge groups.
         */
        private PaymentPlanWrapper parseWithChargeGroups() {
            return parse(this.objJson.chargegroups);
        }

        @TestVisible
        private Payment_Plan__c parseAsPaymentPlan() {

            Payment_Plan__c paymentPlanObj = new Payment_Plan__c();

            if (!String.isBlank(objJson.url)) {
                String strPaymentPlan = parseSironoId(objJson.url, 'paymentplan');
                if (!String.isBlank(strPaymentPlan)) {
                    paymentPlanObj = PaymentPlanDao.getPaymentPlanBySironoId(strPaymentPlan);
                    if (paymentPlanObj == null) {
                        paymentPlanObj = new Payment_Plan__c();
                        paymentPlanObj.Sirono_ID__c = Decimal.valueOf(strPaymentPlan);
                        paymentPlanObj.Name = strPaymentPlan;
                    }
                }
            } else { // VR: We thing else condition not needed because of URL Cannot be null in response. 
                //I don't really see how this is possible with valid JSON & if the JSON is not valid, we should have already puked
                paymentPlanObj = new Payment_Plan__c();
            }

            paymentPlanObj.Active__c = objJson.active;
            paymentPlanObj.Installment_Amount__c = convertToDollars(objJson.installment_amount);
            paymentPlanObj.Original_Installment_Count__c = objJson.number_installments;
            paymentPlanObj.Original_Balance__c = convertToDollars(objJson.plan_value);
            paymentPlanObj.Plan_Type__c = objJson.plan_type;
            if (objJson.plan_type == 'auto') {
                paymentPlanObj.Plan_Type__c = Constants.AUTOMATIC;
            } else if (objJson.plan_type == 'promise') {
                paymentPlanObj.Plan_Type__c = Constants.MANUAL;
            }

            paymentPlanObj.Remaining_Balance__c = convertToDollars(objJson.payable_amount);
            paymentPlanObj.Execute_on_Day__c = objJson.execute_on_day;
            paymentPlanObj.NextPaymentDate__c = parseDate(objJson.next_payment_date);
            paymentPlanObj.Skip_Payment_Until__c = parseDate(objJson.skip_payment_until);
            paymentPlanObj.Has_Error__c = objJson.has_error;
            paymentPlanObj.Error_Date__c = parseDate(objJson.error_date);
            paymentPlanObj.Delinquent__c = objJson.delinquent;
            paymentPlanObj.Delinquent_Date__c = parseDate(objJson.delinquent_date);
            paymentPlanObj.Status__c = objJson.status;

            String gtId = parseSironoId(objJson.guarantor, 'guarantors');
            Contact gt = GuarantorService.getGuarantorBySironoId(gtId);
            paymentPlanObj.Guarantor__c = gt.Id;

            return paymentPlanObj;
        }
    }

    /**
     * Call the sirono server to add the chargegroups to the payment plan & then
     * update the SF copy of the data
     *
     * @param - String planId  The Sirono id of the plan.
     * @param -  List<String> chargegroupIds  The Sirono ids of the chargeGroups to add.
     */
    public static void addChargeGroups(String planId,  List<String> chargegroupIds) {

        validatePlanId(planId);
        validateChargeGroupIds(chargegroupIds);

        PaymentPlanRestClient client = new PaymentPlanRestClient();
        client.addToPlan(planId, chargeGroupIds);

        client = new PaymentPlanRestClient();
        HttpResponse response = client.getPlan(planId);
        updateObjects(response.getBody(), chargegroupIds);
    }
    
    /**
     * Call the sirono server to add payment plan & then
     * insert/update the SF copy of the data.
     *
     * @param PaymentPlanInformation ppInfo - It as an object that holds the information required to create a payment plan.
     **/
    public static void addPaymentPlan(PaymentPlanInformation ppInfo) {
        validateChargeGroupIds(ppInfo.chargeGroupIds);

        PaymentPlanRestClient client = new PaymentPlanRestClient();
        HttpResponse response = client.createPaymentPlan(ppInfo);

        updateObjects(response.getBody(), ppInfo.chargeGroupIds);
    }

    /**
     * Call the sirono server to update auto payment plan & then
     * insert/update the SF copy of the data.
     *
     * @param String sironoPaymentPlanId - The id of the Payment Plan to update.
     * @param PaymentPlanInformation ppInfo - It as an object that holds the information required to create a payment plan.
     * @return Payment_Plan__c The updated payment plan.
     **/
    public static Payment_Plan__c updateAutoPaymentPlanTerms(String sironoPaymentPlanId, PaymentPlanInformation ppInfo) {

        if (ppInfo.planType != Constants.PLANTYPE_AUTO) {
            throw new ServiceException('This method only supports auto payment plans.');
        }

        PaymentPlanRestClient client = new PaymentPlanRestClient();
        HttpResponse response = client.updatePaymentPlan(sironoPaymentPlanId, ppInfo);
        return updatePaymentPlan(response.getBody());
    }

    /**
     * Add a new Payment Plan and associated Payment Method.
     *
     * @param PaymentPlanInformation ppInfo - Information object populated with initial values for Payment Plan.
     * @param Boolean persistPaymentMethod - Boolean that indicates if the Payment Method should be persisted in SF.
     * @param String guarantorId - The guarantor Id assoicated with the plan and payment method.
     */
    public static Payment_Plan__c addPaymentPlanWithPaymentMethod(PaymentPlanInformation ppInfo, Boolean persistPaymentMethod, String guarantorId) {
        addPaymentPlan(ppInfo);
        Payment_Method__c payMethod = PaymentMethodService.generatePaymentMethod(ppInfo, guarantorId);
        Payment_Plan__c payPlan = getActivePaymentPlanWithMethod(guarantorId);
        payPlan.Payment_Method__r = payMethod;

        if (persistPaymentMethod) {
            PaymentMethodDao.insertPaymentMethod(payMethod);
            payPlan.Payment_Method__c = payMethod.Id;
            PaymentPlanDao.upsertPlans(new List<Payment_Plan__c>{payPlan});
        }

        return payPlan;
    }

    /**
     * Call the Sirono service to delete a payment plan and updated all related SF objects.
     *
     * @param String paymentPlanId - The SF payment plan to delete.
     */
    public static void removePaymentPlan(String paymentPlanId) {
        // Look up the SF payment plan in ordr to get the Sirono Id.
        Payment_Plan__c payPlan = getPaymentPlan(paymentPlanId);
        if (payPlan == null) {
            System.debug('No payment plan found for id: ' + paymentPlanId);
            throw new ServiceException('No Payment Plan found.');
        }

        // Make the call to Sirono to delete the payment plan.
        String sironoPaymentPlanId = payPlan.Sirono_ID__c.toPlainString();
        PaymentPlanRestClient restClient = new PaymentPlanRestClient();
        restClient.deletePaymentPlan(sironoPaymentPlanId);

        // Now retrieve the payment plan from sirono in order to get the charge groups associated with the payment plan.
        PaymentPlanRestClient getRestClient = new PaymentPlanRestClient();
        HttpResponse getRes = getRestClient.retrievePaymentPlan(sironoPaymentPlanId);

        PaymentPlanJSONParser parser = new PaymentPlanJSONParser(getRes.getBody());
        PaymentPlanWrapper wrapper = parser.parseWithChargeGroups();

        // Update the SF object for the deleted plan.
        Payment_Plan__c deletedPlan = wrapper.paymentPlanRecord;
        deletedPlan.Active__c = false;
        deletedPlan.Cancellation_Date__c = System.today();

        // Go get the charge groups from the Sirono server in order to update the associated SF records.
        List<Charge_Group__c> cgs = wrapper.chargeGroupRecords;

        List<Decimal> cgSironoIds = ChargeGroupService.getSironoIds(cgs);
        // Get the charge groups from the Sirono service.
        Map<Decimal, ChargeGroupJSONParser> cgWrappers = ChargeGroupService.retrieveMapByIds(cgSironoIds);

        // Now update all SF cg records with the data from the Sirono server.
        for (Charge_Group__c cg: cgs) {
            if (cgWrappers.containsKey(cg.Sirono_ID__c)) {
                ChargeGroupJSONParser parsing = cgWrappers.get(cg.Sirono_ID__c);
                cg.Account_Sub_Status__c = parsing.account_sub_status;
                cg.Account_Status__c= parsing.account_status;
                cg.Payment_Plan__c = null;
            } else {
                System.debug('Did not find charge group to update on plan delete for sironoId: ' + cg.Sirono_ID__c);
                throw new ServiceException('Error occurred when looking up charge groups.');
            }
        }

        // Finally persist the SF PaymentPlan and ChargeGroups
        PaymentPlanDao.upsertPlan(deletedPlan);
        ChargeGroupService.updateChargeGroupsWithStatus(cgs);

    }

    /**
     * Return the payment plan for the given sironoId, null if there is none
     *
     * @param - String sironoId  The sironoId of the plan.
     * @return - Payment_Plan__c The active plan.
     **/
	public static Payment_Plan__c getPaymentPlanBySironoId(String sironoId){
		return PaymentPlanDao.getPaymentPlanBySironoId(sironoId);
	}

    /**
     * Return the payment plan for the given sironoId, null if there is none
     *
     * @param - Decimal sironoId  The sironoId of the plan.
     * @return - Payment_Plan__c The active plan.
     **/
	public static Payment_Plan__c getPaymentPlanBySironoId(Decimal sironoId){
		return PaymentPlanDao.getPaymentPlanBySironoId(sironoId);
	}

    private static void validatePlanId(String planId) {
        Payment_Plan__c pp = PaymentPlanDao.getPaymentPlanBySironoId(planId);
        if (pp == null) {
            throw new SironoServiceException('Unknown Payment Plan: '+planId);
        }
        //TODO check that the plan is active?
    }

    private static void validateChargeGroupIds(List<String> chargegroupIds) {
        Charge_Group__c[] cgs = ChargeGroupService.getBySironoIds(new List<Decimal>(AbstractSironoJSONParser.asDecimalSet(chargegroupIds)));

        System.debug('validateChargeGroupIds: ' + cgs);
        Map<String, Charge_Group__c> foundCGMap = new Map<String, Charge_Group__c>();
        for (Charge_Group__c cg : cgs) {
            foundCGMap.put(String.valueOf(cg.Sirono_ID__c), cg);
        }
        Set<String> unknownIds = new Set<String>();
        for (String cgId : chargegroupIds) {
            if (!foundCGMap.containsKey(cgId)) {
                unknownIds.add(cgId);
            }
        }
        if (!unknownIds.isEmpty()) {
            throw new SironoServiceException('Unknown chargegroup requested: '+String.join(new List<String>(unknownIds), ', '));
        }
    }

    /**
     * Parse the payment plan JSON and update the status and plan on the associated charge groups. Because we have
     * added charge_groups to the plan, the plan value has changed, so also set Plan_Value_Modified_Date__c.
     *
     * @param - String jsonStr  The JSON object return from the service call.
     * @param - List<String> chargegroupIds  The Sirono Ids of the chargegroups that were added/removed
     */
    private static void updateObjects(String jsonStr, List<String> chargegroupIds) {

        PaymentPlanJSONParser parser = new PaymentPlanJSONParser(jsonStr);
        PaymentPlanWrapper wrapper = parser.parse(chargegroupIds);

        Payment_Plan__c pmtPlan = upsertPaymentPlan(wrapper);

        List<Charge_Group__c> cgList = wrapper.chargeGroupRecords;
        //TODO this should move into a method like: ChargeGroupService.putOnPlan(pmtPlan, wrapper.chargeGroupRecords)
        for (Charge_Group__c cg : cgList) {
            cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
            cg.Payment_Plan__c = pmtPlan.Id;
        }

        ChargeGroupService.updateChargeGroups(cgList);
    }

    /**
     * Parse the response from the Sirono service and update the Payment Plan object returned.  This is used to process
     * the response from the update call to the Sirono service.
     *
     * @param String jsonStr - The JSON reponse from the http update request.
     * @return Payment_Plan__c - The updated Payment Plan.
     */
    private static Payment_Plan__c updatePaymentPlan(String jsonStr) {
        PaymentPlanJSONParser parser = new PaymentPlanJSONParser(jsonStr);
        PaymentPlanWrapper wrapper = parser.parse(new List<String>());

        return upsertPaymentPlan(wrapper);
    }

    /**
     * Upsert an existing Payment Plan.
     *
     * @param PaymentPlanWrapper wrapper - A payment plan wrapper.
     * @return Payment_Plan__c - The upserted Payment Plan.
     */
    private static Payment_Plan__c upsertPaymentPlan(PaymentPlanWrapper wrapper) {
        Payment_Plan__c pmtPlan = wrapper.paymentPlanRecord;
        pmtPlan.Plan_Value_Modified_Date__c = Datetime.now();
        PaymentPlanDao.upsertPlans(new Payment_Plan__c[]{pmtPlan});

        return pmtPlan;
    }

    /**
     * Return the active payment plan for the given guarantorId, null if there is none
     *
     * @param - String guarantorId  The guarantorId of the plan.
     * @return - Payment_Plan__c The active plan.
     **/
    public static Payment_Plan__c getActivePaymentPlan(String guarantorId) {
        return PaymentPlanDao.getActivePaymentPlan(guarantorId);
    }

    /**
     * Get Active PaymentPlan and assoicated payment methods.
     *
     * @param Id guarantorId - The plan owner.
     * @return Payment_Plan__c - The payment plan. null if no payment plan was found.
     */
    public static Payment_Plan__c getActivePaymentPlanWithMethod(Id guarantorId) {
        List<Payment_Plan__c> plans = PaymentPlanDao.getActivePaymentPlanWithMethod(guarantorId);
        return (!plans.isEmpty()) ? plans[0] : null;
    }

    /**
     * Get a payment plan by id.
     *
     * @param Id planId - The plan id.
     * @return Payment_Plan__c - The payment plan. null if no payment plan was found.
     */
    public static Payment_Plan__c getPaymentPlan(Id planId) {
        List<Payment_Plan__c> plans = PaymentPlanDao.getPaymentPlan(planId);
        return (!plans.isEmpty()) ? plans[0] : null;
    }

    /**
     * Update the Payment_Method__c on a payment plan.
     *
     * @param String planId - The payment plan id.
     * @param String creditCardId - The credit card id. Empty string for a new credit card.
     * @param PaymentPlanInformation paymentInfo - The payment plan information object.
     * @param Boolean persistPaymentMethod - If true the generated Payment_Method__c to be saved as well as the payment plan updated.
     */
    public static Payment_Plan__c addPaymentMethod(String planId, String creditCardId, PaymentPlanInformation paymentInfo, Boolean persistPaymentMethod) {
        Payment_Plan__c payPlan = getPaymentPlan(planId);
        Payment_Method__c payMethod = null;

        if (String.isBlank(creditCardId)) {
            payMethod = PaymentMethodService.generatePaymentMethod(paymentInfo, payPlan.Guarantor__c);
        } else {
            payMethod = PaymentMethodService.getCreditCard(creditCardId);
        }

        payPlan.Payment_Method__r = payMethod;

        if (persistPaymentMethod) {
            // If this is a new paymentMethod save it.
            if (payMethod.Id == null) {
                PaymentMethodDao.insertPaymentMethod(payMethod);
            }
            payPlan.Payment_Method__c = payMethod.Id;
            PaymentPlanDao.upsertPlans(new List<Payment_Plan__c>{payPlan});
        }

        return payPlan;
    }

    //TODO this is just here until ProcessPaymentLightning can be removed
    public static String convertToCents(String amount) {
        return SironoRestClient.convertToCents(amount);
    }

}
