/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/*
 * We need to set the portal custom settings to specify the Financial Assistance application for portal users. The document
 * itself is loaded as a static resource metadata - the custom setting entry simply points to it.
 */

// We're going to set the org defaults for the financial aid application.
sPFP__Sirono_Portal_Settings__c settings = sPFP__Sirono_Portal_Settings__c.getOrgDefaults();
settings.sPFP__Financial_Assistance_Document__c = 'Financial_Aid_Doc';

upsert settings;