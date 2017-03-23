# Partner Developer Edition Deployment Checklist
### Use the following conventions when creating your own Developer Edition Org
To create a new org, log into the DevHub and click on the Environment Hub app. From there, click on the _New Org_ button in the top right-hand corner. You should see the following modal appear:

### Below are the settings that need to be configured _after_ creating your org but _before_ you deploy

- [ ] Create a Force.com Site domain name
  - Setup > User Interface > Sites & Domains > Sites
    - Take the prefix from your username and add `-sirono`
    - For example, my dev org username is `justinbox+justin.dove@sirono.com`, so my Force.com Site subdomain is `justinbox-sirono`
    - You should now have 2 domains listed in Domains:
      - 	`justinbox-sirono-dev-ed.my.salesforce.com`
      -   `justinbox-sirono-developer-edition.na40.force.com`
- [ ] Enable Communities
  - [ ] Set the Community subdomain
    - Take the prefix from your username and add `-sirono-community`
    - For example, my dev org username is `justinbox+justin.dove@sirono.com` and my community subdomain is `justinbox-sirono-community`
  - [ ] Create a Guarantor community
  - [ ] Create a Partner Community community
- [ ] Enable Chatter
  - [ ] Enable Users to edit posts (throws unrecognized permission error when deploying profile if not enabled)
- [ ] Enable External Sharing Model
- [ ] Update the Opportunity Sharing Model to Private
  * Throws error: `objects/Opportunity.object -- Error: ReadWrite is not a valid sharing model for Opportunity when Account sharing model is Private`
- [ ] Enable Notes
  * Resolves issues when trying to deploy certain quickActions

### After the initial deployment, be sure to publish your Site changes in your community.
- [ ] Go to Setup >

#### Tickets created for successful deployment
1. [Remove unneeded applications/installed packages](https://www.pivotaltracker.com/story/show/142221257)
2. [Remove references to Opportunity object](https://www.pivotaltracker.com/story/show/142076765)
3. [Deploy "Sirono Support Queue" after initial deployment to a clean dev org](https://www.pivotaltracker.com/story/show/142242433)
4. [Remove reports/dashboards from src/](https://www.pivotaltracker.com/story/show/142244089)
5. [List view shared to all internal users throws error](https://www.pivotaltracker.com/story/show/142195957)
6. [Deploy sharing rules after initial deploy](https://www.pivotaltracker.com/story/show/142251105)
7. [Add email templates](https://www.pivotaltracker.com/story/show/142263921)
8. [Remove erroroneous list views](https://www.pivotaltracker.com/story/show/142254571)
