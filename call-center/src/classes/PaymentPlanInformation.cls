/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Payment Plan Info class.
 * It is use to set all parameters which are pass or set in web request to create/edit Payment Plan.
 **/
global with sharing class PaymentPlanInformation {

    public static final String SIRONO_PP_KEY = 'sironoPaymentPlanId';

    @TestVisible
    private static final String PLAN_TYPE = 'planType';
    @TestVisible
    private static final String PLAN_VALUE = 'planValue';
    @TestVisible
    private static final String AMOUNT_KEY = 'amount';
    @TestVisible
    private static final String EXECUTE_ON_DAY = 'executeOnDay';
    @TestVisible
    private static final String CHARGE_GROUP_IDS = 'chargeGroupIds';
    @TestVisible
    private static final String GUARANTOR_ID = 'guarantorId';
    @TestVisible
    private static final String CARD_HOLDER_NAME = 'cardHolderName';
    @TestVisible
    private static final String EXPIRATION_YEAR = 'expirationYear';
    @TestVisible
    private static final String EXPIRATION_MONTH = 'expirationMonth';
    @TestVisible
    private static final String CREDITCARD_NUMBER = 'creditCardNumber';
    @TestVisible
    private static final String CVV_KEY = 'cvv';
    @TestVisible
    private static final String STATE_KEY = 'state';
    @TestVisible
    private static final String ZIP_KEY = 'zip';
    @TestVisible
    private static final String ADDRESS_KEY = 'address';
    @TestVisible
    private static final String CITY_KEY = 'city';

    public String planType { get; set; }
    public String planValue { get; set; }
    public String amount { get; set; }
    public String executeOnDay { get; set; }
    public List<String> chargeGroupIds { get; set; }
    public String guarantorId { get; set; }
    public String cardholderName { get; set; }
    public String expirationYear { get; set; }
    public String expirationMonth { get; set; }
    public String creditCardNumber { get; set; }
    public String cvv { get; set; }
    public String state { get; set; }
    public String zip { get; set; }
    public String address { get; set; }
    public String city { get; set; }

    public PaymentPlanInformation() {
    }

    global PaymentPlanInformation(Map<String, Object> ppInfoMap) {

        this.planType = getStringValueFromMap(ppInfoMap, PLAN_TYPE);
        this.planValue = getStringValueFromMap(ppInfoMap, PLAN_VALUE);
        this.amount = getStringValueFromMap(ppInfoMap, AMOUNT_KEY);
        this.executeOnDay = getStringValueFromMap(ppInfoMap, EXECUTE_ON_DAY);
        this.guarantorId = getStringValueFromMap(ppInfoMap, GUARANTOR_ID);
        this.cardholderName = getStringValueFromMap(ppInfoMap, CARD_HOLDER_NAME);
        this.expirationYear = getStringValueFromMap(ppInfoMap, EXPIRATION_YEAR);
        this.expirationMonth = getStringValueFromMap(ppInfoMap, EXPIRATION_MONTH);
        this.creditCardNumber = getStringValueFromMap(ppInfoMap, CREDITCARD_NUMBER);
        this.cvv = getStringValueFromMap(ppInfoMap, CVV_KEY);
        this.state = getStringValueFromMap(ppInfoMap, STATE_KEY);
        this.zip = getStringValueFromMap(ppInfoMap, ZIP_KEY);
        this.address = getStringValueFromMap(ppInfoMap, ADDRESS_KEY);
        this.city = getStringValueFromMap(ppInfoMap, CITY_KEY);

        String cgString = getStringValueFromMap(ppInfoMap, CHARGE_GROUP_IDS);
        if (!String.isEmpty(cgString)) {
            this.chargeGroupIds = cgString.split(',');
        } else {
            this.chargeGroupIds = new List<String>();
        }
    }

    private String getStringValueFromMap(Map<String, Object> objMap, String key) {
        String str = '';
        if (objMap.containsKey(key) && !String.isEmpty(String.valueOf(objMap.get(key)))) {
            str = String.valueOf(objMap.get(key));
        }
        return str;
    }
}