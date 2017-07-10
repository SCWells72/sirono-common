/**
 * @description MissedCallReportHandler requests a report using the Five9 SOAP client, retrieves a report, and hands it to
 * a MissedCallReportProcessor for processing
 *
 * TODO - 
**/

public with sharing class MissedCallReportHandler {
    String reportId = null;
    MissedCallReportDefinition reportDef;
    Five9SoapClient.WsAdminPort soapClient;
    String csvResults = null;

    public MissedCallReportHandler(MissedCallReportDefinition reportDef) {
        this.reportDef = reportDef;
        this.soapClient = new Five9SoapClient.WsAdminPort();
    }
    /**
     * @description processReportRequest is the entry point for the class. It takes a report definition, validates the values, runs
     * a report, gets the results and then creates the tasks.
     *
     * @param reportDef - instance of an UnsuccesfulDialAttemptReportDefinition
    **/
    public void process() {
        // If the report parameters are valid, then instantiate and construct the objects needed to run a report.
        if (!reportDef.isValid()) {
            throw new Five9ReportingException('The report definition is not valid. Please check your values.');
        }

        // Run the report to get the report Id
        runReport();

        // Report is finished running, get the results
        getReportResults();

        if (!String.isEmpty(csvResults)) {
            MissedCallReportProcessor creator = new MissedCallReportProcessor(csvResults);
            creator.process();
        }
    }

    /**
     * @description runReport sets the report Criteria, runs the report, and sets the reportId
     *
    **/
    private void runReport() {

        Five9SoapClient.reportTimeCriteria timeCriteria = new Five9SoapClient.reportTimeCriteria();
        Five9SoapClient.customReportCriteria customCriteria = new Five9SoapClient.customReportCriteria();

        // Set the time criteria and custom criteria objects using the report definition.
        timeCriteria.start = reportDef.START_DATE;
        timeCriteria.end_x = reportDef.END_DATE;
        customCriteria.time_x = timeCriteria;

        try {
            reportId = soapClient.runReport(reportDef.FOLDER_NAME, reportDef.REPORT_NAME, customCriteria);
        } catch (CalloutException ce) {
            // Log and throw the error to kill the process.
            //TODO log all the parameters to runReport
            System.debug('Error running report message: ' + ce.getMessage());
            throw ce;
        }

    }

    /**
     * @description getReportResults checks if the report is still running, when complete, retrieve the report.
     *
    **/
    private void getReportResults() {
        if (String.isEmpty(reportId)) {
            throw new Five9ReportingException('No report Id was provided.');
        }

        Boolean isRunningBoolean = true;

        while (isRunningBoolean) {
            try {
                // TODO - what units is the timeout value supposed to be in?
                isRunningBoolean = soapClient.isReportRunning(reportId, 20);
            } catch (CalloutException ce) {
                // Log and throw the error to kill the process.
                System.debug('Error running report: ' + reportId +' message: ' + ce.getMessage());
                throw ce;
            }
        }

        // When the report finishes running, get the results
        try {
            csvResults = soapClient.getReportResultCsv(reportId);
        } catch (CalloutException ce) {
            // Log and throw the error to kill the process
            System.debug('Error retrieving report id: '+reportId+' message: ' + ce.getMessage());
            throw ce;
        }
    }

}
