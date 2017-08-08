/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
public with sharing class SettingsControllerTest {

    @IsTest
    public static void testGetSironoSettingsNoFinancialAidDoc() {

        Test.startTest();
        Map<String, Object> settings = SettingsController.getSironoSettings();
        Test.stopTest();

        System.assertEquals(false, settings.get(SettingsController.HAS_PDF), 'Should not have a document.');
        System.assert(settings.containsKey(SettingsController.FINANCIAL_AID_NAME), 'Should have a static resource name.');
        System.assertEquals(null, settings.get(SettingsController.FINANCIAL_AID_NAME), 'Should have null name by default.');

    }

    @IsTest
    public static void testGetSironoSettingsFinancialAidDoc() {
        Sirono_Portal_Settings__c sironoSettings = new Sirono_Portal_Settings__c();
        sironoSettings.Financial_Aid_Document__c = 'TestDoc';

        insert sironoSettings;

        Test.startTest();
        Map<String, Object> settings = SettingsController.getSironoSettings();
        Test.stopTest();

        System.assertEquals(true, settings.get(SettingsController.HAS_PDF), 'Should have a document.');
        System.assert(settings.containsKey(SettingsController.FINANCIAL_AID_NAME), 'Should have a static resource name.');
        System.assertEquals(sironoSettings.Financial_Aid_Document__c, settings.get(SettingsController.FINANCIAL_AID_NAME), 'Should have correct name.');

    }
}