/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class is use to test the logic of PayStaffWSUtill Class.
 **/
@IsTest
private class PayStaffWSUtillTest {
    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = 12345;
        insert gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = 67890;
        insert pt;

        // Create Charge Group Record.
        List<Charge_Group__c> cgs = TestUtility.generateChargeGroupList(gt.Id);
        insert cgs;

        // Check system assert.
        System.assertEquals(12345, gt.Profile_Pointer_ID__c, 'Expected Profile_Pointer_ID__c equals to "12345" but got ' + gt.Profile_Pointer_ID__c);
    }

    /**
     * This method tests the logic of fetchGuarantorId.
     **/
    @IsTest
    static void checkGuarantorIdPopulated() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        gt = GuarantorService.getGuarantorWithActiveCG(gt.Id);

        String guarantorSironoId = PayStaffWSUtill.fetchGuarantorId(gt);
        PayStaffWSUtill.fetchChargeGroupIds(ChargeGroupWrapper.buildList(gt));
        PayStaffWSUtill.buildChargeGroupsURL('1,2');

        // Check System assert.
        System.assertEquals(guarantorSironoId, String.valueOf(gt.Profile_Pointer_ID__c), 'Expected Sirono Id ' + guarantorSironoId + ' but got ' + gt.Profile_Pointer_ID__c);
    }


    /**
     * Verify the build charge group method can handle a comma delimited list.
     */
    @IsTest
    static void testBuildChargeGroupsURL() {
        Test.startTest();
        String urlJSONString = PayStaffWSUtill.buildChargeGroupsURL('1,2');
        Test.stopTest();
        Integer urlCount = urlJSONString.countMatches(SironoSettingsUtil.getServerEndpoint());
        System.assert(urlCount == 2, 'Expected 2 urls but got ' + urlCount);
    }

    /**
     * Verify the build charge group method when param is null
     */
    @IsTest
    static void testBuildChargeGroupsURL_nullParam() {
        String itsNull;
        Test.startTest();
        String urlJSONString = PayStaffWSUtill.buildChargeGroupsURL(itsNull);
        Test.stopTest();

        System.assert(urlJSONString == '[]', 'Should have gotten an empty List for a null parameter.');
    }
        
    @IsTest
    static void convertCentToDollars() {
        String inputCents = '100';
        Test.startTest();
        String dollarAmount = PayStaffWSUtill.convertToDollars(inputCents);
        Test.stopTest();

        // Check system assert.
        System.assert('1.00'.equals(dollarAmount), 'Expected 1.00, but got ' + dollarAmount);
    }

    /**
     * This method tests the logic of Fetch Patient Id method.
     **/
    @IsTest
    static void checkPatientId() {
        Contact con = new Contact(LastName = 'Sirono', Patient_Id__c = 123456);
        insert con;

        Test.startTest();
        String patientId = PayStaffWSUtill.fetchPatientId(con);
        PayStaffWSUtill.addNoteWSCallout(null, null);
        Test.stopTest();

        // Check System assert.
        System.assertEquals(Decimal.valueOf(patientId), con.Patient_Id__c, 'Should have failed due to different patient id.');
    }

    /**
     * Check all access rights for a read only User using runAs.
     **/
    @IsTest
    static void checkAccessRights() {
        List<TransactionSecurityContext> allContexts = new List<TransactionSecurityContext> {
            TransactionSecurityContext.CREATE_CONTEXT,
            TransactionSecurityContext.CREATE_WITH_PAYMENT_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (TransactionSecurityContext context : allContexts) {
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