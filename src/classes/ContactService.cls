/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * ContactService Class, It is use to get Contact related data using ContactDao class.
 **/
public with sharing class ContactService extends AbstractService {

    /**
     * Get Contact details filtered by Id.
     *
     * @param String contactId - That contains Contact Id.
     * @returns Contact ob - That contains Contact details.
     **/
    public static Contact getContactDetails(String contactId) {
        return ContactDao.getContactDetails(contactId);
    }
}