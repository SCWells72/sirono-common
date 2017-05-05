/**
 * Test the ChargeGroupDao methods
 */
@isTest
public with sharing class ChargeGroupDaoTest {

    @TestSetup
    public static void setup() {
        Contact gt = TestUtility.generateGuarantorContact();
        INSERT gt;
        System.debug('gt.Id: '+gt.Id);

        List<Charge_Group__c> cgToAddList = TestUtility.generateChargeGroupList(gt.Id);
        Decimal i = 1;
        for (Charge_Group__c cg : cgToAddList) {
            cg.Sirono_ID__c = i++;
        }

        INSERT cgToAddList;

        // Check system assert.
        System.assertEquals(1, cgToAddList[0].Sirono_ID__c, 'Expected Chargegroup Sirono_ID__c equals to 1 but we got '+ cgToAddList[0].Sirono_ID__c);
    }

    @isTest
    public static void getBySironoIdsAllFoundTest(){

        List<Decimal> cgSironoIds = new Decimal[]{1, 3, 5, 10};

        Test.startTest();
        Charge_Group__c[] cgs = ChargeGroupDao.getBySironoIds(cgSironoIds);
        Test.stopTest();

        Map<Decimal, Charge_Group__c> cgMap = new Map<Decimal, Charge_Group__c>();
        for (Charge_Group__c cg : cgs) {
            cgMap.put(cg.Sirono_ID__c, cg);
        }

        for (Decimal sironoId : cgSironoIds) {
            System.assert(cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: '+sironoId+' not in result set');
        }
    }


    @isTest
    public static void getBySironoIdsNotAllFoundTest(){

        List<Decimal> cgSironoIds = new Decimal[]{1, 3, 5, 10, 99};

        Test.startTest();
        Charge_Group__c[] cgs = ChargeGroupDao.getBySironoIds(cgSironoIds);
        Test.stopTest();

        Map<Decimal, Charge_Group__c> cgMap = new Map<Decimal, Charge_Group__c>();
        for (Charge_Group__c cg : cgs) {
            cgMap.put(cg.Sirono_ID__c, cg);
        }

        for (Decimal sironoId : cgSironoIds) {
            if (sironoId != 99) {
                System.assert(cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' not in result set');
            } else {
                System.assert(!cgMap.containsKey(sironoId), 'ChargeGroup with sironoId: ' + sironoId + ' was in result set');
            }
        }
    }

    @isTest
    public static void updateChargeGroupsTest(){

        Charge_Group__c[] cgs = [SELECT Id, Name, Sirono_ID__c FROM Charge_Group__c];

        for (Charge_Group__c cg : cgs) {
            cg.Name = 'test_name_'+cg.Sirono_ID__c;
        }

        Test.startTest();
        ChargeGroupDao.updateChargeGroups(cgs);
        Test.stopTest();

        cgs = [SELECT Id, Name, Sirono_ID__c FROM Charge_Group__c];

        for (Charge_Group__c cg : cgs) {
            String newName = 'test_name_'+cg.Sirono_ID__c;
            System.assertEquals(cg.Name, newName, 'Chargegroup name expected: '+newName+' but is: '+cg.Name);
        }
    }

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @isTest
    static void checkAccessRightsForRead() {
        List<ChargeGroupSecurityContext> allContexts = new List<ChargeGroupSecurityContext>{ChargeGroupSecurityContext.SELECT_CONTEXT,
                ChargeGroupSecurityContext.GD_SELECT_CONTEXT, ChargeGroupSecurityContext.IU_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (ChargeGroupSecurityContext context: allContexts) {
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