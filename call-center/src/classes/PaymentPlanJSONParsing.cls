/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * JSON Parsing Class for the response which comes from Request. 
 */
public class PaymentPlanJSONParsing extends AbstractSironoJSONParser {

    public class PaymentPlanJSON {
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
        //noinspection ApexUnusedDeclaration
        public Integer installments_paid;
        //noinspection ApexUnusedDeclaration
        public Integer installments_total;
        //noinspection ApexUnusedDeclaration
        public Credit_card credit_card;
        public Boolean has_error;
        //noinspection ApexUnusedDeclaration
        public String charges_added_since_start;
        public Date error_date;
        public List<String> chargegroups;
        public Boolean delinquent;
        //noinspection ApexUnusedDeclaration
        public Date delinquent_date;
        //noinspection ApexUnusedDeclaration
        public List<Encounters> encounters;
        //noinspection ApexUnusedDeclaration
        public Integer authorized_amount;
        public String skip_payment_until;
        public String status;
    }

    public class Encounters {
    }

    public class Credit_card {
        //noinspection ApexUnusedDeclaration
        public String card_type;
        //noinspection ApexUnusedDeclaration
        public String last_4;
    }

    public class PaymentPlanWrapper {
        public List<Charge_Group__c> chargeGroupRecords { get; set; }
        public Payment_Plan__c paymentPlanRecord { get; set; }
        public List<Encounter__c> encounterRecords { get; set; }

        public PaymentPlanWrapper() {
            chargeGroupRecords = new List<Charge_Group__c>();
            paymentPlanRecord = new Payment_Plan__c();
            encounterRecords = new List<Encounter__c>();
        }
    }

    public static PaymentPlanJSON parse(String json) {
        return (PaymentPlanJSON) System.JSON.deserialize(json, PaymentPlanJSON.class);
    }

    //TODO when do we pass in a chargegroupId? why don't we just always retrieve all that were sent back with the plan?
    public static PaymentPlanWrapper createPaymentPlanRecord(String json, String guarantorId, String chargeGroupId) {

        List<String> cgIds = new List<String>();
        Set<Decimal> cgIdSet = new Set<Decimal>();
        if (String.isNotBlank(chargeGroupId)) {
            cgIds = chargeGroupId.split(',');
            for (String str : cgIds) {
                if (str.isNumeric()) {
                    cgIdSet.add(Decimal.valueOf(str));
                }
            }
        }

        PaymentPlanWrapper objPaymentPlanWrapper = new PaymentPlanWrapper();
        PaymentPlanJSON objJson = parse(json);

        Payment_Plan__c paymentPlanObj = new Payment_Plan__c();
        paymentPlanObj.Active__c = objJson.active;
        paymentPlanObj.Installment_Amount__c = AbstractSironoJSONParser.convertToDollars(objJson.installment_amount);
        paymentPlanObj.Original_Installment_Count__c = objJson.number_installments;
        paymentPlanObj.Original_Balance__c = AbstractSironoJSONParser.convertToDollars(objJson.plan_value);

        if (Constants.PLANTYPE_AUTO.equalsIgnoreCase(objJson.plan_type)) {
            paymentPlanObj.Plan_Type__c = Constants.AUTOMATIC;
        } else if (Constants.PLANTYPE_PROMISE.equalsIgnoreCase(objJson.plan_type)) {
            paymentPlanObj.Plan_Type__c = Constants.MANUAL;
        }

        paymentPlanObj.Remaining_Balance__c = AbstractSironoJSONParser.convertToDollars(objJson.payable_amount);
        paymentPlanObj.Execute_On_Day__c = objJson.execute_on_day;
        paymentPlanObj.NextPaymentDate__c = AbstractSironoJSONParser.parseDate(objJson.next_payment_date);
        paymentPlanObj.Skip_Payment_Until__c = AbstractSironoJSONParser.parseDate(objJson.skip_payment_until);
        paymentPlanObj.Has_Error__c = objJson.has_error;
        paymentPlanObj.Error_Date__c = objJson.error_date;
        paymentPlanObj.Delinquent__c = objJson.delinquent;

        if (!String.isBlank(guarantorId)) {
            paymentPlanObj.Guarantor__c = guarantorId;
        } else {
            String gtId = AbstractSironoJSONParser.parseSironoId(objJson.guarantor, RestClientConstants.GUARANTOR_URL_RESOURCE_TYPE);
            Contact gt = GuarantorService.getGuarantorBySironoId(gtId);
            paymentPlanObj.Guarantor__c = gt.Id;
        }

        paymentPlanObj.Status__c = objJson.status;
        if (!String.isBlank(objJson.url)) {
            String planSironoIdStr = AbstractSironoJSONParser.parseSironoId(objJson.url, RestClientConstants.PPLAN_URL_RESOURCE_TYPE);

            if (!String.isBlank(planSironoIdStr)) {
                Decimal planSironoId = Decimal.valueOf(planSironoIdStr);
                paymentPlanObj.Sirono_ID__c = planSironoId;
                // TODO remove when name is turned into an autonumber field
                paymentPlanObj.Name = String.valueOf(paymentPlanObj.Sirono_ID__c);
                Payment_Plan__c paymentPlan = PaymentPlanDao.getPaymentPlanBySironoId(planSironoId);
                if (paymentPlan != null) {
                    paymentPlanObj.Id = paymentPlan.Id ;
                }
            }
        }

        //Get chargeGroup id from SF.
        System.debug('chargeGroupId' + chargeGroupId);
        if (String.isBlank(chargeGroupId)) {
            System.debug('objJson.chargegroups' + objJson.chargegroups);
            for (String str : objJson.chargegroups) {
                String strChargeGroupID = AbstractSironoJSONParser.parseSironoId(str, 'chargegroups');
                if (strChargeGroupID.isNumeric()) {
                    cgIdSet.add(Decimal.valueOf(strChargeGroupID));
                }
            }
        }

        System.debug('cgIdSet' + cgIdSet);
        if (!cgIdSet.isEmpty()) {
            List<Charge_Group__c> chargeGroups = ChargeGroupService.getBySironoIds(new List<Decimal>(cgIdSet));
            for (Charge_Group__c objCG: chargeGroups) {
                objCG.Payment_Plan__c = paymentPlanObj.Id;
            }
            objPaymentPlanWrapper.chargeGroupRecords = chargeGroups;
        }

        objPaymentPlanWrapper.paymentPlanRecord = paymentPlanObj;
        return objPaymentPlanWrapper;
    }

