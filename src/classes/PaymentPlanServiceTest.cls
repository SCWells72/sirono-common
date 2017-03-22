/**
 * Test the PaymentPlanService
 */
@isTest
public with sharing class PaymentPlanServiceTest {

    private static String PLAN_SIRONO_ID = '2876';
    private static Decimal CG_TO_ADD_ID = 123456;

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = 23232323;
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        INSERT pt;

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(gt);
        pp.Plan_Type__c = Constants.AUTOMATIC;
        pp.Sirono_ID__c = Decimal.valueOf(PLAN_SIRONO_ID);
        pp.CreatedDate = Datetime.now().addDays(-3);
        pp.Plan_Value_Modified_Date__c = pp.CreatedDate;
        INSERT pp;

        Charge_Group__c cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, 12345, pp.id);
        cg.Sirono_ID__c = 12345;
        INSERT cg;

        Service__c svc = TestUtility.generateService(cg, 450.00);
        INSERT svc;

        Transaction__c txn = TestUtility.generateServiceTxn(cg, svc.Amount__c, svc);
        INSERT txn;

        cg = TestUtility.generateChargeGroup(gt.Id, pt.Id, CG_TO_ADD_ID);
        cg.Sirono_ID__c = CG_TO_ADD_ID;
        INSERT cg;

        svc = TestUtility.generateService(cg, 200.00);
        INSERT svc;

        txn = TestUtility.generateServiceTxn(cg, svc.Amount__c, svc);
        INSERT txn;
    }

    /*
     *
     * Test adding a chargegroup to an existing paymentplan
     */
    @isTest
    public static void testAddChargeGroup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        PaymentPlanService.addChargeGroups(PLAN_SIRONO_ID, new String[]{String.valueOf(CG_TO_ADD_ID)});
        Test.stopTest();

        Payment_Plan__c pp = [
                SELECT Id, Sirono_ID__c, Plan_Value_Modified_Date__c, CreatedDate
                FROM Payment_Plan__c
                WHERE Sirono_ID__c = :Decimal.valueOf(PLAN_SIRONO_ID)
                LIMIT 1
        ];

        Charge_Group__c[] cgs = [SELECT Id, Sirono_ID__c, Payment_Plan__c FROM Charge_Group__c WHERE Payment_Plan__c = :pp.Id];

        System.assert(cgs.size() == 2, 'Expected 2 cgs on the payment plan, but had '+cgs.size());
        System.assert(pp.Plan_Value_Modified_Date__c > pp.CreatedDate,
                'Expected Plan_Value_Modified_Date__c ('+pp.Plan_Value_Modified_Date__c+
                        ') > pp.CreatedDate ('+pp.CreatedDate+')');
    }

    /*
     *
     * Test adding a bad chargegroupId to an existing paymentplan
     */
    @isTest
    public static void testAddBadChargeGroupId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Boolean expectedFailure = false;
        Test.startTest();
        try {
            PaymentPlanService.addChargeGroups(PLAN_SIRONO_ID, new String[]{'1962'});
        } catch (SironoServiceException ex) {
            System.assertEquals('Unknown chargegroup requested: 1962', ex.getMessage());
            expectedFailure = true;
        }
        Test.stopTest();

        System.assert(expectedFailure, 'Exception expected adding unknown chargegroupId');
    }

    /*
     *
     * Test adding a chargegroupId to a non-existing paymentplan
     */
    @isTest
    public static void testAddChargeGroupBadPlanId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Boolean expectedFailure = false;
        Test.startTest();
        try {
            PaymentPlanService.addChargeGroups('1492', new String[]{String.valueOf(CG_TO_ADD_ID)});
        } catch (SironoServiceException ex) {
            System.assertEquals('Unknown Payment Plan: 1492', ex.getMessage());
            expectedFailure = true;
        }
        Test.stopTest();

        System.assert(expectedFailure, 'Exception expected adding to unknown payment plan');
    }

    @isTest
    public static void testPlanJSONParsing() {
        Test.startTest();

        PaymentPlanService.PaymentPlanJSONParser parser = new PaymentPlanService.PaymentPlanJSONParser(MockHttpResponseGenerator.getPaymentPlanJSONBody());
        Payment_Plan__c pp = parser.parseAsPaymentPlan();

        Test.stopTest();

        System.assertEquals(pp.Name, '2876', 'Plan Name is: '+pp.Name);
        System.assertEquals(pp.Sirono_ID__c, Decimal.valueOf(PLAN_SIRONO_ID), 'Plan sirono_id is: '+pp.Sirono_ID__c);
        System.assertEquals(pp.Installment_Amount__c, 50,'Expected Installment_Amount to be 50, but was: '+pp.Installment_Amount__c);
        System.assert(pp.Active__c,'Expected Plan to be active, but was not');
        System.assertEquals(pp.Original_Balance__c, 327.72,'Expected Plan Original_Balance__c to be 327.72, but was: '+pp.Original_Balance__c);
        System.assertEquals(pp.Plan_Type__c, Constants.AUTOMATIC,'Expected Plan_Type__c to be Automatic, but was: '+pp.Plan_Type__c);
        System.assertEquals(pp.Remaining_Balance__c, 327.72,'Expected Plan Remaining_Balance__c to be 327.72, but was: '+pp.Remaining_Balance__c);
        System.assertEquals(pp.Status__c, 'started', 'Expected Status__c to be "started", but was: '+pp.Status__c);
        System.assertEquals(pp.NextPaymentDate__c, Date.newInstance(2017, 05, 13), 'Expected NextPaymentDate__c to be "2017-05-13", but was: '+pp.NextPaymentDate__c);
    }
}