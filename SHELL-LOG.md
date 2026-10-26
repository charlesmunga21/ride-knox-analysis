# DATA 501; Assignment 10 Shell Log

**Name:Charles Munga Muirur**
**NetID:cmuiruri**
**Terminal used: (VS Code terminal Git Bash on Windows)**

## Part 0: Setup & Orientation (5 pts)
TODO 0a. cd into the folder holding your data files. Run head -1 trips_2025.csv and wc -l trips_2025.csv exactly as they appear in the Module 10 slides. Paste both. If your line count isn't 250601, you have the wrong file; fix that before going further.
```$ head -1 trips_2025.csv 
trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
$ wc -l trips_2025.csv
250601 trips_2025.csv
```

TODO 0b. Create SHELL-LOG.md from the template above, add the ## Part 0 through ## Part 10 headings, and commit it on a new branch named feature/bash-week10-triage. (Note the branch name; it is not the one from any earlier assignment.)


Q0c: wc -l reported 250601 but the dataset has 250,600 rows. Explain the difference in one sentence. Then name the command from the slides that would let you drop the offending line before counting.
```wc -l counts all lines, including the CSV header. 
tail -n +2 trips_2025.csv | wc -l would skip the csv header
```
## Part 1: Navigation, Files & Directories (7 pts)
TODO 1a. From inside your data folder, run pwd and then ls -lh. Paste both. In one sentence, say what -h changed about the output.
```$ pwd
/c/Users/cmuiruri/Notebooks_Python/ride-knox-analysis
$ ls -lh
total 167M
-rw-r--r-- 1 cmuiruri 1049089  174 Sep 26 20:51  _config.yml
-rw-r--r-- 1 cmuiruri 1049089  162 Sep 17 10:38 '~$_instructions_git.docx'
drwxr-xr-x 1 cmuiruri 1049089    0 Sep 26 20:38  2025/
drwxr-xr-x 1 cmuiruri 1049089    0 Oct 18 22:10  2026/
-rw-r--r-- 1 cmuiruri 1049089  15K Sep 26 18:36  COLLAB-LOG.md
-rw-r--r-- 1 cmuiruri 1049089 1.2K Sep 26 20:54  index.md
-rw-r--r-- 1 cmuiruri 1049089  53K Sep 24 15:28  Line_comment_PR.png
-rw-r--r-- 1 cmuiruri 1049089  51K Sep 23 17:08  Mention_cross_link.png
-rw-r--r-- 1 cmuiruri 1049089  92K Sep 26 15:22  Pinned_ride_Knox.png
-rw-r--r-- 1 cmuiruri 1049089  23K Sep 28 15:25  PROJECT-LOG.md...16+ lines
```
h now shows what permissions i have for every file inside my directory, read, write permissions.

TODO 1b. Create a directory called out/ inside your ride-knox-analysis repo. Everything you redirect to a file in this assignment goes there.


TODO 1c. Add out/ to your .gitignore, then run ls -a in the repo folder and paste the output. Confirm in one sentence that .gitignore is visible in that listing and was not visible under plain ls.
```$ ls -a
 ./           '~$_instructions_git.docx'   Line_comment_PR.png      README.md                 ride-knox-queries/   stations.xlsx        WORKLOG.md
 ../           2025/                       Mention_cross_link.png   RELEASE-NOTE.md           scratch/             stations_2026.xlsx
 .git/         2026/                       out/                     repository_evidence.png   SHELL-LOG.md         trips_2025.csv
 .gitignore    COLLAB-LOG.md               Pinned_ride_Knox.png     requirements.txt          Side_bar_link.png    trips_2026_07.csv
 _config.yml   index.md                    PROJECT-LOG.md           ride_knox_v2.db           SQL-LOG.md           trips_2026_h1.csv
 ``` .gitignore is only visible with ls -a or list all but not with only ls.

Q1d: You are about to write result files into out/. Give the Module 5 reason those files should not be committed, and then give the specific one-line reason that applies to this week's outputs in particular. (Hint: what would someone need in order to regenerate them?)
Committing generated results when they can be recreated from the source inputs and commands adds redundant, potentially stale files to the repository and therefore, MUST be sent to the .gitignore.
For this week's data, the output can be generated from the data files and the pipeline commands we generate, that's why we commit the input commands and leave the output, since it's just a view of the file in question, not an outcome or analysis of what the data means.