    private static String testGuarantorSironoId = '23232323';

    /**
     *  Test response for the test class and testing.
     */
    public static String testResponse() {

        String responseBody = '{' +
            '   "url": "' + TestUtility.url + '",' +
            '   "active": true,' +
            '   "installment_amount": 5000,' +
            '   "number_installments": 7,' +
            '   "plan_value": 32772,' +
            '   "plan_type": "' + TestUtility.planType + '",' +
            '   "payable_amount": 32772,' +
            '   "execute_on_day": 13,' +
            '   "guarantor": "http://127.0.0.1:8000/paystaff/api/guarantors/' + testGuarantorSironoId + '/",' +
            '   "next_payment_date": "2016-05-13",' +
            '   "installments_paid": 0,' +
            '   "installments_total": 7,' +
            '   "credit_card": {' +
            '       "card_type": "Visa",' +
            '       "last_4": "1881"' +
            '   },' +
            '   "has_error": false,' +
            '   "charges_added_since_start": null,' +
            '   "error_date": "' + TestUtility.errorDate + '",' +
            '   "chargegroups": ["http://127.0.0.1:8000/paystaff/api/chargegroups/1321212/", "http://127.0.0.1:8000/paystaff/api/chargegroups/10283475/"],' +
            '   "delinquent": false,' +
            '   "delinquent_date": "' + TestUtility.delinquentDate + '",' +
            '   "encounters": [],' +
            '   "authorized_amount": 0,' +
            '   "skip_payment_until":"2016-12-01",' +
            '   "status":"started"' +
            '}';
        return responseBody;
    }
    
    
    /*
    * 08-17-2016: Sirono - Tracker # 127940071
    *  Test response for the test class and testing.
    */
    public static String testResponse1() {

        String responseBody = '{' +
            '   "url": "' + TestUtility.url + '",' +
            '   "active": true,' +
            '   "installment_amount": 5000,' +
            '   "number_installments": 7,' +
            '   "plan_value": 32772,' +
            '   "plan_type": "' + TestUtility.planType + '",' +
            '   "payable_amount": 32772,' +
            '   "execute_on_day": 13,' +
            '   "guarantor": "http://127.0.0.1:8000/paystaff/api/guarantors/23232323/",' +
            '   "next_payment_date": "2016-05-13",' +
            '   "installments_paid": 0,' +
            '   "installments_total": 7,' +
            '   "credit_card": {' +
            '       "card_type": "Visa",' +
            '       "last_4": "1881"' +
            '   },' +
            '   "has_error": false,' +
            '   "charges_added_since_start": null,' +
            '   "error_date": null, ' +
            '   "chargegroups": ["http://127.0.0.1:8000/paystaff/api/chargegroups/1321212/", "http://127.0.0.1:8000/paystaff/api/chargegroups/10283475/"],' +
            '   "delinquent": false,' +
            '   "delinquent_date": null, ' +
            '   "encounters": [],' +
            '   "authorized_amount": 0,' +
            '   "skip_payment_until":"2016-12-01",' +
            '   "status":"started"' +
            '}';

        return responseBody;
    }
}