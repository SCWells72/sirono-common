# sirono-salesforce

## Getting set up
#### Get the Code
You'll need to checkout the git repository from github. Feel free to use the client of your choice (you
can familiarize yourself with using git/github from the command line [here](https://help.github.com/articles/set-up-git))

Create a directory for the repo:  
```
mkdir Development Development/sirono-salesforce
cd Development/sirono-salesforce
```
If you're not using SSH keys and wish to cache your password locally:  
`git clone https://github.com/blueprinthealth/sirono-salesforce.git`

If you are using SSH keys (to avoid locally caching your password):  
`git clone git@github.com:/blueprinthealth/sirono-salesforce.git`

#### Git Strategies for Developing Features
1. create a new branch for the feature/user story:  
    `git checkout -b new_feature_branch`

1. to ensure the branch is based off master, immediately rebase  
    `git pull --rebase origin master`

1. make changes & test within your local sandbox, making commits to your feature branch along the way.
    (use your tool of choice - Force.com IDE/MavensMate/Illuminated Cloud)

1. When your changes are complete, rebase the local feature branch onto master again
    as master may have changed in the interim. Squash all of the local commits into one before 
    pushing the feature branch back to github. The simplest way is to do an [interactive rebase](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html):
    `git pull --rebase -i origin master`
    
1. address any merge conflicts that come up and run full tests in your sandbox again

1. push your branch to github  
    `git push origin new_feature_branch`

1. [Create a pull request](https://help.github.com/articles/creating-a-pull-request). 

_Under no circumstances should you force push the branch once a pull request has been made_