## Part 2: Wildcards & the Multi-File Folder (10 pts)
TODO 2a. With a single command using a wildcard, report the line count of every trips CSV in the folder at once. Paste the output including the total line.
```$ wc -l trips_*.csv
  250601 trips_2025.csv
   33086 trips_2026_07.csv
  137342 trips_2026_h1.csv
  421029 total
  ```

TODO 2b. Write a wildcard pattern that matches only the two 2026 trip files and not trips_2025.csv, and use it with ls -lh. Paste the command and output. (There is more than one correct pattern; yours must exclude the 2025 file.)
```$ ls -lh trips_2026_*.csv
-rw-r--r-- 1 cmuiruri 1049089 2.9M Oct 18 22:10 trips_2026_07.csv
-rw-r--r-- 1 cmuiruri 1049089  12M Oct 18 22:10 trips_2026_h1.csv
```

TODO 2c. Write a wildcard pattern that matches both station workbooks; stations.xlsx and stations_2026.xlsx; and use it with ls -lh. Paste the command and output.
```$ ls -lh stations*.xlsx
-rw-r--r-- 1 cmuiruri 1049089 15K Aug 25 16:11 stations.xlsx
-rw-r--r-- 1 cmuiruri 1049089 15K Sep 13 16:40 stations_2026.xlsx
```

Q2d: In 2a you typed one *, and the output named three files individually. Explain what happened to the * between pressing Enter and wc running. Then say why the slides call rm *.csv exactly as dangerous as typing every filename out.
```Before wc (word count) ran, the shell expanded * into the names of all matching files and passed those filenames as arguments, thus rm *.csv removes every matching CSV as if we had typed each filename explicitly. An overly broad pattern can delete files we didn’t intend to remove.
```

Q2e: Compare the sizes from 2b with the line counts from 2a. Work out roughly what share of trips_2025.csv's rows the 2026 half-year file holds, and roughly what share of its bytes. Report both figures. Then explain in one sentence what the relationship between those two shares tells you about the rows in these particular files; and name one kind of CSV column that would break that relationship.
```Share of rows: (137,342 − 1) ÷ (250,601 − 1) = 54.8%
Share of bytes: 12 MB ÷ 22 MB = 54.5% 
Since the share is around 50%, this means that the average row sizes are closely similar, however, adding a CSV column containing variable text length such as descriptions/comments, would alter the share significantly. A big file could occupy less than a smaller file with more descriptions.
```

## Part 3: Inspecting Files Without Loading Them (10 pts)
TODO 3a. Print the last 3 lines of trips_2025.csv. Paste them. In one sentence, say what this tells you that head cannot.
```$ head -n 3 trips_2025.csv
trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
T0057984,2025-01-01 00:06:48,2025-01-01 00:19:16,S17,Happy Holler,S16,casual,electric
T0073896,2025-01-01 00:40:20,2025-01-01 01:20:19,S09,Neyland Stadium,S08,casual,classic

tail -n 3 trips_2025.csv
T0029313,2025-12-31 23:33:25,2025-12-31 23:47:31,S08,Student Union - UT,S09,CASUAL,classic
T0233859,2025-12-31 23:40:52,2025-12-31 23:51:14,S04,Old City - Jackson Ave,S04,member,electric
T0140894,2025-12-31 23:42:04,2026-01-01 00:37:04,S12,Fort Sanders - Laurel Ave,S12,casual,electric

tail can reveal how the 2025 trips file ends, which head alone cannot.
```
TODO 3b. Print lines 500 through 504 of trips_2025.csv. Do it two ways; once by combining head and tail with a pipe, and once with sed -n. Paste both commands and confirm the outputs match. (Class printed lines 2–4; the technique is the same, the arithmetic is yours.)
```$ head -n 504 trips_2025.csv | tail -n 5
T0193042,2025-01-02 12:56:34,2025-01-02 13:07:49,S06,HODGES LIBRARY,S08,member,classic
T0109309,2025-01-02 12:58:14,2025-01-02 13:08:04,S05,World's Fair Park,S04,casual,classic
T0017188,2025-01-02 12:59:01,2025-01-02 13:17:00,S11,Cumberland Ave & 17th St,S02,member,electric
T0004700,2025-01-02 12:59:54,2025-01-02 13:37:33,S07,The Hill - Ayres Hall,S02,member,electric
T0183710,2025-01-02 12:59:57,2025-01-02 13:14:14,S01,Market Square,S01,casual,classic
(takes the first 504 lines, then prints the last 5 of them, 500 t0 504)

$ sed -n '500,504p' trips_2025.csv
T0193042,2025-01-02 12:56:34,2025-01-02 13:07:49,S06,HODGES LIBRARY,S08,member,classic
T0109309,2025-01-02 12:58:14,2025-01-02 13:08:04,S05,World's Fair Park,S04,casual,classic
T0017188,2025-01-02 12:59:01,2025-01-02 13:17:00,S11,Cumberland Ave & 17th St,S02,member,electric
T0004700,2025-01-02 12:59:54,2025-01-02 13:37:33,S07,The Hill - Ayres Hall,S02,member,electric
T0183710,2025-01-02 12:59:57,2025-01-02 13:14:14,S01,Market Square,S01,casual,classic

(In sed -n; -n suppresses automatic printing, and p stands for print, so '500,504p')
```

