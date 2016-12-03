/* 
* @author Sirono
* @version 1.0.1
* @date   07-12-2016
*/
public with sharing class ViewStatementExtension {
    public Statement__c stmt {get; set;}
    public String errorMsg {get; set;}
    public Id id;
    public Date stmtDate;
    public String guarantorId;
    public Map<String, String> stmtUrlMap;

    //Constructor initializing the member variables
    public ViewStatementExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>{
                    'Statement_Date__c', 'Guarantor__r.Profile_Pointer_ID__c'
            });
        }
        stmt = (Statement__c) controller.getRecord();
        id = stmt.Id;
        stmtDate = stmt.Statement_Date__c;
        guarantorId = stmt.Guarantor__r.Profile_Pointer_ID__c.format();
        stmtUrlMap = new Map<String, String>();
    }

    //Method called from the Visual Force page action attribute
    public PageReference viewPdf() {
        stmtUrlMap = getStatementUrlMap(guarantorId);
        PageReference pageRef = null;
        if (stmtUrlMap.containsKey(stmtDate.format())) {
            pageRef = new PageReference(stmtUrlMap.get(stmtDate.format()));
            pageRef.setRedirect(true);
        } else {
            errorMsg = 'Statement PDF not found';
        }

        return pageRef;
    }

    //Parsing the response from external Webservice callout
    private Map<String, String> getStatementUrlMap(String guarantorId) {
        Map<String, String> stmtUrlMmap = new Map<String, String>();
        try {
            HttpResponse res = PayStaffWSUtill.getStatementUrls(guarantorId);

            if (200 == res.getStatusCode()) {
                // Parse JSON response to get all the statement date/url pairs
                JSONParser parser = JSON.createParser(res.getBody());
                System.debug('res' + res.getBody());

                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Get the value.
                        StatementURL inv = (StatementURL) parser.readValueAs(StatementURL.class);
                        if (inv.pdf_url != null) {
                            System.debug(inv.statement_date.format() + ' url: ' + inv.pdf_url);
                            stmtUrlMmap.put(inv.statement_date.format(), inv.pdf_url);
                        }
                    }
                }
            } else {
                System.debug('Error retrieving stmt urls for guarantor: ' + guarantorId + ' statusCode: ' + res.getStatus() +
                        ' body: ' + res.getBody());
            }
        } catch (Exception ex) {
            if (Apexpages.currentPage() != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'ERROR: ' + ex.getMessage()));
            } else {
                System.debug('[' + ApexPages.SEVERITY.ERROR + '] ' + ex.getMessage());
            }
        }

        return stmtUrlMmap;
    }

    //Inner Class 

    private class StatementURL {
        public Date statement_date;
        public String pdf_url;
    }
}