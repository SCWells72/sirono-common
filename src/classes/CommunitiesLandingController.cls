/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-03-2016
* @description An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
public with sharing class CommunitiesLandingController {

    //Code we will invoke on page load.
    public PageReference forwardToStartPage() {
    	String activeTab = apexPages.currentPage().getParameters().get('activeTab');
    	if (String.isEmpty(activeTab)) {
    		return Network.communitiesLanding();
    	} else {
    		String returnUrl = Network.communitiesLanding().getUrl() + '/?activeTab=' + activeTab;
    		return new PageReference(returnUrl);
    	}
    }

    public CommunitiesLandingController() {
    }

}