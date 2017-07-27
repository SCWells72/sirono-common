/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Perform setup needed after installing the package
 */
public with sharing class SironoPRSPostInstallHandler implements InstallHandler {

    public void onInstall(InstallContext context) {
        initializeSironoSettings();
    }

    public static void initializeSironoSettings() {
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getOrgDefaults();
        if (sironoSettings.Id == null) {
            SironoSettingsUtil.setNamespacePrefixes(sironoSettings);
            insert sironoSettings;
        }
    }
}