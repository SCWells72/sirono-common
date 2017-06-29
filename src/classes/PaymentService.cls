/**
 * Payment Service with logic for working with Payment__c object.
 */
public class PaymentService extends AbstractService {
    // Constant variable.
    public static final String PAYMENTNAME = 'Payment';

    @TestVisible
    private class PaymentRestClient extends SironoRestClient {

        /**
         * Provides the URL map to the HttpSirono class for looking up urls.
         */
        @TestVisible
        private Map<String, String> getUrls() {
            return RestClientConstants.PAYMENT_URLS;
        }

        /**
         * Make the call to pay on the given chargegroups
         *
         * @param - String planId The sirono id of the payment plan
         * @param - List<String> chargeGroupIds List of sironoIds of the charge groups to add
         * @returns - HttpResponse The response to the call.
         */
        @TestVisible
        private HttpResponse payChargeGroups(PaymentRequest pmtRequest) {

            return postRequestor()
                    .url(RestClientConstants.PAY_CHARGEGROUPS_KEY, new String[] {})
                    .body(buildPayChargeGroupsBody(pmtRequest))
                    .call();

        }

        /**
         * Get the payment transactions by paymentId from the sirono server.
         *
         * @param - String paymentId The sirono id for the payment.
         * @returns - HttpResponse The response to the call.
         */
        @TestVisible
        private HttpResponse getPaymentTransactions(String paymentId) {

            return getRequestor()
                    .url(RestClientConstants.PAYMENT_TXNS_KEY, new String[]{
                            stripCommas(paymentId)
                    })
                    .call();

        }

        /**
         * Build the JSON structure required to make a payment
          *
          * @param - PaymentRequestData
          * @return - String The Json payload.
         */
        //TODO make the keys constants
        @TestVisible
        private String buildPayChargeGroupsBody(PaymentRequest pmtRequest) {

            List<String> cgUrls = new List<String>();
            for (Charge_Group__c cg : pmtRequest.chargeGroups) {
                cgUrls.add(asChargeGroupURL(cg.Sirono_ID__c.toPlainString()));
            }

            Map<String, Object> rawData = new Map<String, Object>{
                    RestClientConstants.CHARGE_GROUPS => cgUrls,
                    RestClientConstants.CSRF_JSON_KEY => getCsrf(),
                    'guarantor' => asGuarantorURL(pmtRequest.guarantor.Profile_Pointer_ID__c.toPlainString()),
                    'number' => pmtRequest.chargeInfo.creditCardNumber,
                    'expiration_year' => pmtRequest.chargeInfo.expirationYear,
                    'cvv' => pmtRequest.chargeInfo.cvv,
                    'amount' => convertToCents(pmtRequest.chargeInfo.amount),
                    'expiration_month' => pmtRequest.chargeInfo.expirationMonth,
                    'cardholder_name' => pmtRequest.chargeInfo.cardHolderName,
                    'state' => pmtRequest.chargeInfo.state,
                    'address_1' => pmtRequest.chargeInfo.address,
                    'zipcode' => pmtRequest.chargeInfo.zip,
                    'city' => pmtRequest.chargeInfo.city,
//This doesn't appear to be required - remove and confirm
//                    'total-amount' => convertToCents(data.amount),
                    'method' => 'credit'
            };

            String body = JSON.serializePretty(rawData);
            System.debug('buildPayChargeGroupBody: '+body);
            return body;
        }
    }

    private class PaymentSironoJSON {
        String url;
        String guarantor;
        Integer amount;
        String transaction_number;
        String payment_date;
        String method;
        String last_4;
        String processor_transaction_id;
        String receipt_link;
        String payment_info;
        String payment_type;
        String account_number;
        String routing_number;
        String bank_account_type;
        String is_voidable;
        String post_date;
    }

    public class PaymentJSONParser extends AbstractSironoJSONParser {
        private String json;
        @TestVisible
        private PaymentSironoJSON objJson;

        @TestVisible
        PaymentJSONParser(String jsonBody) {
            if (jsonBody.startsWith('[')){
                System.debug('PaymentJSONParser jsonBody: ' + jsonBody);
                json = jsonBody.substring(1);
                if (json.endsWith(']'))
                    json = json.substring(0, json.lastIndexOf(']'));
            } else {
                this.json = jsonBody;
            }

            this.objJson = (PaymentSironoJSON) System.JSON.deserialize(json, PaymentSironoJSON.class);
        }

