/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Test Class for the CallEarlyOutAutoCase class
 */
@IsTest
private class CallEarlyOutAutoCaseTest {


    public static String cronExp = '0 0 0 15 3 ? 2022';

    static testMethod void test() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',
            cronExp,
            new CallEarlyOutAutoCase());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered,
                NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        // Verify the expressions are the same
        System.assertEquals(cronExp,
            ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);


    }
}