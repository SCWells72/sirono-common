/**
 * Created by justindove on 5/4/17.
 */

public with sharing class Five9SoapClient {

    public class reportTimeCriteria {
        public DateTime end_x;
        public DateTime start;
        private String[] end_x_type_info = new String[]{'end','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] start_type_info = new String[]{'start','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'end_x','start'};
    }
    public class getReportResultCsv {
        public String identifier;
        private String[] identifier_type_info = new String[]{'identifier','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'identifier'};
    }
    public class getReportResultCsvResponse {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class isReportRunningResponse {
        public Boolean return_x;
        private String[] return_x_type_info = new String[]{'return','http://service.admin.ws.five9.com/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class runReportResponse {
        public String return_x;
        private String[] return_x_type_info = new String[]{'return','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'return_x'};
    }
    public class runReport {
        public String folderName;
        public String reportName;
        public Five9SoapClient.customReportCriteria criteria;
        private String[] folderName_type_info = new String[]{'folderName','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] reportName_type_info = new String[]{'reportName','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] criteria_type_info = new String[]{'criteria','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'folderName','reportName','criteria'};
    }
    public class customReportCriteria {
        public Five9SoapClient.reportObjectList[] reportObjects = new List<Five9SoapClient.reportObjectList>();
        public Five9SoapClient.reportTimeCriteria time_x;
        private String[] reportObjects_type_info = new String[]{'reportObjects','http://service.admin.ws.five9.com/',null,'0','-1','true'};
        private String[] time_x_type_info = new String[]{'time','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'reportObjects','time_x'};
    }
    public class reportObjectList {
        public String[] objectNames;
        public String objectType;
        private String[] objectNames_type_info = new String[]{'objectNames','http://service.admin.ws.five9.com/',null,'0','-1','true'};
        private String[] objectType_type_info = new String[]{'objectType','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'objectNames','objectType'};
    }
    public class isReportRunning {
        public String identifier;
        public Long timeout;
        private String[] identifier_type_info = new String[]{'identifier','http://service.admin.ws.five9.com/',null,'0','1','false'};
        private String[] timeout_type_info = new String[]{'timeout','http://service.admin.ws.five9.com/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://service.admin.ws.five9.com/','false','false'};
        private String[] field_order_type_info = new String[]{'identifier','timeout'};
    }
    public class WsAdminPort {
        public String endpoint_x = 'callout:Five9ServiceAdmin';
        public Map<String,String> inputHttpHeaders_x = new Map<String, String>();
        public Map<String,String> outputHttpHeaders_x = new Map<String, String>();
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://service.admin.ws.five9.com/', 'Five9SoapClient'};
        public String getReportResultCsv(String identifier) {
            Five9SoapClient.getReportResultCsv request_x = new Five9SoapClient.getReportResultCsv();
            request_x.identifier = identifier;
            Five9SoapClient.getReportResultCsvResponse response_x;
            Map<String, Five9SoapClient.getReportResultCsvResponse> response_map_x = new Map<String, Five9SoapClient.getReportResultCsvResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                            '',
                            'http://service.admin.ws.five9.com/',
                            'getReportResultCsv',
                            'http://service.admin.ws.five9.com/',
                            'getReportResultCsvResponse',
                            'Five9SoapClient.getReportResultCsvResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public Boolean isReportRunning(String identifier,Long timeout) {
            Five9SoapClient.isReportRunning request_x = new Five9SoapClient.isReportRunning();
            request_x.identifier = identifier;
            request_x.timeout = timeout;
            Five9SoapClient.isReportRunningResponse response_x;
            Map<String, Five9SoapClient.isReportRunningResponse> response_map_x = new Map<String, Five9SoapClient.isReportRunningResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                            '',
                            'http://service.admin.ws.five9.com/',
                            'isReportRunning',
                            'http://service.admin.ws.five9.com/',
                            'isReportRunningResponse',
                            'Five9SoapClient.isReportRunningResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
        public String runReport(String folderName,String reportName,Five9SoapClient.customReportCriteria criteria) {
            Five9SoapClient.runReport request_x = new Five9SoapClient.runReport();
            request_x.folderName = folderName;
            request_x.reportName = reportName;
            request_x.criteria = criteria;
            Five9SoapClient.runReportResponse response_x;
            Map<String, Five9SoapClient.runReportResponse> response_map_x = new Map<String, Five9SoapClient.runReportResponse>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                            '',
                            'http://service.admin.ws.five9.com/',
                            'runReport',
                            'http://service.admin.ws.five9.com/',
                            'runReportResponse',
                            'Five9SoapClient.runReportResponse'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.return_x;
        }
    }
}
