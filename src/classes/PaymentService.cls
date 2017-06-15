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
         * Get the payment by id from the sirono server.
         *
         * @param - String paymentId The sirono id for the payment.
         * @returns - HttpResponse The response to the call.
         */
        @TestVisible
        private HttpResponse getPayment(String paymentId) {

            return getRequestor()
                    .url(RestClientConstants.PAYMENT_KEY, new String[]{
                            stripCommas(paymentId)
                    })
                    .call();

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
                    'number' => pmtRequest.creditCardNumber,
                    'expiration_year' => pmtRequest.expirationYear,
                    'cvv' => pmtRequest.cvv,
                    'amount' => convertToCents(pmtRequest.amount),
                    'expiration_month' => pmtRequest.expirationMonth,
                    'cardholder_name' => pmtRequest.cardHolderName,
                    'state' => pmtRequest.state,
                    'address_1' => pmtRequest.address,
                    'zipcode' => pmtRequest.zip,
                    'city' => pmtRequest.city,
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
        public String url;
        public String guarantor;
        public Integer amount;
        public String transaction_number;
        public String payment_date;
        public String method;
        public String last_4;
        public String processor_transaction_id;
        public String receipt_link;
        public String payment_info;
        public String payment_type;
        public String account_number;
        public String routing_number;
        public String bank_account_type;
        public String is_voidable;
        public String post_date;
    }

    public class PaymentJSONParser extends AbstractSironoJSONParser {
        private String json;
        @TestVisible
        private PaymentSironoJSON objJson;

        @TestVisible
        PaymentJSONParser(String jsonBody) {
            if (jsonBody.contains('[')){
                System.debug('PaymentJSONParser jsonBody: ' + jsonBody);
                json = jsonBody.replace('[','');
                json = json.replace(']','');
            } else {
                this.json = jsonBody;
            }

            this.objJson = (PaymentSironoJSON) System.JSON.deserialize(json, PaymentSironoJSON.class);
        }

        @TestVisible
        private Payment__c parse(Contact gt) {

            Payment__c paymentObj = new Payment__c(Guarantor__c = gt.Id);

            if (!String.isBlank(objJson.url)) {
                String pmtIdStr = parseSironoId(objJson.url, 'payment');
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

            //TODO remove this when we clean up the Payment__c object
            paymentObj.Name = parseSironoId(objJson.url,'payments');
            return paymentObj;
        }
    }

    private class TransactionSironoJSON {
        public String url;
        public Integer amount;
        public String post_date;
        public String fail_date;
        public String export_date;
        public String created_at;
        public String modified_at;
        public String method;
        public String notes;
        public Boolean credit_balance;
        public String payment;
        public String chargegroup;
    }

    public class TransactionJSONParser extends AbstractSironoJSONParser {
        private String json;
        @TestVisible
        List<TransactionSironoJSON> txnJsons;
        Payment__c pmt;
        //Resulting list of Transaction__c objects
        List<Transaction__c> transactions = new List<Transaction__c>();
        //Map of ChargeGroup Sirono Id => txn
        Map<Decimal, Transaction__c> cgIdTxnMap = new Map<Decimal, Transaction__c>();

        @TestVisible
        TransactionJSONParser(Payment__c payment, String jsonBody) {
            this.pmt = payment;
            this.json = jsonBody.replace('_credit_balance','credit_balance');

            if (!json.startsWith('[') || !json.endsWith(']')){
                System.debug('TransactionJSONParser jsonBody: ' + jsonBody);
                if(!json.endsWith(']')) {
                    json = json + ']';
                }

                if (!json.startsWith('[')) {
                    json = '[' + json;
                }
            }

            txnJsons = (List<TransactionSironoJSON>) System.JSON.deserialize(json, List<TransactionSironoJSON>.class);
        }

        private void createTransactionObjects() {
            for (TransactionSironoJSON txnJson : txnJsons) {
                Transaction__c txnObj = new Transaction__c();
                txnObj.Payment__c = pmt.Id;
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
     *  1) Make the payment in Sirono & save it to SF,
     *  2) Retrieve the resulting transactions for that payment, associate them with it, resolve their chargegroups &
     *  save them to SF
     *
     * @param PaymentsRequestData pmtRequest - the data needed to make a payment for chargegroups
     */
    public static Payment__c makePayment(PaymentRequest pmtRequest) {
        if (pmtRequest == null){
            throw new SironoServiceException('Valid PaymentRequestData is required');
        }

        List<String> errors = pmtRequest.validateCardData();
        errors.addAll(pmtRequest.validateAmount());
        if (!errors.isEmpty()) {
            throw new SironoServiceException('Invalid PaymentRequest data: ' + String.join(errors, '\n '));
        }

        PaymentRestClient client = new PaymentRestClient();
        HttpResponse response = client.payChargeGroups(pmtRequest);
        PaymentJSONParser parser = new PaymentJSONParser(response.getBody());
        Payment__c newPayment = parser.parse(pmtRequest.guarantor);

        PaymentDao.insertPayment(new List<Payment__c>{newPayment});

        client = new PaymentRestClient();
        response = client.getPaymentTransactions(newPayment.Sirono_ID__c.toPlainString());
        TransactionJSONParser txnParser = new TransactionJSONParser(newPayment, response.getBody());
        List<Transaction__c> transactions = txnParser.parse();
        TransactionDao.insertTransactions(transactions);

        return newPayment;
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
}