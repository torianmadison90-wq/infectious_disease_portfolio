# SQL and Epi Notes: Infectious Disease Portfolio

Working notes from my data analytics training. I am using CDC vaccination survey data to practice SQL and to learn how to read survey estimates the way an epidemiologist does.

## Project snapshot

- **Driving question:** How did adult COVID-19 vaccination coverage differ by age, race/ethnicity, and state during the 2024-25 season?
- **Data:** CDC National Immunization Survey, Adult COVID Module (NIS-ACM), RespVaxView, 2024-25 archive season. Download it from data.cdc.gov (not stored in this repo because of its size).
- **Size:** 1,440,643 rows, 14 columns. Covers COVID-19, flu, and RSV vaccination.
- **Tools:** SQL (SQLite via DB Browser for SQLite). Python and Tableau are next.
- **Queries file:** `queries.sql`

## Progress

- [x] Day 1: set up GitHub, DB Browser for SQLite, and Anaconda; imported the CSV as a table named `vax`; SQLBolt lessons 1 and 2
- [x] Day 2: filtered by group (sex, age, race/ethnicity); read confidence intervals and sample sizes
- [x] Day 3: `COUNT`, `GROUP BY`, ranking states with `ORDER BY` and `LIMIT`
- [ ] SQLBolt lessons 3 to 5 (more `WHERE`, sorting, review)
- [ ] SQLBolt lessons 8, 10, 11 (NULLs, aggregates, `GROUP BY`)
- [ ] Python (pandas) analysis
- [ ] Tableau dashboard

## About the data

| Column | What it holds |
|---|---|
| `Vaccine` | COVID-19, Flu, or RSV (two RSV groups) |
| `Geography Type` | National, State, HHS Region, or Substate |
| `Geography` | The place (for example, Georgia) |
| `Group Name` | The kind of grouping (Age, Sex, Race/Ethnicity (4 level), Race/Ethnicity (7 level), and others) |
| `Group Category` | The specific group within it (for example, 65+ years, Female) |
| `Indicator Name` / `Indicator Category` | What was measured (for example, received a 2024-2025 COVID-19 dose, intent to vaccinate, confidence, difficulty getting vaccinated) |
| `Time Period` / `Year` / `Time Type` | The survey window (eight periods from Sept 1, 2024 to Apr 27, 2025) |
| `Estimate (%)` | The survey estimate |
| `95% CI (%)` | The 95% confidence interval |
| `Sample Size` | How many people the estimate is based on |
| `Suppression Flag` | 1 means CDC hid the estimate because the sample was too small |

### Data quirks I found

- **Repeated rows.** The same estimate can appear several times (listed under different indicator names). Use `DISTINCT` or filter more tightly.
- **Blank estimates.** About 19% of rows have no estimate because they were suppressed (`Suppression Flag = 1`).
- **Trailing spaces.** Some text values end in a space (for example `'Received a 2024-2025 COVID-19 dose '`), so I match them with `LIKE '...%'`.
- **Time periods sort alphabetically.** `ORDER BY "Time Period"` puts April and December before September. Sort by date needs a later cleaning step.
- **Column names need quotes.** Names with spaces or symbols (for example `"Estimate (%)"`) must be wrapped in straight double quotes.
- **"State" includes more than states.** Washington D.C., Puerto Rico, and the U.S. Virgin Islands appear under `Geography Type = 'State'`.

## SQL concepts learned

| Concept | What it does | Example |
|---|---|---|
| `SELECT` | Picks which columns to show | `SELECT "Geography", "Estimate (%)"` |
| `FROM` | Says which table to read | `FROM vax` |
| `WHERE` | Filters rows | `WHERE "Geography" = 'Georgia'` |
| `AND` | Requires every condition to be true | `WHERE a = 1 AND b = 2` |
| `LIKE` with `%` | Matches text patterns; `%` means "anything" | `LIKE 'April%'` |
| `DISTINCT` | Removes repeated rows | `SELECT DISTINCT "Vaccine"` |
| `AS` | Renames a column in the results | `"Group Category" AS Age` |
| `ORDER BY` | Sorts results (`ASC` low to high, `DESC` high to low) | `ORDER BY "Estimate (%)" DESC` |
| `LIMIT` | Caps how many rows come back | `LIMIT 10` |
| `COUNT(*)` | Counts rows | `SELECT COUNT(*) FROM vax` |
| `GROUP BY` | Sorts rows into piles by a column so you can count or summarize each pile | `GROUP BY "Vaccine"` |
| `--` | A comment (SQL ignores it) | `-- Finding: ...` |

