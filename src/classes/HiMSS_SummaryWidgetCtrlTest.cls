/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class HiMSS_SummaryWidgetCtrlTest {
    static testMethod void getGuarantorInfoTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HiMSS_SummaryWidgetMocks());
        List<HiMSS_SummaryWidgetCtrl.GuarantorWrapper> gwRecordList = HiMSS_SummaryWidgetCtrl.getAllHeaderInfo('true');

        System.assert(gwRecordList[0].grtUser.userName == 'cgreen_1@sirono.com', 'Incorrect username');
        System.assert(gwRecordList[0].grtUser.password == 'p@$$w0rd', 'Incorrect user password');
        System.assert(gwRecordList[0].newEstimatesCount == 1, 'Incorrect new estimates count');
        System.assert(gwRecordList[0].invoiceOverdue.dueDate != null, 'Incorrect invoice');
        System.assert(gwRecordList[0].contact.status == 'Delinquent', 'Incorrect contact status');

        Test.stopTest();
    }
}