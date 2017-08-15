/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class AdjustmentServiceTest {

    public static String CREATE_ADJUSTMENT_JSON_RESPONSE = '{' +
            '   "url": "https://test.sirono.com/paystaff/api/adjustments/3151479/", ' +
            '   "chargegroup":"https://test.sirono.com/paystaff/api/chargegroups/'+RestClientConstants.CHARGE_GROUP_ID+'/",' +
            '   "amount":125,' +
            '   "code":"ADM",' +
            '   "description":"BC/BS adjustment",' +
            '   "display_kind":"",' +
            '   "post_date":"2016-10-13"' +
            '}';

    @TestSetup
    public static void setupData() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = Decimal.valueOf(MockHttpResponseGenerator.guarantorSironoId);
        insert guarantorContact;

        Contact externalGT = TestUtility.generateExternalGuarantor();
        insert externalGT;

        // Create Patient Contact record.
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        // Create Payment Plan record.
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Sirono_Id__c = Decimal.valueOf(MockHttpResponseGenerator.planSironoId);
        paymentPlan.Active__c = true;
        paymentPlan.Delinquent__c = true;
        insert paymentPlan;

        // Create Invoice record.
        Invoice__c invoice = TestUtility.generateInvoice(guarantorContact.Id, patientContact.Id);
        insert invoice;

        // Create Charge Group record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 121114);
        chargeGroup.Invoice__c = invoice.Id;
        chargeGroup.Sirono_Id__c = Decimal.valueOf(RestClientConstants.CHARGE_GROUP_ID);
        chargeGroup.Payment_Plan__c = paymentPlan.Id;
        chargeGroup.Charge_Group_External_Id__c = true;
        chargeGroup.External_Guarantor_Id__c = externalGT.Id;
        insert chargeGroup;

        Charge_Group__c[] someCGs = ChargeGroupDao.getBySironoIds(new Decimal[]{chargeGroup.Sirono_Id__c});

        System.debug('>>>> Found '+someCGs.size()+' chargegroups');
        for (Charge_Group__c cg : someCGs) {
            System.debug('exgt: '+cg.External_Guarantor_ID__r.External_Guarantor_Id__c);
        }

        Service2__c svc = TestUtility.generateService(guarantorContact, 675.00);
        insert svc;

        Transaction__c txn = TestUtility.generateServiceTxn(chargeGroup, 675.00, svc);
        insert txn;
    }

    @IsTest
    public static void testAdjustmentParser() {
        AdjustmentService.AdjustmentResponseParser parser = new AdjustmentService.AdjustmentResponseParser(CREATE_ADJUSTMENT_JSON_RESPONSE);
        parser.parse();

        System.assertEquals('3151479', parser.adjSironoId);
        System.assertEquals(RestClientConstants.CHARGE_GROUP_ID, parser.cgSironoId);
        System.assertEquals('BC/BS adjustment', parser.newAdjustment.Description__c);
        System.assertEquals(1.25, parser.newAdjustment.Amount__c);
        System.assertEquals(Date.newInstance(2016, 10, 13), parser.newAdjustment.Post_Date__c);
    }

    @IsTest
    public static void testCreateAdjustment() {

        Contact gt = [SELECT Id, Profile_Pointer_Id__c FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        Decimal cgSironoId = Decimal.valueOf(RestClientConstants.CHARGE_GROUP_ID);
        String adjCode = 'ADM';
        Decimal adjAmount = 1.25;

        AdjustmentService.AdjustmentRequest req = new AdjustmentService.AdjustmentRequest(gt.Id, cgSironoId, adjCode, adjAmount);

        Test.setMock(HttpCalloutMock.class, ParameterizedMockHttpResponseGenerator.ADJUSTMENT_MOCK);

        Test.startTest();
        AdjustmentService.createAdjustment(req);
        System.debug('No exception thrown creating an adjustment!');
        Test.stopTest();

        Adjustment__c[] adjs = [SELECT Id FROM Adjustment__c];
        System.assertEquals(1, adjs.size(), 'Expected 1 Adjustment__c');

        Transaction__c[] txns = [
                SELECT
                        Adjustment2__c,
                        Amount__c,
                        Id,
                        Name,
                        Payment__c,
                        Post_Date__c,
                        Service2__c,
                        Sirono_Id__c,
                        Transaction_Date__c,
                        Txn_Method__c
                FROM Transaction__c WHERE Adjustment2__c = :adjs[0].Id];

        System.assertEquals(1, txns.size(), 'Expected 1 adjustment transaction');
        System.assertEquals(-1.25, txns[0].Amount__c, 'Expected -1.25 adjustment transaction');
        System.assert(txns[0].Payment__c == null, 'Expected Payment__c to be null');
        System.assert(txns[0].Service2__c == null, 'Expected Service2__c to be null');
        System.assertEquals('10/13/2016', txns[0].Post_Date__c.format('MM/dd/yyyy'), 'Expected txn Post_Date__c to be 10/13/2016');
        System.assert(txns[0].Transaction_Date__c != null, 'Expected Tranaction_Date__c to be set');
    }
}