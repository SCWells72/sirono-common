/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-02-2016
 * Test class for the ChargeGroupTriggerHandler
 */

@isTest
public class ChargeGroupTriggerTest {

    public static @isTest void main() {
    Contact con = TestUtility.generatePatientContact();
    insert con;
    Contact cont = TestUtility.generateGuarantorContact();
    insert cont;
    Contact c = new Contact(LastName = 'Matc');
    insert c;
    test__c pp = TestUtility.generatePaymentPlan(c.Id);
    insert pp;
    Charge_Group__c cg = TestUtility.generateChargeGroup(cont.Id, con.Id, 100.0, pp.id);
    insert cg;

    Charge_Group__c cg1 = [Select id from Charge_Group__c where name = 'Sirono'];
    cg1.name = 'Sir';
    Update cg1;
    System.assertEquals('Sir', cg1.Name);
    delete cg1;
    undelete cg1;

    ChargeGroupTriggerHandler.getIsTriggerProcessed();
ChargeGroupTriggerHandler.setIsTriggerProcessed(true);

List<ApexPages.Message> msgList = ApexPages.getMessages();
System.assertEquals(0, msgList.size());
}

public static @isTest void afterUpdate() {
Contact con = TestUtility.generatePatientContact();
insert con;

Contact cont = TestUtility.generateGuarantorContact();
insert cont;

Contact c = new Contact(LastName='Matc');
insert c;

test__c pp = TestUtility.generatePaymentPlan(c.Id);
insert pp;

Charge_Group__c cg = TestUtility.generateChargeGroup(cont.Id, con.Id, 100.0,pp.id);
insert cg;
cg.Pre_Collection_Sent__c = null;
cg.Guarantor_Name__c =c.Id;

List<test__c> lst = [Select id, Payable_Amount__c from test__c where id =: pp.Id];
System.assertEquals(0, lst[0].Payable_Amount__c) ;

Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
insert transactionObj ;

Update cg;

lst = [Select id, Payable_Amount__c from test__c where id =: pp.Id];
System.assertEquals(100, lst[0].Payable_Amount__c) ;

}

}