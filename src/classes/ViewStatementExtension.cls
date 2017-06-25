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
        stmtUrlMap = GuarantorService.getStatementMap(guarantorId);
        PageReference pageRef = null;
        if (stmtUrlMap.containsKey(stmtDate.format()) && stmtUrlMap.get(stmtDate.format()) != null) {
            pageRef = new PageReference(stmtUrlMap.get(stmtDate.format()));
            pageRef.setRedirect(true);
        } else {
            errorMsg = 'Statement PDF not found';
        }

        return pageRef;
    }


}
