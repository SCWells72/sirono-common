/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public abstract with sharing class WrapperBadResponse {

    public final static String SHORT_ERROR = '{0}: {1}';
    public final static String LONG_ERROR = '{0}: {1} - {2}';
    public final static String NON_FIELD_ERRORS_STR = 'Nonfield Error';

    /**
     * Method that will return a list of errors associated with the JSON data that is mapped into it's values.
     */
    public abstract List<String> getErrors();
}
