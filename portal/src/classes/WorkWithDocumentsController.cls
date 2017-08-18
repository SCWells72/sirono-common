/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class WorkWithDocumentsController {
    public static final String PATCH_PREFIX = '/guarantor/servlet/servlet.FileDownload?file=';
    public static final String QUERY = 'SELECT Id, Name, Description, ContentType, CreatedDate, Url, LastModifiedDate FROM Document';
    public static final String ORDER_BY = ' ORDER BY ';
    public static final String DEFAULT_ORDER = 'LastModifiedDate';
    public static final String DEFAULT_ORDER_TYPE = ' DESC ';
    public static final String LIMIT_SUFFIX = ' LIMIT 50000';
    public static String FOLDER_NAME = 'Sirono';
    public static final Integer WAIT_DAY = -30;

    @AuraEnabled
    public static List<DocumentWrapper> getDocumentsInOrder(String criteria, String orderType) {
        System.debug('criteria=' + criteria + ' order=' + orderType);
        if (String.isBlank(criteria)) {
            criteria = DEFAULT_ORDER;
            orderType = DEFAULT_ORDER_TYPE;
        } else {
            //adding space
            orderType = orderType.center(orderType.length() + 2);
        }
        List<DocumentWrapper> documents = new List<DocumentWrapper>();
        String searchFolderQuery = ' WHERE Folder.Name = :FOLDER_NAME';
        String finalQuery = QUERY + searchFolderQuery + ORDER_BY + criteria + orderType + LIMIT_SUFFIX;
        System.debug('finalQuery=' + finalQuery);
        for (Document doc : Database.query(finalQuery)) {
            doc.Url = PATCH_PREFIX + doc.Id;
            documents.add(new DocumentWrapper(doc));
        }
        return documents;
    }

    public class DocumentWrapper {
        @AuraEnabled public Document doc { get; set; }
        @AuraEnabled public Boolean old { get; set; }

        public DocumentWrapper(Document doc) {
            this.doc = doc;
            this.old = doc.CreatedDate > Datetime.now().addDays(WAIT_DAY);
        }
    }
}