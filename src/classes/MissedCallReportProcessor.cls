/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * @description MissedCallReportProcessor takes a CSV string and creates objects to be inserted into Salesforce.
**/
public with sharing class MissedCallReportProcessor {
    String csvReportString;

    public MissedCallReportProcessor(String csvReport) {
        this.csvReportString = csvReport;
    }

    /**
     * @description parse the csvReportString and turn each line into a task, then ask the
     * TaskService to validate and save the resulting list of tasks
    **/
    public void process() {
        List<Task> taskList = new List<Task>();

        for (String line : parseLines()) {
            if (!String.isEmpty(line)) {
                String[] fields = parseFields(line);

                if (!fields.isEmpty()) {
                    Task newTask = createTask(fields);
                    if (newTask != null) {
                        taskList.add(newTask);
                    }
                }
            }
        }

        /**
         * If taskList is not empty, first weed out the tasks that already exist (based on Five9 session Id) and then
         * upsert the rest.
        **/
        if (!taskList.isEmpty()) {
            TaskService.insertValidatedTasks(TaskService.getNewTasks(taskList));
        }
    }

    /**
     * parseCsvString takes a string in CSV format, splits each line using the new line character then takes each line
     * and splits based on the comma. A list of string lists (each field from the report) is returned.
    **/
    @TestVisible
    private List<String> parseLines() {
        List<String> csvLines = new List<String>();
        if (String.isEmpty(csvReportString)) {
            System.debug('The CSV provided is empty.');
            return csvLines;
        }

        // Split the CSV string into an array by splitting on new line character.
        csvLines = csvReportString.split('\n');

        // Check to make sure the report contains more than the header row.
        if (csvLines.size() == 1) {
            System.debug('The report contains only the header row: ' + csvLines[0]);
            return new List<String>();
        }

        // Remove the header row from the lines
        csvLines.remove(0);

        return csvLines;
    }

    /**
     * @description parseFields returns a list of the fields in the given csvString
     * TODO - handle quoted fields that have commas in them
     *
     * @param csvString string in CSV format to be parsed
     * @return fields the list of string field values
    **/
    @TestVisible
    private String[] parseFields(String csvString) {
        return csvString.split(',');
    }

    /**
     * @description This method takes a list of strings and returns a Task object
     * TODO - Create a dynamic way of using the header row to map fields
     *
     * @param fieldList the list of strings.
     * @return task task to be inserted into Salesforce.
    **/
    @TestVisible
    private Task createTask(String[] fields) {
        // First, check to make sure the field collection isn't empty.
        if (fields.isEmpty()) {
            System.debug('List of fields is empty.');
            return null;
        }

        Task task = new Task();

        task.WhoId = fields[13];
        task.Five9__Five9ANI__c = fields[7];
        task.Five9__Five9DNIS__c = fields[10];
        task.CallDisposition = fields[3];
        task.Five9__Five9SessionId__c = fields[0];
        task.Five9__Five9CallType__c = fields[8];
        task.Five9__Five9Campaign__c = fields[9];
        task.Five9__Five9AgentName__c = fields[5];
        task.ActivityDate = System.today();
        task.Status = 'Completed';

        return task;
    }
}
