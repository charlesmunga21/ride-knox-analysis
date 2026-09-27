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

_(filled in live during Part C — see below.)_

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
