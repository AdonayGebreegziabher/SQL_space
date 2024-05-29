####################################################################
-- SQL Data Cleaning Project --
####################################################################

# 1. Checking for duplicates and removing any
# 2. Standardizing the data and fixing errors
# 3. Looking for blanks and null values to see if they can be populated 
# 4. Removing any columns and rows that are not necessary

-- First I start by creating a staging table
CREATE TABLE layoffs_staging 
LIKE layoffs;

INSERT INTO layoffs_staging 
SELECT * FROM layoffs;

-- Now I move on to cleaning the data:
# 1. Checking for duplicates and removing any
-- First I will check for duplicates
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM 
    layoffs_staging;

SELECT *
FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM 
        world_layoffs.layoffs_staging
) duplicates
WHERE 
    row_num > 1;

-- Now I will delete the ones were the row number is > 1 by creating a new table with a row_num column
CREATE TABLE layoffs_staging2 (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Now I can delete rows were the row_num is > 1
DELETE FROM layoffs_staging2
WHERE row_num > 1;

# 2. Standardizing the data and fixing errors
-- First I will do a trim
UPDATE layoffs_staging2
SET company = TRIM(company), 
    location = TRIM(location), 
    industry = TRIM(industry), 
    total_laid_off = TRIM(total_laid_off),
    percentage_laid_off = TRIM(percentage_laid_off), 
    `date` = TRIM(`date`), 
    stage = TRIM(stage), 
    country = TRIM(country), 
    funds_raised_millions = TRIM(funds_raised_millions);

-- I will a standardization issue I caught in the industry column
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- I will then go on to fix an error I caught in the country column
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

-- I will finish up the standardization by altering the data format of the date column
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

# 3. Looking for blanks and null values to see if they can be populated 
-- I feel the nulls in total_laid_off and percentage_laid_off can't be populated organically
-- Everyother column can potentially be populated
-- I have discovered that the industry and funds_raised_millions are the ideal ones for populating
-- I will try to populate the industry column, but first I will have to convert the blanks into nulls
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
  
-- Second I will tackle the nulls in funds_raised_millions column
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
ON t1.company = t2.company
SET t1.funds_raised_millions = t2.funds_raised_millions
WHERE t1.funds_raised_millions IS NULL
AND t2.funds_raised_millions IS NOT NULL;

# 4. Removing any columns and rows that are not necessary
-- First I will start by removing rows that contain null values for total_laid_off and percentage_laid_off as these are unnecessary during analysis
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Following that I will drop the row_num column I had created
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

####################################################################
-- The final table is presented as follows --
####################################################################
SELECT * 
FROM layoffs_staging2;