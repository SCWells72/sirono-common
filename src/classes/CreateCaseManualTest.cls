/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use to test the logic of CreateCaseManual Class.
 **/
@IsTest
public class CreateCaseManualTest {

    /**
     * This method checks logic implemented for create case record manually.
     **/
    @IsTest
    public static void testCallCreateCaseManual() {
        Contact objContact = TestUtility.generateGuarantorContact();
        insert objContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(objContact.Id, null, 1214);
        insert objCG;

        Transaction__c txn = TestUtility.generateTransaction(objCG, -100, 'Credit');
        insert txn;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', objContact.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
        CreateCaseManual objManual = new CreateCaseManual(sc);
        objManual.caseType = 'Billing';
        objManual.cancel();
        objManual.doNext();

        // Check system assert, No charge group is selected.
        System.assertEquals(false, objManual.chargeGroupsSelected, 'Charge group selected');
        for (ChargeGroupWrapper cg : objManual.chargeGroupList) {
            cg.isSelected = true;
        }
        objManual.doNext();
        // Check system assert, charge group is selected.
        System.assertEquals(true, objManual.chargeGroupsSelected, 'No Charge group selected');

        objManual.caseNotes = 'wedwew';
        objManual.gotoCaseCreation();

        List<Case> lstCase = [SELECT Id FROM Case];
        // Check system assert, No Case record exist.
        System.assert(lstCase.isEmpty(), 'Case Exist.');
        objManual.submit();
        Test.stopTest();

        lstCase = [SELECT Id, Status FROM Case];
        // Check system assert, Case record created with some values.
        System.assertEquals(1, lstCase.size(), 'One Case Created.');
        System.assertEquals(Constants.CASE_STATUS_NEW, lstCase[0].Status, 'Case created with different Status');
    }

    /**
     * This method checks logic for create case record manually for patient.
     **/
    @IsTest
    public static void testCallCreateCaseManualForPatient() {
        Contact objContactguarantor = TestUtility.generateGuarantorContact();
        insert objContactguarantor ;

        Contact objContact = TestUtility.generatePatientContact();
        insert objContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(objContactguarantor.Id, objContact .Id, 121343);
        insert objCG;

        Transaction__c txn = TestUtility.generateTransaction(objCG, 100, 'Credit');
        insert txn;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', objContact.Id);
        ApexPages.currentPage().getParameters().put('reason', Constants.CASE_REASON_BANKRUPTCY);
        ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
        CreateCaseManual objManual = new CreateCaseManual(sc);
        objManual.caseType = 'Billing';
        objManual.guarantorRecordId = '';
        objManual.cancel();
        objManual.refresh();
        objManual.caseType = 'General';

        // Check system assert, No Charge Group Selected.
        System.assertEquals(false, objManual.chargeGroupsSelected, 'Charge group selected');
        for (ChargeGroupWrapper cg : objManual.chargeGroupList) {
            cg.isSelected = true;
        }
        objManual.doNext();
        // Check system assert, Charge Group Selected.
        System.assertEquals(true, objManual.chargeGroupsSelected, 'No Charge group selected');

        objManual.caseNotes = 'wedwew';
        objManual.gotoCaseCreation();

        // Get Coverage detail for selected charge group, so we insert Converage record.
        Coverage__c objcoverage = new Coverage__c();
        objcoverage.Name = 'Test';
        insert objcoverage;

        // Get Coverage detail for selected charge group, so we insert Charge_Group_Coverage_Junction__c record.
        // Set Charge Group Id and Coverage Id.
        Charge_Group_Coverage_Junction__c objCGCoverage = new Charge_Group_Coverage_Junction__c();
        objCGCoverage.Name = 'Test';
        objCGCoverage.Charge_Group__c = objManual.chargeGroup.Id;
        objCGCoverage.Coverage__c = objcoverage.Id;
        insert objCGCoverage;

        objManual.refresh();

        List<Case> lstCase = [SELECT Id FROM Case];
        // Check system assert, No Case record created.
        System.assert(lstCase.isEmpty(), 'Case Exist.');
        objManual.submit();
        Test.stopTest();

        lstCase = [SELECT Id, Status FROM Case];
        // Check system assert, Case record created.
        System.assertEquals(1, lstCase.size(), 'One Case Created.');
        System.assertEquals(Constants.CASE_STATUS_NEW, lstCase[0].Status, 'Case created with different Status');
    }

    /**
     * This method checks logic for create case record without any case record type id.
     **/
    @IsTest
    public static void testCallCreateCaseManualWithoutanyID() {
        Contact objContactguarantor = TestUtility.generateGuarantorContact();
        insert objContactguarantor ;

        Contact objContact = TestUtility.generatePatientContact();
        insert objContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(objContactguarantor.Id, objContact .Id, 121343);
        insert objCG;

        Transaction__c txn = TestUtility.generateTransaction(objCG, -100, 'Credit');
        insert txn;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(objContact);
        CreateCaseManual objManual = new CreateCaseManual(sc);
        objManual.gotoCaseCreation();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg : msgList) {
            if (msg.getDetail().contains(Label.Case_Type_Require)) {
                isError = true;
            }
        }
        // Check system assert, Error occurrence during process.
        System.assert(isError, 'Should have gotten an error message because Case type required');
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @IsTest
    static void checkAccessRights() {
        List<CaseSecurityContext> allContexts = new List<CaseSecurityContext> {
            CaseSecurityContext.CREATE_CONTEXT,
            CaseSecurityContext.CREATE_WITH_GT_CONTEXT,
            CaseSecurityContext.CU_CREATE_WITH_ENCOUNTER_CONTEXT,
            CaseSecurityContext.UPDATE_CONTEXT,
            CaseSecurityContext.UPSERT_CONTEXT,
            CaseSecurityContext.DELETE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (CaseSecurityContext context : allContexts) {
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