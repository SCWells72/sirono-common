/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public with sharing class VisualforceControllerUtil {

    public static final String HOME_PAGE_URL = '/home/home.jsp';
    public static final PageReference HOME_PAGE_REFERENCE = new PageReference(HOME_PAGE_URL);

    static {
        HOME_PAGE_REFERENCE.setRedirect(true);
    }

    private VisualforceControllerUtil() {
        // Utility class
    }

    public static PageReference getRecordPageReference(String recordId) {
        if (String.isNotBlank(recordId)) {
            PageReference recordPageReference = new PageReference('/' + recordId);
            recordPageReference.setRedirect(true);
            return recordPageReference;
        } else {
            return HOME_PAGE_REFERENCE;
        }
    }
}