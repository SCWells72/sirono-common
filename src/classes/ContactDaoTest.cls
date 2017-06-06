/**
 * This class is use to test the logic of ContactDao class.
 **/

@IsTest
public with sharing class ContactDaoTest {

    private static String SIRONO_ID = '12345';

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        gt.Profile_Pointer_ID__c = Decimal.valueOf(SIRONO_ID);
        INSERT gt;

        Contact pt = TestUtility.generatePatientContact();
        pt.Patient_Id__c = Decimal.valueOf(SIRONO_ID);
        INSERT pt;

        // Check system assert.
        System.assertEquals(Decimal.valueOf(SIRONO_ID), gt.Profile_Pointer_ID__c, 'Expected ' + SIRONO_ID + ' but we got ' + gt.Profile_Pointer_ID__c);
    }

    private static Contact getTestGuarantorContact() {
        return [
                SELECT Id, Profile_Pointer_ID__c
                FROM Contact
                WHERE Profile_Pointer_ID__c =: Decimal.valueOf(SIRONO_ID)
        ];
    }

    private static Contact getTestPatientContact() {
        return [
                SELECT Id, Patient_Id__c
                FROM Contact
                WHERE Patient_Id__c =: Decimal.valueOf(SIRONO_ID)
        ];
    }

    /**
     * This method tests the logic of getContactDetails method For Guarantor.
     **/
    @isTest
    public static void getContactDetailsForGuarantorTest() {
        Contact gt1 = getTestGuarantorContact();

        Test.startTest();
        Contact gt2 = ContactDao.getContactDetails(gt1.Id);
        Test.stopTest();

        // Check system asserts.
        System.assertEquals(gt1.Id, gt2.Id, 'Contact Ids should be the same');
        System.assertEquals(RecordTypeUtil.guarantorRt, gt2.RecordTypeId,
                'Expected RecordTypeId of ' + RecordTypeUtil.guarantorRt + ' but got: ' + gt2.RecordTypeId);
    }

    /**
     * This method tests the logic of getContactDetails method For Patient.
     **/
    @isTest
    public static void getContactDetailsForPatientTest() {
        Contact pt1 = getTestPatientContact();

        Test.startTest();
        Contact pt2 = ContactDao.getContactDetails(pt1.Id);
        Test.stopTest();

        // Check system asserts.
        System.assertEquals(pt1.Id, pt2.Id, 'Contact Ids should be the same');
        System.assertEquals(RecordTypeUtil.patientRt, pt2.RecordTypeId,
                'Expected RecordTypeId of ' + RecordTypeUtil.patientRt + ' but got: ' + pt2.RecordTypeId);
    }
}