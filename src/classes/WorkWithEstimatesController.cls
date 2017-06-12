public without sharing class WorkWithEstimatesController {
    //TODO dynamic domain
    public static final String FILE_PREFIX = '/guarantor/servlet/servlet.FileDownload?file=';

    @AuraEnabled
    public static List<EstimateWrapper> getAllEstimates(String groupFilter, String additionalFilter) {
        List<EstimateWrapper> allEstimates = new List<EstimateWrapper>();
        Contact guarantor = GuarantorService.getPortalGuarantor(UserInfo.getUserId());

        if (guarantor != null) {
            List<String> patientIds = null;
            if (!String.isBlank(additionalFilter)) {
                //additionalFilter is a string of the format:  '00346000004KwR8AAK','00346000004KwRBAA0',
                patientIds = additionalFilter.replace('\'', '').split(',');
            }

            List<Encounter__c> listOfEncounters = EncounterService.getEncountersByGuarantor(guarantor, groupFilter, patientIds);
            System.debug('listOfEncounters :' + listOfEncounters);
            for (Encounter__c encounter : listOfEncounters) {
                EstimateWrapper estimate = new EstimateWrapper(encounter);
                allEstimates.add(estimate);
            }
        }
        return allEstimates;
    }

    @AuraEnabled
    public static List<WorkWithInvoicesController.PatientWrapper> getPatientList() {
        List<WorkWithInvoicesController.PatientWrapper> result = new List<WorkWithInvoicesController.PatientWrapper>();
        Contact guarantor = GuarantorService.getPortalGuarantor(UserInfo.getUserId());

        if (guarantor == null) {
            return new List<WorkWithInvoicesController.PatientWrapper>();
        }

        List<Encounter__c> estimateList = EncounterService.getAllPatients(guarantor);

        for (Integer i = 0; i < estimateList.size(); i++) {
            result.add(new WorkWithInvoicesController.PatientWrapper(estimateList[i]));
        }
        return result;
    }

    public class EstimateWrapper {
        @AuraEnabled Encounter__c singleEncounter { get; set; }
        @AuraEnabled Decimal insuranceDiscount { get; set; }
        @AuraEnabled Decimal insurancePortion { get; set; }
        @AuraEnabled String estimateStatus { get; set; }
        @AuraEnabled String fileUrl { get; set; }

        public EstimateWrapper(Encounter__c singleEncounter) {
            this.singleEncounter = singleEncounter;
            if (singleEncounter.Insurance_Discount__c != null)
                insuranceDiscount = -singleEncounter.Insurance_Discount__c; // TODO update after fields creation
            if (singleEncounter.Insurance_Portion__c != null)
                insurancePortion = -singleEncounter.Insurance_Portion__c; // TODO update after fields creation
            String status = '';
            if (singleEncounter.Balance__c > 0 && (singleEncounter.Total_Payments__c == null || singleEncounter.Total_Payments__c == 0)) {
                status = 'Unpaid';
            } else if ((singleEncounter.Balance__c > 0 && singleEncounter.Total_Payments__c > 0) || singleEncounter.Balance__c <= 0) {
                status = 'Paid';
            }
            this.estimateStatus = status;
            if (singleEncounter.Attachments != null && singleEncounter.Attachments.size() > 0) {
                fileUrl = FILE_PREFIX + singleEncounter.Attachments[0].Id;
            }
        }
    }
}