### Clause order (always this order)

`SELECT` → `FROM` → `WHERE` → `GROUP BY` → `ORDER BY` → `LIMIT`

Filters go in `WHERE`. `LIMIT` always comes last. Putting `AND ...` after `LIMIT` causes a syntax error.

### Working in DB Browser

- Run one query at a time. If the editor holds several queries, highlight the one you want, then press play or Command + Return. Only the last result is shown otherwise.
- `LIMIT 10` is a maximum, not a guarantee. If only 9 rows qualify, you get 9.
- If numbers came in as text, sorting and `>` comparisons go wrong. Check with `SELECT typeof("Sample Size") FROM vax LIMIT 1;` and fix with `CAST("Sample Size" AS REAL)`.

## Anatomy of my standard query

```sql
SELECT DISTINCT "Group Category", "Estimate (%)", "95% CI (%)", "Sample Size"
FROM vax
WHERE "Geography Type" = 'National'
  AND "Vaccine" = 'COVID-19'
  AND "Group Name" = 'Age'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
  AND "Time Period" LIKE 'April%'
ORDER BY "Estimate (%)" DESC;
```

| Line | What it does |
|---|---|
| `SELECT DISTINCT ...` | Shows these four columns and drops repeated rows |
| `FROM vax` | Reads from my imported table |
| `"Geography Type" = 'National'` | Uses nationwide estimates (change to `'State'` for states) |
| `"Vaccine" = 'COVID-19'` | Keeps only COVID-19 rows |
| `"Group Name" = 'Age'` | Picks the topic to compare (swap in `'Sex'`, `'Race/Ethnicity (7 level)'`, and so on) |
| `"Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'` | Keeps only "received the dose" estimates; `%` handles the trailing space |
| `"Time Period" LIKE 'April%'` | Uses the April 1 to April 27 period |
| `ORDER BY ... DESC` | Sorts highest first |

To ask a new question, change one line (usually `Group Name`, `Geography`, or `Time Period`) and keep the rest.

## Query library and findings

All findings are from the 2024-25 season, "received a 2024-2025 COVID-19 dose."

### Rows per vaccine and per geography type

```sql
SELECT "Vaccine", COUNT(*) AS n_rows
FROM vax
GROUP BY "Vaccine";

SELECT "Geography Type", COUNT(*) AS n_rows
FROM vax
GROUP BY "Geography Type"
ORDER BY n_rows DESC;
```

`GROUP BY` makes one pile per value and `COUNT(*)` counts each pile. COVID-19 has 939,735 rows (about 65% of the data). State has 1,022,331 rows (about 71%). Both tables total 1,440,643.

### Georgia vs. the nation, all adults, by period

| Period | Georgia | U.S. |
|---|---|---|
| Sep 1 to Sep 28 | 2.6% | 4.7% |
| Sep 29 to Oct 26 | 12.2% | 13.7% |
| Oct 27 to Nov 30 | 13.4% | 18.6% |
| Dec 1 to Dec 28 | 10.3% | 20.1% |
| Dec 29 to Jan 25 | 13.8% | 21.6% |
| Jan 26 to Feb 22 | 10.3% | 21.2% |
| Feb 23 to Mar 31 | 16.7% | 21.1% |
| Apr 1 to Apr 27 | 15.5% | 20.4% |

**Finding:** Nationally, coverage jumped from 4.7% to 13.7% as the vaccine rolled out, then plateaued around 19% to 22%. Georgia tracked lower through winter, but its confidence intervals are wide (samples of about 240 to 675), and by April its estimate (15.5%, CI 9.4 to 21.5) was not clearly different from the national 20.4%.

### By age (national, April)

| Age | Estimate | 95% CI | Sample size |
|---|---|---|---|
| 65+ | 39.1% | 36.6 to 41.7 | 10,907 |
| 50 to 64 | 22.7% | 20.5 to 24.8 | 9,031 |
| 18 to 49 | 12.0% | 11.0 to 13.0 | 16,367 |

**Finding:** Adults 65+ were about three times as likely as adults 18 to 49 to have received the vaccine. The intervals do not overlap, so the gap is unlikely to be sampling error.

### By age in Georgia (April)

