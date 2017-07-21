/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test class for EarlyOutSchedulerBatch.
 */
@isTest
public class EarlyOutSchedulerBatchTest {
    Public Static List<Statement__c> lstStatement = new List<Statement__c>();
    static testMethod void main() {
        contact con = TestUtility.generateGuarantorContact();
        insert con;

        contact con1 = TestUtility.generateGuarantorContact();
        con1.LastName = 'Test';
        con1.Profile_Pointer_Id__c = 123;
        insert con1;

        contact p = TestUtility.generatePatientContact();
        insert p;

        Date dtst = System.today();

        Statement__c statement = TestUtility.generateStatement(con.Id);
        statement.Statement_Date__c = dtst;
        lstStatement.add(statement);

        statement = TestUtility.generateStatement(con1.Id);
        lstStatement.add(statement);
        insert lstStatement;

        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(con1.Id, p.id, 121343);
        chargeGroup.Account_Status__c = Constants.ACCT_STATUS_BILLED;
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        insert chargeGroup;

        Transaction__c objTransaction = TestUtility.generateTransaction(chargeGroup, -120, Constants.SERVICE);
        insert objTransaction;

        Date dt = System.today().addDays(-50);

        Invoice__c i = TestUtility.generateInvoice(con1.Id, p.id);
        i.Invoice_Date__c = dt;
        i.Guarantor__c = con1.Id;
        insert i;

        Campaign c = TestUtility.generateCampaign(Constants.CAMPAIGN_NAME_OVERDUE);
        c.isActive = true;
        insert c;

        CampaignMember cmm = TestUtility.generateCampaignMember(c.Id, con.Id);
        insert cmm;

        Test.startTest();
        List<CampaignMember> memberList = [select id from CampaignMember];
        System.assertEquals(1, memberList.size());
        EarlyOutSchedulerBatch eosb = new EarlyOutSchedulerBatch();
        system.schedule('schJob', '0 11 22 * 9 ?', eosb);
        Test.stopTest();

    }

    static testMethod void pain() {
        Test.startTest();
        List<CampaignMember> memberList = [select id from CampaignMember];
        System.assertEquals(0, memberList.size());
        EarlyOutSchedulerBatch eosb = new EarlyOutSchedulerBatch();
        Database.executeBatch(eosb);
        Test.stopTest();
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<CmpnMemberSecurityContext> allContexts = new List<CmpnMemberSecurityContext> {
            CmpnMemberSecurityContext.CREATE_CONTEXT,
            CmpnMemberSecurityContext.UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (CmpnMemberSecurityContext context: allContexts) {
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