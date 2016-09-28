/* 
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex page controller that exposes the site forgot password functionality
 * 
 * 14/09/2016 commented the code since it is not used into community/site for any business requirement 
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