/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class ViewStatementExtension {
    public Statement__c stmt {get; set;}
    public String errorMsg {get; set;}
    public Id id;
    public Date stmtDate;
    public String guarantorId;
    public Map<Date, String> stmtUrlMap;

    //Constructor initializing the member variables
    public ViewStatementExtension(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String> {
                    'Statement_Date__c', 'Guarantor__r.Profile_Pointer_ID__c'
            });
        }
        stmt = (Statement__c) controller.getRecord();
        id = stmt.Id;
        stmtDate = stmt.Statement_Date__c;
        guarantorId = stmt.Guarantor__r.Profile_Pointer_ID__c.format();
        stmtUrlMap = new Map<Date, String>();
    }

    //Method called from the Visual Force page action attribute
    public PageReference viewPdf() {
        stmtUrlMap = GuarantorService.getStatementMap(guarantorId);
        PageReference pageRef = null;
        if (stmtUrlMap.containsKey(stmtDate) && !String.isEmpty(stmtUrlMap.get(stmtDate))) {
            pageRef = new PageReference(stmtUrlMap.get(stmtDate));
            pageRef.setRedirect(true);
        } else {
            errorMsg = 'Statement PDF not found';
        }

        return pageRef;
    }


}
