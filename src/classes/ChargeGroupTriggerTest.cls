/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 09-02-2016
 * Test class for the ChargeGroupTriggerHandler
 */

@isTest
public class ChargeGroupTriggerTest {

    @isTest
    public static void main() {
    Contact con = TestUtility.generatePatientContact();
    insert con;
    Contact cont = TestUtility.generateGuarantorContact();
    insert cont;
    Contact c = new Contact(LastName = 'Matc');
    insert c;
    Payment_Plan__c pp = TestUtility.generatePaymentPlan(c.Id);
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

    @isTest
    public static void afterUpdate() {
Contact con = TestUtility.generatePatientContact();
insert con;

Contact cont = TestUtility.generateGuarantorContact();
insert cont;

Contact c = new Contact(LastName='Matc');
insert c;

Payment_Plan__c pp = TestUtility.generatePaymentPlan(c.Id);
insert pp;

Charge_Group__c cg = TestUtility.generateChargeGroup(cont.Id, con.Id, 100.0,pp.id);
insert cg;
cg.Pre_Collection_Sent__c = null;
cg.Guarantor__c =c.Id;

List<Payment_Plan__c> lst = [Select id, Remaining_Balance__c from Payment_Plan__c where id =: pp.Id];
System.assertEquals(0, lst[0].Remaining_Balance__c) ;

Transaction__c transactionObj = TestUtility.generateTransaction(cg, 100, 'Automatic');
insert transactionObj ;

Update cg;

lst = [Select id, Remaining_Balance__c from Payment_Plan__c where id =: pp.Id];
System.assertEquals(100, lst[0].Remaining_Balance__c) ;

}

}