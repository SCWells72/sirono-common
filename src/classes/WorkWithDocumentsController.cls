public with sharing class WorkWithDocumentsController {
	public static final String PATCH_PREFIX     = '/guarantor/servlet/servlet.FileDownload?file=';
    public static final String QUERY            = 'SELECT Id, Name, Description, ContentType, Url, LastModifiedDate FROM Document';
    public static final String ORDER_BY         = ' ORDER BY ';
    public static final String DEFAULT_ORDER    = 'LastModifiedDate DESC';
    public static final String LIMIT_SUFFIX     = ' LIMIT 50000';
    public static final String FOLDER_NAME      = 'Sirono';

    @AuraEnabled
    public static List<Document> getDocumentsInOrder(String order) {
        if(String.isBlank(order)) {
            order = DEFAULT_ORDER;
        }
        List<Document> documents = new List<Document>(); 
        List<Folder> folder = [SELECT Id FROM Folder WHERE Name = :FOLDER_NAME LIMIT 1];
        String searchFolderQuery = '';
        if(folder.size() > 0) {
            searchFolderQuery = ' WHERE FolderId=\'' + folder[0].Id + '\' ';
        }
        String finalQuery = QUERY + searchFolderQuery + ORDER_BY + order + LIMIT_SUFFIX; 
        for(Document doc : Database.query(finalQuery)) {           
            doc.url = PATCH_PREFIX + doc.id;
            documents.add(doc); 
        }
        return documents;
    }
}