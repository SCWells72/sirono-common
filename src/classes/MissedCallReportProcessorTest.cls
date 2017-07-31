/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * MissedCallReportProcessorTest tests the functions in MissedCallReportProcessor.
 */
@IsTest
public class MissedCallReportProcessorTest {
    @TestSetup
    public static void testData() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            Contact contact = TestUtility.generateGuarantorContact();
            contact.LastName = 'LastName' + i;
            contact.FirstName = 'FirstName' + i;
            contacts.add(contact);
        }
        insert contacts;
    }

    @IsTest
    public static void parseCSVTest() {
        String nullCsv = null;
        String csvHeader = 'FirstName,LastName';
        String csvBody = '';

        List<Contact> contacts = new List<Contact>([SELECT FirstName, LastName FROM Contact]);
        for (Contact contact : contacts) {
            csvBody = csvBody + contact.FirstName + ',' + contact.LastName + '\r\n';
        }

        String fullCsvString = csvHeader + '\r\n' + csvBody;

        Test.startTest();
        // Instantiate a new processor with each of the created CSVs and assert the results
        MissedCallReportProcessor headerProcessor = new MissedCallReportProcessor(csvHeader);
        List<String> headerResults = headerProcessor.parseLines();

        MissedCallReportProcessor nullProcessor = new MissedCallReportProcessor(nullCsv);
        List<String> nullCsvResults = nullProcessor.parseLines();

        MissedCallReportProcessor fullCsvProcessor = new MissedCallReportProcessor(fullCsvString);
        List<String> fullCsvResults = fullCsvProcessor.parseLines();
        Test.stopTest();

        System.assertEquals(0, headerResults.size(), 'Only a header was provided, null should have been returned.');
        System.assertEquals(0, nullCsvResults.size(), 'CSV provided was null, null should have been returned.');
        System.assertEquals(3, fullCsvResults.size(), 'Result size should be the full CSV string size minus the header row');
    }

    @IsTest
    public static void createTaskListTest() {
        // These fields are part of a returned Five9 report and are crucial for testing successfully created Tasks
        String SESSION_ID = '';
        String CALL_ID = '';
        String DATE_STRING = String.valueOf(System.today());
        String DISPOSITION = '';
        String RECORDINGS = '';
        String AGENT_NAME = '';
        String EXTENSION = '';
        String ANI = '';
        String CALL_TYPE = '';
        String CAMPAIGN = '';
        String DNIS = '';
        String HANDLE_TIME = '';
        String COST = '';
        String TIME_STRING = '';
        String AFTER_CALL_WORK_TIME = '';
        String CONTACT_ID = '';
        String CALL_TIME = '';

        String fullCsvString = '';
        String five9ReportHeaderCsv = 'SESSION_ID,CALL_ID,DATE,DISPOSITION,RECORDINGS,AGENT_NAME,EXTENSION,ANI,CALL_TYPE,' +
            'CAMPAIGN,DNIS,HANDLE_TIME,COST,salesforce_id,TIME,AFTER_CALL_WORK_TIME,CONTACT_ID,CALL_TIME';
        // Record the header length, each line parsed into fields should equal the header size
        Integer headerLength = five9ReportHeaderCsv.split(',').size();

        List<Contact> contacts = new List<Contact>([SELECT Id FROM Contact]);
        String resultString = '';
        for (Contact contact : contacts) {
            String tempResultString = SESSION_ID + ',' + CALL_ID + ',' + DATE_STRING + ',' + DISPOSITION + ',' + RECORDINGS + ',' +
                AGENT_NAME + ',' + EXTENSION + ',' + ANI + ',' + CALL_TYPE + ',' + CAMPAIGN + ',' + DNIS + ',' +
                HANDLE_TIME + ',' + COST + ',' + contact.Id + ',' + TIME_STRING + ',' + AFTER_CALL_WORK_TIME + ',' +
                CONTACT_ID + ',' + CALL_TIME + '\r\n';
            resultString = resultString + tempResultString;
        }

        fullCsvString = five9ReportHeaderCsv + '\r\n' + resultString;

        Test.startTest();
        MissedCallReportProcessor processor = new MissedCallReportProcessor(resultString);
        List<String> processedResultStrings = processor.parseLines();
        List<Task> taskList = new List<Task>();

        for (String line : processedResultStrings) {
            List<String> processedFields = processor.parseFields(line);
            Task tempTask = processor.createTask(processedFields);

            System.assertEquals(headerLength, processedFields.size());
            taskList.add(tempTask);
        }

        Test.stopTest();

        System.assertNotEquals(0, processedResultStrings .size());
        System.assertEquals(processedResultStrings.size(), taskList.size());
    }
}