65+: 36.4% (CI 16.7 to 56.1, n=61). 50 to 64: 19.6% (CI 4.5 to 34.6, n=54). 18 to 49: 6.8% (CI 2.4 to 11.1, n=177). Same pattern as the nation, but with very wide intervals. One estimate (65+, December) was suppressed.

### By race/ethnicity (national, April, 7 levels)

| Group | Estimate | 95% CI | Sample size |
|---|---|---|---|
| White, non-Hispanic | 23.4% | 22.1 to 24.6 | 23,576 |
| Asian, non-Hispanic | 21.9% | 17.1 to 26.7 | 1,520 |
| Black, non-Hispanic | 18.1% | 15.2 to 20.9 | 3,260 |
| Other or multiple races, non-Hispanic | 13.5% | 9.4 to 17.7 | 1,220 |
| Hispanic | 13.0% | 10.9 to 15.1 | 5,217 |
| Native Hawaiian/Pacific Islander, non-Hispanic | 9.4% | 5.3 to 13.6 | 177 |
| American Indian/Alaska Native, non-Hispanic | 7.6% | 4.6 to 10.6 | 364 |

**Finding:** White adults had higher coverage than Black and Hispanic adults, and those differences are well supported. The Asian estimate is imprecise and overlaps with White adults. The lowest estimates (AI/AN and NHPI) rest on small samples, so they should be reported with caution.

### By self-perceived equity in seeking healthcare (national, April)

Better than other groups: 35.2% (n=8,327). Don't know/refused: 18.9% (n=7,020). Same: 16.5% (n=19,333). Worse: 13.2% (CI 8.5 to 18.0, n=1,108).

### By sex in Georgia

```sql
SELECT DISTINCT "Year", "Time Period", "Group Category" AS Sex,
       "Estimate (%)", "95% CI (%)", "Sample Size"
FROM vax
WHERE "Geography" = 'Georgia'
  AND "Group Name" = 'Sex'
  AND "Vaccine" = 'COVID-19'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
ORDER BY "Year", "Time Period", Sex;
```

**Finding:** No consistent difference by sex. December looked like a gap (male 16.7%, female 4.5%), but it reversed in later months and rests on small samples (n=92 to 148), so it is more likely noise.

### States ranked, April

```sql
SELECT DISTINCT "Geography", "Estimate (%)", "95% CI (%)", "Sample Size"
FROM vax
WHERE "Geography Type" = 'State'
  AND "Vaccine" = 'COVID-19'
  AND "Group Name" = 'All adults 18+ years'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
  AND "Time Period" LIKE 'April%'
  AND "Sample Size" > 1000
ORDER BY "Estimate (%)" ASC
LIMIT 10;
```

Only 9 geographies had samples above 1,000, so this returns 9 rows (Puerto Rico 8.5% up to D.C. 40.8%). Without the sample filter there are 53 geographies: D.C. (40.8%), Vermont (37.8%), and Minnesota (33.8%) were highest; the U.S. Virgin Islands (3.8%), Puerto Rico (8.5%), and Alabama (11.4%) were lowest. Georgia was 15.5%.

## Reading survey estimates (epi notes)

- **Confidence interval (CI):** The range the true value likely falls in. A narrow CI means a precise estimate.
- **Overlap rule of thumb:** If two groups' CIs do not overlap, the difference is likely real. If they overlap, you cannot conclude there is a difference. (A formal test comes later.)
- **Sample size controls precision, not the result.** A bigger sample does not make a group more or less vaccinated. It only narrows the CI.
- **Suppression:** CDC hides estimates from samples that are too small. Blank values in the table are not missing by accident.
- **Small samples:** Report "estimates were lowest, though based on small samples" instead of "this group was least vaccinated."
- **Describe, do not explain.** The data shows who was vaccinated, not why. Access, trust, and outreach are hypotheses, not findings.
- **Wording:** Say "more likely to have received the vaccine," not "more prone to."

## Glossary

- **Coverage:** the percent of a population that received a vaccine.
- **Estimate:** a number calculated from a survey sample, not a full count.
- **NIS-ACM:** the National Immunization Survey, Adult COVID Module.
- **Aggregate:** a calculation across many rows (`COUNT`, `AVG`, `MIN`, `MAX`).
- **NULL:** a blank or missing value.

## Next up

1. SQLBolt lessons 8, 10, 11 (NULLs, aggregates).
2. Use `GROUP BY` with averages and counts on the vaccination data.
3. Load the data into Python (pandas) and make my first chart.
4. Build a Tableau Public dashboard.
5. Write the project summary in the main README.
