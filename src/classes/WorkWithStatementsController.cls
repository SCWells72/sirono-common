public with sharing class WorkWithStatementsController {
	public class StatementWrapper {
		@AuraEnabled
		public String pdf_Url 			{get;set;}
		@AuraEnabled
		public Date statement_date 	{get;set;}

		public StatementWrapper(Date stmtDate, String stmtUrl) {
			this.statement_date 	= stmtDate;
			this.pdf_Url = stmtUrl;
		}
	}

	@AuraEnabled
	public static List<StatementWrapper> getAllInfo() {
		System.debug('At the top of WorkWithStatementsController.getAllInfo');
		List<StatementWrapper> result = new List<StatementWrapper>();

		try {
			Contact gt = GuarantorService.getPortalGuarantor(UserInfo.getUserId());

			Map<String, String> statementUrlMap = GuarantorService.getStatementMap(gt.Profile_Pointer_ID__c.toPlainString());

			System.debug('UrlMap retrieved: '+statementUrlMap);

			List<String> statementDates = new List<String>(statementUrlMap.keySet());
			statementDates.sort();

			for (Integer i = statementDates.size() - 1; i >= 0; i--){
				String stmtDate = statementDates.get(i);
				System.debug('Wrapper date: '+stmtDate+ ' url: '+statementUrlMap.get(stmtDate));
				result.add(new StatementWrapper(Date.parse(stmtDate), statementUrlMap.get(stmtDate)));
			}
		} catch (Exception ex) {
			System.debug(ex.getStackTraceString());
			System.debug('Error retrieving statements: '+ex.getMessage());
		}
		return result;
	}
}