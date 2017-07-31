/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * WorkWithInvoicesController for Lightning components dealing with Invoices.
 */
public with sharing class WorkWithInvoicesController {

    /**
     * Get all invoices for the current user.
     *
     * @param {String} groupFilter - A optional String intdicating which invoice status values to filter by.  Valid values are ALL,
     * Paid, UnPaid, or a specfic status.
     * @param {List<String>} partientsFilter - A list of patient ids for which to include invoices.
     *
     * @returns List<InvoicesWrapper> - The List of InvoicesWrapper objects.
     */
    @AuraEnabled
    public static List<InvoicesWrapper> getAllInvoices(String groupFilter, List<String> patientsFilter) {
        System.debug('getAllInvoices: [groupFilter: ' + groupFilter + '] [patientFilters: ' + patientsFilter + ']');
        List<InvoicesWrapper> allInvoices = new List<InvoicesWrapper>();

        UserWrapper user = UserService.getCurrentUser();

        if (user.contactId != null) {
            allInvoices = getInvoicesForUser(user, groupFilter, patientsFilter);
        }
        return allInvoices;
    }

    /**
     * Get the Estimates for the current user.
     *
     * @param {String} groupFilter - filter to return only 'Paid', 'Unpaid' encounters. If null == 'All'
     * @param {String} additionFilter - comma delimited list of patient ids.
     * @returns {List<EstimateWrapper>} - The list of wrapped estimates.
     */
    @AuraEnabled
    public static List<WorkWithEstimatesController.EstimateWrapper> getAllEstimates(String groupFilter, String additionalFilter) {
        if (additionalFilter == 'null') {
            return new List<WorkWithEstimatesController.EstimateWrapper>();
        }
        return WorkWithEstimatesController.getAllEstimates(groupFilter, additionalFilter);
    }

    /**
     * Get the list of estimates for an invoice.
     *
     * @param String invoiceId - The invoice id.
     * @returns List<WorkWithEstimatesController.EstimateWrapper> - The list of estimate wrapper object related to the invoice.
     */
    @AuraEnabled
    public static List<WorkWithEstimatesController.EstimateWrapper> getEstimate(String invoiceId) {
        List<WorkWithEstimatesController.EstimateWrapper> allEstimates = new List<WorkWithEstimatesController.EstimateWrapper>();
        UserWrapper user = UserService.getCurrentUser();

        if (user.contactId != null) {
            List<Encounter__c> listOfEncounters = EncounterService.getForInvoice(user.contactId, invoiceId);

            for (Encounter__c encounter : listOfEncounters) {
                allEstimates.add(new WorkWithEstimatesController.EstimateWrapper(encounter));
            }
        }
        return allEstimates;
    }

    /**
     * Get an InvoiceWrapper by invoice id.
     *
     * @params String invoiceId - The invoice id.
     * @returns InvoicesWrapper - The InvoicesWrapper object for the associated Invoice.
     */
    @AuraEnabled
    public static List<InvoicesWrapper> getInvoice(String invoiceId) {
        List<InvoicesWrapper> allInvoices = new List<InvoicesWrapper>();
        UserWrapper user = UserService.getCurrentUser();

        if (user.contactId != null) {
            List<Invoice__c> listOfInvoices = InvoiceService.getInvoiceDetails(user.contactId, invoiceId);
            allInvoices = convertToInvoiceWrappers(listOfInvoices);
        }

        return allInvoices;
    }

    /**
     * Convert a list of Invoice__c object to InvoicesWrappers.
     *
     * @param {List<Invoice__c> invoices - The list of invoice objects.
     * @returns {List<InvoicesWrapper> - The list of InvoicesWrapper objects.
     */
    public static List<InvoicesWrapper> convertToInvoiceWrappers(List<Invoice__c> invoices) {
        List<InvoicesWrapper> invoiceWrappers = new List<InvoicesWrapper>();

        if (invoices.size() > 0) {

            Set<Id> allChargeGroupIds = InvoiceService.getChargeGroupIds(invoices);

            // Get Charge Group List from ChargeGroupService class. Second parameter is use to get the order by result.
            List<Charge_Group__c> allGroups = ChargeGroupService.getCGForInvoiceController(allChargeGroupIds, true);

            Map<Id, Charge_Group__c> allGroupsMap = new Map<Id, Charge_Group__c>(allGroups);

            for (Invoice__c invoice : invoices) {
                invoiceWrappers.add(new InvoicesWrapper(invoice, allGroupsMap));
            }
        }

        return invoiceWrappers;
    }

    /**
     * Get the List of PatientWrappsers for the current user.
     */
    @AuraEnabled
    public static List<PatientWrapper> getPatientList() {
        List<PatientWrapper> patients = new List<PatientWrapper>();

        UserWrapper user = UserService.getCurrentUser();

        if (user.contactId == null) {
            return patients;
        }

        List<Invoice__c> invoiceList = InvoiceService.getPatientInvoices(user.contactId);
        for (Invoice__c inv : invoiceList) {
            patients.add(new PatientWrapper(inv));
        }
        return patients;
    }

    /**
     * Get the List of InvoicesWrapper for the a user.
     *
     * @param UserWrapper user - The user for which to get the invoices.
     * @param String groupFilter - The status to filter by.  Options are All, Constants.UNPAID, Constants.PAID, or a particular status value.
     * @param List<String> patients - A list of the Ids of the patients to filter by.
     *
     * @returns List<InvoicesWrapper> - The list of wrapped Invoices.
     */
    private static List<InvoicesWrapper> getInvoicesForUser(UserWrapper user, String groupFilter, List<String> patients) {

        List<Invoice__c> listOfInvoices = new List<Invoice__c>();
        Set<String> invoiceStatuses = new Set<String>();
        if (groupFilter != null && groupFilter != '' && groupFilter != 'All') {
            if (groupFilter == Constants.UNPAID) {
                invoiceStatuses = Constants.INVOICE_UNPAID_STATUSES;
            } else if (groupFilter == Constants.PAID) {
                invoiceStatuses = Constants.INVOICE_PAID_STATUSES;
            } else {
                invoiceStatuses.add(groupFilter);
            }
        }

        listOfInvoices = InvoiceService.getInvoicesForUser(user.contactId, invoiceStatuses, patients);

        return convertToInvoiceWrappers(listOfInvoices);
    }

    public class InvoicesWrapper {
        @AuraEnabled Invoice__c singleInvoice { get; set; }
        @AuraEnabled Decimal balanceDue { get; set; }
        @AuraEnabled public List<ChargeGroupWrapper> allGroups { get; set; }
        @AuraEnabled Decimal nextPayment { get; set; }
        @AuraEnabled Date nextDate { get; set; }

        public InvoicesWrapper(Invoice__c invoice, Map<Id, Charge_Group__c> allGroupsMap) {
            this.singleInvoice = invoice;
            this.balanceDue = invoice.Invoice_Balance__c;

            allGroups = new List<ChargeGroupWrapper>();

            for (Charge_Group__c cGroup : invoice.Charge_Groups__r) {
                allGroups.add(new ChargeGroupWrapper(allGroupsMap.get(cGroup.Id)));

                if (cGroup.Payment_Plan__c != null) {
                    this.nextPayment = cGroup.Payment_Plan__r.Installment_Amount__c;
                    this.nextDate = cGroup.Payment_Plan__r.NextPaymentDate__c;
                }
            }
        }
    }

    public class ChargeGroupWrapper {
        @AuraEnabled
        public Charge_Group__c cGroup {
            get;
            set;
        }
        @AuraEnabled Decimal totalCharges { get; set; }
        @AuraEnabled Decimal totalCredits { get; set; }
        @AuraEnabled List<ServiceWrapper> services { get; set; }
        @AuraEnabled List<ServiceWrapper> adjusts { get; set; }
        @AuraEnabled Boolean validPayer { get; set; }

        public ChargeGroupWrapper(Charge_Group__c cGroup) {
            this.cGroup = cGroup;
            totalCharges = 0;
            totalCredits = 0;
            Map<String, ServiceWrapper> adjustMap = new Map<String, ServiceWrapper>();
            Map<String, ServiceWrapper> serviceMap = new Map<String, ServiceWrapper>();
            validPayer = false;
            for (Integer i = 0; i < cGroup.Charge_Group_Coverages__r.size(); i++) {
                Charge_Group_Coverage_Junction__c coverageJunction = cGroup.Charge_Group_Coverages__r[i];
                if (coverageJunction.Coverage__r.Payor__r != null) {
                    validPayer = true;
                    break;
                }
            }
            for (Integer i = 0; i < cGroup.Transactions__r.size(); i++) {
                Transaction__c pa = cGroup.Transactions__r[i];
                if (pa.Txn_Method__c == Constants.SERVICE) {
                    totalCharges += pa.Amount__c;
                    String displayName = getName(pa);
                    if (serviceMap.containsKey(displayName)) {
                        serviceMap.get(displayName).amount += pa.Amount__c;
                    } else {
                        serviceMap.put(displayName, new ServiceWrapper(displayName, pa.Amount__c));
                    }
                } else {
                    totalCredits += pa.Amount__c;
                    String displayName = getName(pa);
                    if (adjustMap.containsKey(displayName)) {
                        adjustMap.get(displayName).amount += pa.Amount__c;
                    } else {
                        adjustMap.put(displayName, new ServiceWrapper(displayName, pa.Amount__c));
                    }
                }
            }
            this.adjusts = adjustMap.values();
            this.services = serviceMap.values();
        }

        private String getName(Transaction__c pa) {
            String displayName = Constants.UNKNOWN;
            if (pa.Adjustment__r.Custom_Name__c != null) {
                displayName = pa.Adjustment__r.Custom_Name__c;
            } else if (pa.Payment__r.Display_Name__c != null) {
                displayName = pa.Payment__r.Display_Name__c;
            } else if (pa.Service__r.Display_Name__c != null) {
                displayName = pa.Service__r.Display_Name__c;
                displayName = displayName.split('-')[0]; //get Name e.g. Aetna Payment - 1/14/2016  finded(Aetna Payment )
            }

            displayName = displayName.replace('- //', '');
            return displayName;
        }
    }

    public class ServiceWrapper {
        @AuraEnabled public String displayName { get; set; }
        @AuraEnabled public String serviceDate { get; set; }
        @AuraEnabled public Decimal amount { get; set; }

        public ServiceWrapper(String displayName, Decimal amount) {
            this.amount = amount;
            List<String> nameParts = displayName.split('-');
            this.displayName = nameParts[0];
            this.serviceDate = nameParts.size() > 1 ? nameParts[1] : '';
        }
    }

    public class PatientWrapper {
        @AuraEnabled public String MRN { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public Boolean isSelected { get; set; }

        public PatientWrapper(Invoice__c invoice) {
            this.name = invoice.Patient__r.Name;
            this.id = invoice.Patient__r.Id;
            this.isSelected = true;
            this.MRN = '';
            if (invoice.Patient__r.Medical_Record_Number__c != null) {
                this.MRN = ' (MRN: ' + invoice.Patient__r.Medical_Record_Number__c + ')';
            }
        }
        public PatientWrapper(Encounter__c estimate) {
            this.name = estimate.Patient__r.Name;
            this.id = estimate.Patient__r.Id;
            this.isSelected = true;
            this.MRN = '';
            if (estimate.Patient__r.Medical_Record_Number__c != null) {
                this.MRN = ' (MRN: ' + estimate.Patient__r.Medical_Record_Number__c + ')';
            }
        }
    }

}