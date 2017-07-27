/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class PaymentDaoTest {
	/**
     * This method is used to test PaymentDao.insertPayment method
     **/
    static testMethod void insertPaymentTest() {
        // Create Guarantor Contact record.
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        insert guarantorContact;

        // Create Encounter record.
        Encounter__c selectedEncounter = TestUtility.generateEncounter(guarantorContact.Id, 500, System.today());
        insert selectedEncounter;

        Payment__c payment = new Payment__c(
            Name = 'Test Payment',
            Guarantor__c = guarantorContact.Id,
            Amount__c = 123,
            Encounter__c = selectedEncounter.Id,
            Deposit_Date__c = System.now(),
            Method__c = null
        );

        Test.startTest();
        // Pass list of payment object because of Security Scan issue
        PaymentDao.insertPayment(new List<Payment__c> { payment });

        List<Payment__c> paymentList = [
            SELECT Id, Name
            FROM Payment__c
        ];
        // Check that record was created
        System.assertEquals(paymentList.size(), 1);
        Test.stopTest();
    }

    /**
    * Check all access rights for a read only User using runAs.
    **/
    @IsTest
    static void checkAccessRights() {
        List<PaymentSecurityContext> allContexts = new List<PaymentSecurityContext> {
            PaymentSecurityContext.CREATE_CONTEXT,
            PaymentSecurityContext.PSWU_CREATE_CONTEXT,
            PaymentSecurityContext.UPDATE_CONTEXT
        };

        System.runAs(TestUtility.generateReadOnlyUser()) {
            for (PaymentSecurityContext context : allContexts) {
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

    /**
     * Check all Read rights for a Chatter User using runAs.
     **/
    @IsTest
    static void checkAccessRightsForRead() {
        List<PaymentSecurityContext> allContexts = new List<PaymentSecurityContext> {
            PaymentSecurityContext.SELECT_CONTEXT,
            PaymentSecurityContext.EU_SELECT_CONTEXT
        };

        System.runAs(TestUtility.generateChatterOnlyUser()) {
            for (PaymentSecurityContext context : allContexts) {
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