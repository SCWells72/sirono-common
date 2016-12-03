/*
* @author Sirono
* @version 1.0.1
* @Date: 09-02-2016
*/

@isTest
public class CaseCommentTriggerTest {
        
    /* Coverage the code for the CaseCommentTriggerHandler class and 
     * call the afterInsert and checkAndDoAddNoteCallout method
     */
    @isTest
    static void main() { 
        CaseCommentTriggerHandler obj = new CaseCommentTriggerHandler();
        /*
        //Get case object record type.
        RecordType rt = [Select Id, Name From RecordType Where sObjectType = 'Case' AND Name = 'Internal Case'];    
        
        //Create case record.
        case c = new case(Status='New',Origin='Phone',Charge_Group_IDs__c = '1234,1235',recordTypeID=rt.Id);
        insert c;
        
        //Create Case Comment record.
        CaseComment cc = TestUtility.generateCaseComment(c.Id);
        insert cc;
        
        //Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assertEquals(0 ,msgList.size());*/ 
    }
    
    /* Coverage the code for the CaseCommentTriggerHandler class and 
     * call the afterInsert and checkAndDoAddNoteCallout method
     *
    static testMethod void testRunAs() {
        //Get System Administrator Profile.
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        //Create new user with System Administrator Profile.
        User u = new User(Alias = 'standt', Email='admin@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='admin@testorg1212.com');
        
        //Run as a System Administrator.
        System.runAs(u) {
            //Get case object record type.
            RecordType rt = [Select Id, Name From RecordType Where sObjectType = 'Case' AND Name = 'Internal Case'];    
            
            //Create case record.
            case c = new case(Status='New',Origin='Phone',Charge_Group_IDs__c = '1234,1235',recordTypeID=rt.Id);
            insert c;
            
            //Create Case Comment record.
            CaseComment cc = TestUtility.generateCaseComment(c.Id);
            insert cc;
            
            //Check system assert.
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            System.assertEquals(0 ,msgList.size()); 
        }
   }
    /* Coverage the code for the CaseCommentTriggerHandler class and 
     * call the afterInsert and checkAndDoAddNoteCallout method
     *
    static testMethod void testCaseChargeGroup() {
       //Create Patient Contact record.
       Contact patientContact = TestUtility.generatePatientContact();
       insert patientContact;
       
       //Create Guarantor Contact record.
       Contact guarantorContact = TestUtility.generateGuarantorContact();
       insert guarantorContact;
       
       //Create Charge Group record.
       Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id,patientContact.Id,12345);
       insert chargeGroup; 
       
       //Get System Administrator Profile.
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       
       //Create new user with System Administrator Profile.
       User u = new User(Alias = 'standt', Email='admin@testorg.com', 
       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
       LocaleSidKey='en_US', ProfileId = p.Id, 
       TimeZoneSidKey='America/Los_Angeles', UserName='admin@testorg1212.com');
       
       //Run as a System Administrator.
       System.runAs(u) {           
           //Get case object record type.
           RecordType rt = [Select Id, Name From RecordType Where sObjectType = 'Case' AND Name = 'Internal Case'];    
           
           //Create case record.
           case c = new case(Status='New',Origin='Phone',Charge_Group_IDs__c = '1234,1235',recordTypeID=rt.Id);
           insert c;
           
           //Create Case Charge Group record.
           Case_Charge_Group_Junction__c ccg = new Case_Charge_Group_Junction__c(Case__c = c.Id, Charge_Group__c = chargeGroup.Id); 
           insert ccg;
           
           //Create Case Comment record.
           CaseComment cc = TestUtility.generateCaseComment(c.Id);
           insert cc;
        }
    }*/
}