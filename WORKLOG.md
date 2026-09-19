# DATA 501; Assignment 5 Worklog
**Name: Charles Muiruri**
**NetID:cmuiruri**

Part	Points
0. Setup & identity check	5
1. Repo birth & first commits	15
2. .gitignore: the house rules	10
3. History & diffs	10
4. The three levels of "oops"	10
5. The branch experiment	15
6. Manufacture & resolve a conflict	15
7. To GitHub: remote & push	10
8. The round trip (clone → push → pull)	5
Reflection + AI disclosure (in WORKLOG.md)	5


## Part 0
```git version 2.55.0.windows.5```
```Name and email are stamped together with the time and changes made```


## Part 1
TODO 1b) 
	```On branch master

	No commits yet

	Untracked files:
 	 (use "git add <file>..." to include in what will be committed)
       	 	WORKLOG.md
        	analysis.ipynb
        	charts/
        	memo.md
        	~$_instructions_git.docx

	nothing added to commit but untracked files present (use "git 	add" to 	track)```

TODO 1e)
```On branch master
	Untracked files:
  	(use "git add <file>..." to include in what will be committed)
        	~$_instructions_git.docx

	nothing added to commit but untracked files present (use "git add" to 	track): I had a problem with this file (~$_instructions_git.docx) 	even after deleting it, so I 	will be including it in the .gitignore 	downstream.```

Q1:Git commits of files individually are useful especially when files are spread across different folders or when files introduce different changes to different parts of the existing code.

## Part 2
TODO 2a.
```On branch master
	Untracked files:
  	(use "git add <file>..." to include in what will be committed)
        	scratch/
       	 	stations.xlsx
        	stations_2026.xlsx
        	trips_2025.csv
        	~$_instructions_git.docx

	nothing added to commit but untracked files present (use "git add" to 	track)```
TODO 2c.
```On branch master
	Changes not staged for commit:
  	(use "git add <file>..." to update what will be committed)
  	(use "git restore <file>..." to discard changes in working directory)
        	modified:   WORKLOG.md

	Untracked files:
  	(use "git add <file>..." to include in what will be committed)
        	.gitignore

	no changes added to commit (use "git add" and/or "git commit -a")```
Q2: Raw CSV is a large origin data file that never gets changed and logging it would be pointless. Charts are small outputs that can change depending on the question of the management, and history of those changes is important.

## Part 3
TODO 3b.
```	-A January app bug left 800 trips without end timestamps; I kept them 	for
	+About 800 trips were affected by an app bug in January and were left 	without end timestamps; I kept them for
 counting and excluded them from duration operation.```
 
3c. 
```38fe329 (HEAD -> master) Reword trips affected by January app bug
	3ff306c Add gitignore to exclude large raw data files and temporary 	files
	3f23ef3 Added the tracking document for this repo
	ccc21da Added code netbook and corresponding charts showing ridership 	trend
	e3ebe1f Add report answering manager question on whether ridership is 	down```
Q3: Running git diff after committing would not show any changes since everything would have been updated and saved in the repository.

## Part 4
TODO 4a.
```On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   WORKLOG.md
        modified:   memo.md

no changes added to commit (use "git add" and/or "git commit -a")```

```Command : git restore memo.md```
 
TODO 4b.
This requires me to edit WORKLOG file and stage together with analysis file which I haven't changed. This is my edit.
```On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   WORKLOG.md```
TODO 4c.
```540504f (HEAD -> master) Revert "Add exaggerated claim (on purpose, for Part 4)"
d2247e6 Add exaggerated claim (on purpose, for Part 4)
f4115fd tested the function of restore unstaging in WORKLOG
9326fc0 Fixed wrongfully staged analysis file
fa49493 fixed paragraph deletion from the memo by restoring original file
38fe329 Reword trips affected by January app bug
3ff306c Add gitignore to exclude large raw data files and temporary files
3f23ef3 Added the tracking document for this repo
ccc21da Added code netbook and corresponding charts showing ridership trend
e3ebe1f Add report answering manager question on whether ridership is down```

