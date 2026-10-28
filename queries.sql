SELECT DISTINCT "Group Category", "Estimate (%)", "95% CI (%)", "Sample Size"
FROM vax
WHERE "Geography Type" = 'National'
  AND "Vaccine" = 'COVID-19'
  AND "Group Name" = 'race/ethnicity  (7 level)'
  AND "Indicator Category" LIKE 'Received a 2024-2025 COVID-19 dose%'
  AND "Time Period" LIKE 'April%'
ORDER BY "Estimate (%)" DESC;