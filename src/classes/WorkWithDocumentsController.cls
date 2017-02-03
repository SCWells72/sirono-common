public with sharing class WorkWithDocumentsController {
	public static final String  PATCH_PREFIX         = '/guarantor/servlet/servlet.FileDownload?file=';
    public static final String  QUERY                = 'SELECT Id, Name, Description, ContentType, CreatedDate, Url, LastModifiedDate FROM Document';
    public static final String  ORDER_BY             = ' ORDER BY ';
    public static final String  DEFAULT_ORDER        = 'LastModifiedDate';
    public static final String  DEFAULT_ORDER_TYPE   = ' DESC ';
    public static final String  LIMIT_SUFFIX         = ' LIMIT 50000';
    public static final String  FOLDER_NAME          = 'Sirono';
	public static final Integer WAIT_DAY			 = -15;

    @AuraEnabled
    public static List<DocumentWrapper> getDocumentsInOrder(String criteria, String orderType) {
        System.debug('criteria=' + criteria + ' order=' + orderType);
        if(String.isBlank(criteria)) {
            criteria  = DEFAULT_ORDER;
            orderType = DEFAULT_ORDER_TYPE; 
        } else {
            //adding space
            orderType = orderType.center(orderType.length() + 2);
        }
        List<DocumentWrapper> documents = new List<DocumentWrapper>(); 
        List<Folder> folder = [SELECT Id FROM Folder WHERE Name = :FOLDER_NAME LIMIT 1];
        String searchFolderQuery = '';
        if(folder.size() > 0) {
            searchFolderQuery = ' WHERE FolderId=\'' + folder[0].Id + '\' ';
        }
        String finalQuery = QUERY + searchFolderQuery + ORDER_BY + criteria + orderType + LIMIT_SUFFIX; 
        System.debug('finalQuery=' + finalQuery);
        for(Document doc : Database.query(finalQuery)) {           
            doc.url = PATCH_PREFIX + doc.id;
            documents.add(new DocumentWrapper(doc)); 
        }
        return documents;
    }

	public class DocumentWrapper {
		@AuraEnabled public Document doc {get;set;}
		@AuraEnabled public Boolean  old {get;set;}

		public DocumentWrapper(Document doc) {
			this.doc = doc;
			this.old = doc.CreatedDate > DateTime.now().addDays(WAIT_DAY);
		}
	}
}