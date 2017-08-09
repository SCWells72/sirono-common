/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

@IsTest
private class VisualforceControllerUtilTest {

    @IsTest
    static void testGetRecordPageReferenceWithId() {
        PageReference pageReference = VisualforceControllerUtil.getRecordPageReference('testid');
        System.assertNotEquals(null, pageReference, 'Expected a non-null page reference.');
        System.assertEquals('/testid', pageReference.getUrl(), 'Expected a URL of /testid.');
        System.assert(pageReference.getRedirect(), 'Expected page reference to be configured for redirect.');
    }

    @IsTest
    static void testGetRecordPageReferenceWithoutId() {
        PageReference pageReference = VisualforceControllerUtil.getRecordPageReference(null);
        System.assertNotEquals(null, pageReference, 'Expected a non-null page reference.');
        System.assertEquals(VisualforceControllerUtil.HOME_PAGE_URL, pageReference.getUrl(), 'Expected a URL of ' + VisualforceControllerUtil.HOME_PAGE_URL + '.');
        System.assert(pageReference.getRedirect(), 'Expected home page reference to be configured for redirect.');
        System.assertEquals(VisualforceControllerUtil.HOME_PAGE_REFERENCE, pageReference, 'Expected HOME_PAGE_REFERENCE.');
    }
}