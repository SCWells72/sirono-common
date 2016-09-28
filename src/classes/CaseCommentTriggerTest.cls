/*
* @author Sirono
* @version 1.0.1
* @Date: 09-02-2016
*/

@isTest
public class CaseCommentTriggerTest {

    static @isTest void main() {
    RecordType rt = [Select Id, Name From RecordType Where sObjectType = 'Case' AND Name = 'Internal Case'];
    case c = new case(Status = 'New', Origin = 'Phone', Charge_Group_IDs__c = '1234,1235', recordTypeID = rt.Id);
    insert c;
    CaseComment cc = TestUtility.generateCaseComment(c.Id);
    insert cc;

    List<ApexPages.Message> msgList = ApexPages.getMessages();
    System.assertEquals(0, msgList.size());
}

static testMethod void testRunAs() {

Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id,
TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1212.com');

System.runAs(u) {
RecordType rt = [Select Id, Name From RecordType Where sObjectType = 'Case' AND Name = 'Internal Case'];
case c = new case(Status='New', Origin='Phone', Charge_Group_IDs__c = '1234,1235', recordTypeID=rt.Id);
insert c;
CaseComment cc = TestUtility.generateCaseComment(c.Id);
insert cc;

List<ApexPages.Message> msgList = ApexPages.getMessages();
System.assertEquals(0, msgList.size());
}
}

static testMethod void testCaseChargeGroup() {
Contact patientContact = TestUtility.generatePatientContact();
insert patientContact;
Contact guarantorContact = TestUtility.generateGuarantorContact();
insert guarantorContact;
Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
insert chargeGroup;
Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id,
TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg1212.com');
System.runAs(u) {
RecordType rt = [Select Id, Name From RecordType Where sObjectType = 'Case' AND Name = 'Internal Case'];
case c = new case(Status='New', Origin='Phone', Charge_Group_IDs__c = '1234,1235', recordTypeID=rt.Id);
insert c;
Case_Charge_Group__c ccg = new Case_Charge_Group__c(Case__c = c.Id, Charge_Group__c = chargeGroup.Id);
insert ccg;
CaseComment cc = TestUtility.generateCaseComment(c.Id);
insert cc;

}

}
}