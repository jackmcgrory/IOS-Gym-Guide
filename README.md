Note: If you already have experience with rebase then use the one liner below for a fast rebase option.
The one-liner solution:
This assumes you are on your working branch and you are the only person working on it.
git fetch && git rebase origin/master
Resolve any conflicts, test your code, commit and push new changes to the remote branch.
The longer solution for those new to rebase:
Step 1: This assumes that there are no commits or changes to be made on YourBranch at this point.
First we checkout YourBranch:
git checkout YourBranch
git pull --rebase
What happened? We just pulled all changes made by other developers working on YourBranch and rebased your changes on top of this rebased version.
Step 2: Resolve any conflicts brought up by the rebase.
Step 3: Rebase your local master on the remote master:
git checkout master
git pull --rebase
What happened? We just pulled all the latest changes from the remote master and rebased our local master on the remote master. I always keep the remote master clean and release ready! I also prefer to work on master or other branches locally. I recommend this approach until you become comfortable with git changes and commits.
Note: Step 3 is not needed if you are not maintaining local master, in which case you can do a fetch and rebase remote master directly on your local branch, as in the single-step solution above.
Step 4: Resolve any conflicts brought up by the rebase.
Step 5: Rebase your (rebased) local YourBranch branch on the (rebased) local master:
git checkout YourBranch
git rebase master
What happened? We just rebased our local YourBranch on the local master branch, both of which we had previously rebased on the remote versions.
Step 6: Resolve any conflicts, if any. Use git rebase --continue to continue the rebase after adding the resolved conflicts. At any time you can use git rebase --abort to abort the rebase.
Step 7:
git push --force-with-lease 
What happened? We just pushed our changes to the remote YourBranch. --force-with-lease will determine whether there are any incoming changes for YourBranch from other developers while you rebasing. If there are such changes, git will fetch them to update your local YourBranch before pushing to the remote. This is more advisable than a plain force push, which will not fetch incoming changes from the remote.
Yahoooo...! You have successfully done a rebase!
You might also consider using:
git checkout master
git merge YourBranch
When and Why? This merges YourBranch into master if you and your co-developers are finished making changes to YourBranch. This makes YourBranch up-to-date with master when you want to work on this branch later.
                            ~:   (๑ơ ₃ ơ)♥ rebase   :~
 
