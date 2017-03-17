/**
 * Created by mmartin on 3/14/17.
 */
@IsTest
public with sharing class GuarantorDaoTest {

    private static String GT_SIRONO_ID = '12345';


    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = Decimal.valueOf(GT_SIRONO_ID);
        INSERT gt;
        System.debug('gt.Id: '+gt.Id);

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(GT_SIRONO_ID);
        INSERT pt;
        System.debug('pt.Id: '+pt.Id);

    }

    @isTest
    public static void getGTBySironoIdTest() {
        Contact gt = GuarantorDao.getGuarantorBySironoId(GT_SIRONO_ID);
        System.assertNotEquals(gt, null, 'Expected guarantor but got null');
        System.assertEquals(GT_SIRONO_ID, String.valueOf(gt.Profile_Pointer_ID__c), 'Expected Sirono_ID__c of '+GT_SIRONO_ID+' but got: '+gt.Profile_Pointer_ID__c);
        System.assertEquals(RecordTypeUtil.guarantorRt, gt.RecordTypeId, 'Expected RecordTypeId of '+RecordTypeUtil.guarantorRt+' but got: '+gt.RecordTypeId);
    }
}