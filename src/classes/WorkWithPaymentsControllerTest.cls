/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class WorkWithPaymentsControllerTest {

    @IsTest static void getPaymentHistoryTest() {
        User portalUser = TestUtility.getGuarantorCommunityUser();
        Contact guarantorContact = TestUtility.getPortalGuarantor();
        User adminUser = TestUtility.getPortalAdminUser();

        System.runAs(adminUser) {

            Map<String, String> recordTypeMap = new Map<String, String>();
            for (RecordType recordType : [
                SELECT Id, Name
                FROM RecordType
                WHERE SobjectType = 'Payment_Method__c'
            ]) {
                recordTypeMap.put(recordType.Name, recordType.Id);
            }

            Payment_Method__c pmCreditCard = TestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Credit Card'));
            pmCreditCard.Card_Type__c = 'Visa';
            pmCreditCard.Last_4__c = '1111';

            Payment_Method__c pmCheck = TestUtility.generatePaymentMethod(guarantorContact.Id, recordTypeMap.get('Check/Cash'));

            List<Payment_Method__c> paymentMethods = new List<Payment_Method__c> { pmCreditCard, pmCheck };
            insert paymentMethods;

            //TODO Figure out sharing for portal users!
            List<Payment_Method__Share> shares = new List<Payment_Method__Share>();
            for (Payment_Method__c pm : paymentMethods) {
                Payment_Method__Share share = new Payment_Method__Share();
                share.ParentId = pm.Id;
                share.UserOrGroupId = portalUser.Id;
                share.AccessLevel = 'edit';
                shares.add(share);
            }
            insert shares;

            Payment__c payment1 = TestUtility.generateSironoPayment(guarantorContact.Id, 1234, 12);
            payment1.Payment_Method__c = pmCreditCard.Id;
            payment1.Method__c = 'Credit';

            Payment__c payment2 = TestUtility.generateSironoPayment(guarantorContact.Id, 1235, 25);
            payment2.Payment_Method__c = pmCheck.Id;
            payment2.Method__c = 'Check';
            payment2.Processor_Transaction_ID__c = '12345qwert';

            List<Payment__c> payments = new List<Payment__c> { payment1, payment2 };
            insert payments;

            //TODO Figure out sharing for portal users!
            List<Payment__Share> pmtShares = new List<Payment__Share>();
            for (Payment__c pmt : payments) {
                Payment__Share share = new Payment__Share();
                share.ParentId = pmt.Id;
                share.UserOrGroupId = portalUser.Id;
                share.AccessLevel = 'edit';
                pmtShares.add(share);
            }
            insert pmtShares;
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