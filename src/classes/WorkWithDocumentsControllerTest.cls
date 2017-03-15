@isTest
private class WorkWithDocumentsControllerTest {
	public static final Integer DOCUMENT_RECORDS = 15;

	static testmethod void workWithDocumentsTest() {
		WorkWithDocumentsController.FOLDER_NAME = 'Sirono';
		List<Folder> folderList = [SELECT Id FROM Folder WHERE Name = :WorkWithDocumentsController.FOLDER_NAME LIMIT 1];		
		List<Document> documentsToInsert = new List<Document>();
		for(Integer i = 0; i < DOCUMENT_RECORDS; i++) {
			Document newDoc = new Document();
			newDoc.FolderId = (folderList.isEmpty()) ? UserInfo.getUserId() : folderList[0].Id;
			newDoc.Name = 'TestDoc' + i;
			documentsToInsert.add(newDoc);
		}
		insert documentsToInsert;

		Test.startTest();

		Integer countDocumentsByController = WorkWithDocumentsController.getDocumentsInOrder(null, null).size();
		System.assertEquals(15, countDocumentsByController);

		Test.stopTest();
	}

	static testmethod void workWithDocumentsEmptyFolderTest() {
		WorkWithDocumentsController.FOLDER_NAME = 'qwertyqwertyqwerty';
		List<Document> documentsToInsert = new List<Document>();
		for(Integer i = 0; i < DOCUMENT_RECORDS; i++) {
			Document newDoc = new Document();
			newDoc.FolderId = UserInfo.getUserId();
			newDoc.Name = 'TestDoc' + i;
			documentsToInsert.add(newDoc);
		}
		insert documentsToInsert;

		Test.startTest();

		Integer countDocumentsByController = WorkWithDocumentsController.getDocumentsInOrder('LastModifiedDate', ' DESC ').size();
		System.assertEquals(0, countDocumentsByController);

		Test.stopTest();
		WorkWithDocumentsController.FOLDER_NAME = 'Sirono';
	}
	
}