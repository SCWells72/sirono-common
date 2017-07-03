/**
 * AddPaymentPlanVFControllerTest Class for the AddPaymentPlanVFController
 **/

@isTest
public class AddPaymentPlanVFControllerTest {

    /**
     * This method tests the logic of constructor, init, doCancel, doNothing, doNext and getPaymentPlanSettings methods.
     * If guarantor have already active payment plan than it will not allow to create another payment plan.
     **/
    @isTest
    static void testActivePaymentPlan() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        paymentPlan.Active__c = true;
        INSERT paymentPlan;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        // Create instance of AddPaymentPlanVFController class.
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();
        Test.stopTest();

        // Check system assert, We got 'This guarantor have already active Payment Plan.' error.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg: msgList) {
            if (msg.getDetail().contains(System.Label.Payment_Plan_Error))
                isError = true;
        }
        System.assert(isError, 'Expected ' + System.Label.Payment_Plan_Error + ' error message but got different');
    }

    /**
     * This method tests the logic of fillNameAndAddress method.
     **/
    @isTest
    static void testFillNameAddress() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();

        // Check system assert, cardHolderName become null before call fillNameAndAddress method.
        System.assert(objAddPaymentPlan.cardHolderName == null, 'Expected card holder name is null');

        // Call fillNameAndAddress method.
        objAddPaymentPlan.fillNameAndAddress();
        Test.stopTest();

        Contact gc = GuarantorDao.getGuarantor(guarantorContact.Id);
        // Check system assert, cardHolderName set as contact's name.
        System.assertEquals(gc.Name, objAddPaymentPlan.cardHolderName, 'Expected card holder name ' + gc.name + ' but got ' + objAddPaymentPlan.cardHolderName);
    }

    /**
     * This method tests the logic of page reference when doCancel method call for home page.
     **/
    @isTest
    static void testdoCancelForHomePage() {

        Test.startTest();
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();

        PageReference pg = objAddPaymentPlan.doCancel();
        Test.stopTest();

        // Check system assert, We got page reference as a Home page.
        System.assert(pg != null, 'Expected page reference "/home/home.jsp" but got null');
    }

    /**
     * This method tests the logic of page reference when doCancel method call for guarantor.
     **/
    @isTest
    static void testdoCancelForGuarantorPage() {

        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();

        PageReference pg = objAddPaymentPlan.doCancel();
        Test.stopTest();

        // Check system assert, We got page reference as a Home page.
        System.assert(pg != null, 'Expected page reference "/' + guarantorContact.Id + '" but got ' + pg);
    }

    /**
     * This method tests the logic of doSubmit method with all necessary parameters.
     **/
    @isTest
    public static void testCreatePaymentPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        guarantorContact.Profile_Pointer_Id__c = 23232323;
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        objCG.Sirono_ID__c = 1321212;
        objCG.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        INSERT transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();
        for (ChargeGroupWrapper cg: objAddPaymentPlan.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objAddPaymentPlan.expirationMonth = '07';
        objAddPaymentPlan.creditCardNumber = '378282246310005';
        objAddPaymentPlan.cardHolderName = 'Test';
        objAddPaymentPlan.zip = '07897';
        objAddPaymentPlan.amount = '100';
        objAddPaymentPlan.planType = 'auto';
        objAddPaymentPlan.planValue = '100';
        objAddPaymentPlan.executeOnDay = '10';
        objAddPaymentPlan.cvv = '1234';
        objAddPaymentPlan.state = 'test';
        objAddPaymentPlan.address = 'test';
        objAddPaymentPlan.city = 'test';
        objAddPaymentPlan.doNext();
        objAddPaymentPlan.getPaymentPlanSettings();
        List<SelectOption> paymentPlanType = objAddPaymentPlan.paymentPlanTypeOptions;

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        objAddPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isSuccess = false;
        for (ApexPages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_CREATED_SUCCESSFULLY)) isSuccess = true;
        }
        System.assert(isSuccess, 'Expected Payment Plan record created but its not created.');
    }

    /**
     * This method tests the logic of doSubmit method's error.
     **/
    @isTest
    static void testFailPaymentPlan() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 121114);
        INSERT objCG;

        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        INSERT transactionObj ;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();
        for (ChargeGroupWrapper cg: objAddPaymentPlan.chargeGroupList) {
            cg.isSelected = true;
        }
        objAddPaymentPlan.expirationYear = String.valueof(System.today().Year() + 1);
        objAddPaymentPlan.expirationMonth = '07';
        objAddPaymentPlan.creditCardNumber = '1234567891113';
        objAddPaymentPlan.cardHolderName = '1234567891113';
        objAddPaymentPlan.zip = '07897';
        objAddPaymentPlan.amount = '';
        objAddPaymentPlan.planType = 'promise';
        objAddPaymentPlan.planValue = '100';
        objAddPaymentPlan.executeOnDay = '10';
        objAddPaymentPlan.cvv = 'test';
        objAddPaymentPlan.state = 'test';
        objAddPaymentPlan.address = 'test';
        objAddPaymentPlan.city = 'test';
        objAddPaymentPlan.doNext();

        Test.startTest();

        TestUtility.status = 'CREATED';
        TestUtility.statusCode = 201;
        TestUtility.responsebody = PaymentPlanJSONParsing.testResponse();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorTest());
        objAddPaymentPlan.doSubmit();
        Test.stopTest();

        // Check system assert.
        List<ApexPages.Message> msgList = ApexPages.getMessages();
        Boolean isError = false;
        for (ApexPages.Message msg: msgList) {
            if (msg.getDetail().contains(Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO)) isError = true;
        }
        System.assert(isError, 'Expected ' + Constants.PAGE_MESSAGE_AMOUNT_GREATER_THAN_ZERO + ' error message');
    }

    /**
     * This method tests the logic of Charge Group List.
     **/
    @isTest
    static void testChargeGroupList() {
        // Create contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create charge group record with account sub status equals to overdue.
        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        objCG.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_OVERDUE;
        INSERT objCG;

        // Create transaction record to populate balance in CG.
        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        INSERT transactionObj;

        Test.startTest();
        // Create AddPaymentPlanVFController class object.
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();
        List<ChargeGroupWrapper> chargeGroups = objAddPaymentPlan.chargeGroupList;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, chargeGroups.size(), 'Expected Charge Groups size equals to 1 but we got ' + chargeGroups.size());
    }

    /**
     * This method tests the logic of Charge Group List with multiple CGs.
     **/
    @isTest
    static void testChargeGroupListWithMultiple() {
        // Create contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        // Create charge group record with account sub status equals to Delinquent.
        Charge_Group__c objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 13);
        objCG.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_DELINQUENT;
        INSERT objCG;

        // Create transaction record to populate balance in CG.
        Transaction__c transactionObj = TestUtility.generateTransaction(objCG, 100, 'Automatic');
        INSERT transactionObj;

        // Create charge group record with account sub status equals to Pre-Invoiced.
        objCG = TestUtility.generateChargeGroup(guarantorContact.Id, null, 1321212);
        objCG.Account_Sub_Status__c = Constants.ACCT_SUBSTATUS_PREINVOICED;
        INSERT objCG;

        // Create transaction record to populate balance in CG.
        transactionObj = TestUtility.generateTransaction(objCG, 500, 'Automatic');
        INSERT transactionObj;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('guarantorId', guarantorContact.Id);
        AddPaymentPlanVFController objAddPaymentPlan = new AddPaymentPlanVFController();
        List<ChargeGroupWrapper> chargeGroups = objAddPaymentPlan.chargeGroupList;
        Test.stopTest();

        // Check system assert.
        System.assertEquals(1, chargeGroups.size(), 'Expected Charge Groups size equals to 1 but we got ' + chargeGroups.size());
    }
}