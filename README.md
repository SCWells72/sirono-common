# sirono-salesforce

## Getting set up

#### Install the [Salesforce Migration tool](https://developer.salesforce.com/docs/atlas.en-us.daas.meta/daas/meta_development.htm)

#### Get the Code

You'll need to checkout the git repository from github. Feel free to use the client of your choice.
You can familiarize yourself with using git/github from the command line [here](https://help.github.com/articles/set-up-git)

Create a directory for the repo:

    mkdir Development Development/sirono-salesforce
    cd Development/sirono-salesforce

If you're not using SSH keys and wish to cache your password locally:

    git clone https://github.com/blueprinthealth/sirono-salesforce.git

If you are using SSH keys to avoid locally caching your password:

    git clone git@github.com:/blueprinthealth/sirono-salesforce.git


#### Git Strategies for Developing Features

    # create a new branch for the feature/user story
    git checkout -b new_feature_branch

    # rebase the branch onto master
    git pull --rebase origin master

    # make changes (use your tool of choice - Force.com IDE/MavensMate/Illuminated Cloud)
    push to your local org, etc.

    # When your changes are complete, rebase the local feature branch onto master again (master may have changed in the interim)
    git pull --rebase origin master

    # address any merge conflicts and run full tests in your dev org again

    # push your branch to github
    git push origin new_feature_branch

    # [create a pull request](https://help.github.com/articles/creating-a-pull-request)

    **_UNDER NO CIRCUMSTANCES SHOULD YOU FORCE PUSH ONCE A PULL REQUEST HAS BEEN MADE_**
