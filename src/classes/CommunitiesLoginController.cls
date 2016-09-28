/*
* @author: Sirono
* @version 1.0.1
* @Date: 05-03-2016
* @description An apex page controller that exposes the site login functionality
*/
global with sharing class CommunitiesLoginController {

    global CommunitiesLoginController() {
    }

    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');

        return Network.forwardToAuthPage(startUrl, displayType);

    }

}