        @TestVisible
        private Payment__c parse(Contact gt) {

            Payment__c paymentObj = new Payment__c(Guarantor__c = gt.Id);

            if (!String.isBlank(objJson.url)) {
                String pmtIdStr = parseSironoId(objJson.url, 'payments');
                if (!String.isBlank(pmtIdStr)) {
                    paymentObj = PaymentDao.getPaymentBySironoId(Decimal.valueOf(pmtIdStr));
                    if (paymentObj == null) {
                        paymentObj = new Payment__c();
                        paymentObj.Sirono_ID__c = Decimal.valueOf(pmtIdStr);
                    }
                }
            } else {
                //TODO Service-specific exception
                throw new SironoServiceException('Invalid JSON returned - no payment id');
            }

            String guarantorSironoId = parseSironoId(objJson.guarantor, 'guarantors');

            Contact guarantorContact = GuarantorService.getGuarantorBySironoId(guarantorSironoId);
            paymentObj.Guarantor__c = guarantorContact.Id;

            if (!String.isBlank(objJson.payment_date)) {
                paymentObj.Charge_Date__c = parseDate(objJson.payment_date);
                paymentObj.Deposit_Date__c = parseDate(objJson.payment_date);
            }
            paymentObj.Method__c = objJson.method;
            paymentObj.Last_4__c = objJson.last_4;
            paymentObj.Processor_Transaction_ID__c = objJson.processor_transaction_id;
            paymentObj.Amount__c = convertToDollars(objJson.amount);

            return paymentObj;
        }
    }

    private class TransactionSironoJSON {
        String url;
        Integer amount;
        String post_date;
        String fail_date;
        String export_date;
        String created_at;
        String modified_at;
        String method;
        String notes;
        Boolean credit_balance;
        String payment;
        String chargegroup;
    }

    private class TransactionJSONParser extends AbstractSironoJSONParser {
        String json;
        List<TransactionSironoJSON> txnJsons;
        Payment__c payment;
        //Resulting list of Transaction__c objects
        List<Transaction__c> transactions = new List<Transaction__c>();
        //Map of ChargeGroup Sirono Id => txn
        Map<Decimal, Transaction__c> cgIdTxnMap = new Map<Decimal, Transaction__c>();

        @TestVisible
        TransactionJSONParser(Payment__c newPayment, String jsonBody) {
            this.payment = newPayment;
            this.json = SironoRestClient.ensureJsonList(jsonBody.replace('_credit_balance','credit_balance'));

            txnJsons = (List<TransactionSironoJSON>) System.JSON.deserialize(json, List<TransactionSironoJSON>.class);
        }

        private void createTransactionObjects() {
            for (TransactionSironoJSON txnJson : txnJsons) {
                Transaction__c txnObj = new Transaction__c();
                txnObj.Payment__r = new Payment__c(Sirono_ID__c=payment.Sirono_ID__c);
                String transactionExternalId = parseSironoId(txnJson.url, 'transaction');

                txnObj.Sirono_ID__c = Decimal.valueOf(transactionExternalId);
                txnObj.Amount__c = -1.00 * convertToDollars(txnJson.amount);
                if (!String.isBlank(txnJson.post_date)) {
                    txnObj.Post_Date__c = Date.valueOf(txnJson.post_date);
                }
                if (!String.isBlank(txnJson.fail_date)) {
                    txnObj.Fail_Date__c = Date.valueOf(txnJson.fail_date);
                }
                if (!String.isBlank(txnJson.export_date)) {
                    txnObj.Export_Date__c = Date.valueOf(txnJson.export_date);
                }
                txnObj.Credit_Balance__c = txnJson.credit_balance;

                if (txnJson.chargegroup != null) {
                    Decimal cgSironoId = Decimal.valueOf(parseSironoId(txnJson.chargegroup, 'chargegroups'));
                    cgIdTxnMap.put(cgSironoId, txnObj);
                }

                transactions.add(txnObj);
            }
        }

        private void resolveChargeGroups() {
            List<Decimal> cgSironoIds = new List<Decimal>(cgIdTxnMap.keySet());

            List<Charge_Group__c> chargeGroups = ChargeGroupDao.getBySironoIds(cgSironoIds);
            for (Charge_Group__c cg : chargeGroups) {
                cgIdTxnMap.get(cg.Sirono_ID__c).Charge_Group__c =cg.Id;
            }
        }

