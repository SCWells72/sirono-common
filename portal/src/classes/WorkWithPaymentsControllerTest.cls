/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class WorkWithPaymentsControllerTest {

    @IsTest static void getPaymentHistoryTest() {
        User portalUser = PortalTestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = PortalTestUtility.getPortalGuarantor();
        User adminUser = PortalTestUtility.getPortalAdminUser();

        System.runAs(adminUser) {

            Map<String, String> recordTypeMap = new Map<String, String>();
            for (RecordType recordType : [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = 'sPRS__Payment_Method__c'
            ]) {
                recordTypeMap.put(recordType.Name, recordType.Id);
            }

            sPRS__Payment_Method__c pmCreditCard = PortalTestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Credit Card'));
            pmCreditCard.sPRS__Card_Type__c = 'Visa';
            pmCreditCard.sPRS__Last_4__c = '1111';

            sPRS__Payment_Method__c pmCheck = PortalTestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Check/Cash'));

            List<sPRS__Payment_Method__c> paymentMethods = new List<sPRS__Payment_Method__c> { pmCreditCard, pmCheck };
            insert paymentMethods;

            sPRS__Payment__c payment1 = PortalTestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
            payment1.sPRS__Payment_Method__c = pmCreditCard.Id;
            payment1.sPRS__Method__c = 'Credit';

            sPRS__Payment__c payment2 = PortalTestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
            payment2.sPRS__Payment_Method__c = pmCheck.Id;
            payment2.sPRS__Method__c = 'Check';
            payment2.sPRS__Processor_Transaction_Id__c = '12345qwert';

            List<sPRS__Payment__c> payments = new List<sPRS__Payment__c> { payment1, payment2 };
            insert payments;
        }

        System.runAs(portalUser) {
            Test.startTest();

            List<WorkWithPaymentsController.PaymentsWrapper> paymentsList = WorkWithPaymentsController.getPaymentHistory();
            System.assertEquals(2, paymentsList.size());
            for (WorkWithPaymentsController.PaymentsWrapper pw : paymentsList) {
                if (pw.method == 'Credit') {
                    System.assertEquals('Visa 1111', pw.description);
                } else {
                    System.assertEquals('12345qwert', pw.description);
                }
            }
            Test.stopTest();
        }
    }
}