TODO 3c. Run wc -l stations.xlsx. Paste the number.
```$ wc -l stations.xlsx
48 stations.xlsx
```

Q3d: The number in 3c is not the number of stations, and it is dangerously close to being believable. Say what wcactually counted, and explain why this file behaves differently from trips_2025.csv under every command in this module. Then name one command from the slides you could run to confirm your explanation before trusting any result from this file.
```wc -l counted newline (line breaks) characters in the .xlsx file’s binary data and not station records since a .xlsx workbook isn’t a plain-text list of rows. The command I would run before trusting this file would be file stations.xlsx which would tell me what file type it is before I can run any command on it.
```

Q3e: You want the column names of trips_2026_07.csv without loading it. Give the command, run it, and paste the output. Then state in one sentence which pandas attribute from Module 2 you just replaced.
```$ head -n 1 trips_2026_07.csv
trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type
this replaces the .column attribute such as 'df.columns'
```
## Part 4: Filtering Text; grep & cut (12 pts)
(grep selects matching lines; cut selects parts of lines)
TODO 4a. Using grep -c, count the rows containing a September 2025 date. Paste the command and the count.
```$ grep -c '2025-09' trips_2025.csv
23202
```

TODO 4b. Run grep -c for member twice; once case-sensitively and once ignoring case. Paste both commands and both numbers, and state the difference between them.
```$ grep -c 'member' trips_2025.csv 
153388

$ grep -ic 'member' trips_2025.csv
158927

Ignoring case (using -ic) finds 5,539 more rows, because it also matches member written with different capitalization
```

