/**
 * Created by swells on 6/26/2017.
 */

@IsTest
public class PaymentPlanProcessBuilderFlowTest {
    private static final Integer NUM_CHARGE_GROUPS = 2;

    @TestSetup
    private static void setup() {
        SironoSettingsUtil.setProcessBuilderIds(Sirono_Settings__c.getInstance());
    }

    private static Contact createPaymentPlanPrereqs() {
        Contact guarantor = TestUtility.generateGuarantorContact();
        guarantor.Profile_Pointer_ID__c = 100.0;
        insert guarantor;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        List<Charge_Group__c> chargeGroups = new List<Charge_Group__c>();
        for (Integer i = 0; i < NUM_CHARGE_GROUPS; i++) {
            Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(
                guarantor.Id,
                patientContact.Id,
                200.0
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
            WHERE Subject = 'Payment Plan Error'
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

    private static void verifyPaymentPlanNoErrorsResults() {
        List<Case> cases = [
            SELECT Id, Type, (
                SELECT Id, Charge_Group__r.Account_Status__c, Charge_Group__r.Account_Sub_Status__c
                FROM Case_Charge_Groups__r
            )
            FROM Case
            WHERE Subject = 'Payment Plan Error'
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
    private static void testPaymentPlanCreatedNoErrors() {
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

        verifyPaymentPlanNoErrorsResults();
    }

    @IsTest
    private static void testPaymentPlanUpdatedWithErrors() {
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
    private static void testPaymentPlanUpdatedNoErrors() {
        Contact guarantor = createPaymentPlanPrereqs();

        Payment_Plan__c paymentPlan = new Payment_Plan__c(
            Guarantor__c = guarantor.Id,
            Has_Error__c = true
        );
        insert paymentPlan;

        // TODO: Delete the case that was created above to simulate case closure
        List<Case> cases = [SELECT Id, Type FROM Case WHERE Subject = 'Payment Plan Error'];
        System.assertEquals(1, cases.size());
        System.assertEquals(Constants.CASE_TYPE_PAYMENT_PLAN_ERROR, cases[0].Type);
        delete cases;

        Test.startTest();
        {
            // And update the payment plan not to have
            paymentPlan.Has_Error__c = false;
            update paymentPlan;
        }
        Test.stopTest();

        // TODO: Case closure should have removed the case above when the errors were cleared
        verifyPaymentPlanNoErrorsResults();
    }
}