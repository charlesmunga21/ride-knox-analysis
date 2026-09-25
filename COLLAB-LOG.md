# DATA 501 — Assignment 6 Collaboration Log

**Name:*Charles Muiruri*
**NetID:*cmuiruri*

## Part 0
(pasted output + answers here)
```On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
3f6453c (HEAD -> master, origin/master, origin/HEAD) Added remarks on AI use confirming this work's originality
366bf32 Tested how git draws and presented output in the worklog
aedd5fa Revert "The same 2 min line changed on master branch to test divergence"
82ba326 The same 2 min line changed on master branch to test divergence
79cb3b7 Added screenshot evidence that will be attached with assignment
73d8454 fixed commit error for the 1 to  2 min changes in notebook cleaning cell
04832f3 Added comment on how git and github secure work
7d6f56f Keep local WORKLOG and finish pull
85abb71 Updated the date to indicate when recovery test occurred
706938d Resolve WORKLOG merge and keep local history
83c2f09 Updates before git pull is executed
706f9b9 Tested cloning to see how push responds after commit in worklog
3cafbf0 Updated worklog history after git push execution
e7fb35e Created a change in memo max durations in two branches and fixed the conflict
2b3a50a Resolved max duration conflict by keeping main branch wording
b711a56 Updated max duration in memo on main branch
cf8e644 Updated maximum duration wording in memo
b880872 Added the 24 -hour max limitation
1e20257 Updated main branch with new min-duration using merge
d1efcd8 Fixed minimum trip duration from 1 to 2 minutes
f152051 Added the 1 minute cutoff limitation in report to fit question
339d78c Fixed exaggerated claim in part 4 using revert & stated why
540504f Revert "Add exaggerated claim (on purpose, for Part 4)"
d2247e6 Add exaggerated claim (on purpose, for Part 4)
f4115fd tested the function of restore unstaging in WORKLOG
9326fc0 Fixed wrongfully staged analysis file
fa49493 fixed paragraph deletion from the memo by restoring original file
38fe329 Reword trips affected by January app bug
3ff306c Add gitignore to exclude large raw data files and temporary files
3f23ef3 Added the tracking document for this repo
ccc21da Added code netbook and corresponding charts showing ridership trend
e3ebe1f Add report answering manager question on whether ridership is down.```

Q0.
The repo still can't explain itself, and nobody outside GitHub can see it.

## Part 1: Issues, The Shared To-Do List
TODO 1a. 
Issue #1 URL: https://github.com/charlesmunga21/ride-knox-analysis/issues/1 

TODO 1b.
Issue #2:https://github.com/charlesmunga21/ride-knox-analysis/issues/2

### What / where
3774 of 247,967 trips have no end-station_id, do we drop or flag and keep?
### Expected vs. actual
Expected: 0 rows where end_station_id == 0.
Actual: 3773 rows.
### Why it matters
These trips potentially indicate bikes that were never docked

Issue #3:https://github.com/charlesmunga21/ride-knox-analysis/issues/3

### What / where
Some trips have negative duration whereby end_time comes before start_time
### Expected vs. actual
Expected: (end_time) - (start_time) == +ve integer values for 247967 rows.
Actual: (end_time) - (start_time) == -ve integer value for 747 rows.
### Why it matters
They deflate duration estimations and corrupt final interpretation.

TODO 1C.
Took screenshot of @charlesmunga21#1 in issue #2 which simply references the README at the question regarding 3773 missing end stations.

Q1: 
### Expected vs. actual
Expected: (end_time) - (start_time) == +ve integer values for 247967 rows.
Actual: (end_time) - (start_time) == -ve integer values for 747 rows.

Part 2: A Pull Request, End to End

TODO 2a.Create and switch to a branch named chore/tidy-report in one command. Paste the output of git branch showing where you are.

```* chore/tidy-report
  	master```

TODO 2b. On that branch, make one small, genuine improvement to report.md; for example, tighten the sentence about station capacity pressure (the trips-per-dock finding), or add one sentence noting that the raw data lives outside the repo. Keep it to one logical change.
```sentence: Raw data files live outside the Github repo```

TODO 2c. Stage, commit (a message that says why), and push the branch with the upstream link set. Then on GitHub open a pull request into main. In the PR description, explain the change in one or two sentences; if it resolves one of your Part 1 issues, add Closes #N. Paste the commit message and the PR description.
```created a branch that will be used to execute pull request on GitHub```
```This branch updated the memo.md to highlight that the raw data files are not contained within the repo. Users 	must inquire about those files from the repo owner```

TODO 2d. Self-review: on the PR's "Files changed" tab, leave at least one line comment on your own diff (e.g., noting why you reworded it), then merge the pull request. Paste a screenshot of the line comment.

```The rewording ensures that future users consistently remember not to scramble through this repo looking for the raw data. This will also be addressed in issue #1```

TODO 2e. Locally, git switch main and git pull, then paste git log --oneline showing the merge landed on main.

``` git log --oneline
a66800d (HEAD -> master, origin/master, origin/HEAD) Merge pull request #4 from charlesmunga21/chore/tidy-report
69b1041 (origin/chore/tidy-report, chore/tidy-report) Updated COLLAB-LOG before starting PR
3892b6a created a branch that will be used to execute pull request on GitHub
7711b63 Added a message in the memo recommendation indicating that raw files are not on the repo
588d215 Created 3 issues on GitHub and referenced them
361b324 Added a png of the cross_link referencing README at missing end_stations
3859a99 Added COLLAB-LOG markdown that will track all code outputs and answers to assignment questions```

Q2: At the moment your PR was open but not yet merged, what was true of main? Answer in one sentence.
Main/master was static and untouched since no changes had occurred there.

Part 3: Write the Project README
TODO 3a. Create and switch to a branch named docs/project-readme
```$ git branch
  chore/tidy-report
* docs/project-readme
  master```

TODO 3b. Create README.md with all of the following sections:

	•Title + one-line description.
	•Overview: the manager's two questions (ridership decline and where to add stations), in your own words.
	•Data: a schema table for trips_2025.csv and a second schema table for stations.xlsx (the stations table 	was notshown in class — document its real columns: station_id, station_name, neighborhood, latitude, 	longitude, docks, year_installed). State clearly that the raw files are not in the repo and how to obtain 	them.
	•How to run: the reproducibility steps (install requirements, open analysis.ipynb, Restart & Run All).
	•Key findings: you must cite the station capacity / trips-per-dock story (busy campus stations vs. near-	idle Bearden and Sequoyah Hills) and embed your station bar chart with a relative path. (The class example 	embedded the monthly rider-type line chart; embed the station chart instead, using its real filename in 	charts/.)
	•Limitations: the same honest caveats as report.md (one year of data; observational; documented cutoffs).
	•Repo structure: a short file map.

TODO 3c. Also on this branch, reword the bottom-line headline sentence of memo.md to your preferred wording (you'll need this in Part 4). Commit README.md and the report.md edit together on the branch. Do not open a PR yet.

Q3: The class README embedded charts/monthly_by_rider_type.png. Which chart did you embed instead, and why does a relative path (rather than a path on your laptop) matter for someone who clones the repo?
-I embedded two charts, one showing docks with highest arrivals and another of docks with lowest arrivals in 2025 to asses where resources are scarce and where a cut might be useful due to underutilization. 
-A relative path is accessible to anybody who clones the repo as opposed to a path on my laptop which is only accessible locally to me (the user).








