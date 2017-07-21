/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {

    public ForgotPasswordController() {
    }    //Delete this line when the below code is uncommented.
    /*
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
  		boolean success = Site.forgotPassword(username);
  		PageReference pr = Page.ForgotPasswordConfirm;
  		pr.setRedirect(true);
        
        if (success== false &&  !Test.isRunningTest()) {  			
          	  
                    return pr;
        
        }      
  		return null;
  	}
*/
}