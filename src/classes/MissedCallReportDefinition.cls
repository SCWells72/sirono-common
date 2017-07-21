/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * MissedCallReportDefinition class defines variables needed to successfully run a Five9 Unsuccessful dial
 * attempts report.
 **/
public with sharing class MissedCallReportDefinition {
    public String FOLDER_NAME;
    public String REPORT_NAME;
    public Datetime START_DATE;
    public Datetime END_DATE;

    public MissedCallReportDefinition(String folderName, String reportName,
            Datetime startDate, Datetime endDate) {
        this.FOLDER_NAME = folderName;
        this.REPORT_NAME = reportName;
        this.START_DATE = startDate;
        this.END_DATE = endDate;
    }

    /**
     * isValid confirms that the report definition variables are valid
     *
     * @return Boolean isValid – true if the variables are valid, false if not
     **/
    @testVisible
    public Boolean isValid() {

        // Folder and report names cannot be null, though we can't tell if they actually exist in Five9.
        if (String.isEmpty(FOLDER_NAME) || String.isEmpty(REPORT_NAME)) {
            // TODO - log the variables
            return false;
        }

        // The start and end dates must have values and the start date cannot be greater than the end date.
        if (START_DATE == null || END_DATE == null || START_DATE > END_DATE) {
            // TODO - log the variables
            return false;
        }

        return true;
    }
}