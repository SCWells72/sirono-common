/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {

    //Code we will invoke on page load.
    public PageReference forwardToStartPage() {
    	String activeTab = apexPages.currentPage().getParameters().get('activeTab');
        String tab = apexPages.currentPage().getParameters().get('tab');
    	if (String.isEmpty(activeTab) && String.isEmpty(tab)) {
    		return Network.communitiesLanding();
    	} else if (! String.isEmpty(activeTab)) {
    		String returnUrl = Network.communitiesLanding().getUrl() + '/?activeTab=' + activeTab;
    		return new PageReference(returnUrl);
    	} else {
            String returnUrl = Network.communitiesLanding().getUrl() + 'payments/?tab=' + tab;
            return new PageReference(returnUrl);
        }
    }

    public CommunitiesLandingController() {
    }

}