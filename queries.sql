SELECT DISTINCT "Group Category", "Estimate (%)", "95% CI (%)", "Sample Size"
FROM vax
WHERE "Geography Type" = 'National'
  AND "Vaccine" = 'COVID-19'
  AND "Group Name" = 'race/ethnicity  (7 level)'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
  AND "Time Period" LIKE 'April%'
ORDER BY "Estimate (%)" DESC;




SELECT DISTINCT
    "Year",
    "Time Period",
    "Group Category" AS Sex,
    "Estimate (%)",
    "95% CI (%)",
    "Sample Size"
FROM vax
WHERE "Geography" = 'Georgia'
  AND "Group Name" = 'Age'
  AND "Vaccine" = 'COVID-19'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
ORDER BY "Year", "Time Period", Sex;




SELECT "Vaccine", COUNT(*) AS n_rows
FROM vax
GROUP BY "Vaccine";









SELECT "Geography Type", COUNT(*) AS n_rows
FROM vax
GROUP BY "Geography Type"
ORDER BY n_rows DESC;




SELECT DISTINCT "Geography", "Estimate (%)", "95% CI (%)", "Sample Size"
FROM vax
WHERE "Geography Type" = 'State'
  AND "Vaccine" = 'COVID-19'
  AND "Group Name" = 'All adults 18+ years'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
  AND "Time Period" LIKE 'April%'
ORDER BY "Estimate (%)" DESC;




SELECT DISTINCT "Geography", "Estimate (%)", "95% CI (%)", "Sample Size"
FROM vax
WHERE "Geography Type" = 'State'
  AND "Vaccine" = 'COVID-19'
  AND "Group Name" = 'All adults 18+ years'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
  AND "Time Period" LIKE 'April%'
ORDER BY "Estimate (%)" ASC;



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

