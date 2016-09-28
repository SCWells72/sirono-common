/*
* @author Sirono
* @version 1.0.1
* @Date: 08-12-2016
* @ Unit class  for the CaseUtil class.
* Do the code coverage for the CaseUtil class
*/

@isTest
public class CreateCaseManualTest {

    @isTest
    Public static void testCallCreateCaseManual() {
        test.startTest();
        TestUtility objUtility = new TestUtility();
        Contact objContact = TestUtility.generateguarantorContact();
        insert objContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(objContact.Id, null, 1214);
        insert objCG;

        Transaction__c txn = TestUtility.generateTransaction(objCG, -100, 'Credit');
        insert txn;

        Apexpages.currentpage().getparameters().put('guarantorId', objContact.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
        CreateCaseManual objManual = new CreateCaseManual(sc);
        objManual.caseType = 'Billing';
        objManual.cancel();
        objManual.doNext();

        System.assertEquals(false, objManual.chargeGroupsSelected, 'Charge group selected');
        for (ChargeGroupWrapper cg : objManual.chrageGroupList) {
            cg.isSelected = true;
        }
        objManual.doNext();
        System.assertEquals(true, objManual.chargeGroupsSelected, 'No Charge group selected');

        objManual.caseNotes = 'wedwew';
        objManual.gotoCaseCreation();

        List<Case> lstCase = [Select id from case];
        System.assertEquals(0, lstCase.Size(), 'Case Exist.');
        objManual.submit();
        lstCase = [Select id from case];
        System.assertEquals(1, lstCase.Size(), 'One Case Created.');

        test.stopTest();
    }

    @isTest
    Public static void testCallCreateCaseManualForPatent() {
        test.startTest();

        TestUtility objUtility = new TestUtility();
        Contact objContactguarantor = TestUtility.generateguarantorContact();
        insert objContactguarantor ;

        Contact objContact = TestUtility.generatePatientContact();
        insert objContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(objContactguarantor.Id, objContact .id, 121343);
        insert objCG;

        Transaction__c txn = TestUtility.generateTransaction(objCG, -100, 'Credit');
        insert txn;

        Apexpages.currentpage().getparameters().put('guarantorId', objContact.id);
        Apexpages.currentpage().getparameters().put('reason', 'Bankruptcy');
        ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
        CreateCaseManual objManual = new CreateCaseManual(sc);
        objManual.caseType = 'Billing';
        objManual.guarantorRecordId = '';
        objManual.cancel();
        objmanual.refresh();
        objManual.caseType = 'General';


        System.assertEquals(false, objManual.chargeGroupsSelected, 'Charge group selected');
        for (ChargeGroupWrapper cg : objManual.chrageGroupList) {
            cg.isSelected = true;
        }
        objManual.doNext();
        System.assertEquals(true, objManual.chargeGroupsSelected, 'No Charge group selected');

        objManual.caseNotes = 'wedwew';
        objManual.gotoCaseCreation();

        List<Case> lstCase = [Select id from case];
        System.assertEquals(0, lstCase.Size(), 'Case Exist.');
        objManual.submit();
        lstCase = [Select id from case];
        System.assertEquals(1, lstCase.Size(), 'One Case Created.');

        test.stopTest();

    }

    @isTest
    Public static void testCallCreateCaseManualWithoutanyID() {
        test.startTest();

        TestUtility objUtility = new TestUtility();
        Contact objContactguarantor = TestUtility.generateguarantorContact();
        insert objContactguarantor ;

        Contact objContact = TestUtility.generatePatientContact();
        insert objContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(objContactguarantor.Id, objContact .id, 121343);
        insert objCG;

        Transaction__c txn = TestUtility.generateTransaction(objCG, -100, 'Credit');
        insert txn;


        ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
        CreateCaseManual objManual = new CreateCaseManual(sc);
        objManual.gotoCaseCreation();
        test.stopTest();
    }

}