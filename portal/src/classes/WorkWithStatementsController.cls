/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class WorkWithStatementsController {

    public class StatementWrapper {
        @AuraEnabled
        public String pdf_url { get; set; }
        @AuraEnabled
        public Date statement_date { get; set; }

        public StatementWrapper(Date stmtDate, String stmtUrl) {
            this.statement_date = stmtDate;
            this.pdf_url = stmtUrl;
        }
    }

	/**
	 *
	 * Return a list of StatementWrappers containing the statements for the current guarantor user. A wrapper is
	 * returned for every statement date, even if the pdf url is empty
	 *
	 */
    @AuraEnabled
    public static List<StatementWrapper> getStatements() {
        System.debug('At the top of WorkWithStatementsController.getAllInfo');
        List<StatementWrapper> statements = new List<StatementWrapper>();

        try {
            Contact gt = GuarantorService.getPortalGuarantor(UserInfo.getUserId());

            Map<Date, String> statementUrlMap = GuarantorService.getStatementMap(gt.Profile_Pointer_Id__c.toPlainString());

            System.debug('UrlMap retrieved: ' + statementUrlMap);

            List<Date> statementDates = new List<Date>(statementUrlMap.keySet());
            statementDates.sort();

            for (Integer i = statementDates.size() - 1; i >= 0; i--) {
                Date stmtDate = statementDates.get(i);
                System.debug('Wrapper date: ' + stmtDate.format() + ' url: ' + statementUrlMap.get(stmtDate));
                statements.add(new StatementWrapper(stmtDate, statementUrlMap.get(stmtDate)));
            }
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            System.debug('Error retrieving statements: ' + ex.getMessage());
        }
        return statements;
    }
}