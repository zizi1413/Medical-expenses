/* ============================================================
   Medical Insurance Charges Analysis (PostgreSQL)
   Table: dwh.medicall
   ============================================================ */

-- 0) Quick view
SELECT *
FROM dwh.medicall
LIMIT 10;

-- 1) Row count
SELECT COUNT(*) AS total_rows
FROM dwh.medicall;

-- 2) Missing values check (important columns)
SELECT
  SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END)      AS missing_age,
  SUM(CASE WHEN sex IS NULL THEN 1 ELSE 0 END)      AS missing_sex,
  SUM(CASE WHEN bmi IS NULL THEN 1 ELSE 0 END)      AS missing_bmi,
  SUM(CASE WHEN children IS NULL THEN 1 ELSE 0 END) AS missing_children,
  SUM(CASE WHEN smoker IS NULL THEN 1 ELSE 0 END)   AS missing_smoker,
  SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END)   AS missing_region,
  SUM(CASE WHEN charges IS NULL THEN 1 ELSE 0 END)  AS missing_charges
FROM dwh.medicall;

-- 3) Duplicates check (exact duplicates across all columns)
SELECT
  COUNT(*) - COUNT(DISTINCT (age, sex, bmi, children, smoker, region, charges)) AS duplicate_rows
FROM dwh.medicall;

-- 4) Basic summary of charges
SELECT
  AVG(charges) AS avg_charges,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY charges) AS median_charges,
  MIN(charges) AS min_charges,
  MAX(charges) AS max_charges
FROM dwh.medicall;

-- 5) Charges by smoker (core business insight)
SELECT
  smoker,
  COUNT(*) AS n,
  AVG(charges) AS avg_charges,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY charges) AS median_charges
FROM dwh.medicall
GROUP BY smoker
ORDER BY avg_charges DESC;

-- 6) Smoker premium (% difference vs non-smoker)
WITH smoker_stats AS (
  SELECT smoker, AVG(charges) AS avg_charges
  FROM dwh.medicall
  GROUP BY smoker
)
SELECT
  100.0 * (MAX(CASE WHEN smoker = 'yes' THEN avg_charges END)
         - MAX(CASE WHEN smoker = 'no'  THEN avg_charges END))
       / NULLIF(MAX(CASE WHEN smoker = 'no' THEN avg_charges END), 0) AS smoker_premium_percent
FROM smoker_stats;

-- 7) Average charges by region (and smoker split)
SELECT
  region,
  smoker,
  COUNT(*) AS n,
  AVG(charges) AS avg_charges
FROM dwh.medicall
GROUP BY region, smoker
ORDER BY region, avg_charges DESC;

-- 8) Average charges by sex (and smoker split)
SELECT
  sex,
  smoker,
  COUNT(*) AS n,
  AVG(charges) AS avg_charges
FROM dwh.medicall
GROUP BY sex, smoker
ORDER BY sex, avg_charges DESC;

-- 9) BMI categories vs charges (simple segmentation)
SELECT
  CASE
    WHEN bmi < 18.5 THEN 'Underweight'
    WHEN bmi < 25   THEN 'Normal'
    WHEN bmi < 30   THEN 'Overweight'
    ELSE 'Obese'
  END AS bmi_category,
  smoker,
  COUNT(*) AS n,
  AVG(charges) AS avg_charges
FROM dwh.medicall
GROUP BY bmi_category, smoker
ORDER BY avg_charges DESC;

-- 10) Charges by age group (and smoker split)
SELECT
  CASE
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 45 THEN '36-45'
    WHEN age BETWEEN 46 AND 55 THEN '46-55'
    ELSE '56+'
  END AS age_group,
  smoker,
  COUNT(*) AS n,
  AVG(charges) AS avg_charges
FROM dwh.medicall
GROUP BY age_group, smoker
ORDER BY age_group, avg_charges DESC;

-- 11) Charges by number of children (and smoker split)
SELECT
  children,
  smoker,
  COUNT(*) AS n,
  AVG(charges) AS avg_charges
FROM dwh.medicall
GROUP BY children, smoker
ORDER BY children, avg_charges DESC;

-- 12) Top 5 highest charges per region (Window Function – strong for CV)
WITH ranked AS (
  SELECT
    region, sex, smoker, age, bmi, children, charges,
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY charges DESC) AS rn
  FROM dwh.medicall
)
SELECT *
FROM ranked
WHERE rn <= 5
ORDER BY region, charges DESC;

-- 13) Quartiles (NTILE) for price distribution
SELECT
  region,
  smoker,
  charges,
  NTILE(4) OVER (ORDER BY charges) AS charges_quartile
FROM dwh.medicall;

-- 14) Rank individuals by charges within each smoker group
SELECT
  smoker,
  region,
  age,
  bmi,
  children,
  charges,
  DENSE_RANK() OVER (PARTITION BY smoker ORDER BY charges DESC) AS charge_rank_in_smoker_group
FROM dwh.medicall
ORDER BY smoker, charge_rank_in_smoker_group
LIMIT 50;
