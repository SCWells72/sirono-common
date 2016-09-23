public with sharing class ViewStatementExtension {
    public Id id {get; set;}
    public Statement__c stmt {get; set;}
    public Date stmtDate {get; set;}
    public String guarantor_id {get; set;}
    public Map<String, String> stmt_url_map {get; set;}
    public String errorMsg {get; set;}

    public ViewStatementExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>{
                    'Statement_Date__c', 'Guarantor__r.Profile_Pointer_ID__c'
            });
        }
        stmt = (Statement__c) controller.getRecord();
        id = stmt.Id;
        stmtDate = stmt.Statement_Date__c;
        guarantor_id = stmt.Guarantor__r.Profile_Pointer_ID__c.format();

        stmt_url_map = new Map<String, String>();
    }

    private class StatementURL {
        public Date statement_date;
        public String pdf_url;
    }

    private Map<String, String> getStatementUrlMap(String guarantorId) {

        Map<String, String> stmt_url_map = new Map<String, String>();
        try {
            HttpResponse res = PayStaffWSUtill.getStatementUrls(guarantorId);

            if (200 == res.getStatusCode()) {
                // Parse JSON response to get all the statement date/url pairs
                JSONParser parser = JSON.createParser(res.getBody());
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Get the value.
                        StatementURL inv = (StatementURL) parser.readValueAs(StatementURL.class);
                        if (inv.pdf_url != null) {
                            System.debug(inv.statement_date.format() + ' url: ' + inv.pdf_url);
                            stmt_url_map.put(inv.statement_date.format(), inv.pdf_url);
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

        return stmt_url_map;
    }

    //Method called from the Visual Force page action attribute
    public PageReference viewPdf() {

        stmt_url_map = getStatementUrlMap(guarantor_id);

        PageReference pageRef = null;
        if (stmt_url_map.containsKey(stmtDate.format())) {
            pageRef = new PageReference(stmt_url_map.get(stmtDate.format()));
            pageRef.setRedirect(true);
        } else {
            errorMsg = 'Statement PDF not found';
        }

        return pageRef;
    }
}