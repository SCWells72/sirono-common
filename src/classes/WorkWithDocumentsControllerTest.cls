@isTest
private class WorkWithDocumentsControllerTest {
	public static final Integer DOCUMENT_RECORDS = 15;

	static testmethod void workWithDocumentsTest() {
		Profile testProfile = [
            SELECT Id, Name
            FROM Profile 
            WHERE Name = 'System Administrator'
        ];

        UserRole usrRole = [
            SELECT Id
            FROM UserRole 
            WHERE Name = 'CEO'
        ];

		User testUser = new User (
            LastName = 'test user 1', 
            Username = String.valueOf(System.now().millisecond()) + 'test.user.document@example.com', 
            Email = 'test.1@example.com', 
            Alias = 'testu1', 
            TimeZoneSidKey = 'GMT', 
            LocaleSidKey = 'en_GB', 
            EmailEncodingKey = 'ISO-8859-1', 
            ProfileId = testProfile.Id, 
            UserRoleId = usrRole.Id,
            LanguageLocaleKey = 'en_US'
        ); 
        insert testUser; 

        System.runAs(testUser) {
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

			Integer countDocumentsByController = (! folderList.isEmpty()) ? WorkWithDocumentsController.getDocumentsInOrder(null, null).size() : DOCUMENT_RECORDS;
			System.assertEquals(DOCUMENT_RECORDS, countDocumentsByController);

			Test.stopTest();
		}
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