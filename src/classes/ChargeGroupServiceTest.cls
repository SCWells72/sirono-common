@isTest
public with sharing class ChargeGroupServiceTest {

    @isTest
    public static void testRetrieveBySironoId() {

    }

    @isTest
    public static void testGetSironoIds() {
        Decimal cgOneSironoId = 54321;
        Decimal cgTwoSironoId = 12345;

        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = 23232323;
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        INSERT pt;

        Datetime createdDT = Datetime.now().addDays(-3);

        Payment_Plan__c pp = TestUtility.generatePaymentPlan(gt);
        pp.Plan_Type__c = Constants.AUTOMATIC;
        pp.Sirono_ID__c = 33556677;
        pp.Plan_Value_Modified_Date__c = createdDT;
        INSERT pp;
        Test.setCreatedDate(pp.Id, createdDT);

        List<Charge_Group__c> cgs = new List<Charge_Group__c>();
        cgs.add(TestUtility.generateChargeGroup(gt.Id, pt.Id, cgOneSironoId, pp.id));
        cgs.get(0).Sirono_ID__c = cgOneSironoId;
        cgs.add(TestUtility.generateChargeGroup(gt.Id, pt.Id, cgTwoSironoId, pp.id));
        cgs.get(1).Sirono_ID__c = cgTwoSironoId;

        INSERT cgs;

        Test.startTest();
        List<Decimal> sironoIds = ChargeGroupService.getSironoIds(cgs);
        Test.stopTest();

        System.assertEquals(2, sironoIds.size(), 'Should have the two ids.');
        Set<Decimal> sironoIdSet = new Set<Decimal>(sironoIds);
        System.assert(sironoIdSet.contains(cgOneSironoId), 'Should have the first cgSironoId.');
        System.assert(sironoIdSet.contains(cgTwoSironoId), 'Should have the second cgSironoId.');

    }

}