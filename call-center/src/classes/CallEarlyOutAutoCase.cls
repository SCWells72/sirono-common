/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * This Scheduled Class is Executed Every Day and it will create a case for the Early Out
 */
global class CallEarlyOutAutoCase implements Schedulable {

    global void execute(SchedulableContext sc) {
        CaseUtil.callEarlyOutAutoCaseCloser();
    }
}