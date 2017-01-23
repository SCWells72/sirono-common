@isTest
private class WorkWithDocumentsControllerTest {
	public static final Integer DOCUMENT_RECORDS = 15;

	static testmethod void workWithDocumentsTest() {
		List<Document> documentsToInsert = new List<Document>();
		for(Integer i = 0; i < DOCUMENT_RECORDS; i++) {
			Document newDoc = new Document();
			newDoc.FolderId = UserInfo.getUserId();
			newDoc.Name = 'TestDoc' + i;
			documentsToInsert.add(newDoc);
		}
		insert documentsToInsert;

		Integer countDocumentsByController = WorkWithDocumentsController.getDocumentsInOrder(null).size();
		System.assertEquals(DOCUMENT_RECORDS, countDocumentsByController);
	}
	
}