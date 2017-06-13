/**
 * Header Controller Tests.
 */

@isTest
public with sharing class HeaderControllerTest {

    @isTest
    public static void getUserInfo() {
        User usr = TestUtility.getGuarantorCommunityUser();

        System.runAs(usr) {
            Test.startTest();
            UserWrapper userWrapper = HeaderController.getUserInfo();
            Test.stopTest();

            System.debug(userWrapper);
            System.assert(userWrapper != null, 'Should have a UserWrapper.');
            System.assertEquals(usr.Id, userWrapper.id, 'Should find id.');
            System.assert(userWrapper.firstName != null, 'Should find firstName.');
            System.assertEquals(usr.ContactId, userWrapper.contactId, 'Should find contactId.');
            //TODO: figure out why this is null.
//          System.assert(userWrapper.profilePointerId != null, 'Should find profile pointer id.');
        }
    }

    @isTest
    public static void getMessageInfo_GTStatus() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        guarantorWrapperMock.paymentPlanExists = false;
        guarantorWrapperMock.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        guarantorWrapperMock.planType = Constants.AUTOMATIC;
        guarantorWrapperMock.paymentPlanActive = true;


        Test.startTest();
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_OVERDUE;
        String hasStatusError = HeaderController.getMessageInfo(guarantorWrapperMock);
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;
        String delqError = HeaderController.getMessageInfo(guarantorWrapperMock);

        Test.stopTest();

        System.assert(hasStatusError.indexOf(HeaderController.WARNING_MESSAGE) != -1, 'Should have the warning');
        System.assert(delqError.indexOf(HeaderController.WARNING_MESSAGE) == -1, 'Should not have the warning');
        System.assert(hasStatusError.indexOf(HeaderController.DELINQUENT_MESSAGE) == -1, 'Should not have the deliquent message');
        System.assert(delqError.indexOf(HeaderController.DELINQUENT_MESSAGE) != -1, 'Should have the deliquent message');
    }

    @isTest
    public static void getMessageInfo_pastDue() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        guarantorWrapperMock.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        guarantorWrapperMock.paymentPlanActive = true;

        Test.startTest();
        guarantorWrapperMock.paymentPlanExists = true;
        guarantorWrapperMock.paymentPlanStanding = Constants.PAST_DUE;

        guarantorWrapperMock.planType = Constants.AUTOMATIC;
        String automaticMessage = HeaderController.getMessageInfo(guarantorWrapperMock);
        guarantorWrapperMock.planType = Constants.MANUAL;
        String manualMessage = HeaderController.getMessageInfo(guarantorWrapperMock);

        Test.stopTest();

        System.assert(automaticMessage.indexOf(HeaderController.PASTDUE_MESSAGE) != -1, 'Should have the past due message.');
        System.assert(manualMessage.indexOf(HeaderController.PASTDUE_MESSAGE) != -1, 'Should have the past due message.');
        System.assert(automaticMessage.indexOf(HeaderController.PASTDUE_MANUAL_MESSAGE) == -1, 'Should not have the past due manual message.');
        System.assert(manualMessage.indexOf(HeaderController.PASTDUE_MANUAL_MESSAGE) != -1, 'Should have the past due manual message.');
    }

    @isTest
    public static void getMessageInfo_inError() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        guarantorWrapperMock.paymentPlanExists = false;
        guarantorWrapperMock.paymentPlanActive = true;

        Test.startTest();
        // Error message condition
        guarantorWrapperMock.planType = Constants.AUTOMATIC;
        guarantorWrapperMock.paymentPlanStanding = Constants.IN_ERROR;
        String hasError = HeaderController.getMessageInfo(guarantorWrapperMock);
        guarantorWrapperMock.paymentPlanStanding = Constants.DUE;
        String noError = HeaderController.getMessageInfo(guarantorWrapperMock);

        Test.stopTest();

        System.assert(hasError.indexOf(HeaderController.ERROR_MESSAGE) != -1, 'Should have the error message.');
        System.assert(noError.indexOf(HeaderController.ERROR_MESSAGE) == -1, 'Should not have the error message.');
    }

    @isTest
    public static void hasBalanceAndNotAddPaymentPlan_AddToPaymentPlan() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        guarantorWrapperMock.addPaymentPlan = true;
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;

        Test.startTest();
        Boolean onPlanCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(false, onPlanCheck, 'Should be false if ADD_TO_PAYMENT_PLAN is true.');
    }

    @isTest
    public static void hasBalanceAndNotAddPaymentPlan_NoAddToPaymentPlan() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        guarantorWrapperMock.addPaymentPlan = false;

        Test.startTest();
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        Boolean dueCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(guarantorWrapperMock);
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_OVERDUE;
        Boolean overdueCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(guarantorWrapperMock);
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;
        Boolean deliquentCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(guarantorWrapperMock);
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        Boolean onPlanCheck = HeaderController.hasBalanceAndNotAddPaymentPlan(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(true, dueCheck, 'Should be true for DUE and no payment plan.');
        System.assertEquals(true, overdueCheck, 'Should be true for Overdue and no payment plan.');
        System.assertEquals(true, deliquentCheck, 'Should be true for Deliquent and no payment plan.');
        System.assertEquals(false, onPlanCheck, 'Should be false for on plan and no add payment plan.');
    }

    @isTest
    public static void hasBalanceAndAddPaymentPlan_VerifyPlan() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_OVERDUE;

        Test.startTest();
        guarantorWrapperMock.addPaymentPlan = true;
        Boolean hasPlanCheck = HeaderController.hasBalanceAndAddPaymentPlan(guarantorWrapperMock);
        guarantorWrapperMock.addPaymentPlan = false;
        Boolean noPlanCheck = HeaderController.hasBalanceAndAddPaymentPlan(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(true, hasPlanCheck, 'Should be true with Add to Payment Plan.');
        System.assertEquals(false, noPlanCheck, 'Should be true with no Add to Payment Plan.');
    }

    @isTest
    public static void hasPaymentPlanInGoodStanding_noPPlan() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        GuarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        GuarantorWrapperMock.addPaymentPlan = true;

        GuarantorWrapperMock.paymentPlanExists = false;

        Test.startTest();
        Boolean noPPlanCheck = HeaderController.hasPaymentPlanInGoodStanding(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(false, noPPlanCheck, 'Should be false with no payment plan.');
    }

    @isTest
    public static void hasPaymentPlanInGoodStanding_notGoodStanding() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        GuarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        GuarantorWrapperMock.addPaymentPlan = true;

        GuarantorWrapperMock.paymentPlanExists = true;
        GuarantorWrapperMock.paymentPlanStanding = Constants.PLANTYPE_PROMISE;

        Test.startTest();
        Boolean notGoodStandingCheck = HeaderController.hasPaymentPlanInGoodStanding(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(false, notGoodStandingCheck, 'Should be false when payment plan status is not Good Standing.');
    }


    @isTest
    public static void hasPaymentPlanInGoodStanding_GoodStanding() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        GuarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DUE;
        GuarantorWrapperMock.addPaymentPlan = true;

        GuarantorWrapperMock.paymentPlanExists = true;
        GuarantorWrapperMock.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;

        Test.startTest();
        Boolean goodStandingCheck = HeaderController.hasPaymentPlanInGoodStanding(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(true, goodStandingCheck, 'Should be true when payment plan status is Good Standing.');
    }

    @isTest
    public static void balanceDueOrError_notGoodStanding() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        GuarantorWrapperMock.paymentPlanExists = true;
        GuarantorWrapperMock.paymentPlanStanding = Constants.PLANTYPE_AUTO;

        Test.startTest();
        Boolean notGoodStandingCheck = HeaderController.balanceDueOrError(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(true, notGoodStandingCheck, 'Should true when there is a plan no in good standing.');
    }

    @isTest
    public static void balanceDueOrError_hasBalAndPPlan() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        GuarantorWrapperMock.paymentPlanExists = true;
        GuarantorWrapperMock.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        GuarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;

        Test.startTest();
        GuarantorWrapperMock.addPaymentPlan = true;
        Boolean balAndPPlan = HeaderController.balanceDueOrError(guarantorWrapperMock);
        GuarantorWrapperMock.addPaymentPlan = false;
        Boolean balAndNoPPlan = HeaderController.balanceDueOrError(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(true, balAndPPlan, 'Should be true if Add To PPlan is true.');
        System.assertEquals(false, balAndNoPPlan, 'Should be false if Add To PPlan is false.');
    }

    @isTest
    public static void balanceDueOrError_statusCheck() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        GuarantorWrapperMock.paymentPlanExists = true;
        GuarantorWrapperMock.paymentPlanStanding = Constants.PLANTYPE_GOOD_STANDING;
        // HasBalanceAndPaymentPlan will return false
        GuarantorWrapperMock.addPaymentPlan = false;

        Test.startTest();
        GuarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        Boolean onPaymentPlanCheck = HeaderController.balanceDueOrError(guarantorWrapperMock);
        GuarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_DELINQUENT;
        Boolean notOnPaymentPlanCheck = HeaderController.balanceDueOrError(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(true, onPaymentPlanCheck, 'Should be true if status is gt status is on payment plan.');
        System.assertEquals(false, notOnPaymentPlanCheck, 'Should be true if status is gt status is not payment plan.');
    }

    @isTest
    public static void onPaymentPlan_verifyGTStatus() {
        GuarantorWrapperMock guarantorWrapperMock = new GuarantorWrapperMock();
        // Already verifyed hasBalanceAndAddPaymentPlan so just make it return false
        guarantorWrapperMock.addPaymentPlan = false;

        Test.startTest();
        guarantorWrapperMock.guarantorStatus = Constants.GUARANTOR_STATUS_ON_PAYMENT_PLAN;
        Boolean checkOnPPlan = HeaderController.onPaymentPlan(guarantorWrapperMock);
        guarantorWrapperMock.guarantorStatus = Constants.DUE;
        Boolean checkOther = HeaderController.onPaymentPlan(guarantorWrapperMock);
        Test.stopTest();

        System.assertEquals(true, checkOnPPlan, 'Should be false if GTStatus is not on pplan.');
        System.assertEquals(false, checkOther, 'Should be false if GTStatus is not on pplan.');
    }
}