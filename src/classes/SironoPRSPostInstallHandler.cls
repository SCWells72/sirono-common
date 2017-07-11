/**
 * Perform setup needed after installing the package
 */

public with sharing class SironoPRSPostInstallHandler implements InstallHandler {

    public void onInstall(InstallContext context) {
        initializeSironoSettings();
    }

    public static void initializeSironoSettings() {
        Sirono_Settings__c sironoSettings = Sirono_Settings__c.getValues(UserInfo.getOrganizationId());
        if (sironoSettings == null) {
            sironoSettings = new Sirono_Settings__c();

            SironoSettingsUtil.setNamespacePrefixes(sironoSettings);
            SironoSettingsUtil.setProcessBuilderIds(sironoSettings);

            INSERT sironoSettings;
        }
    }
}