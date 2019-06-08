# Content Workflow

## Git & GitHub

Git is a software development tool. It solves the problem of having multiple people working on the same collection of files by intelligently "merging" changes. The software is very powerful but along with that power comes a some small additional complications to content development process.

On its surface Git is a way of tracking changes to a collection of files over time and amongst a potentially large group of developers. Each time a developer changes a bunch of files they create a _commit_, a kind of note that says what they changed and when and why and so forth. Developers can _push_ commits to remote repositories, essentially publishing them, and then other developers can _fetch_ those commits into their own repositories and build a more complete picture of the project's ongoing development.

Here's how to think about Git. On your computer you have a directory that contains a bunch of files. This is called your *working directory*. If you make some changes to the files in your working directory you can save those changes in the Git repository. This is called *committing*. You can make several sets of changes and commit several times. Eventually you want to publish what you've done so you send all the data in your repository to a remote server. This is called *pushing*. Now that its published other people who may have been working on the same set of files can download your changes (*fetching*) and integrate them with their own (*merging*). Because it is common to merge immediately after fetching this combined operation has its own name, *pulling*.

GitHub is an online provider of services related to Git. In our model every developer has two repositories a "local" repository which is stored on their computer and in which they directly make changes and a "remote" repository, called "origin", which is stored by GitHub. In addition each developer needs to be aware of one other repository, referred to as the "upstream" repository, which is stored on GitHub.

## Process

### Setup

1. Go to https://github.com, click "Sign Up" and create an account.
2. Go to https://github.com/chardbury/crucible-data and click the "Fork" button.
3. Go to https://desktop.github.com, download and install the desktop client.
4. Log in to the desktop client and clone the [your-user-name]/crucible-data repository.
5. Go to [Documents]/GitHub/crucible-data on your computer.
6. Put the editor binary, DLL files, graphics and settings folders in this folder.

### Fetch

7. Click on the "Fetch origin" button.
8. Click on the "Current branch" button.
9. Select the "master" branch.
10. Click on the "Current branch" button again.
11. Click on the "Choose a branch to merge into master" button.
12. Select the "upstream/master" branch.
13. Click on the "Merge upstream/master into master" button.
14. If you then have a button marked "Push origin", you may click on it.

### Branch

15. Click on the "Current branch" button.
16. Click on the "New branch" button.
17. Give the new branch a name related to the card.
18. If you have the option of selecting a base branch then select "master".
19. Click on the "Create branch" button.

### Commit

20. Click on the "Current branch" button.
21. Select the branch you intend to work on.
22. Make the required changes in the editor.
23. Back in the GitHub client, in the lower left, enter a commit message.
24. Press the "Commit to [your-branch-name]" button.
25. Repeat steps 21-23 until you have completed the feature.

### Pull Request

26. Click on the "Publish branch" button.
27. From the "Branch" menu select "Create pull request".
28. Your web browser will open, enter any additional details for the request.
29. Press the "Create pull request button".