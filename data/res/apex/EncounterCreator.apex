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

List<Encounter__c> encounterList = new List<Encounter__c>();

List<Contact> guarantorList = [
    SELECT Id
    FROM Contact
    WHERE RecordType.Name = 'Guarantor'
    AND sPRS__Guarantor_Id__c >= 200000
    ORDER BY Profile_Pointer_Id__c ASC
];

List<Contact> patientList = [
    SELECT Id
    FROM Contact
    WHERE RecordType.Name = 'Patient'
    AND Patient_Id__c >= 200000
    AND FirstName = 'Charles'
    ORDER BY Patient_Id__c ASC
];

for (Integer i = 0; i < guarantorList.size(); i++) {
    Encounter__c encounter = new Encounter__c();

    encounter.Patient__c = patientList[i].Id;
    encounter.Department__c = 'Radiology';
    encounter.Ordering_Physician__c = 'Dr. Glendon, Wilfred';
    encounter.Location__c = 'Austin Hospital';
    encounter.Location_Phone_Number__c = '(512) 555-5871';
    encounter.Procedure__c = '73718 – MRI Foot WO Contrast Left';
    encounter.Duration_Minutes__c = 90;
    encounter.Encounter_Id__c = 'EN-20170224-1';
    encounter.Type__c = 'HB';
    encounter.Estimate_Id__c = '456789';
    encounter.Individual_Deductible__c = 2000;
    encounter.Individual_Deductible_Used__c = 0;
    encounter.Co_Insurance__c = 0;
    encounter.Scheduler__c = 'Jenkins';
    encounter.Total_Charges__c = 1050;
    encounter.Insurance_Discount__c = 367;
    encounter.Family_Deductible__c = 4000;
    encounter.Family_Deductible_Used__c = 0;
    encounter.Individual_Out_Of_Pocket_Max__c = 4000;
    encounter.Individual_Out_Of_Pocket_Used__c = 0;
    encounter.Co_Pay__c = 0;
    encounter.Co_Insurance_Percent__c = 0;
    encounter.Cancelled__c = false;
    encounter.Date_Of_Service__c = parseDatetime('2017-02-25T00:08:00.000Z');
    encounter.Family_Out_Of_Pocket_Max__c = 6000;
    encounter.Family_Out_Of_Pocket_Used__c = 0;
    encounter.Insurance_Portion__c = 0;
    encounter.Deductible__c = 683;
    encounter.Patient_Portion__c = 683;
    encounter.Guarantor__c = guarantorList[i].Id;
    encounter.Diagnosis__c = 'M79.672 – Pain in left foot';

    encounterList.add(encounter);
}

System.debug('Saving ' + encounterList.size() + 'encounters.');
insert encounterList;