/*
 * Copyright (c) 2017-present Sirono LLC, All rights reserved
 */

public class SimpleLoginToCommunityController {
    Id userId = null;
    String username = null;
    
    public PageReference login(){
        User user = [SELECT Id, IsActive, ContactId
                     FROM User 
                     WHERE Id =:userId];
        if(!user.IsActive){
            User actUser = [SELECT Id, IsActive
                            FROM User 
                            WHERE IsActive =true
                            AND (Profile.UserLicense.Name = 'Partner Community' 
                               OR Profile.UserLicense.Name = 'Customer Community')
                            LIMIT 1];
            if(actUser != null){
                actUser.IsActive = false;
                update actUser;   
            }
            user.IsActive = true;
            update user;
        }
        String orgId = UserInfo.getOrganizationId();
        String contactId = user.ContactId;
        String usId = user.Id;
        String communityId = '0DB11000000CajG';
        return new PageReference('/servlet/servlet.su?oid=' + orgId + '&retURL=/' + contactId + '&sunetworkid=' + communityId + '&sunetworkuserid=' + usId);
    }
    
    public List<SelectOption> getItems(){
        List<SelectOption> options = new List<SelectOption>();
        List<User> commUsers = [SELECT Id, Name
                               FROM User
                               WHERE Profile.UserLicense.Name = 'Partner Community' 
                               OR Profile.UserLicense.Name = 'Customer Community'];
        for(User user:commUsers){
            options.add(new SelectOption(user.Id, user.Name));
        }
        return options;
    }
    
    public Id getUserId(){
        return userId;
    }
    public void setUserId(Id userId){
        this.userId = userId;
    }
}