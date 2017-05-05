/**
 * Tests for the PaymentPlanDao methods
 */
@IsTest
public with sharing class PaymentPlanDaoTest {

    private static Decimal PP_SIRONO_ID = 98765;
    private static String GT_SIRONO_ID = '12345';

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = Decimal.valueOf(GT_SIRONO_ID);
        INSERT gt;
        System.debug('gt.Id: '+gt.Id);

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(gt);
        pp.Active__c = true;
        pp.Plan_Type__c = 'Automatic';
        pp.Sirono_ID__c = PP_SIRONO_ID;
        INSERT pp;

        pp = TestUtility.generatePaymentPlan(gt);
        pp.Active__c = false;
        pp.Plan_Type__c = 'Automatic';
        pp.Sirono_ID__c = 434343;
        INSERT pp;
        
        // Check system assert.
        System.assertEquals(Decimal.valueOf(GT_SIRONO_ID), gt.Profile_Pointer_ID__c, 'Expected Profile_Pointer_ID__c is ' + GT_SIRONO_ID + ' but got '+ gt.Profile_Pointer_ID__c);
    }

    @isTest
    public static void getActivePaymentPlanTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);
        System.assertNotEquals(gt, null);

        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan((String) gt.Id);

        System.assertNotEquals(pp, null, 'Expected paymentplan but got null');
        System.assertEquals(PP_SIRONO_ID, pp.Sirono_ID__c, 'Expected Sirono_ID__c of '+PP_SIRONO_ID+' but got: '+pp.Sirono_ID__c);
    }

    @isTest
    public static void getActivePaymentPlanUseWrongIdTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);
        System.assertNotEquals(gt, null);

        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(GT_SIRONO_ID);
        System.assertEquals(pp, null, 'Expected null but got a paymentplan retrieved by GT sirono_id');

        pp = PaymentPlanDao.getActivePaymentPlan(String.valueOf(PP_SIRONO_ID));
        System.assertEquals(pp, null, 'Expected null but got a paymentplan retrieved by PP sirono_id');
    }

    @isTest
    public static void getPaymentPlanBySironoIdTest() {

        Payment_Plan__c pp = PaymentPlanDao.getPaymentPlanBySironoId(PP_SIRONO_ID);

        System.assertNotEquals(pp, null, 'Expected paymentplan retrieved by sirono_id but got null');
        System.assertEquals(PP_SIRONO_ID, pp.Sirono_ID__c, 'Expected Sirono_ID__c of '+PP_SIRONO_ID+' but got: '+pp.Sirono_ID__c);
    }

    @isTest
    public static void getPaymentPlanBySironoIdNotFoundTest() {

        Payment_Plan__c pp = PaymentPlanDao.getPaymentPlanBySironoId(88);
        System.assert(pp == null, 'Expected null paymentplan retrieved by sirono_id but got: '+pp);
    }

    @isTest
    public static void upsertPlansTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);
        Payment_Plan__c pp = PaymentPlanDao.getActivePaymentPlan(gt.Id);

        pp.Active__c = false;
        Test.startTest();
        PaymentPlanDao.upsertPlans(new Payment_Plan__c[]{pp});
        Test.stopTest();
        pp = PaymentPlanDao.getPaymentPlanBySironoId(PP_SIRONO_ID);

        System.assert(!pp.Active__c, 'Expected pp to be inactive');
    }

    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<PaymentPlanSecurityContext> allContexts = new List<PaymentPlanSecurityContext>{PaymentPlanSecurityContext.UPSERT_CONTEXT,
                PaymentPlanSecurityContext.UPDATE_CONTEXT, PaymentPlanSecurityContext.DP_UPDATE_CONTEXT,
                PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentPlanSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @isTest
    static void checkAccessRightsForRead() {
        List<PaymentPlanSecurityContext> allContexts = new List<PaymentPlanSecurityContext>{PaymentPlanSecurityContext.SELECT_CONTEXT,
                PaymentPlanSecurityContext.CLU_SELECT_CONTEXT, PaymentPlanSecurityContext.CTH_SELECT_CONTEXT, PaymentPlanSecurityContext.DPPSB_SELECT_CONTEXT,
                PaymentPlanSecurityContext.EPP_SELECT_CONTEXT, PaymentPlanSecurityContext.SPP_SELECT_CONTEXT, PaymentPlanSecurityContext.PP_SELECT_CONTEXT,
                PaymentPlanSecurityContext.CU_SELECT_CONTEXT, PaymentPlanSecurityContext.SELECT_CONTEXT_FOR_CLOSE
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (PaymentPlanSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}