# Partner Developer Edition Deployment Checklist
### Use the following conventions when creating your own Developer Edition Org
To create a new org, log into the DevHub and click on the Environment Hub app. From there, click on the _New Org_ button in the top right-hand corner.

Rules to consider when making your new org:
- Your Org name can be anything you want, but it cannot be a name that is already in use. This will prevent errors when creating subdomains later on.
- Enabling My Domain and setting a My Domain value will allow you use SSO. You can set My Domain and SSO after you create your org, if you wish.
- Your username _**must**_ follow the following naming convention: orgname+email@something.com. For instance, Justin Dove's username for the dev org "justinbox" is `justinbox+justin.dove@sirono.com`. If this convention is not followed, we will have issues deploying code to the new org.

### Below are the settings that need to be configured _after_ creating your org but _before_ you deploy
##### The steps below must be set in order

- [ ] Enable Chatter
  - [ ] Enable Users to edit posts
- [ ] Create a Force.com Site domain name
  - Setup > User Interface > Sites and Domains > Sites
  - Your site domain must follow the following convention: org name and add `-sirono`. For example, The Site.com subdomain for justinbox is `justinbox-sirono`.
- [ ] Enable Communities
  - [ ] Create the Community subdomain
    - Take your org name and add `-sirono-community`
    - For example, the justinbox community subdomain will be `justinbox-sirono-community`
  - [ ] Create the Guarantor community
    - Choose the Napili template
    - The community name must be "Guarantor Portal"
    - The community url must end with "/guarantor"
  - [ ] Create a Partner Community community
    - Choose the Napili template
    - The community name must be "Partner Community"
    - The community url must end with "/partner"
- [ ] Enable External Sharing Model
- [ ] Update the Opportunity Sharing Model to Private
- [ ] Enable Notes
- [ ] Enable Report and Dashboard Folder Sharing (available only in Salesfoce Classic setup menu)
  - Setup > Reports & Dashboards > Folder Sharing
- [ ] Enable "Set Audit Fields upon Record Creation" and "Update Records with Inactive Owners" User Permissions in User Interface options
  - Setup > Customize > User Interface

### Below are steps to take after a successful deployment & before loading data into it
##### Publish Site changes in your community
- Go to Setup > Communities > Manage
- In the community manager, go to Administration > Pages and click on "Go to Site.com Studio" in the lower right-hand corner of the page
- In the Site.com Studio, click on "Publish Changes"
- Go back into the community manager and click on Builder to see if your changes have taken effect

##### Assign yourself the Salesforce Console User permission set
- Go to Setup > Users > Permission Sets
- Click on Salesforce Console User > Manage Assignments
- Assign yourself the permission set and save

##### Turn off Salesforce duplicate checking
- Go to Setup > Data.com Administration > Duplicate Management > Duplicate Rules
- Select 'Standard Contact Duplicate Rule' and deactivate it
- Go to Setup > Data.com Administration > Duplicate Management > Matching Rules
- Deactivate 'Standard Contact Matching Rule'

### Load with data
- Create a tracker ticket, assigned to Margaret, with your new dev org username, pwd & security token requesting a data load
