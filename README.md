# sirono-salesforce

## Getting set up
#### Get the Code
You'll need to checkout the git repository from github. Feel free to use the client of your choice (you
can familiarize yourself with using git/github from the command line [here](https://help.github.com/articles/set-up-git))

Create a directory for the repo:  
```
mkdir Development 
cd Development
```
If you're not using SSH keys and wish to cache your password locally:  
`git clone https://github.com/blueprinthealth/sirono-salesforce.git`

If you are using SSH keys (to avoid locally caching your password):  
`git clone git@github.com:/blueprinthealth/sirono-salesforce.git`

#### Git Strategies for Developing Features
1. Create a new branch for the feature/user story:  
    `git checkout -b new_feature_branch`

1. To ensure the branch is based off master, immediately rebase  
    `git pull --rebase origin master`

1. Make changes & test within your local sandbox, making commits to your feature branch along the way.
    (use your tool of choice - Force.com IDE/MavensMate/Illuminated Cloud)
    
1. To link your changes back to PivotalTracker, add the Tracker story id within square brackets at 
    the end of your commit message. Optionally, you can include a state change for the Tracker story 
    within the brackets. “Finishes” and “Fixes” will change the specified story to Finished state. 
    “Delivers” will change the specified story to Delivered state.
    
    `[(Finishes|Fixes|Delivers) #TRACKER_STORY_ID]`

    So, if you just fixed a CSS bug for story #109683950, your commit might look like this:
    `mmartinATX Fixed CSS bug [Fixes #109683950]`
  
    When you push to GitHub, the post-receive hook will then call back to Tracker and put a comment on the 
    story with a link to the commit on GitHub.                                          

1. When your changes are complete, rebase the local feature branch onto master again
    as master may have changed in the interim. Squash all of the local commits into one before 
    pushing the feature branch back to github. The simplest way is to do an [interactive rebase](http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html):
    `git pull --rebase -i origin master`
    
1. address any merge conflicts that come up and run full tests in your sandbox again

1. push your branch to github  
    `git push origin new_feature_branch`

1. [Create a pull request](https://help.github.com/articles/creating-a-pull-request). 

_Under no circumstances should you force push the branch once a pull request has been made_
