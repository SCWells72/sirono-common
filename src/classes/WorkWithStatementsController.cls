public with sharing class WorkWithStatementsController {
	public static final String VIEW_URL_SUFFIX = '/guarantor/apex/ViewStatementPDF?id=';

	public class StatementWrapper {
		@AuraEnabled
		public String pdf_Url 			{get;set;}
		@AuraEnabled
		public Statement__c statement 	{get;set;}

		public StatementWrapper(Statement__c statement) {
			this.pdf_Url 	= WorkWithStatementsController.VIEW_URL_SUFFIX + statement.Id;
			this.statement 	= statement;
		}
	}

	@AuraEnabled
	public static List<StatementWrapper> getAllInfo() {
		List<StatementWrapper> result = new List<StatementWrapper>();
		User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :userInfo.getUserId()];
		if(currentUser.ContactId == null) {
			return result;
		}
		List<Statement__c> statementList = [
												SELECT 
															Id, 
															PdfUrl__c, 
															Statement_Date__c 
												FROM 		Statement__c 
												WHERE 		Guarantor__c = :currentUser.ContactId
												ORDER BY 	Statement_Date__c DESC 
												LIMIT 50000
											];
		for(Integer i = 0; i < statementList.size(); i++) {
			result.add(new StatementWrapper(statementList.get(i)));
		}
		return result;
	}
}