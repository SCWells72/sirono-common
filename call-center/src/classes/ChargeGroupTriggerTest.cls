/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test class for the ChargeGroupTriggerHandler
 */
@IsTest
public class ChargeGroupTriggerTest {

    private static Decimal CG_EXT_ID = 100.00;
    @IsTest
    public static void main() {
        Contact pt = TestUtility.generatePatientContact();
        insert pt;

        Contact gt = TestUtility.generateGuarantorContact();
        insert gt;

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(gt.Id);
        insert pp;

        Charge_Group__c cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, CG_EXT_ID, pp.Id);
        insert cg;

        Charge_Group__c cg1 = [SELECT Id FROM Charge_Group__c WHERE Name = 'Sirono'];
        cg1.Name = 'Sir';
        update cg1;

        cg1 = [SELECT Id, Name FROM Charge_Group__c];

        System.assertEquals('Sir', cg1.Name);
        delete cg1;
        undelete cg1;

        ChargeGroupTriggerHandler.getIsTriggerProcessed();
        ChargeGroupTriggerHandler.setIsTriggerProcessed(true);

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @IsTest
    public static void afterUpdate() {
        Contact con = TestUtility.generatePatientContact();
        insert con;

        Contact cont = TestUtility.generateGuarantorContact();
        insert cont;

        Contact c = TestUtility.generateGuarantorContactByName('Matc');
        insert c;

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(c.Id);
        insert pp;

        Charge_Group__c cg = TestUtility.generateChargeGroup(cont.Id, con.Id, CG_EXT_ID, pp.Id);
        insert cg;
        cg.Pre_Collection_Sent__c = null;
        cg.Guarantor__c = c.Id;

        List<Payment_Plan__c> lst = [SELECT Id, Remaining_Balance__c FROM Payment_Plan__c WHERE Id = :pp.Id];
        System.assertEquals(0, lst[0].Remaining_Balance__c) ;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, Constants.AUTOMATIC);
        insert transactionObj ;

        update cg;

        lst = [SELECT Id, Remaining_Balance__c FROM Payment_Plan__c WHERE Id = :pp.Id];
        System.assertEquals(100, lst[0].Remaining_Balance__c) ;

    }

    /**
     * Check all access rights for a read only User using runAs.
     **/
    @IsTest
    static void checkAccessRights() {
        List<PaymentPlanSecurityContext> allContexts = new List<PaymentPlanSecurityContext> {
            PaymentPlanSecurityContext.UPSERT_CONTEXT,
            PaymentPlanSecurityContext.UPDATE_CONTEXT,
            PaymentPlanSecurityContext.DP_UPDATE_CONTEXT,
            PaymentPlanSecurityContext.PPU_UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentPlanSecurityContext context : allContexts) {
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
    @IsTest
    static void checkAccessRightsForRead() {
        List<ChargeGroupSecurityContext> allContexts = new List<ChargeGroupSecurityContext> {
            ChargeGroupSecurityContext.SELECT_CONTEXT,
            ChargeGroupSecurityContext.GD_SELECT_CONTEXT,
            ChargeGroupSecurityContext.IU_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (ChargeGroupSecurityContext context : allContexts) {
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