Q4. The mistake and its fix are part of the story just as we left a cell audit trail in week 3 while working with codes. The commit after the fix is intentional, to make sure that anybody who comes across the repo understands how a mistake occurred and was fixed, instead of a deletion(lost trail). 

## Part 5

TODO 5a.
```  master
* min-cutoff-2min```

Q5a.
One commit is appropriate at this point because changes affect the same component, minimum duration threshold in both analysis and memo files.

TODO 5d.
```Updating f152051..d1efcd8
	Fast-forward
 	memo.md | 2 +-
 	1 file changed, 1 insertion(+), 1 deletion(-)```

Q5b. Fast forward message here shows that since there was no other commit or change in main branch(master didn't move) since we started working on min-cutoff-2min branch, merge simply matches and connects last main branch label to corresponding label in the new branch to form one continuous line.

TODO 5e.
```$ git branch
	* master```

## Part 6

TODO 6c. 
```Auto-merging memo.md
CONFLICT (content): Merge conflict in memo.md
Automatic merge failed; fix conflicts and then commit the result.```

```<<<<<<< HEAD
Trips over 24 hours were excluded since bikes likely never docked.
=======
Abnormal trips that lasted more than 24 hours were excluded.
>>>>>>> reword-limitations```

Q6a. The wording committed on main. This is because merge action was initiated while on main branch.

TODO 6d.
```2b3a50a (HEAD -> master) Resolved max duration conflict by 	keeping main branch wording
b711a56 Updated max duration in memo on main branch
cf8e644 (reword-limitations) Updated maximum duration 	wording in memo
b880872 Added the 24 -hour max limitation
1e20257 Updated main branch with new min-duration using 	merge
d1efcd8 Fixed minimum trip duration from 1 to 2 minutes
f152051 Added the 1 minute cutoff limitation in report to 	fit question
339d78c Fixed exaggerated claim in part 4 using revert & 	stated why
540504f Revert "Add exaggerated claim (on purpose, for Part 	4)"
d2247e6 Add exaggerated claim (on purpose, for Part 4)
f4115fd tested the function of restore unstaging in WORKLOG
9326fc0 Fixed wrongfully staged analysis file
fa49493 fixed paragraph deletion from the memo by restoring 	original file
38fe329 Reword trips affected by January app bug
3ff306c Add gitignore to exclude large raw data files and 	temporary files
3f23ef3 Added the tracking document for this repo
ccc21da Added code netbook and corresponding charts showing 	ridership trend
e3ebe1f Add report answering manager question on whether 	ridership is down```

Q6b. "A merge conflict is not Git failing; it is Git _refusing to guess between two/more decisions made on the same component of a given problem____."

## Part 7

TODO 7b. 
```$  git remote add origin https://github.com/charlesmunga21/ride-knox-analysis.git
git remote add origin https://github.com/ride-knox-analysis/ride-knox-analysis.git
git push -u origin master

error: remote origin already exists.
error: remote origin already exists.

Enumerating objects: 63, done.
Counting objects: 100% (63/63), done.
Delta compression using up to 16 threads
Compressing objects: 100% (61/61), done.
Writing objects: 100% (63/63), 760.07 KiB | 6.55 MiB/s, done.
Total 63 (delta 30), reused 0 (delta 0), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (30/30), done.
To https://github.com/charlesmunga21/ride-knox-analysis.git
 * [new branch]      master -> master
branch 'master' set up to track 'origin/master'.``` 

TODO 7c. (i) Allcommits appear in the history, (ii) report.md and charts/ are visible, and (iii) trips_2025.csv, stations.xlsx, and scratch/ are not there (PNG uploaded).

Q7. git push -u origin main: origin is the name for GitHub copy we are creating from our local repo and u stands for universal in that we can push any local changes inside our repositories directly to our online GitHub repository.







## Part 8
## Reflection + AI disclosure (in WORKLOG.md)
## Part 9: Challenge (optional)