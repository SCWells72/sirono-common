/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public class PaymentPlanTriggerHandlerTest {
    private static final Integer NUM_CHARGE_GROUPS = 2;

    // NOTE: Keeping this out of setup method because it might be parameterized per-test
    private static Contact createPaymentPlanPrereqs() {
        Contact guarantor = TestUtility.generateGuarantorContact();
        guarantor.Guarantor_Id__c = 100.0;
        insert guarantor;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
        for (Integer i = 0; i < NUM_CHARGE_GROUPS; i++) {
            Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(
                guarantor.Id,
                patientContact.Id,
                200.0 + i
            );
            chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
            chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PAYMENT_PLAN;
            chargeGroups.add(chargeGroup);
        }
        insert chargeGroups;

        return guarantor;
    }

    private static void verifyPaymentPlanWithErrorsResults() {
        List<Case> cases = [
            SELECT Id, Type, (
                SELECT Id, Charge_Group__r.Account_Status__c, Charge_Group__r.Account_Sub_Status__c
                FROM Case_Charge_Groups__r
            )
            FROM Case
            WHERE Subject = :Constants.CASE_SUBJECT_PAYMENT_PLAN_ERROR
        ];

        // Verify the cases
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, cases[0].Type);

        // Verify the case/charge groups
        List<Case_Charge_Group_Junction__c> caseChargeGroupJunctions = cases[0].Case_Charge_Groups__r;
        System.assertEquals(NUM_CHARGE_GROUPS, caseChargeGroupJunctions.size());
        for (Case_Charge_Group_Junction__c caseChargeGroupJunction : caseChargeGroupJunctions) {
            System.assertEquals(Constants.ACCT_STATUS_BILLED, caseChargeGroupJunction.Charge_Group__r.Account_Status__c);
            System.assertEquals(Constants.ACCT_SUBSTATUS_PAYMENT_PLAN, caseChargeGroupJunction.Charge_Group__r.Account_Sub_Status__c);
        }
    }

    private static void verifyPaymentPlanWithoutErrorsResults() {
        List<Case> cases = [
            SELECT Id, Type, (
                SELECT Id, Charge_Group__r.Account_Status__c, Charge_Group__r.Account_Sub_Status__c
                FROM Case_Charge_Groups__r
            )
            FROM Case
            WHERE Subject = :Constants.CASE_SUBJECT_PAYMENT_PLAN_ERROR
        ];

        // There should be no matches
        System.assert(cases.isEmpty());
    }

    @IsTest
    private static void testPaymentPlanCreatedWithErrors() {
        Contact guarantor = createPaymentPlanPrereqs();

        Test.startTest();
        {
            Payment_Plan__c paymentPlan = new Payment_Plan__c(
                Guarantor__c = guarantor.Id,
                Has_Error__c = true
            );
            insert paymentPlan;
        }
        Test.stopTest();

        verifyPaymentPlanWithErrorsResults();
    }

    @IsTest
    private static void testPaymentPlanCreatedWithoutErrors() {
        Contact guarantor = createPaymentPlanPrereqs();

        Test.startTest();
        {
            Payment_Plan__c paymentPlan = new Payment_Plan__c(
                Guarantor__c = guarantor.Id,
                Has_Error__c = false
            );
            insert paymentPlan;
        }
        Test.stopTest();

        verifyPaymentPlanWithoutErrorsResults();
    }

    @IsTest
    private static void testPaymentPlanCreatedWithErrorsAndSettingDisabled() {
        // Disable payment plan errors auto-case creation
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();
        sironoCallCenterSettings.Auto_Create_Payment_Plan_Error_Cases__c = false;
        update sironoCallCenterSettings;

        Contact guarantor = createPaymentPlanPrereqs();

        Test.startTest();
        {
            Payment_Plan__c paymentPlan = new Payment_Plan__c(
                Guarantor__c = guarantor.Id,
                Has_Error__c = true
            );
            insert paymentPlan;
        }
        Test.stopTest();

        verifyPaymentPlanWithoutErrorsResults();
    }

    @IsTest
    private static void testPaymentPlanUpdatedToAddErrors() {
        Contact guarantor = createPaymentPlanPrereqs();

        Payment_Plan__c paymentPlan = new Payment_Plan__c(
            Guarantor__c = guarantor.Id,
            Has_Error__c = false
        );
        insert paymentPlan;

        Test.startTest();
        {
            paymentPlan.Has_Error__c = true;
            update paymentPlan;
        }
        Test.stopTest();

        verifyPaymentPlanWithErrorsResults();
    }

    @IsTest
    private static void testPaymentPlanUpdatedToAddErrorsWithSettingDisabled() {
        // Disable payment plan errors auto-case creation
        Sirono_Call_Center_Settings__c sironoCallCenterSettings = SironoCallCenterSettingsUtil.getSironoCallCenterSettings();
        sironoCallCenterSettings.Auto_Create_Payment_Plan_Error_Cases__c = false;
        update sironoCallCenterSettings;

        Contact guarantor = createPaymentPlanPrereqs();

        Payment_Plan__c paymentPlan = new Payment_Plan__c(
            Guarantor__c = guarantor.Id,
            Has_Error__c = false
        );
        insert paymentPlan;

        Test.startTest();
        {
            paymentPlan.Has_Error__c = true;
            update paymentPlan;
        }
        Test.stopTest();

        verifyPaymentPlanWithoutErrorsResults();
    }

    @IsTest
    private static void testPaymentPlanUpdatedToClearErrors() {
        Contact guarantor = createPaymentPlanPrereqs();

        Payment_Plan__c paymentPlan = new Payment_Plan__c(
            Guarantor__c = guarantor.Id,
            Has_Error__c = true
        );
        insert paymentPlan;

        Test.startTest();
        {
            // And update the payment plan not to have
            paymentPlan.Has_Error__c = false;
            update paymentPlan;
        }
        Test.stopTest();

        List<Case> cases = [
            SELECT Id, Type, Status, Reason
            FROM Case
            WHERE Subject = :Constants.CASE_SUBJECT_PAYMENT_PLAN_ERROR
        ];

        // There should be one case in a closed state
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, cases[0].Type);
        System.assertEquals(Constants.CASE_STATUS_CLOSED, cases[0].Status);
        System.assertEquals(Constants.CASE_REASON_CLOSED_AUTOMATED, cases[0].Reason);
    }

    @IsTest
    private static void testPaymentPlanWithErrorsUpdatedBenignChange() {
        Contact guarantor = createPaymentPlanPrereqs();

        // Start with errors
        Payment_Plan__c paymentPlan = new Payment_Plan__c(
            Name = 'Before',
            Guarantor__c = guarantor.Id,
            Has_Error__c = true
        );
        insert paymentPlan;

        verifyPaymentPlanWithErrorsResults();

        Test.startTest();
        {
            // Make a change other than clearing the errors field and make sure no new case is added
            paymentPlan.Name = 'After';
            update paymentPlan;
        }
        Test.stopTest();

        verifyPaymentPlanWithErrorsResults();
    }

    @IsTest
    private static void testPaymentPlanWithoutErrorsUpdatedBenignChange() {
        Contact guarantor = createPaymentPlanPrereqs();

        // Start without errors
        Payment_Plan__c paymentPlan = new Payment_Plan__c(
            Name = 'Before',
            Guarantor__c = guarantor.Id,
            Has_Error__c = false
        );
        insert paymentPlan;

        verifyPaymentPlanWithoutErrorsResults();

        Test.startTest();
        {
            // Make a change other than setting the errors field and make sure no new case is added
            paymentPlan.Name = 'After';
            update paymentPlan;
        }
        Test.stopTest();

        verifyPaymentPlanWithoutErrorsResults();
    }
}