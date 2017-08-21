/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class WorkWithEstimatesController {
    //TODO dynamic domain
    public static final String FILE_PREFIX = '/guarantor/servlet/servlet.FileDownload?file=';

    /**
     * Return all the Estimates for the current user. They can also be filtered by whether or not the Encounter is paid,
     * and by patientId
     *
     */
    @AuraEnabled
    public static List<EstimateWrapper> getAllEstimates(String paidFilter, String patientFilter) {
        List<EstimateWrapper> allEstimates = new List<EstimateWrapper>();
        Contact guarantor = sPRS.GuarantorService.getPortalGuarantor(UserInfo.getUserId());

        if (guarantor != null) {
            List<String> patientIds = null;
            if (!String.isBlank(patientFilter)) {
                //patientFilter is a string of Ids in the format:  '00346000004KwR8AAK','00346000004KwRBAA0',
                patientIds = patientFilter.replace('\'', '').split(',');
            }

            List<sPRS__Encounter__c> listOfEncounters = sPRS.EncounterService.getEncountersByGuarantor(guarantor, paidFilter, patientIds);
            System.debug('listOfEncounters :' + listOfEncounters);
            for (sPRS__Encounter__c encounter : listOfEncounters) {
                EstimateWrapper estimate = new EstimateWrapper(encounter);
                allEstimates.add(estimate);
            }
        }
        return allEstimates;
    }

    /**
     * Return all the patients associated with the current user's Encounters
     *
     */
    @AuraEnabled
    public static List<WorkWithInvoicesController.PatientWrapper> getPatientList() {
        List<WorkWithInvoicesController.PatientWrapper> result = new List<WorkWithInvoicesController.PatientWrapper>();
        Contact guarantor = sPRS.GuarantorService.getPortalGuarantor(UserInfo.getUserId());

        if (guarantor == null) {
            return new List<WorkWithInvoicesController.PatientWrapper>();
        }

        List<sPRS__Encounter__c> encounterList = sPRS.EncounterService.getAllPatients(guarantor);

        for (sPRS__Encounter__c encounter : encounterList) {
            result.add(new WorkWithInvoicesController.PatientWrapper(encounter));
        }
        return result;
    }

    public class EstimateWrapper {
        @AuraEnabled sPRS__Encounter__c singleEncounter { get; set; }
        @AuraEnabled Decimal insuranceDiscount { get; set; }
        @AuraEnabled Decimal insurancePortion { get; set; }
        @AuraEnabled String estimateStatus { get; set; }
        @AuraEnabled String fileUrl { get; set; }

        public EstimateWrapper(sPRS__Encounter__c singleEncounter) {
            this.singleEncounter = singleEncounter;
            if (singleEncounter.sPRS__Insurance_Discount__c != null) {
                // TODO update after fields creation
                insuranceDiscount = -singleEncounter.sPRS__Insurance_Discount__c;
            }
            if (singleEncounter.sPRS__Insurance_Portion__c != null) {
                // TODO update after fields creation
                insurancePortion = -singleEncounter.sPRS__Insurance_Portion__c;
            }
            String status = '';
            if (singleEncounter.sPRS__Balance__c > 0 && (singleEncounter.sPRS__Total_Payments__c == null || singleEncounter.sPRS__Total_Payments__c == 0)) {
                status = 'Unpaid';
            } else if ((singleEncounter.sPRS__Balance__c > 0 && singleEncounter.sPRS__Total_Payments__c > 0) || singleEncounter.sPRS__Balance__c <= 0) {
                status = 'Paid';
            }
            this.estimateStatus = status;
            if (singleEncounter.Attachments != null && singleEncounter.Attachments.size() > 0) {
                fileUrl = FILE_PREFIX + singleEncounter.Attachments[0].Id;
            }
        }
    }
}