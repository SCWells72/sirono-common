/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This class tests methods implemented in PopulateNextPaymentDateBatch class.
 **/
@isTest
public class PopulateNextPaymentDateBatchTest {
    
    /**
     * This method checks Next Payment Date gets Populated.
     **/
    static testMethod void checkNextPaymentDatePopulated() {
        Contact guarantorContact = TestUtility.generateGuarantorContact();
        INSERT guarantorContact;

        Contact patientContact = TestUtility.generatePatientContact();
        INSERT patientContact;

        Payment_Plan__c paymentPlan = TestUtility.generatePaymentPlan(guarantorContact.Id);
        INSERT paymentPlan;

        Test.startTest();

        PopulateNextPaymentDateBatch eosb = new PopulateNextPaymentDateBatch();
        system.schedule('schJob', '0 11 22 * 9 ?', eosb);
        Test.stopTest();

        // Check system assert, Check NextPaymentDate__c should be populated.
        List<Payment_Plan__c> paymentPlans = [SELECT Id, NextPaymentDate__c FROM Payment_Plan__c
                WHERE Guarantor__c = :guarantorContact.Id];
        System.assertNotEquals(paymentPlans[0].NextPaymentDate__c, null, 'NextPaymentDate__c should not be null for Payment Plan.');
    }

    /**
     * This method verifies CRON expression that is generated internally.
     **/
    static testMethod void checkInternalCRONExpression() {
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new PopulateNextPaymentDateBatch());

        Test.stopTest();

        // Get the information from the CronTrigger object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        // Check expressions are the same, CRON Expression should be same.
        System.assertEquals(CRON_EXP, ct.CronExpression, 'CRON Expression does not match with submitted job.');
    }
}