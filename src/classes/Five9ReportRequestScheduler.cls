/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * @description Five9ReportRequestScheduler is a schedulable Apex class so we can run a report request on an automated, on-going
 * basis. A new report definition is created and then a report is requested via the MissedCallReportHandler. If run
 * successfully, tasks for missed calls will be created.
 **/
public class Five9ReportRequestScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {

        if(!Test.isRunningTest()) {
            requestReport();
        }

    }

    @future(callout=true)
    private static void requestReport() {
        // Instantiate a report definition to request a report for non-agent calls.
        // TODO - use custom metadata to set these values instead of hardcoding values.
        MissedCallReportDefinition reportDefinition = new MissedCallReportDefinition(
                'Missed Call Reports','Missed calls',System.today().addDays(-7),System.today()
        );

        MissedCallReportHandler reportHandler = new MissedCallReportHandler(reportDefinition);
        reportHandler.process();
    }
}
