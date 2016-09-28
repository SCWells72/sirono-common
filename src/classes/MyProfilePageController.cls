/*
 * @author Sirono
 * @version 1.0.1
 * @Date: 05-03-2016
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.

 * 14/09/2016 commented the code since it is not used into community/site for any business requirement
 */
public with sharing class MyProfilePageController {

    public MyProfilePageController() {
    } //Delete this line when the above code is uncommented.
    /*
    private User user;
    private boolean isEdit = false;

    public User getUser() {
        return user;
    }
  
    public MyProfilePageController() {
       user = [SELECT id, email, username, usertype, communitynickname, timezonesidkey,
        		languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey,
                mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
	 
    }

    public Boolean getIsEdit() {
        return isEdit;
    }

    public void edit() {
        isEdit=true;
    }

    public void save() {
        if (user.contact != null) {
            setContactFields(user.contact, user);
        }

        try {
            update user;
            if (user.contact != null) {
                update user.contact;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }

    public PageReference changePassword() {
        return Page.ChangePassword;
    }

    public void cancel() {
        isEdit=false;
        user = [SELECT id, email, username, communitynickname, timezonesidkey,
        		languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey,
                mobilephone, extension, fax, contact.email
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }

    public static void setContactFields(Contact c, User u) {
        c.title = u.title;
        c.firstname = u.firstname;
        c.lastname = u.lastname;
        c.email = u.email;
        c.phone = u.phone;
        c.mobilephone = u.mobilephone;
        c.fax = u.fax;
        c.mailingstreet = u.street;
        c.mailingcity = u.city;
        c.mailingstate = u.state;
        c.mailingpostalcode = u.postalcode;
        c.mailingcountry = u.country;
    }
*/
}