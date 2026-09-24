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

