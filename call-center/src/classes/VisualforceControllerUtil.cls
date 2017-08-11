/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * Utility class for presentation tier work.
 */
public with sharing class VisualforceControllerUtil {

    /**
     * The home page URL.
     */
    public static final String HOME_PAGE_URL = '/home/home.jsp';
    /**
     * The home page reference.
     */
    public static final PageReference HOME_PAGE_REFERENCE = new PageReference(HOME_PAGE_URL);

    static {
        HOME_PAGE_REFERENCE.setRedirect(true);
    }

    private VisualforceControllerUtil() {
        // Utility class
    }

    /**
     * Builds a redirecting page reference to the specified record ID if provided or the home page if not.
     *
     * @param recordId the optional record ID for which a page reference should be created
     * @return a redirecting page reference to the record's detail page or the home page if not record ID was specified
     */
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