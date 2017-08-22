/*
* Copyright (c) 2017-present Sirono LLC, All rights reserved
*/

public Datetime parseDatetime(String str) {

    if (!String.isBlank(str)) {
        String[] parts = str.split('T');
        String[] timeParts = parts[1].replace('.', ':').split(':');

        return Datetime.newInstance(
            Date.valueOf(parts[0]),
            Time.newInstance(
                Integer.valueOf(timeParts[0]),
                Integer.valueOf(timeParts[1]),
                Integer.valueOf(timeParts[2]),
                //Ignore milliseconds
                0));
    }

    return null;
}

List<sPRS__Encounter__c> encounterList = new List<sPRS__Encounter__c>();

List<Contact> guarantorList = [
    SELECT Id
    FROM Contact
    WHERE RecordType.Name = 'Guarantor'
    AND sPRS__Guarantor_Id__c >= 200000
    ORDER BY sPRS__Guarantor_Id__c ASC
];

List<Contact> patientList = [
    SELECT Id
    FROM Contact
    WHERE RecordType.Name = 'Patient'
    AND sPRS__Patient_Id__c >= 200000
    AND FirstName = 'Charles'
    ORDER BY sPRS__Patient_Id__c ASC
];

for (Integer i = 0; i < guarantorList.size(); i++) {
    sPRS__Encounter__c encounter = new sPRS__Encounter__c();

    encounter.sPRS__Patient__c = patientList[i].Id;
    encounter.sPRS__Department__c = 'Radiology';
    encounter.sPRS__Ordering_Physician__c = 'Dr. Glendon, Wilfred';
    encounter.sPRS__Location__c = 'Austin Hospital';
    encounter.sPRS__Location_Phone_Number__c = '(512) 555-5871';
    encounter.sPRS__Procedure__c = '73718 – MRI Foot WO Contrast Left';
    encounter.sPRS__Duration_Minutes__c = 90;
    encounter.sPRS__Encounter_Id__c = 'EN-20170224-1';
    encounter.sPRS__Type__c = 'HB';
    encounter.sPRS__Estimate_Id__c = '456789';
    encounter.sPRS__Individual_Deductible__c = 2000;
    encounter.sPRS__Individual_Deductible_Used__c = 0;
    encounter.sPRS__Co_Insurance__c = 0;
    encounter.sPRS__Scheduler__c = 'Jenkins';
    encounter.sPRS__Total_Charges__c = 1050;
    encounter.sPRS__Insurance_Discount__c = 367;
    encounter.sPRS__Family_Deductible__c = 4000;
    encounter.sPRS__Family_Deductible_Used__c = 0;
    encounter.sPRS__Individual_Out_Of_Pocket_Max__c = 4000;
    encounter.sPRS__Individual_Out_Of_Pocket_Used__c = 0;
    encounter.sPRS__Co_Pay__c = 0;
    encounter.sPRS__Co_Insurance_Percent__c = 0;
    encounter.sPRS__Cancelled__c = false;
    encounter.sPRS__Date_Of_Service__c = parseDatetime('2017-02-25T00:08:00.000Z');
    encounter.sPRS__Family_Out_Of_Pocket_Max__c = 6000;
    encounter.sPRS__Family_Out_Of_Pocket_Used__c = 0;
    encounter.sPRS__Insurance_Portion__c = 0;
    encounter.sPRS__Deductible__c = 683;
    encounter.sPRS__Patient_Portion__c = 683;
    encounter.sPRS__Guarantor__c = guarantorList[i].Id;
    encounter.sPRS__Diagnosis__c = 'M79.672 – Pain in left foot';

    encounterList.add(encounter);
}

System.debug('Saving ' + encounterList.size() + 'encounters.');
insert encounterList;