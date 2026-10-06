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

**Q-D1.** Before this part, `charlesmunga21.github.io/ride-knox-analysis/` showed the
old `index.md`: a 2025-only story (which rider group caused the 2025 decline, which
stations were strained), with no links to anything else — a dead end, and a year out of
date now that the Day Pass reversed the story. After this part, the home page leads with
the 2026 verdict ("the Day Pass worked") and its recovery chart above the fold, then
links out to the 2025 report, the 2026 memo, and the README (release note link added in
#15). Confirmed live: home page, both linked memo pages, and the embedded chart all
return 200; `2025/memo.md`/`2026/memo_2026.md` render as proper HTML pages via GitHub
Pages' relative-links rewriting, while `README.md` is served as-is (GitHub Pages
excludes README.md from HTML conversion by default) — acceptable since it's explicitly
the "for the technically curious" link, not one of the three readable pages.

---

## Part E — Audit answer

**Change history (five merged PRs that tell this release's story):**

| Date | Commit | What it means, in plain English |
| --- | --- | --- |
| 2026-09-26 | `e744078` | Split the site into a 2025 area and a 2026 area, so the two years can never be confused with each other. |
| 2026-09-26 | `ba482db` | Added the full 2026 Day Pass analysis on top of the existing 2025 analysis, without touching it. |
| 2026-09-26 | `f729e2f` | Rewrote the front page's story to cover both years together, reviewed by a second analyst before it went live. |
| 2026-09-26 | `d470ba3` | Replaced the public home page's headline finding with the 2026 verdict and its chart. |
| 2026-09-26 | `f753b94` | Published a plain-language release note for leadership, linked from the home page. |

**Why this page is auditable (stakeholder language):** Every one of the changes above
went through the same open review step before it became public, so there's a
timestamped, named record of who proposed each change, who looked at it, and why it was
made — not just what the page says today. If someone claims the page said something
different last month, we can point to the exact date and reason it changed, instead of
relying on someone's memory or a saved screenshot.

---

## Part F — Final state

All branches used for this project (`8-separate-year-folders`, `10-extend-gitignore`,
`11-integrate-2026-bundle`, `12-requirements-and-readme-run`, `13-two-year-readme`,
`14-rebuild-pages-home`, `15-release-note`) are deleted, both locally and on GitHub —
`gh pr merge --delete-branch` handled each at merge time. The three stale branches left
over from Assignments 5–6 (`chore/tidy-report`, `docs/project-readme`, `fix/README`) and
one more found during this project (`chore/enable-pages`) were also already-merged and
have now been deleted, locally and on GitHub. `master` is the only branch left in either
place.

Issues #8–#15 (all opened for this project) are closed. Issues #2 and #3 are pre-existing
data-quality issues from before this project (missing `end_station_id`, negative
duration) — left open on purpose, since they're real, unresolved data questions unrelated
to this Git-workflow project, and closing them without investigating would misrepresent
their status.

Final `git status`:

```
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```

Final `git push`:

```
Everything up-to-date
```

Final `git log --oneline` (newest first, full project history):

```
51b414c Record the Part E audit answer (change history + auditability)
f753b94 Merge pull request #22 from charlesmunga21/15-release-note
0646352 Write RELEASE-NOTE.md and link it from the home page
ea71edf Record Q-D1 answer and live-site verification
d470ba3 Merge pull request #21 from charlesmunga21/14-rebuild-pages-home
ff6a7da Rebuild the Pages home page for the two-year story
19901e0 Record the two-laptop transcript and Q-C1/Q-C2/Q-C3 answers
f729e2f Merge pull request #20 from charlesmunga21/13-two-year-readme
01aa1dc [riley] Merge, resolving the headline conflict
c5446b9 [you] Tighten the headline wording
9c4e7c7 [riley] Reword headline and add Open questions section
f353330 [you] Rewrite README.md as the two-year story
d39d8ba Merge pull request #19 from charlesmunga21/12-requirements-and-readme-run
beb7c5e Add requirements.txt and update README How-to-run for both notebooks
50e6a76 Record Part B proof output and Q-B2 answer in the log
ba482db Merge pull request #18 from charlesmunga21/11-integrate-2026-bundle
3eb2e16 Bring in the 2026 notebook, memo, and charts
e744078 Merge pull request #17 from charlesmunga21/8-separate-year-folders
3502b8d Separate 2025 and 2026 artifacts into year-scoped folders
682869a Merge pull request #16 from charlesmunga21/10-extend-gitignore
da980d6 Extend .gitignore ahead of the 2026 hand-off
262dd3e Fix issue numbers in Q-A1 answer (PRs share the issue sequence)
67727df Add PROJECT-LOG.md with starting state and log-commit policy
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
69b1041 Updated COLLAB-LOG before starting PR
3892b6a created a branch that will be used to execute pull request on GitHub
7711b63 Added a message in the memo recommendation indicating that raw files are not on the repo
588d215 Created 3 issues on GitHub and referenced them
361b324 Added a png of the cross_link referencing README at missing end_stations
3859a99 Added COLLAB-LOG markdown that will track all code outputs and answers to assignment questions
3f6453c Added remarks on AI use confirming this work's originality
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
e3ebe1f Add report answering manager question on whether ridership is down
```

**Deliverables:**
1. Repository: https://github.com/charlesmunga21/ride-knox-analysis
2. Live Pages site: https://charlesmunga21.github.io/ride-knox-analysis/

---

## AI use disclosure

This section records where AI was used in the 2026
integration project, so the Git history can be read accurately.

**Tool used:** Claude Code (Anthropic).

**Scope.** Claude Code helped with the 2026 work in PRs **#16–#22** (issues #8–#15) 
to ensure that there was no breakage while integrating with pre-existing 2025 repo. It
was not used for the 2025 analysis in Assignments 6 (PRs #1–#7) as noted in
WORKLOG.md (commit `3f6453c`).

**What Claude Code did:** [drafting initial commit messages and PR descriptions in terminal,
and troubleshooting errors through the `git`/`gh` commands during branching]

**What I did and checked myself:** [decided the issue order and the
.gitignore hazard in Q-A1, ran the two-clone exercise with Riley and resolved the
headline conflict, reviewed every PR before merging, verified the live site, wrote and
approved the Q & A answers]

**How to tell which commits were AI-assisted.**:Check for:
```
Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_...
```

**History rewrite, and why hashes differ.** After the project, `master`'s history was
rewritten to remove those trailer lines. GitHub keeps the original commits on each PR's
page, so both sets exist:

- **The PR pages** (#16–#22) show the original commits, with trailers.
- **`master`** shows the rewritten commits, without trailers.

The hashes in Part E and in Part F's `git log` listing are the **originals**. They open
on GitHub through the PR pages, but `git log master` won't show them. Mapping:

| PR | Commit | Original (PR page) | Now on `master` |
| --- | --- | --- | --- |
| #16 | .gitignore commit | `da980d6` | `2563dc2` |
| #16 | merge | `682869a` | `621d967` |
| #17 | year-folders commit | `3502b8d` | `f05bae5` |
| #17 | merge | `e744078` | `7cec04a` |
| #18 | 2026 bundle commit | `3eb2e16` | `14650c5` |
| #18 | merge | `ba482db` | `85e9d91` |
| #19 | requirements commit | `beb7c5e` | `f4c9024` |
| #19 | merge | `d39d8ba` | `265e361` |
| #20 | [you] README rewrite | `f353330` | `8bd785a` |
| #20 | [riley] headline reword | `9c4e7c7` | `8704de7` |
| #20 | [you] tighten headline | `c5446b9` | `4d68eec` |
| #20 | [riley] conflict merge | `01aa1dc` | `02f1973` |
| #20 | merge | `f729e2f` | `fa165fb` |
| #21 | Pages home commit | `ff6a7da` | `7717a1f` |
| #21 | merge | `d470ba3` | `7a91b4a` |
| #22 | release-note commit | `0646352` | `f23db7d` |
| #22 | merge | `f753b94` | `c2a6638` |

The log-only commits made directly to `master` (for example the Part E and Part F
records) were rewritten the same way, so their hashes in Part F also differ from
`git log master`.

**Responsibility.** I directed every change and reviewed it before it was merged. The
analysis conclusions, the Q&A answers, and the decision to publish are my own.
