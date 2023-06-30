--1. source query
CREATE VIEW source AS 
SELECT
  Donation_Data.id,
  gender, 
  job_field, 
  donation, 
  donation_frequency,
  CASE
    WHEN donation_frequency = 'Once' then (donation * 1)
    WHEN donation_frequency = 'Weekly' then (donation * 52)
    WHEN donation_frequency = 'Monthly' Then (donation * 12)
    WHEN donation_frequency = 'Yearly' Then (donation * 1)
    ELSE 'Check Error'
  END as total_donation_value, 
  state,
  university
FROM Donation_Data 
  INNER JOIN Donor_Data2
    ON Donation_Data.id = Donor_Data2.id
;

/* 2. This query extracts insight on total number of donors, the minimum total donation value, the maximum total donation
 value, and average donation value. */

SELECT
  COUNT(id) AS donor_count,
  SUM(total_donation_value) AS total_donation, 
  ROUND(AVG(total_donation_value),1) AS average_donation,
  MAX(total_donation_value) AS max_donation,
  MIN(total_donation_value) AS min_donation
FROM source
;


/* 2. This query aggregates number of donors, the minimum total donation value, the maximum total donation value, 
and average donation value by distinct donation frequency. */

SELECT 
   donation_frequency,
   COUNT (id) As donor_count,
   SUM(total_donation_value) AS total_donation,
   round(AVG(total_donation_value),1) AS average_donation,
   MAX(total_donation_value) AS max_donation,
   MIN(total_donation_value) AS min_donation
FROM source
GROUP BY 1
ORDER BY 2 DESC
;


/* 3. Donor churn: This is the percentage of donors who stopped donating. This percentage may be estimated by the 
number of donors who donated to the charity just once, as opposed to committing. The query also extracts the percentage 
of total donation value that is lost to those donors. */

SELECT
COUNT(CASE WHEN donation_frequency = 'Once' THEN id END)*1.0
/
COUNT(DISTINCT id)*1.0 AS donor_churn,

round(SUM(CASE WHEN donation_frequency = 'Once' THEN total_donation_value END) *1.0
/
sum(total_donation_value)*1.0,3) AS donation_churn

FROM source
;


/*Donor Count, Total Donation Value, Average Donation Value, Minimum and Maximum Donation Value
by Gender */

SELECT 
    gender,
    COUNT (id) AS donor_count,
    SUM (total_donation_value) AS total_donation, 
    round(AVG(total_donation_value),1) AS average_donation,
    MAX (total_donation_value) AS max_donation,
    MIN (total_donation_value) AS min_donation
FROM source
GROUP BY 1
; 


-- Least Donating States: this query extracts the states in ascending order of number of donors.

SELECT 
  state,
  COUNT(id) AS donor_count,
  SUM(total_donation_value) AS total_donation,
  ROUND(AVG(total_donation_value),1) AS average_donation,
  MAX(total_donation_value) AS max_donation,
  MIN(total_donation_value) AS min_donation
FROM source
GROUP BY 1
ORDER BY 2 
;


/* Top Job Fields by Average Donation Value: This query extracts job fields in order of descending
donor count and average donation value. */

SELECT 
  job_field,
  COUNT(id) AS donor_count,
  SUM(total_donation_value) AS total_donation,
  ROUND(AVG(total_donation_value),1) AS average_donation,
  MAX(total_donation_value) AS max_donation,
  MIN(total_donation_value) AS min_donation
FROM source
GROUP BY 1
HAVING average_donation > 3922
ORDER BY 2 DESC, 4 DESC
;


/* Number of Donors in state + job field: This is the number of donors who work in job fields and live
in states where the average donation value is lower than the overall average donation value of
donors.*/

WITH low_donating_demo AS 
(SELECT 
  state,
  job_field,
  COUNT(id) AS donor_count,
  SUM(total_donation_value) AS total_donation,
  ROUND(AVG(total_donation_value),1) AS average_donation,
  MAX(total_donation_value) AS max_donation,
  MIN(total_donation_value) AS min_donation
 FROM source
 GROUP BY 1,2
 HAVING average_donation < 3922
 )
 
SELECT 
 sum(donor_count)
FROM low_donating_demo
;


/*Top 10 donors by state + job field: The query result is in descending order of total 
donation value. */

SELECT 
  state,
  job_field,
  COUNT(id) AS donor_count,
  SUM(total_donation_value) AS total_donation,
  ROUND(AVG(total_donation_value),1) AS average_donation,
  MAX(total_donation_value) AS max_donation,
  MIN(total_donation_value) AS min_donation
FROM source
GROUP BY 1,2
HAVING average_donation > 3922
ORDER BY 4 DESC
LIMIT 10
;


/* Least donating Job fields by Average Donation Value: This query extracts job fields with an average donation
value lower than the overall average donation value. */ 

SELECT 
  job_field,
  COUNT(id) AS donor_count,
  SUM(total_donation_value) AS total_donation,
  ROUND(AVG(total_donation_value),1) AS average_donation,
  MAX(total_donation_value) AS max_donation,
  MIN(total_donation_value) AS min_donation
FROM source
GROUP BY 1
HAVING average_donation < 3922
ORDER BY 2 DESC, 4 DESC
-- LIMIT 10
;



/* Level of Education: This query extracts insight on the distribution of donors and donations 
by the donors’ level of education. ‘Uneducated’ refers to donors with no data on university 
attended.*/

SELECT
  CASE 
    WHEN university IS NOT null THEN 'Educated'
    WHEN university IS null THEN 'Uneducated'
  END AS Education,
  COUNT(CASE WHEN university IS NOT null THEN id
             WHEN university IS null THEN id
        END) AS donor_count,
  SUM(CASE WHEN university IS NOT null THEN total_donation_value
           WHEN university IS null THEN total_donation_value
      END) AS donations,
  ROUND(AVG(CASE WHEN university IS NOT null THEN total_donation_value
                 WHEN university IS null THEN total_donation_value
            END), 1) AS avg_donations
FROM source
GROUP BY 1
;

