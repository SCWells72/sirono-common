/*
 * @author Viraj Rana
 * @version 1.0.1
 * @Date: 09-26-2016
 * @PopulateNextPaymentDateBatchTest Test Class for the unit test of PopulateNextPaymentDateBatch Class.
 */

@isTest
public class PopulateNextPaymentDateBatchTest {
    Public Static List<Statement__c> lstStatement = new List<Statement__c>();
    static testMethod void main() {

        TestUtility objTestUtil = new TestUtility();

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        test__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        insert paymentPlan;


        Test.startTest();

        PopulateNextPaymentDateBatch eosb = new PopulateNextPaymentDateBatch();
        system.schedule('schJob', '0 11 22 * 9 ?', eosb);
        Test.stopTest();

    }

    static testMethod void pain() {
        Test.startTest();
        PopulateNextPaymentDateBatch eosb = new PopulateNextPaymentDateBatch();
        Database.executeBatch(eosb);
        Test.stopTest();
    }
}