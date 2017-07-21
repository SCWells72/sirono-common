/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@isTest
public class PaymentServiceTest {

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = Decimal.valueOf(PaymentRestClientMock.GT_SIRONO_ID);
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(PaymentRestClientMock.PT_SIRONO_ID);
        INSERT pt;

        Charge_Group__c cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, 12345.00);
        cg.Sirono_ID__c = Decimal.valueOf(PaymentRestClientMock.CG_SIRONO_ID);
        cg.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        cg.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DUE_BY;
        INSERT cg;

        Service__c svc = TestUtility.generateService(cg, 575.00);
        INSERT svc;

        Transaction__c txn = TestUtility.generateServiceTxn(cg, 575.00, svc);
        INSERT txn;
    }

    public static PaymentRequest buildValidRequest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(PaymentRestClientMock.GT_SIRONO_ID);
        Charge_Group__c[] cgs = [
                SELECT Id, Guarantor__c, Balance__c, Sirono_ID__c
                FROM Charge_Group__c
                WHERE Account_Status__c = :Constants.ACCT_STATUS_BILLED
                AND Guarantor__c = :gt.Id
        ];

        PaymentRequest pmtRequest = new PaymentRequest();
        pmtRequest.chargeInfo.creditCardNumber = '4005519200000004';
        pmtRequest.chargeInfo.cardHolderName = 'Joe Schmoe';
        pmtRequest.chargeInfo.expirationYear = String.valueOf(Date.today().addYears(2).year()).substring(2);
        pmtRequest.chargeInfo.expirationMonth = String.valueOf(Date.today().month());
        pmtRequest.chargeInfo.cvv = '123';
        pmtRequest.chargeInfo.amount = '150.00';
        pmtRequest.chargeInfo.address = '1111 Cedar St';
        pmtRequest.chargeInfo.city = 'Austin';
        pmtRequest.chargeInfo.state = 'TX';
        pmtRequest.chargeInfo.zip = '78704';
        pmtRequest.guarantor = gt;
        pmtRequest.chargeGroups = new List<Charge_Group__c>{ cgs[0] };
        return pmtRequest;
    }

	/**
     * This method is used to test PaymentService.createNewPayment method
     **/
    @IsTest
    static void createNewPaymentTest() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create Encounter record.
        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        INSERT encounter;

        Test.startTest();
        PaymentService.createNewPayment(guarantorContact.Id, 123, encounter.Id, System.now(), null);

        List<Payment__c> paymentList = [
                SELECT Id, Name
                FROM Payment__c
        ];
        Test.stopTest();
        // Confirm that record was created
        System.assertEquals(paymentList.size(), 1);

    }

    @IsTest
    public static void buildPayChargeGroupsBodyTest() {
        PaymentRequest pmtRequest = buildValidRequest();
        List<String> errors = pmtRequest.validate();

        Test.setMock(HttpCalloutMock.class, new PaymentRestClientMock());

        Test.startTest();
        PaymentService.PaymentRestClient client = new PaymentService.PaymentRestClient();
        String jsonBody = client.buildPayChargeGroupsBody(pmtRequest);
        Test.stopTest();

        /**
        The response should look like this (except for whitespace):
            {
              "method" : "credit",
              "city" : "Austin",
              "zipcode" : "78704",
              "address_1" : "1111 Cedar St",
              "state" : "TX",
              "cardholder_name" : "Joe Schmoe",
              "expiration_month" : "6",
              "amount" : "1000",
              "cvv" : "123",
              "expiration_year" : "19",
              "number" : "4005519200000004",
              "guarantor" : "https://sf-portal.sirono.com/paystaff/api/guarantors/11111111/",
              "csrfmiddlewaretoken" : "csrfT0kens1s1n",
              "chargegroups" : [ "https://sf-portal.sirono.com/paystaff/api/chargegroups/33333333/" ]
            }
         */
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        System.assertEquals(pmtRequest.chargeInfo.address, jsonMap.get('address_1'), 'Address mismatch');
        System.assertEquals(pmtRequest.chargeInfo.city, jsonMap.get('city'), 'City mismatch');
        System.assertEquals(pmtRequest.chargeInfo.state, jsonMap.get('state'), 'State mismatch');
        System.assertEquals(pmtRequest.chargeInfo.zip, jsonMap.get('zipcode'), 'Zip mismatch');

        System.assertEquals(pmtRequest.chargeInfo.creditCardNumber, jsonMap.get('number'), 'CardNumber mismatch');
        System.assertEquals(pmtRequest.chargeInfo.cardHolderName, jsonMap.get('cardholder_name'), 'CardHolderName mismatch');
        System.assertEquals(pmtRequest.chargeInfo.cvv, jsonMap.get('cvv'), 'CVV mismatch');
        System.assertEquals(pmtRequest.chargeInfo.expirationYear, jsonMap.get('expiration_year'), 'expirationYear mismatch');
        System.assertEquals(pmtRequest.chargeInfo.expirationMonth, jsonMap.get('expiration_month'), 'expirationMonth mismatch');


        System.assertEquals(pmtRequest.chargeInfo.amount.replace('.', ''), jsonMap.get('amount'), 'Amount mismatch');

        String gtUrl = (String)jsonMap.get('guarantor');
        System.assert(gtUrl.endsWith(PaymentRestClientMock.GT_SIRONO_ID+'/'), 'GT Url incorrectly constructed: '+gtUrl);

        List<Object> cgUrls = (List<Object>)jsonMap.get('chargegroups');
        System.assert(cgUrls.size() == 1, 'Expected 1 chargegroup url in the request body');
        String cgUrl = (String)cgUrls[0];
        System.assert(cgUrl.endsWith(PaymentRestClientMock.CG_SIRONO_ID+'/'), 'Chargegroup url incorrectly constructed: '+cgUrl);

        String csrfToken = (String)jsonMap.get('csrfmiddlewaretoken');
        System.assert(!String.isEmpty(csrfToken), 'csrfmiddlewaretoken missing');

        System.assertEquals('credit', jsonMap.get('method'), 'Invalid payment method');

    }
    @IsTest
    public static void makePaymentTest() {

        PaymentRequest pmtRequest = buildValidRequest();

        Test.setMock(HttpCalloutMock.class, new PaymentRestClientMock());

        Test.startTest();
        Payment__c payment = PaymentService.makePayment(pmtRequest);
        Test.stopTest();

        System.assert(payment != null, 'Payment not created');

        List<Transaction__c> txns = [SELECT Id, Amount__c FROM Transaction__c WHERE Payment__c = :payment.Id];
        System.assert(!txns.isEmpty(), 'No transactions found for payment');
        System.assert(txns[0].Amount__c + payment.Amount__c == 0, 'Invalid transaction amount: '+txns[0].Amount__c+' expected: '+(-1*payment.Amount__c));

    }

}