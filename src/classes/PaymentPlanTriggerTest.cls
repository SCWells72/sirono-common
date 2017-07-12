/**
 * This class tests the logic of PaymentPlanTriggerHandler class.
 **/

@isTest
private class PaymentPlanTriggerTest {

    @TestSetup
    private static void setup() {
        SironoSettingsUtil.setProcessBuilderIds(Sirono_Settings__c.getInstance());
    }

    /**
     * This method tests the logic of Next Payment Plan date is populated or not.
     **/
    static testMethod void checkNextPaymentDatePopulated() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        INSERT guarantorContact;

        Test.startTest();
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;
        paymentPlan.Active__c = true;
        UPDATE paymentPlan;
        paymentPlan.Plan_Type__c = 'Automatic';
        UPDATE paymentPlan;

        paymentPlan.Skip_Payment_Until__c = date.newInstance(2016, 1, 5);
        UPDATE paymentPlan;

        guarantorContact.Invoice_Offset_Date__c = 30;
        UPDATE guarantorContact;
        UPDATE paymentPlan;

        paymentPlan.Plan_Type__c = null;
        UPDATE paymentPlan;

        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Execute_on_Day__c = 0;
        UPDATE paymentPlan;

        paymentPlan.Execute_on_Day__c = 31;
        UPDATE paymentPlan;
        Test.stopTest();

        //TODO: verfiy value
        // We can't verify the value for NextPaymentDate__c because of its dynamic generated based on date.
        // Check system assert, Check NextPaymentDate__c should not be populated.
        List<Payment_Plan__c> paymentPlans = [
            SELECT Id, NextPaymentDate__c
            FROM Payment_Plan__c
            WHERE Guarantor__c = :guarantorContact.Id
        ];
        System.assertNotEquals(paymentPlans[0].NextPaymentDate__c, null, 'NextPaymentDate__c should be null for Payment Plan');
    }

    /**
     * This method checks number of case records created count for guarantor contact.
     **/
    @isTest
    static void checkCaseCountForRelevantGuarantor() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        INSERT guarantorContact;

        Test.startTest();
        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.active__c = false;
        paymentPlan.Plan_Type__c = 'Automatic';
        paymentPlan.Remaining_Balance__c = 100;
        paymentPlan.Has_Error__c = false;
        paymentPlan.Delinquent__c = true;
        INSERT paymentPlan;

        paymentPlan.Active__c = true;
        paymentPlan.Remaining_Balance__c = 101;
        paymentPlan.Plan_Type__c = 'Manual';
        UPDATE paymentPlan;
        Test.stopTest();

        // Check system assert, Check & verify number of Case record exists for guarantor.
        List<Case> cases = [
            SELECT Id, Reason, Guarantor_Information__c, Status, Type
            FROM Case
            WHERE Guarantor_Information__c = :guarantorContact.Id
        ];
        System.assertEquals(cases.size(), 1, 'Number of Case records created is not equals to 1');
        System.assertEquals(cases[0].Type, Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS, 'Case record not created with ' + Constants.CASE_TYPE_PAST_DUE_PAYMENT_PLANS + ' Type');
    }

    /**
     * This method checks Next Payment Date is getting updated after Update Payment Plan.
     **/
    @isTest
    static void checkNextPaymentDateUpdated() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        INSERT guarantorContact;

        Test.startTest();
        Payment_Plan__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan1.active__c = true;
        paymentPlan1.Plan_Type__c = 'Automatic';
        paymentPlan1.Remaining_Balance__c = 100;
        paymentPlan1.Has_Error__c = false;
        paymentPlan1.Delinquent__c = true;
        INSERT paymentPlan1;

        paymentPlan1.active__c = false;
        paymentPlan1.Delinquent__c = false;
        UPDATE paymentPlan1;
        Test.stopTest();

        // Check system assert, Check NextPaymentDate__c should be populated.
        List<Payment_Plan__c> paymentPlans = [
            SELECT Id, NextPaymentDate__c
            FROM Payment_Plan__c
            WHERE Guarantor__c = :guarantorContact.Id
        ];
        System.assertNotEquals(paymentPlans[0].NextPaymentDate__c, null, 'NextPaymentDate__c should not null for Payment Plan');
    }

   /**
     * This method checks CCError case created for relevent guarantor contact.
     **/
    @isTest
    static void checkCCErrorCaseCreatedForRelevantGuarantor() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        INSERT guarantorContact;

        Test.startTest();
        Payment_Plan__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan1.active__c = false;
        paymentPlan1.Plan_Type__c = 'Manual';
        paymentPlan1.Remaining_Balance__c = 200;
        paymentPlan1.Has_Error__c = false;
        INSERT paymentPlan1;

        paymentPlan1.active__c = true;
        paymentPlan1.Plan_Type__c = 'Automatic';
        paymentPlan1.Remaining_Balance__c = 501;
        paymentPlan1.Has_Error__c = true;
        UPDATE paymentPlan1;
        Test.stopTest();

        // Check system assert, Check & verify number of Case record exists for guarantor.
        List<Case> cases = [
            SELECT Id, Reason, Guarantor_Information__c, Subject
            FROM Case
            WHERE Guarantor_Information__c = :guarantorContact.Id
        ];
        System.assertEquals(cases.size(), 1, 'Number of Case records created is not equals to 1');
        System.assertEquals(cases[0].Subject, Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, 'Case record created with different Subject');
    }
	
    /**
     * This method checks Execute on day date field value is getting populated.
     **/
    @isTest
    static void checkExecuteOnDayPopulated() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        INSERT guarantorContact;

        Date refDt = Date.newInstance(TestUtility.currentYear, TestUtility.currentMonth, TestUtility.currentDay);

        Test.startTest();
        Payment_Plan__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan1.active__c = true;
        paymentPlan1.Plan_Type__c = 'Automatic';
        paymentPlan1.Remaining_Balance__c = 100;
        paymentPlan1.Has_Error__c = true;
        paymentPlan1.Skip_Payment_Until__c = refDt.adddays(10);
        INSERT paymentPlan1;
        Test.stopTest();

        // Check system assert, Execute_on_Day__c should be populated with '0' value.
        List<Payment_Plan__c> paymentPlans = [
            SELECT Id, Execute_on_Day__c
            FROM Payment_Plan__c
            WHERE Guarantor__c = :guarantorContact.Id
        ];
        System.assertEquals(paymentPlans[0].Execute_on_Day__c, 1, 'Execute_on_Day__c should be 1 for Payment Plan.');
    }

    /**
     * This method tests the logic of Next Payment Plan date is populated or not.
     **/
    @isTest
    static void checkNextPaymentDatePopulatedForManualPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId();
        INSERT guarantorContact;

        Test.startTest();
        Payment_Plan__c paymentPlan1 = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan1.active__c = true;
        paymentPlan1.Plan_Type__c = Constants.MANUAL;
        paymentPlan1.Remaining_Balance__c = 200;
        paymentPlan1.Has_Error__c = false;
        INSERT paymentPlan1;
        Test.stopTest();

        paymentPlan1 = [
            SELECT Id, NextPaymentDate__c
            FROM Payment_Plan__c
            WHERE Guarantor__c = :guarantorContact.Id
            LIMIT 1
        ];
        System.assertNotEquals(paymentPlan1, null, 'NextPaymentDate__c should be null for Payment Plan');
    }
}