/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 08-17-2016
 * @description This is a test class for the PaymentArrangement class.
 *
 * 08-17-2016: Sirono - Tracker # 127398743
 */

@isTest
public class PaymentArrangementTest {

    //Unit test for the class PaymentArrangement
    @isTest public static void paymentArrangementtest1() {
		PaymentArrangement obj = new PaymentArrangement();
		/*
        Contact patientContact = TestUtility.generatePatientContact();
        insert patientContact;

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 1234;
        insert guarantorContact;

        Encounter__c encounter = TestUtility.generateEncounter(guarantorContact.Id, 100, System.Today());
        encounter.Liability__c = 200;
        encounter.Cancelled__c = true;
        insert encounter;

        Map<String, String> recordTypeMap = new Map<String, String>();
        for (RecordType recordType : [
                Select Id, Name
                From RecordType
                Where sObjectType = 'Payment_Method__c'
        ]) {
            recordTypeMap.put(recordType.Name, recordType.Id);
        }

        Payment_Method__c paymentMethod = TestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Credit Card'));
        Insert paymentMethod;

        Apexpages.currentpage().getparameters().put('id', encounter.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(encounter);
        PaymentArrangement objPaymentArrangement = new PaymentArrangement(sc);

        objPaymentArrangement.createNewPaymentMethod();
        objPaymentArrangement.saveNewPaymentMethod();
        List<Payment_Method__c> paymentMetod = [Select id from Payment_Method__c];
        System.assertEquals(2, paymentMetod.Size(), 'Payment Method record not inserted');

        objPaymentArrangement.cancelNewPaymentMethod();
        System.assertEquals(False, objPaymentArrangement.createPaymentMethod, 'cancel method not call correctly.');

        objPaymentArrangement.submitPaymentArrangement();
        objPaymentArrangement.paymentMethodType = '12';*/
    }
}