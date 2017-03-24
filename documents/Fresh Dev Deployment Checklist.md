# Partner Developer Edition Deployment Checklist
### Use the following conventions when creating your own Developer Edition Org
To create a new org, log into the DevHub and click on the Environment Hub app. From there, click on the _New Org_ button in the top right-hand corner.

Rules to consider when making your new org:
- Your Org name can be anything you want, but it cannot be a name that is already in use. This will prevent errors when creating subdomains later on.
- Enabling My Domain and setting a My Domain value will allow you use SSO. You can set My Domain and SSO after you create your org, if you wish.
- Your username _**must**_ follow the following naming convention: orgname+email@something.com. For instance, Justin Dove's username for the dev org "justinbox" is `justinbox+justin.dove@sirono.com`. If this convention is not followed, we will have issues deploying code to the new org.

### Below are the settings that need to be configured _after_ creating your org but _before_ you deploy
##### The steps below must be set in order

- [ ] Create a Force.com Site domain name
  - Setup > User Interface > Sites and Domains > Sites
  - Your site domain must follow the following convention: org name and add `-sirono`. For example, The Site.com subdomain for justinbox is `justinbox-sirono`.
- [ ] Enable Chatter
- [ ] Enable Communities
  - [ ] Create the Community subdomain
    - Take your org name and add `-sirono-community`
    - For example, the justinbox community subdomain will be `justinbox-sirono-community`
  - [ ] Create a Guarantor community
    - Choose the Napili template
    - The community name should be "Guarantor Portal"
    - The community url should end with "/guarantor"
  - [ ] Create a Partner Community community
    - Choose the Napili template
    - The community name should be "Partner Community"
    - The community url should end with "/partner"
- [ ] Enable External Sharing Model
- [ ] Update the Opportunity Sharing Model to Private
- [ ] Enable Notes
- [ ] Enable Report and Dashboard Folder Sharing (available only in Salesfoce Classic setup menu)

### After the initial deployment, be sure to publish your Site changes in your community.
- Go to Setup > Communities > Manage
- In the community manager, go to Administration > Pages and click on "Go to Site.com Studio" in the lower right-hand corner of the page
- In the Site.com Studio, click on "Publish Changes"

#### Tickets created for successful deployment
1. [Remove unneeded applications/installed packages](https://www.pivotaltracker.com/story/show/142221257)
2. [Remove references to Opportunity object](https://www.pivotaltracker.com/story/show/142076765)
3. [Deploy "Sirono Support Queue" after initial deployment to a clean dev org](https://www.pivotaltracker.com/story/show/142242433)
4. [Remove reports/dashboards from src/](https://www.pivotaltracker.com/story/show/142244089)
5. [List view shared to all internal users throws error](https://www.pivotaltracker.com/story/show/142195957)
6. [Deploy sharing rules after initial deploy](https://www.pivotaltracker.com/story/show/142251105)
7. [Add email templates](https://www.pivotaltracker.com/story/show/142263921)
8. [Remove erroroneous list views](https://www.pivotaltracker.com/story/show/142254571)
9. [Remove workflows](https://www.pivotaltracker.com/story/show/142276637)
10. [Deploy "Sirono Support Queue" after initial deployment to a clean dev org](https://www.pivotaltracker.com/story/show/142242433)
11. [Deploy sharing rules after initial deploy](https://www.pivotaltracker.com/story/show/142251105)
