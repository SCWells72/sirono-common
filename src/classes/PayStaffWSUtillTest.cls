/**
 * This class is use to test the logic of PayStaffWSUtill Class.
 **/

@isTest
private class PayStaffWSUtillTest {
    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = 12345;
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = 67890;
        INSERT pt;

        // Create Charge Group Record.
        List<Charge_Group__c> cgs = TestUtility.generateChargeGroupList(gt.Id);
        INSERT cgs;
        
        // Check system assert.
        System.assertEquals(12345, gt.Profile_Pointer_ID__c, 'Expected Profile_Pointer_ID__c equals to "12345" but got ' + gt.Profile_Pointer_ID__c);
    }

    /**
     * This method is used to setup preliminary data to let's all testmethods to execute as expected.
     **/
    @testSetup static void setupSironoSettings(){
        Test.startTest();
        SironoSettingsUtil.initializeSironoSettings();
        Test.stopTest();
        
        // Check system assert.
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getOrgDefaults();
        System.assertNotEquals(sironoSettings, null, 'Should have failed due to sironoSettings are null.');
    }

    /**
     * This method tests the logic of fetchGuarantorId.
     **/
    @isTest
    static void checkGuarantorIdPopulated() {
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        gt = GuarantorService.getGuarantorWithActiveCG(gt.Id);

        String guarantorSironoId = PayStaffWSUtill.fetchGuarantorId(gt);
        PayStaffWSUtill.fetchChargeGroupIds(ChargeGroupWrapper.buildList(gt));
        PayStaffWSUtill.getCSRFToken();
        PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
        PayStaffWSUtill.buildChargeGroupsURL('1,2');

        Test.startTest();
        PayStaffWSUtill.TokenAuthResponse tokenAuthResponse = new PayStaffWSUtill.TokenAuthResponse();
        tokenAuthResponse.token = 'testToken';
        Test.stopTest();
        
        // Check System assert.
        System.assertEquals(guarantorSironoId, String.valueOf(gt.Profile_Pointer_ID__c), 'Expected Sirono Id ' + guarantorSironoId + ' but got ' + gt.Profile_Pointer_ID__c);
    }


    /**
     * Verify the build charge group method can handle a comma delimited list.
     */
    @isTest
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
    @isTest
    static void testBuildChargeGroupsURL_nullParam() {
        String itsNull;
        Test.startTest();
        String urlJSONString = PayStaffWSUtill.buildChargeGroupsURL(itsNull);
        Test.stopTest();

        System.assert(urlJSONString == '[]', 'Should have gotten an empty List for a null parameter.');
    }

    /**
     * This method tests the logic of Statement Url.
     **/
    @isTest
    static void checkStatementUrlMap() {
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        Test.startTest();
        HttpResponse res = PayStaffWSUtill.getStatementUrls('12345');
        String contentType = res.getHeader('Content-Type');
        Test.stopTest();
        
        // Check system assert.
        System.assert(contentType == 'application/json', 'Should have failed due to contentType is null.');
        System.assertEquals(200, res.getStatusCode(), 'Should have failed due to status code is not 200.');
    }

    /**
     * This method tests the logic of get CSRF Token.
     **/
    @isTest
    static void checkCSRFToken() {
        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 200;
        TestUtility.body = 'sirono<input type=\'hidden\' name=\'csrfmiddlewaretoken\' value=\'';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());

        Test.startTest();
        string str = PayStaffWSUtill.getCSRFToken();
        Test.stopTest();
        
        // Check System assert.
        System.assertNotEquals(str, null, 'Should have failed due to CSRF Token is null.');
    }

    /**
     * This method tests the logic of Cent to Dollar Convert with rounded.
     **/
    @isTest
    static void convertCentToDollarsRounded() {
        Decimal inputCents = 150;
        
        Test.startTest();
        Decimal outputDollars = PayStaffWSUtill.convertToDollars(inputCents);
        Test.stopTest();
        
        // Check system assert.
        System.assert('1.5'.equals(outputDollars.format()), 'Expected 1.5, but got ' + outputDollars);
    }

    /**
     * This method tests the logic of Cent to Dollar Convert.
     **/
    @isTest
    static void convertCentToDollars() {
        string inputCents = '100';
        Test.startTest();
        string dollarAmount = PayStaffWSUtill.convertToDollars(inputCents);
        Test.stopTest();
        
        // Check system assert.
        System.assert('1.00'.equals(dollarAmount), 'Expected 1.00, but got ' + dollarAmount);
    }

    /**
     * This method tests the logic of Fetch Patient Id method.
     **/
    @isTest
    static void checkPatientId() {
        Contact con = new Contact(LastName = 'Sirono', Patient_Id__c = 123456);
        INSERT con;
        
        Test.startTest();
        String patientId = PayStaffWSUtill.fetchPatientId(con);
        PayStaffWSUtill.addNoteWSCallout(null, null);
        Test.stopTest();
        
        // Check System assert.
        System.assertEquals(Decimal.valueOf(patientId), con.Patient_Id__c, 'Should have failed due to different patient id.');
    }

    /**
     * This method tests the logic of fetch CG with acc sub status and fetch patient contact with CG.
     **/
    @isTest
    static void testChargeGroupByAccSubStatus() {
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        INSERT chargeGroup;
        
        Test.startTest();
        PayStaffWSUtill.fetchChargeGroupListbyaccountsubstatus(guarantorContact);
        Contact objContact = PayStaffWSUtill.fetchPatientContactWithCGConstraints(patientContact.Id);
        Test.stopTest();
        
        // Check system assert.
        System.assertEquals(objContact.Id, patientContact.Id, 'Should have failed due to Contact Id differ.');
    }
    
    /**
     * Check all access rights for a read only User using runAs.
     **/
    @isTest
    static void checkAccessRights() {
        List<TransactionSecurityContext> allContexts = new List<TransactionSecurityContext>{TransactionSecurityContext.CREATE_CONTEXT,
        	TransactionSecurityContext.CREATE_WITH_PAYMENT_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (TransactionSecurityContext context: allContexts) {
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

    /**
     * Check all Read rights on TransactionType for a Chatter User using runAs.
     **/
    @isTest
    static void checkAccessRightsForRead() {
        List<TransactionTypeSecurityContext> allContexts = new List<TransactionTypeSecurityContext>{TransactionTypeSecurityContext.SELECT_CONTEXT};

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (TransactionTypeSecurityContext context: allContexts) {
                try {
                    context.actionAllowed();
                    System.assert(false, 'Expected permission to be denied for ' + context);
                } catch (SecurityUtils.SecurityException ex) {
                    System.debug('SecurityException : ' + ex);
                    System.assertEquals('You do not have Read rights on Transaction_Type__c', ex.getMessage(), 'Expected to find a message about TransactionType.');
                } catch (Exception e) {
                    System.assert(false, 'Expected SecurityUtils.SecurityException to be thrown, but got ' + e);
                }
            }
        }
    }
}