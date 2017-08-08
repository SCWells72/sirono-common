/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Controller used by lighting components to get application settings information.
 */
public with sharing class SettingsController {

    public static final String FINANCIAL_AID_NAME = 'financialAidName';
    public static final String HAS_PDF = 'hasFinancialAidPDF';

    /**
     * Get the settings for the portal application.
     *
     * @return Map<String, Object> A map containing settings properies specific to the portal.
     */
    @AuraEnabled
    public static Map<String, Object> getSironoSettings() {
        Map<String, Object> settings = new Map<String, Object>();
        settings.put(HAS_PDF, false);

        try {
            Sirono_Portal_Settings__c portalSettings = Sirono_Portal_Settings__c.getInstance(UserInfo.getProfileId());

            if (portalSettings != null) {
                settings.put(HAS_PDF, String.isNotEmpty(portalSettings.Financial_Aid_Document__c));
                settings.put(FINANCIAL_AID_NAME, portalSettings.Financial_Aid_Document__c);
            }
        } catch (Exception ex) {
            System.debug('Exception encountered when getting settings: ' + ex.getMessage());
            throw LightningUtil.newAuraHandledException('Failed to retrieve settings.');
        }

        return settings;
    }
}