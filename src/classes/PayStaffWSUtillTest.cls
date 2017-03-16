/**
 * This class is use to test the logic of PayStaffWSUtill Class.
 **/

@isTest
private class PayStaffWSUtillTest {
	
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
     * This method tests the logic of expYearOptions is populate or not.
     **/
    @isTest
    static void checkExpYearPopulated() {
        PayStaffWSUtill.fetchGuarantorContact('');
        PayStaffWSUtill.fetchGuarantorId(null);
        PayStaffWSUtill.fetchChargeGroupIds(PayStaffWSUtill.fetchChargeGroupList(null));
        PayStaffWSUtill.getCSRFToken();
        PayStaffWSUtill.getJWTToken(PayStaffWSUtill.un, PayStaffWSUtill.pw);
        PayStaffWSUtill.buildChargeGroupsURL('1,2');
        List<SelectOption> expYearOptions = PayStaffWSUtill.expYearOptions;
        List<SelectOption> expMonthOptions = PayStaffWSUtill.expMonthOptions;

        Test.startTest();
        PayStaffWSUtill.TokenAuthResponse tokenAuthResponse = new PayStaffWSUtill.TokenAuthResponse();
        tokenAuthResponse.token = 'testToken';
        Test.stopTest();
        
        // Check System assert.
        System.assertNotEquals(expYearOptions, null, 'Should have failed due to expYearOptions are null.');
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
     * This method tests the logic of Dollar to Cent Convert.
     **/
    @isTest
    static void convertDollarToCents() {
        String inputDollars = '100';
        Test.startTest();
        String outputCents = PayStaffWSUtill.convertToCents(inputDollars);
        Test.stopTest();
        
        // Check system assert.
        System.assert('10000'.equals(outputCents), 'Expected 10000, but got ' + outputCents);
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
     * This method test the logic of Fetch Guarantor Contact with CG Constrains
     * Here CG account substatus is "Preinvoiced" so we get contact with one CG.
     **/
    @isTest
    public static void fetchContactWithCG() {
        // Create Contact record with guarantor record type.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        // Create Contact record with patient record type.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        INSERT chargeGroup;

	// Call fetchGuarantorFilterCGByAcctSubStatus method.
        Test.startTest();
        Contact contact = PayStaffWSUtill.fetchGuarantorFilterCGByAcctSubStatus(guarantorContact.Id, PayStaffWSUtill.CGConstraintsForDiscount);
        Test.stopTest();
        
        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 1);
        System.assertEquals(guarantorContact.Id, contact.Id);
    }
    
    /**
     * This method test the logic of Fetch Guarantor Contact with CG Constrains
     * Here CG account substatus is "Bad Debt" so we get only contact details.
     * We can't get any CG record with contact.
     **/
    @isTest
    public static void fetchContactWithoutCG() {
        // Create Contact record with guarantor record type.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;
        
        // Create Contact record with patient record type.
        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;
        
        // Create Charge Group Record.
        Charge_Group__c chargeGroup = TestUtility.generateChargeGroup(guarantorContact.Id, patientContact.Id, 12345);
        chargeGroup.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_BAD_DEBT;
        INSERT chargeGroup;

	// Call fetchGuarantorFilterCGByAcctSubStatus method.
        Test.startTest();
        Contact contact = PayStaffWSUtill.fetchGuarantorFilterCGByAcctSubStatus(guarantorContact.Id, PayStaffWSUtill.CGConstraintsForDiscount);
        Test.stopTest();
        
        // Check system assert, Charge Group size of Contact.
        System.assertEquals(contact.Charge_Groups__r.size(), 0);
        System.assertEquals(guarantorContact.Id, contact.Id);
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
}