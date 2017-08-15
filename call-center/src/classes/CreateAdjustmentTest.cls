/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Unit class for the CreateAdjustment class.
 **/
@IsTest
public class CreateAdjustmentTest {

    @TestSetup
    static void setupData() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = Decimal.valueOf(MockHttpResponseGenerator.guarantorSironoId);
        insert guarantorContact;

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
        insert chargeGroup;

        Service2__c svc = TestUtility.generateService(guarantorContact, 675.00);
        insert svc;

        Transaction__c txn = TestUtility.generateServiceTxn(chargeGroup, 675.00, svc);
        insert txn;
    }

    /**
     * Submit without all required data should cause an error message requesting all the details
     */
    @IsTest
    static void testDataVerification() {

        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        CreateAdjustment objCreateAdjustment = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        objCreateAdjustment.submit();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (Apexpages.Message msg: msgList) {
            System.debug('testDataVerification.msg: '+msg.getDetail());
            if (msg.getDetail().contains('Please provide all details.')) {
                isError = true;
                break;
            }
        }

        System.assert(isError, 'Expected "Please provide all details" error message');
    }

    @IsTest
    static void testCreateAdjustment() {
        Contact guarantorContact = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];

        // Call Create Adjustment constructor with Selected charge group records and also call doNext, submit methods.
        CreateAdjustment adjController = new CreateAdjustment(new ApexPages.StandardController(guarantorContact));
        adjController.chargeGroupList[0].isSelected = true;

        adjController.doNext();
        adjController.selectedAdjType = adjController.adjustmentTypeOptions.get(1).getValue();
        adjController.amount = '1.50';

        Test.setMock(HttpCalloutMock.class, ParameterizedMockHttpResponseGenerator.ADJUSTMENT_MOCK);

        Test.startTest();
        adjController.submit();
        Test.stopTest();

        // Check System Assert.
        // It will give an error "Please provide all details" beacuse of we can't enter Adjustment Amount.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (ApexPages.Message msg : msgList) {
            System.debug('msg: '+msg);
            if (msg.getDetail().contains('Adjustment created successfully')) {
                isSuccess = true;
            }
        }

        System.assert(isSuccess, 'Adjustment not created.');
    }
}