TODO 4c. Using grep -v, count the rows that do not involve station S24 (Sequoyah Hills Park). Paste the command and the count. (Careful: match the station id in a way that can't also match S240 or a substring elsewhere on the line; look at how the slides wrote the S99 pattern.)
```$ tail -n +2 trips_2025.csv | grep -vc ',S24,'
246852

(comma boundaries match ',S24,' as a complete CSV field, and tail -n +2 skips the header so the count is of data rows)
```

TODO 4d. Using cut, display the bike_type column for the first four lines of the file. Paste the command and output. State which field number bike_type is and how you determined it; not from memory.
```$ head -n 1 trips_2025.csv | cut -d, -f1-8
trip_id,start_time,end_time,start_station_id,start_station_name,end_station_id,rider_type,bike_type

$ head -n 4 trips_2025.csv | cut -d, -f8
bike_type
electric
classic
classic

(cut -d, the -d stands for delimiter and the comma in front of it shows we are dealing with a comma separated values/text)
```

Q4e: In 4b, one of your two numbers is the answer to "how many member trips are there" and the other is not. Say which is which and why. Then connect this to the module's meta-rule in one sentence.
```The case insensitive value of 158,927 accounts for the member trips as it also includes different case types for the same word, member. This follows the class's meta rule that a command can run successfully and return a plausible number while answering the wrong question if its matching method misses relevant rows.
```

Q4f: Your 4b case-insensitive count and the anchor figure for member at the top of this assignment should agree. Do they? If a classmate's did not, name the single most likely mistake in their command.
```The case insensitive member values match with the anchor figure. If a classmate's command did not find that number, they might have missed the i in the -ic that tells bash to ignore the case and just find matching text, or they might have the wrong file inside the command/directory.
```

## Part 5: Pipes & Redirection (10 pts)
TODO 5a. Using grep and >, create three files in out/, one per month, containing the rows for September, October, and November 2025. Name them out/trips_2025_09.csv, out/trips_2025_10.csv, out/trips_2025_11.csv. Paste all three commands.
```$ grep '2025-09' trips_2025.csv > out/trips_2025_09.csv
grep '2025-10' trips_2025.csv > out/trips_2025_10.csv
grep '2025-11' trips_2025.csv > out/trips_2025_11.csv
```

TODO 5b. With one wildcard command, report the line counts of the three files you just made. Paste the output including the total.
```$ wc -l out/trips_2025_*.csv
  23202 out/trips_2025_09.csv
  19795 out/trips_2025_10.csv
  13750 out/trips_2025_11.csv
  56747 total
  ```

TODO 5c. Build a small summary file, one line at a time. Send the line count of the September file into out/summary.txtwith >, then append the line counts of the October and November files to that same file with >>. Display the finished file. Paste all four commands and the output. (Use >> for the second and third; Q5e asks what you'd have ended up with otherwise.)
```$ wc -l out/trips_2025_09.csv > out/summary.txt

$ wc -l out/trips_2025_10.csv >> out/summary.txt -- (appending)
wc -l out/trips_2025_11.csv >> out/summary.txt   -- (appending)

$ cat out/summary.txt                           -- (getting the line count)
23202 out/trips_2025_09.csv
19795 out/trips_2025_10.csv
13750 out/trips_2025_11.csv
```

TODO 5d. Run a grep against a filename that does not exist, sending only the error message to out/errors.log. Then display the contents of that log. Paste both commands and the output.
```$ grep '2025-09' missing_file.csv 2> out/errors.log
$ cat out/errors.log
grep: missing_file.csv: No such file or directory
```

Q5e: Explain exactly what out/summary.txt would have contained had you typed > for all three commands in 5c, and how many of your three counts would have survived. Then say why the slides treat that one-character difference as a reason to read a redirection twice before pressing Enter.
```only the last command to be executed would have appeared in the end, because using a single > overwrites the previous results/existing output. Always confirm before hitting enter because we might execute a series of commands to only find one output in the end!
```

Q5f: In 5d you separated the error from the results. Give the concrete reason the module offers for why errors travel on their own stream; phrase it in terms of what would end up in a results file otherwise.
```Error messages alongside the intended results would definitely distort the readability, interpretation and even meaning of correct output in a given file, and to avoid this, we ensure that they travel on their own stream.
```


## Part 6: sort & uniq (13 pts)
TODO 6a. Build a pipeline that counts how many trips used each bike_type, sorted with the largest count first. Drop the header. Paste the command and output, and confirm the two counts sum to 250,600.
```$ tail -n +2 trips_2025.csv | cut -d, -f8 | sort | uniq -c | sort -rn     -- (sort -rn is for sort numerically and reverse order)
 155300 classic
  95300 electric
  ```

TODO 6b. Build a pipeline that counts trips per start_station_id, largest first. Paste the top 5 lines. Then run the same pipeline with sort -r instead of sort -rn and paste its top 5.
```$ tail -n +2 trips_2025.csv | cut -d, -f4 | sort | uniq -c | sort -rn | head -n 5
  26112 S06
  25044 S08
  22656 S01
  18983 S11
  16570 S02

$ tail -n +2 trips_2025.csv | cut -d, -f4 | sort | uniq -c | sort -r | head -n 5
  26112 S06
  25044 S08
  22656 S01
  18983 S11
  16570 S02
  ```

Q6c: The two orderings in 6b are identical, even though sort -r compares text and sort -rn compares numbers. Explain why they agree here. (Look closely at the whitespace in front of each count.) Then state the condition under which they would stop agreeing; you will meet exactly that condition in Part 8.
```Sorting the digits as text in reverse order gives the same order as sorting numerically because the counts have the same spacing in front of them and have the same number of digits. Otherwise, sort -r would definitely change the order if any of those conditions changes, while sort -rn compares the numbers.
```

TODO 6d. Using sort and uniq -d, count how many trip_id values appear more than once in the file. Paste the command and the count.
```$ tail -n +2 trips_2025.csv | cut -d, -f1 | sort | uniq -d | wc -l    --(uniq -d (-d for duplicates))
600
```

TODO 6e. Take the first repeated trip_id from 6d and use grep to display every line in the file carrying that id. Paste the command and both lines. In one sentence, say whether the two rows differ in any column.
```$ tail -n +2 trips_2025.csv | cut -d, -f1 | sort | uniq -d | head -n 3
T0000118
T0000716
T0001190

$ grep 'T0000118' trips_2025.csv
T0000118,2025-04-23 15:56:40,2025-04-23 16:15:49,S16,Ijams Nature Center,S14,member,electric
T0000118,2025-04-23 15:56:40,2025-04-23 16:15:49,S16,Ijams Nature Center,S14,member,electric  

The two rows are identical/duplicates.
```

Q6f: Combine 6d and 6e into a claim: what kind of duplicate is this file carrying, and which single command from Part 6 would remove them all? Then reconcile your answer with the anchors at the top of this assignment; show the arithmetic.
```The file contains 600 duplicated trip records since the rows are exactly the sam. Using sort trips_2025.csv | uniq would drop the 600 duplicated rows. The new number would now be 250600 - 600 = 250000 trip rows (header exclude).
```

## Part 7: tr & sed (10 pts)
TODO 7a. Using cut and grep -i, list every distinct spelling of Market Square appearing in start_station_name, with a count for each. Paste the command and output. State how many spellings there are.
```$ tail -n +2 trips_2025.csv | cut -d, -f5 | grep -i 'Market Square' | sort | uniq -c
    644   Market Square
    341 market square
  20781 Market Square
    461 MARKET SQUARE
    429 Market Square  
    
    There are 5 spellings that vary in the white spaces and capitalization.
    ```

TODO 7b. Now build the normalized top-5 station ranking: take start_station_name, drop the header, strip leading and trailing whitespace with sed, lowercase it with tr, and count and rank the results. Paste the command and the top 5 rows. (Class counted how many distinct values survived normalization; nobody built a ranking from it.)
```$ tail -n +2 trips_2025.csv | cut -d, -f5 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -n 5
  26112 hodges library
  25044 student union - ut
  22656 market square
  18983 cumberland ave & 17th st
  16570 gay street & union ave
  ```

Q7c: Compare the count for Market Square in 7b against its most common single spelling from 7a. How many trips would a naïve ranking; one that skipped the sed and tr stages; have failed to credit to Market Square? Show the subtraction.
```After tr and sed, we get 22656 for market square. However, a naive count would easily miss trips by not equalizing white spaces and standardizing the casing in the following way: 22656 - 20781 = 1875 if we consider Market Square spelling and white space order/position.
```

Q7d: Your 7b ranking is by station name. Your 6b ranking is by station id. Put the two top-5 lists side by side in your log. They should carry the same counts in the same order. Say in one sentence what it would have meant about your Part 7 pipeline if they had not matched.
```  |S06 26112 hodges library               26112|
     |S08 25044 student union - ut           25044|
     |S01 22656 market square                22656|
     |S11 18983 cumberland ave & 17th st     18983|
     |S02 16570 gay street & union ave       16570|
Miscounts would mean that our normalization missed on some rows and therefore, ommitted trips or captured the wrong ones.
```
## Part 8: awk (13 pts)
TODO 8a. Count trips that started at station S11 two ways: once with grep -c "S11", and once with awk matching the start-station field exactly. Paste both commands and both numbers.
```$ grep -c "S11" trips_2025.csv
35415

$ awk -F, '$4=="S11"' trips_2025.csv | wc -l
18983
```

Q8b: Your two numbers in 8a differ by a large margin. Account for the gap specifically; name what the extra grep matches are. Then state the general rule this illustrates about grep and columns.
```grep -c "S11" searches the entire row and reports both trips that started and those that ended in the S11 station giving an extra 16432 trips. Therefore, prefer commands that can select a specific column to guard against such errors due to mismatch between the required vs the output.
``` 

TODO 8c. Using a single awk command with two conditions, count the trips that have no end_station_id and were taken by a member; counting all spellings of member, not just the lowercase one. Paste the command and the count. (Class filtered on one condition at a time; this needs both, plus the case fix, in one expression.)
```$ tr 'A-Z' 'a-z' < trips_2025.csv | awk -F, 'NR>1 && $6=="" && $7=="member" {n++} END {print n}'
2371
```

Q8d: Express your 8c count as a share of the 3,774 trips with no end station, and say in one sentence what; if anything; that share suggests. Then name one thing this number cannot tell you.
```2,371 ÷ 3,774 × 100 = 62.8%; suggests about 63% of trips without end station were taken by members but it cannot in any way tell us why the end-station ID is missing or whether those trips were ever completed.
```

TODO 8e. Using an awk associative array, count electric-bike trips per month for 2025 and print the results sorted by month. Paste the command and all 12 rows. (Class grouped casual trips; this groups on the other categorical column.)
```$ awk -F, 'NR>1 && $8 =="electric" {c[substr($2,6,2)]++} END {for (k in c) print k, c[k]}' trips_2025.csv | sort
01 4186
02 5090
03 7526
04 9749
05 11331
06 12067
07 10447
08 9348
09 8837
10 7571
11 5287
12 3861
```

TODO 8f. Re-sort your 8e output by count, descending, twice; once with sort -k2 -r and once with sort -k2 -rn. Paste the top 4 rows of each.
Q8g: This time the two orderings disagree; the text sort names a different busiest month than the numeric sort. Name both months, say which is correct, and explain what makes this output behave differently from the 6b output that sorted identically either way. Then state, in one sentence, what a colleague reading only the wrong version would have concluded about Ride Knox's electric fleet.
```$ awk -F, 'NR>1 && $8=="electric" {c[substr($2,6,2)]++} END {for (k in c) print k, c[k]}' trips_2025.csv | sort -k2 -r | head -n 4
04 9749
08 9348
09 8837
10 7571

$ awk -F, 'NR>1 && $8=="electric" {c[substr($2,6,2)]++} END {for (k in c) print k, c[k]}' trips_2025.csv | sort -k2 -rn | head -n 4
06 12067
05 11331
07 10447
04 9749
```
Q8g: This time the two orderings disagree; the text sort names a different busiest month than the numeric sort. Name both months, say which is correct, and explain what makes this output behave differently from the 6b output that sorted identically either way. Then state, in one sentence, what a colleague reading only the wrong version would have concluded about Ride Knox's electric fleet.
```Busiest month under the text sort is April, while using the number sort, it is June. The correct one is the -rn or the number sort, because the -r sort only considers the leading character whereby, anything that starts with 9 is higher than anything that starts with 1 or lower digit characters. Unlike the 6b uniq -c padding (equalizing leading white space), awk counts lack such padding, and the character sorting causes the mismatch. A colleague relying on the text sorting would end up concluding that peak month was April, while in reality it was June for electric bike ridership in 2025.
```

## Part 9: Synthesis & Pull Request (5 pts)
TODO 9a. Using the three month files you built in Part 5, build one pipeline that reads all three at once with a wildcard and counts trips by month and bike type together; a compound key; sorted by month. Paste the command and the full output.
Careful: out/ now also holds summary.txt and errors.log. Your pattern must match the three month files and nothing else; the same precision Part 2b asked for. If your totals look strange, check what your wildcard actually swept up.
```$ awk -F, '{c[substr($2,6,2) " " $8]++} END {for (k in c) print k, c[k]}' out/trips_2025_??.csv | sort
08 classic 6
08 electric 4
09 classic 14361
09 electric 8842
10 classic 12215
10 electric 7576
11 classic 8456
11 electric 5287
```

Q9b. You built three month files, and each has two bike types, so you expected six groups. You did not get six. Report how many groups you got, name the unexpected one(s), and explain exactly how they got into files you created with a grep for September, October, and November. (Think about which fields on a trip row carry a date.)
```I got 8 groups vs the expected 6 groups. This is because some August trips had start time in August and end time in September(thus, included in september file), and since the compound key is the start time, they were grouped under August.
```

Q9c. Reconcile: the counts in 9a must sum to the total line count from 5b. Show the arithmetic in your log. Then say in one sentence what your 9a pipeline would need in order to count only trips that genuinely started in each month; and whether the commands taught in this module can do it.
```14,361 + 8,842 + 12,215 + 7,576 + 8,456 + 5,287 = 56,747 + 6 + 4 = 56747.
Using: $ awk -F, 'NR>1 && substr($2,1,7)=="2025-09" {n++} END {print n}' trips_2025.csv
23192 could help us get trips for september.
```

TODO 9d. Commit everything on feature/bash-week10-triage, push, and open a pull request into main. In the PR description, paste the single command from this assignment you'd most want a reviewer to check, and say what you want them to look at. Submit the PR URL on Canvas.


## Part 10: Challenge (optional, +5 extra credit)
C1. Ride Knox wants to know which stations are losing bikes; sending out more than they take in, so a van has to rebalance them.
With a single awk command using two associative arrays in one pass, compute for each station: its number of departures, its number of arrivals, and the difference (departures − arrivals). Exclude S99, and don't let trips with a blank end_station_id be counted as arrivals anywhere. Print the three stations with the largest net outflow and the three with the largest net inflow.
```$ tail -n +2 trips_2025.csv |
sort -u |
grep -v ",S99," |
awk -F, '$4!="" {d[$4]++} $6!="" {a[$6]++}
END {for (s in d) print s, d[s], a[s]+0, d[s]-a[s];
for (s in a) if (!(s in d)) print s, 0, a[s], -a[s]}' \
> out/station_balance.txt

$ sort -k4 -rn out/station_balance.txt | head -n 3  ---largest outflows
S06 26058 25486 572
S08 24959 24435 524
S01 22606 22291 315

$ sort -k4 -n out/station_balance.txt | head -n 3  ---largest inflows
S21 2835 2911 -76
S18 4681 4703 -22
S23 2095 2103 -8
```

C2. Module 8 computed this same quantity in SQL with three CTEs, and got a net outflow for Hodges Library (S06) of 581. Your number will be close but not identical. Give the two reasons for the gap; one about which rows Module 8's clean_trips view excluded that your pipeline keeps, and one about the file-versus-database difference you established back in Part 6.
```S06 now has 572 net outflow compared to our SQL 581 because here, we still keep trips with missing end_station_id as departures, but not counted as arrivals. Module 8 did not count those rows although we kept them as flagged. Here, use or exclusion of the sort -u option would definitely affect final count due to the duplicate rows.
```

## Reflection + AI Disclosure (5 pts); answer in SHELL-LOG.md
R1. Four tasks this week had a version that ran cleanly and still gave the wrong answer: the case-sensitive grep in 4b, the text sort in 8f, the field-blind grep in 8a, and the stray month groups in 9a. Pick the one you would have been least likely to catch on your own, and in 2–3 sentences describe the habit you'd build to catch it next time. "Be more careful" is not a habit; name something you would actually run or check.
```The text sort in 8f and field-blind grep in 8a: I would run *sort -rn* on any numerical sorting to ensure that any errors due to incorrect matching of values does not occur since when numbers are critical, then a wrong report makes the matters worse for the decision makers. The field blind grep would require use of *cut ot awk* that are specific to columns/fields for any operation in a chain.
```

R2. In one or two sentences: name a question from this assignment that you could have answered faster in pandas or SQL than in the shell, and say what made the shell the wrong tool for it. Being honest about where the tool stops is worth as much as using it well.
```Counting the number of stations in stations.xlsx is way faster with pandas since shell’s line-count commands were the wrong tool because an Excel workbook is a binary spreadsheet as opposed to a line-oriented text file.
```

R3. AI disclosure: describe any use of generative AI tools in this assignment, or state 
```VS Code copilot was used to expound more on the use of awk and how to construct parts of the chains like in the extra credit question. All final commands, results, and conclusions are my own.
```