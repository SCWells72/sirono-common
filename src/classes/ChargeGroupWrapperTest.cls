/**
 * Test ChargeGroupWrapper list construction
 */
@isTest
public with sharing class ChargeGroupWrapperTest {


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
    }

    @isTest
    public static void buildListTest(){
        Contact gt = [SELECT Id FROM Contact WHERE RecordTypeId = :RecordTypeUtil.guarantorRt];
        gt = GuarantorService.getGuarantorWithActiveCG(gt.Id);

        List<ChargeGroupWrapper> wrapperList = ChargeGroupWrapper.buildList(gt);

        System.assertEquals(gt.Charge_Groups__r.size(), wrapperList.size(),
                'Expected '+gt.Charge_Groups__r.size()+' cg wrappers but got: '+wrapperList.size());
    }

    @isTest
    public static void buildEmptyListTest(){
        Contact gt = TestUtility.generateGuarantorContact();

        List<ChargeGroupWrapper> wrapperList = ChargeGroupWrapper.buildList(gt);

        System.assertEquals(gt.Charge_Groups__r.size(), wrapperList.size(),
                'Expected '+gt.Charge_Groups__r.size()+' cg wrappers but got: '+wrapperList.size());
    }

    @isTest
    public static void buildEmptyListNullTest(){
        Contact gt = null;

        List<ChargeGroupWrapper> wrapperList = ChargeGroupWrapper.buildList(gt);

        System.assertEquals(wrapperList.size(), 0, 'Expected 0 cg wrappers but got: '+wrapperList.size());
    }

    @isTest
    public static void buildEmptyListNullTest2(){
        Charge_Group__c[] cgList = null;

        List<ChargeGroupWrapper> wrapperList = ChargeGroupWrapper.buildList(cgList);

        System.assertEquals(wrapperList.size(), 0, 'Expected 0 cg wrappers but got: '+wrapperList.size());
    }
}