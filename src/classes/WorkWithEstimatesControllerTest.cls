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

		List<Encounter__c> encounters = new List<Encounter__c>();
		Encounter__c encounter1 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
		encounter1.Patient__c = patientContact.Id;
		encounter1.Insurance_Discount__c = 2;
		encounter1.Insurance_Portion__c = 2;
		encounters.add(encounter1);

		Encounter__c encounter2 = TestUtility.generateEncounter(guarantorContact.Id, 10, Date.today());
		encounter2.Total_Payments__c = 5;
		encounter2.Patient__c = patientContact.Id;
		encounter2.Insurance_Discount__c = 3;
		encounter2.Insurance_Portion__c = 2;
		encounters.add(encounter2);

		INSERT encounters;

		//TODO Figure out sharing for portal users!
		List<Encounter__Share> shares = new List<Encounter__Share>();
		for (Encounter__c encounter : encounters) {
			Encounter__Share share  = new Encounter__Share();
			share.ParentId = encounter.Id;
			share.UserOrGroupId = portalUser.Id;
			share.AccessLevel = 'edit';
			shares.add(share);
		}
		insert shares;

		Attachment testAttach = new Attachment (
			Body = Blob.valueOf('Test string'),
			Name = 'test attach',
			ParentId = encounter1.Id
		);
		INSERT testAttach;

        System.runAs(portalUser) {
        	Test.startTest();

        	List<WorkWithEstimatesController.EstimateWrapper> estimateList = WorkWithEstimatesController.getAllEstimates('UNPAID', patientContact.Id);
        	System.assertEquals(1, estimateList.size());

        	estimateList = WorkWithEstimatesController.getAllEstimates('paid', patientContact.Id);
        	System.assertEquals(1, estimateList.size());

        	List<WorkWithInvoicesController.PatientWrapper> patientList = WorkWithEstimatesController.getPatientList();
        	System.assertEquals(2, patientList.size());
			for (WorkWithInvoicesController.PatientWrapper wrapper : patientList) {
				System.debug('wrapper: '+JSON.serializePretty(wrapper));
				System.assert(' (MRN: A12345)'.equals(wrapper.MRN), 'Expected formatted MRN of (MRN: A12345) but got: '+wrapper.MRN);
				System.debug(wrapper.name);
			}

        	Test.stopTest();
        }
	}	
}