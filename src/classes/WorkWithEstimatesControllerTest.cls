/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@isTest
private class WorkWithEstimatesControllerTest {
	
	@isTest
	static void getAllEstimatesAndPatientTest() {

		Contact patientContact = TestUtility.generatePatientContact();
		patientContact.Medical_Record_Number__c = 'A12345';
		INSERT patientContact;

		User portalUser = TestUtility.getGuarantorCommunityUser();

		Contact guarantorContact = [
				SELECT Id, Profile_Pointer_ID__c, Name
				FROM Contact
				WHERE Id = :portalUser.ContactId
		];

		List<Encounter__c> lstEncounter = new List<Encounter__c>();
		Encounter__c encounter1 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
		encounter1.Patient__c = patientContact.Id;
		encounter1.Insurance_Discount__c = 2;
		encounter1.Insurance_Portion__c = 2;
		lstEncounter.add(encounter1);

		Encounter__c encounter2 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
		encounter2.Total_Payments__c = 5;
		encounter2.Patient__c = patientContact.Id;
		encounter2.Insurance_Discount__c = 3;
		encounter2.Insurance_Portion__c = 2;
		lstEncounter.add(encounter2);

		INSERT lstEncounter;

		Attachment testAttach = new Attachment (
			Body = Blob.valueOf('Test string'),
			Name = 'test attach',
			ParentId = encounter1.Id
		);
		INSERT testAttach;

        System.runAs(portalUser) {
        	Test.startTest();

        	List<WorkWithEstimatesController.EstimateWrapper> estimateList = WorkWithEstimatesController.getAllEstimates('UNPAID', patientContact.Id);
        	System.assertEquals(estimateList.size(), 1);

        	estimateList = WorkWithEstimatesController.getAllEstimates('paid', patientContact.Id);
        	System.assertEquals(estimateList.size(), 1);

        	List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithEstimatesController.getPatientList();
        	System.assertEquals(patientList.size(), 2);
			for (WorkWithInvoicesController.PatientWrapper wrapper : patientList) {
				System.assert(' (MRN: A12345)'.equals(wrapper.MRN), 'Expected formatted MRN of (MRN: A12345) but got: '+wrapper.MRN);
				System.debug(wrapper.name);
			}

        	Test.stopTest();
        }
	}	
}