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



## Part 5
## Part 6
## Part 7
## Part 8
## Reflection + AI disclosure (in WORKLOG.md)
## Part 9: Challenge (optional)