        @TestVisible
        private List<Transaction__c> parse() {
            if (txnJsons.isEmpty()) {
                return transactions;
            }

            createTransactionObjects();
            resolveChargeGroups();

            return transactions;
        }
    }

    /**
     * Make a payment for one or more chargegroups
     * This is a two-step process:
     *  1) Make the payment in Sirono
     *  2) Retrieve the resulting transactions for that payment
     *  3) Save the Payment & txns to SF
     *
     * @param PaymentsRequestData pmtRequest - the data needed to make a payment for chargegroups
     */
    public static Payment__c makePayment(PaymentRequest pmtRequest) {
        if (pmtRequest == null){
            throw new SironoServiceException('Valid PaymentRequestData is required');
        }

        List<String> errors = pmtRequest.validate();
        if (!errors.isEmpty()) {
            throw new SironoServiceException('Invalid PaymentRequest data: ' + String.join(errors, '\n '));
        }

        Payment__c newPayment = makeSironoPayment(pmtRequest);
        List<Transaction__c> transactions = retrieveSironoTransactions(newPayment);

        savePaymentAndTransactions(newPayment, transactions);

        return newPayment;
    }

    private static void savePaymentAndTransactions(Payment__c payment, List<Transaction__c> transactions) {
        List<SObject> pmtAndTxns = new List<SObject>{payment};
        pmtAndTxns.addAll((List<SObject>) transactions);
        PaymentDao.insertPaymentAndTransactions(pmtAndTxns);
    }

    private static Payment__c makeSironoPayment(PaymentRequest pmtRequest) {
        PaymentRestClient client = new PaymentRestClient();
        HttpResponse response = client.payChargeGroups(pmtRequest);
        PaymentJSONParser parser = new PaymentJSONParser(response.getBody());
        return parser.parse(pmtRequest.guarantor);
    }

    private static List<Transaction__c> retrieveSironoTransactions(Payment__c newPayment){
        PaymentRestClient client = new PaymentRestClient();
        HttpResponse response = client.getPaymentTransactions(newPayment.Sirono_ID__c.toPlainString());
        TransactionJSONParser txnParser = new TransactionJSONParser(newPayment, response.getBody());
        return txnParser.parse();
    }

    /**
     * This method is used to Create/Insert Payment record based on Encounter, Contact and Amount.
     * @param String paymentName - name of the payment
     * @param String guarantorRecordId - id of the guarantor record
     * @param Decimal amount - payment amount
     * @param String selectedEncounterId - id of the encounter record
     * @param Datetime depositeDate - payment deposite date
     * @param String paymentMethod - payment method
     **/
    public static Payment__c createNewPayment(String guarantorRecordId, Decimal amount, String selectedEncounterId, Datetime depositeDate, String paymentMethod) {
        // Initialize new Payment record
        Payment__c payment = new Payment__c(
            Name = PAYMENTNAME,
            Guarantor__c = guarantorRecordId,
            Amount__c = amount,
            Encounter__c = selectedEncounterId,
            Deposit_Date__c = depositeDate,
            Method__c = paymentMethod
        );
        // Insert new Payment record
        PaymentDao.insertPayment(new List<Payment__c>{payment});
        return PaymentDao.getPayment(payment.Id);
    }

    /**
     * Get a list of Payment_Method__c object for a Guarantor.
     *
     * @param Id guarantorid - The Guarantor Id.
     * @return List<Payment_Method__c> - The list of payment methods associated with the Guarantor.
     */
    public static List<Payment_Method__c> getPaymentMethods(Id guarantorId) {
        return PaymentDao.getPaymentMethods(guarantorId);
    }

    /**
     * Get a credit card by id.
     *
     * @param String cardId - The credit card id.
     * @return Payment_Method__c - The credit card Payment_Method__c object.
     */
    public static Payment_Method__c getCreditCard(String cardId) {
        List<Payment_Method__C> cards = PaymentDao.getCreditCard(cardId);
        return (!cards.isEmpty()) ? cards[0] : null;
    }

    public static Payment_Plan__c getActivePaymentPlan(Id guarantorId) {
        List<Payment_Plan__c> plans = PaymentDao.getActivePaymentPlan(guarantorId);
        return (!plans.isEmpty()) ? plans[0] : null;
    }

    public static Payment_Plan__c getPaymentPlan(Id planId) {
        List<Payment_Plan__c> plans = PaymentDao.getPaymentPlan(planId);
        return (!plans.isEmpty()) ? plans[0] : null;
    }
}