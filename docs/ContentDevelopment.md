# Content Workflow

Using the correct workflow is very important. If we don't then our changes will start to conflict and we might end up having to reimplement some of them. For this reason we have this guide. If any step of this guide is confusing please let someone know on the Discord so that we can fix it.

## Setting up a development environment

Before we can do anything we have to install the right tools. We're going to need a GitHub account and the GitHub desktop client as well as a "fork" of the data repository where we can make our own changes. Lastly we're going to need to install the current version of the editor.

1. Go to https://github.com and click "Sign Up" and create an account.
2. Go to https://github.com/chardbury/crucible-data and click the "Fork" button.
3. Go to https://desktop.github.com, download and install the desktop client.
4. Log in to the desktop client and clone the [your-user-name]/crucible-data repository.
5. Go to http://crucible.oho.life/download/latestBuilds/ and .zip file containing EditCrucible in the name.
6. Go to [Documents]/GitHub/crucible-data on your computer.
7. Put the editor binary, DLL files, graphics and settings folders from the .zip file into this folder.

## Fetching the latest upstream content

Before starting a new content branch we must first ensure that our master branch is up to date with the upstream master branch. The master branches represent the main line of development so if we were looking for sprites or objects added recently by others we want to be certain to have the most recent copy of the upstream master. Here's how we do this.

1. Click on the "Fetch origin" button.
2. Click on the "Current branch" button.
3. Select the "master" branch.
4. Click on the "Current branch" button again.
5. Click on the "Choose a branch to merge into master" button.
6. Select the "upstream/master" branch.
7. Click on the "Merge upstream/master into master" button.
8. If you then have a button marked "Push origin" click on it.

## Starting a new feature branch

Now that our master branch is in sync with the upstream master branch we can create a new feature branch for the features we'd like to add. A feature branch is transient, meaning that it will exist for the duration of the development up until the point it is merged into the upstream master branch and then it can be deleted. Here's how to make a new branch.

1. Click on the "Current branch" button.
2. Click on the "New branch" button.
3. Give the new branch a name related to the feature you are adding.
4. If you have the option of selecting a base branch then select "master".
5. Click on the "Create branch" button.

## Adding and committing changes

Congratulations! We're now ready to start adding features. The steps below can be done any number of times, improving and refining things until you are happy with the feature. The first two steps are included just in case you've switched over to a different branch to work on something else for a bit.

1. Click on the "Current branch" button.
2. Select the branch you intend to work on.
3. Open the editory and make the required changes.
4. Back in the GitHub client, in the lower left, enter a commit message.
5. Press the "Commit to [your-branch-name]" button.

## Pushing your commits

Now that we've got everything we wanted to add all in place it is time to get those changes into the upstream master branch and thereafter the actual game. This is where we hand over the work to the code owners to merge it in and build a new version of the game. Once we've done this we should not touch this branch again without first checking with the code owners on Discord. Here's what we have to do.

1. Click on the "Publish branch" button.
2. From the "Branch" menu select "Create pull request".
3. Your web browser will open, enter any additional details for the request.
4. Press the "Create pull request button".