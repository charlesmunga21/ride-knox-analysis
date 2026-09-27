# DATA 501 — Project GitHub Log: 2026 Integration

**Name:** Charles Muiruri
**NetID:** cmuiruri

**Log-commit policy (House Rule 1 exemption):** PROJECT-LOG.md updates are committed
directly to `master` for the rest of this project. (This repo's default/protected
branch is named `master`, not `main` — every "main" in the assignment brief refers to
this repo's `master`.)

---

## Part 0 — Starting state

`git status` (2026-09-26):

```
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```

`git log --oneline` (2026-09-26), full Assignment 5–6 history, newest first:

```
c8c64b4 Created a fork to a public repo & executed final push to update the origin master
a267e03 Created a personal portfolio with a profile README
ffe3a1b Pinned the ride-knox-analysis repo to my profile
f21e941 Merge pull request #7 from charlesmunga21/fix/README
f66d0be Updated the READMME to start with key findings
a3d31c3 Published live pages on Github
8cdcac4 Added the screenshot showing live pages link on side bar
41e4b8d Merge pull request #6 from charlesmunga21/chore/enable-pages
7213fc3 Add Ride Knox Ridership Analysis for 2025
46cbcc2 Add configuration for Jekyll site
cc3f23a Created a merge conflict on a branch and resolved it through a PR
241598b Merge pull request #5 from charlesmunga21/docs/project-readme
f88c674 Resolved the merge conflict in the bottom-line section of the memo
74902dc Fixed the wording on the same bottom-line sentence in memo
9570f6e Added charts, reworded bottom-line in memo, and added a README file
6e5825d Created the repository README markdown file
cc18683 Reworded the bottom-line headline sentence in the memo
f7b0b17 Added a chart showing docks with lower use
7be9995 Created a PR, commented, self-reviewed it and merged it to main branch
116d13e Added screenshot evidence of PR comment with successful merge
a66800d Merge pull request #4 from charlesmunga21/chore/tidy-report
... (full history continues; see `git log --oneline` in the repo for all commits back to e3ebe1f)
```

Tree is clean; history confirmed intact from Assignments 5–6.

---

## Part A — Q&A

**Q-A1.** Issue **#10** ("Extend `.gitignore` before the 2026 hand-off is added") had to
be done before **#11** ("Bring in the 2026 notebook, memo, and charts"). The hazard:
the 2026 hand-off folder contains `ride_knox_api_token.txt` (a credential file) and raw
data (`trips_2026_h1.csv`). The existing `.gitignore` was written for 2025 only and does
not cover either. If the bundle were copied in and `git add .` run before extending the
ignore rules, the token and/or raw CSV could be staged and committed. Extending
`.gitignore` first closes that hole before the bundle ever touches the working tree.

---

## Part B — Q&A

**Q-B1.** The thing in the 2026 hand-off that must never be committed and isn't a data
file: `ride_knox_api_token.txt`, a credentials file for the export API that arrived
bundled with the data hand-off. Made sure of it by reading the starter pack's README
before touching anything (it explicitly calls the file out) and adding it to
`.gitignore` before copying the bundle in. If it reached a public repo, anyone could
use the token to pull data from the vendor's API under Ride Knox's account — a
credential leak, not a data leak, but with account-takeover/API-abuse consequences and
no undo once public (GitHub's history is fetchable by anyone who cloned before removal).

**Q-B2.** Moving `analysis.ipynb`, `memo.md`, and everything in `charts/` into `2025/`
(#8) broke the relative image paths that `README.md` and `index.md` depended on —
`charts/2025_arrivals_per_dock.png` no longer existed once the folder moved to
`2025/charts/2025_arrivals_per_dock.png`. Caught it by grepping every `.md` file in the
repo for `charts/` before moving anything, so both files were fixed in the same PR that
did the move, and confirmed live on the Pages site immediately after merging (see below).

`git status` right after staging the #11 integration (only the five intended files
staged):

```
On branch 11-integrate-2026-bundle
Changes to be committed:
	new file:   2026/analysis_2026.ipynb
	new file:   2026/charts/daypass_vs_others.png
	new file:   2026/charts/recovery_vs_2025.png
	new file:   2026/charts/station_pressure_change.png
	new file:   2026/memo_2026.md
```

`git status --ignored` for `2026/`, proving the raw data and the credential sit on disk
but are invisible to Git:

```
	2026/stations.xlsx
	2026/stations_2026.xlsx
	2026/trips_2025.csv
	2026/trips_2026_h1.csv
	scratch/
	stations.xlsx
	stations_2026.xlsx
	trips_2025.csv
	~$_instructions_git.docx
```

Live-site check after merging #8's reorg: `index.md` (200), and both moved chart images
under `2025/charts/` (200/200) — no broken images.

**Issue #9 resolution:** re-ran `2026/analysis_2026.ipynb` top-to-bottom inside the repo
(after installing `pandas`/`matplotlib`/`openpyxl`, now pinned in `requirements.txt`)
against the same raw files used elsewhere in the repo. June `casual_plus_dp_yoy_%` came
out to 11.9%, which rounds to the memo's stated "+12%." Confirmed accurate; closed #9
manually with the result recorded in the issue comment, no PR needed.

---

## Part C — Two-laptop transcript ([you] / [riley])

Shared branch `13-two-year-readme`, created off `master` and pushed empty first so
Riley's clone could find it. Riley's clone: `ride-knox-riley`, a second `git clone` of
the same repo on this machine, with `git config user.name "Riley Chen"` /
`user.email "riley.chen@example.com"` set locally (that clone only).

```
[you]    $ git switch -c 13-two-year-readme
         Switched to a new branch '13-two-year-readme'
[you]    $ git push -u origin 13-two-year-readme
         * [new branch]      13-two-year-readme -> 13-two-year-readme

[you]    (rewrote README.md as the two-year story: headline, 2026 chapter, 2025
          chapter, combined limitations, two-year data table, how-to-run)
[you]    $ git add README.md
[you]    $ git commit -m "[you] Rewrite README.md as the two-year story"
[you]    $ git push
         f353330..c5446b9? (first push of this commit: d39d8ba..f353330 master -> 13-two-year-readme)

[riley]  $ git clone https://github.com/charlesmunga21/ride-knox-analysis.git ride-knox-riley
[riley]  $ git switch 13-two-year-readme
         Switched to a new branch '13-two-year-readme'
         branch '13-two-year-readme' set up to track 'origin/13-two-year-readme'.
[riley]  $ git config user.name "Riley Chen"
[riley]  $ git config user.email "riley.chen@example.com"

[riley]  (reworded the headline sentence differently than [you]'s wording; added a new
          "Open questions for the fall" section)
[riley]  $ git add README.md
[riley]  $ git commit -m "[riley] Reword headline and add Open questions section"
         (committed locally — NOT pushed yet)

[you]    (edited the same headline sentence again: "within a few points ... member
          ridership kept growing on its own")
[you]    $ git add README.md
[you]    $ git commit -m "[you] Tighten the headline wording"
[you]    $ git push
         f353330..c5446b9  13-two-year-readme -> 13-two-year-readme      (succeeds — first push)

[riley]  $ git push
         ! [rejected]        13-two-year-readme -> 13-two-year-readme (fetch first)
         error: failed to push some refs to 'https://github.com/charlesmunga21/ride-knox-analysis.git'
         hint: Updates were rejected because the remote contains work that you do not
         hint: have locally. This is usually caused by another repository pushing to
         hint: the same ref. If you want to integrate the remote changes, use
         hint: 'git pull' before pushing again.
         hint: See the 'Note about fast-forwards' in 'git push --help' for details.

[riley]  $ git pull
         Auto-merging README.md
         CONFLICT (content): Merge conflict in README.md
         Automatic merge failed; fix conflicts and then commit the result.

         README.md conflict block:
         <<<<<<< HEAD
         **Headline:** Six months after launch, the Day Pass has recovered most of the
         non-member ridership Ride Knox lost to the 2025 price increase, without cannibalizing
         memberships.
         =======
         **Headline:** The 2026 Day Pass brought non-member ridership back to within a few
         points of its pre-price-increase level, while member ridership kept growing on its own.
         >>>>>>> c5446b9fb9b016b06884cfe8d6e9e13ab4d5b27b

[riley]  (resolved by blending both: kept the "within a few points" / member-ridership
          point from [you]'s side, and the explicit "not cannibalizing memberships"
          conclusion from Riley's side)
[riley]  $ git add README.md
[riley]  $ git commit -m "[riley] Merge, resolving the headline conflict"
[riley]  $ git push
         c5446b9..01aa1dc  13-two-year-readme -> 13-two-year-readme      (succeeds)

[you]    $ git pull
         Fast-forward, README.md updated with Riley's merge

(GitHub) Opened PR #20 for 13-two-year-readme -> master, left a review line comment,
         merged with "Closes #13".

[you]    $ git switch master && git pull      -> f729e2f
[riley]  $ git switch master && git pull      -> f729e2f      (identical to [you]'s master)
```

### Q-C1
In Assignment 5, Part 8, nothing else had pushed to that branch between the clone and
the push — the remote was exactly where the clone left it. Here, [you] pushed a new
commit to the *same shared branch* in the gap between Riley's clone/commit and Riley's
own push, so the remote had moved ahead of what Riley's local branch pointer knew about.
Riley's push was a non-fast-forward for that reason alone.

### Q-C2
The conflict lived entirely on the shared feature branch (`13-two-year-readme`) — never
on `master`. That's the point of "main is sacred": every change, including the messy
part where two people edit the same line, happens on a branch first, and only a clean,
reviewed result ever reaches `master` via PR. The habit that keeps this kind of conflict
small is the "resolve early, resolve small" one from class — pull/sync with the shared
branch often instead of letting local edits drift for days before pushing, so any overlap
is caught while it's still a few lines, not a few files.

### Q-C3
`HEAD` marked Riley's own local commit — the tip of Riley's branch as it stood right
before running `git pull`. Riley never typed the word; `git pull`'s merge step inserts
that label automatically to distinguish "what you already had checked out" (`HEAD`)
from "what just came in from the remote" (labeled by the incoming commit's hash here,
since it hadn't been given a branch name on Riley's side yet).

---

## Part D — Q&A

**Q-D1.** _(filled in after Part D merges.)_

---

## Part E — Audit answer

**Change history (five commits/PRs that tell this release's story):**

_(filled in once Part B–E PRs are merged.)_

**Why this page is auditable (stakeholder language):**

_(filled in alongside the change history.)_

---

## Part F — Final state

_(final `git status`, final `git push`, final `git log --oneline`, branch cleanup —
filled in last.)_
