-- I will be exploring the correlation between smoking status and insurance charges, in relation to various other factors.

# Is there a correlation between smoking status and insurance charges?

SELECT smoker, ROUND(AVG(charges), 0) as average_charges
FROM insurance
GROUP BY smoker;
-- As can be seen from the data smokers are charged on average 3.8 times greater than non-smokers.
-- Thus indicating that there's indeed a correlation between smoking status and insurance charges.

# Smoking status and insurance charges, by gender

SELECT sex,
	   ROUND(AVG(CASE WHEN smoker = 'no' THEN charges ELSE NULL END), 0) AS avg_non_smoker_charges,
       ROUND(AVG(CASE WHEN smoker = 'yes' THEN charges ELSE NULL END), 0) AS avg_smoker_charges
FROM insurance
GROUP BY sex;
-- The data shows that smokers are charged higher insurance premiums regardless of gender.
-- Male smokers are charged approximately 4.1 times more than non-smokers.
-- While female smokers are charged approximately 3.5 times more than non-smokers.

# Smoking status and insurance charges, by region

SELECT region,
       ROUND(AVG(CASE WHEN smoker = 'no' THEN charges END), 0)AS avg_non_smoker_charges,
	   ROUND(AVG(CASE WHEN smoker = 'yes' THEN charges END), 0)AS avg_smoker_charges
FROM insurance
GROUP BY region;
-- The findings show that smokers are charged higher insurance premiums in all regions.
-- The highest disparity between avergae insurance charges by smoking status exists in the southeast region.
-- While the lowest disparity is that of the northeast region.  

# Smoking status and insurance charges, by BMI.
-- Note: the BMI data was categorized using data available on the internet. 

SELECT 
    CASE
        WHEN smoker = 'yes' THEN 'smoker'
        ELSE 'non-smoker'
    END AS smoking_status,
    CASE
        WHEN bmi < 18.5 THEN 'underweight'
        WHEN bmi >= 18.5 AND bmi < 25 THEN 'normal'
        WHEN bmi >= 25 AND bmi < 30 THEN 'overweight'
        WHEN bmi >= 30 THEN 'obese'
    END AS BMI_category,
    COUNT(*) AS total_number,
    ROUND(AVG(charges), 0) AS avg_charges
FROM
    insurance
GROUP BY smoking_status , bmi_category
ORDER BY bmi_category;

-- The data shows that smokers are charged higher regardless of BMI.
-- The highest disparity between avergae insurance charges by smoking status is between obese individuals.
-- While the lowest disparity is that between overweight individuals.  