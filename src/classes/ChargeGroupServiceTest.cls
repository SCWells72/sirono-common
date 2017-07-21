
/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@isTest
public with sharing class ChargeGroupServiceTest {
    public static final Decimal cgOneSironoId = 54321;
    public static final Decimal cgTwoSironoId = 12345;

    @TestSetup
    public static void setup() {

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
    }

    @isTest
    public static void testGetBySironoIds() {
        List<Charge_Group__c> result;

        Test.startTest();
        result = ChargeGroupService.getBySironoIds(new List<Decimal>{cgOneSironoId, cgTwoSironoId});
        Test.stopTest();

        System.assertEquals(2, result.size(), 'Should have found the two cgs.');
    }

    @isTest
    public static void testRetrieveMapByIds() {
        Test.setMock(HttpCalloutMock.class, new ChargeGroupRestClientMock());

        Test.startTest();
        Map<Decimal, ChargeGroupJSONParsing> cgMap = ChargeGroupService.retrieveMapByIds(new List<Decimal> {
            Decimal.valueOf(RestClientConstants.CHARGE_GROUP_ID)
        });
        Test.stopTest();

        System.assertEquals(1, cgMap.size(), 'Should have single results.');

    }

    @isTest
    public static void testRetrieveBySironoId() {
        Test.setMock(HttpCalloutMock.class, new ChargeGroupRestClientMock());

        String sironoId = RestClientConstants.CHARGE_GROUP_ID;
        ChargeGroupJSONParsing expected = ChargeGroupRestClientMock.getParsedChargeGroup();

        Test.startTest();
        ChargeGroupJSONParsing result = ChargeGroupService.retrieveBySironoId(sironoId);
        Test.stopTest();

        System.assert(result != null, 'Should get a result.');
        System.assertEquals(expected.active, result.active, 'Should equal expected result.');
        System.assertEquals(expected.url, result.url, 'Should equal expected result.');
    }

    @isTest
    public static void testGetSironoIds() {
        List<Charge_Group__c> cgs = [
            SELECT Id, Sirono_ID__c
            FROM Charge_Group__c
        ];

        Test.startTest();
        List<Decimal> sironoIds = ChargeGroupService.getSironoIds(cgs);
        Test.stopTest();

        System.assertEquals(2, sironoIds.size(), 'Should have the two ids.');
        Set<Decimal> sironoIdSet = new Set<Decimal>(sironoIds);
        System.assert(sironoIdSet.contains(cgOneSironoId), 'Should have the first cgSironoId.');
        System.assert(sironoIdSet.contains(cgTwoSironoId), 'Should have the second cgSironoId.');

    }

}