/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * PatientService Class, It is use to get Patient Contact related data using PatientDao class.
 **/
public with sharing class PatientService extends AbstractService {

    /**
     * Get the Patient's Patient_Id__c from the given contact.
     *
     * @param Contact contact - the Patient Contact.
     * @returns String - the Patient's sironoId
     * @throws SironoServiceException if the contact doesn't exist
     **/
    public static String getPatientSironoId(Contact contact) {
        String patientId = '';
        if (contact == null) {
            throw new SironoServiceException('Invalid request - Contact required to retrieve SironoId');
        }
        if (contact.Patient_Id__c != null) {
            return contact.Patient_Id__c.toPlainString();
        } else {
            Contact pc = PatientDao.getPatientContact(contact.Id);
            if (pc != null) {
                patientId = pc.Patient_Id__c.toPlainString();
            } else {
                throw new SironoServiceException('Guarantor not found');
            }
        }
        return patientId;
    }

    /**
     * Get Patient Contact details filtered by Id.
     *
     * @param String recordId - That contains Contact Id.
     * @returns Contact pc - That contains Patient Contact details.
     **/
    public static Contact getPatientContact(String recordId) {
        return PatientDao.getPatientContact(recordId);
    }

    /**
     * Get Contact details with active Charge Groups filtered by Account Sub Status
     *
     * @param String contactId - The Contact RecordId.
     * @param Set<String> cgSubStatusFilters - A set of CG Account Sub Statuses.
     * @returns Contact contact - The requested Contact and all active Charge Groups that meet the criteria
     **/
    public static Contact getPatientFilterCGByAcctSubStatus(String contactId, Set<String> cgSubStatusFilters) {
        return PatientDao.getPatientFilterCGByAcctSubStatus(contactId, cgSubStatusFilters);
    }
}