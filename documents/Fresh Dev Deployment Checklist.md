# Partner Developer Edition - Initial Deployment Checklist
### Create your dev org

To create a new org, log into the DevHub and click on the Environment Hub app. From there, click on the _New Org_ button in the top right-hand corner.

##### Follow these naming conventions:
- Your Org name can be anything you want, but it cannot be a name that is already in use. (This will prevent errors when creating subdomains later on).
- ** Note on creating domain names: Domain names are limited to 22 characters. Therefore, your org name is limited to _5 characters_ or the domain names below won't be able to follow the standard naming convention. **
- Your username _**must**_ follow the naming convention: orgname+email@something.com. For instance, Justin Dove's username for the dev org "justinbox" is `justinbox+justin.dove@sirono.com`. If this convention is not followed, the initial deploy to the org will fail.

### _After_ creating your org but _before_ you deploy code, configure these setting (in this order!)
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
- [ ] Update the Opportunity Sharing Model to Private.
  - Setup -> Security Controls -> SharingSettings.
  - Update it for both internal and external access (two dropdowns).
- [ ] Enable Notes
- [ ] Enable Report and Dashboard Folder Sharing (available only in Salesfoce Classic setup menu)
  - Setup > Reports & Dashboards > Folder Sharing
- [ ] Enable "Set Audit Fields upon Record Creation" and "Update Records with Inactive Owners" User Permissions in User Interface options
  - Setup > Customize > User Interface

### Deploy code to new org
- Sync master - be sure there are no local changes
```
git checkout master
git pull
```
- Set sf.target.username, sf.target.password & sf.target.serverurl in build/build.properties. As with a sandbox, the password is the concatenation of password and security token. The sf.target.serverurl should be https://login.salesforce.com
- Run the initial deployment
```
ant initial_deploy
```

### After a successful deployment & before loading data into the org:
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

##### Set named credentials for your org
- [Review this configuration map](https://github.com/blueprinthealth/sirono-salesforce/wiki/Sandbox-%E2%80%90%E2%80%BA-Server-Configuration-Map) to determine which backend is correct for your development org
- Create a new named credential in your org
  - Setup > Security Controls > Named Credentials
  - Add the URL from the configuration map mentioned above
  - Under "Callout Options" make these changes:
    - Deselect _Generate Authorization Header_
    - Select _Allow Merge Fields in HTTP Header_
    - Select _Allow Merge Fields in HTTP Body_
  - Save

### Scheduled jobs and deployment
- We have a group of Batch jobs that run and so to deploy to your org you need to either:
  - Stop the jobs completely
    ```
    ant stop_all_scheduled_jobs
    ```

  ***OR***
  
  - Allow deploys while scheduled jobs are running
    - Setup > Deployment Settings > Allow deployments of components when ...  

### Request data load
- Create a tracker ticket, assigned to Margaret, with your new dev org username, pwd & security token requesting a data load

### Post setup
- Enabling My Domain and setting a My Domain value will allow you use SSO. You can set My Domain and SSO after your org is up and running, if you wish.
