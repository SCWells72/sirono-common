@isTest
public class TestCreateCaseManual {

    @isTest
    Public static void testCallCreateCaseManual() {
        test.startTest();

        Contact objContact = TestUtility.generateGuarantorContact();
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
        for (ChargeGroupWrapper cg : objManual.chrageGroupList) {
            cg.isSelected = true;
        }
        objManual.caseNotes = 'wedwew';
        objManual.gotoCaseCreation();
        objManual.submit();
        test.stopTest();
    }

    @isTest
    Public static void testCallCreateCaseManualForPatent() {
        test.startTest();
        TestUtility objUtility = new TestUtility();
        Contact objContactguarantor = TestUtility.generateGuarantorContact();
        insert objContactguarantor ;

        Contact objContact = TestUtility.generatePatientContact();
        insert objContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(objContactguarantor.Id, objContact .id, 121343);
        insert objCG;

        Transaction__c txn = TestUtility.generateTransaction(objCG, -100, 'Credit');
        insert txn;

        Apexpages.currentpage().getparameters().put('guarantorId', objContact.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
        CreateCaseManual objManual = new CreateCaseManual(sc);
        objManual.caseType = 'Billing';
        objManual.cancel();
        objManual.doNext();
        for (ChargeGroupWrapper cg : objManual.chrageGroupList) {
            cg.isSelected = true;
        }
        objManual.caseNotes = 'wedwew';
        objManual.gotoCaseCreation();
        objManual.submit();
        test.stopTest();

    }
}