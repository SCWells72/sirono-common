/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-02-2016
 * Test class for the ChargeGroupTriggerHandler
 */

@isTest
public class ChargeGroupTriggerTest {

    private static Decimal CG_EXT_ID = 100.00;
    @isTest
    public static void main() {
        Contact pt = TestUtility.generatePatientContact();
        INSERT pt;

        Contact gt = TestUtility.generateGuarantorContact();
        INSERT gt;

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(gt.Id);
        INSERT pp;

        Charge_Group__c cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, CG_EXT_ID, pp.id);
        INSERT cg;

        Charge_Group__c cg1 = [SELECT Id FROM Charge_Group__c WHERE name = 'Sirono'];
        cg1.name = 'Sir';
        UPDATE cg1;

        cg1 = [Select Id, Name FROM Charge_Group__c];

        System.assertEquals('Sir', cg1.Name);
        DELETE cg1;
        UNDELETE cg1;

        ChargeGroupTriggerHandler.getIsTriggerProcessed();
        ChargeGroupTriggerHandler.setIsTriggerProcessed(true);

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0, msgList.size());
    }

    @isTest
    public static void afterUpdate() {
        Contact con = TestUtility.generatePatientContact();
        insert con;

        Contact cont = TestUtility.generateGuarantorContact();
        insert cont;

        Contact c = new Contact(LastName = 'Matc');
        insert c;

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(c.Id);
        insert pp;

        Charge_Group__c cg = TestUtility.generateChargeGroup(cont.Id, con.Id, CG_EXT_ID, pp.id);
        insert cg;
        cg.Pre_Collection_Sent__c = null;
        cg.Guarantor__c = c.Id;

        List<Payment_Plan__c> lst = [Select id, Remaining_Balance__c from Payment_Plan__c where id = :pp.Id];
        System.assertEquals(0, lst[0].Remaining_Balance__c) ;

        Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
        insert transactionObj ;

        Update cg;

        lst = [Select id, Remaining_Balance__c from Payment_Plan__c where id = :pp.Id];
        System.assertEquals(100, lst[0].Remaining_Balance__c) ;

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
}