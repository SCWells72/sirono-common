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

        Transaction__c txn = TestUtility.generateTransaction(objCG, 100, 'Credit');
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

        //10-19-2016: Viraj Rana - Tracker # 132104143: Pre-populate manual case fields where necessary.
        //Get Coverage detail for selected charge group, so we insert Converage record.
        Coverage__c objcoverage = new Coverage__c();
        objcoverage.Name = 'Test';
        insert objcoverage;
        
        //Get Coverage detail for selected charge group, so we insert Charge_Group_Coverage_Junction__c record.
        //Set Charge Group Id and Coverage Id.
        Charge_Group_Coverage_Junction__c objCGCoverage = new Charge_Group_Coverage_Junction__c();
        objCGCoverage.Name = 'Test';
        objCGCoverage.Charge_Group__c = objManual.chargeGroup.Id;
        objCGCoverage.Coverage__c = objcoverage.Id;
        insert objCGCoverage;
        
        objmanual.refresh();
        
        List<Case> lstCase = [Select id from case]; 
        System.assertEquals(0,lstCase.Size() ,'Case Exist.');    
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
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<CaseSecurityContext> allContexts = new List<CaseSecurityContext>{CaseSecurityContext.CREATE_CONTEXT,
        	CaseSecurityContext.CREATE_WITH_GT_CONTEXT, CaseSecurityContext.CU_CREATE_WITH_ENCOUNTER_CONTEXT, 
                CaseSecurityContext.UPDATE_CONTEXT, CaseSecurityContext.UPSERT_CONTEXT, CaseSecurityContext.DELETE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (CaseSecurityContext context: allContexts) {
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