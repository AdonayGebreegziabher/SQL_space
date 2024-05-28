##############################################################################################################

-- FIRST ROUND OF ASSESSMENTS --

###############################################################################################################

# max deaths, by date
-- shows which date had the highest number of deaths
SELECT
  date,
  MAX(CAST(new_deaths AS DECIMAL)) AS deaths
FROM
  deaths
GROUP BY
  date
ORDER BY
  deaths DESC
LIMIT 1;

# max cases, by date
-- shows which date recorded the highest number of cases
SELECT
  date,
  MAX(CAST(new_cases as dec)) AS cases 
FROM
  deaths
GROUP BY
  date
ORDER BY
  cases DESC
LIMIT 1;

# total deaths and percentage, by quarter
-- shows the total number of deaths recorded
-- shows what percentage of the population died due to covid
SELECT 
    EXTRACT(YEAR FROM date) AS Year, 
    EXTRACT(QUARTER FROM date) AS Quarter,
    SUM(new_deaths) AS total_deaths, 
    ROUND((SUM(new_deaths) / AVG(population)) * 100, 7) AS deaths_percentage
FROM 
    deaths
GROUP BY
    EXTRACT(YEAR FROM date),
    EXTRACT(QUARTER FROM date)
ORDER BY
    Year, Quarter;

# total cases and percentage, by quarter
-- shows the total number of cases recorded
-- shows what percentage of the population is infected with covid
SELECT 
    EXTRACT(YEAR FROM date) AS Year, 
    EXTRACT(QUARTER FROM date) AS Quarter,
    SUM(new_cases) AS total_cases, 
    ROUND((SUM(new_cases) / AVG(population)) * 100, 7) AS cases_percentage
FROM 
    deaths
GROUP BY
    EXTRACT(YEAR FROM date),
    EXTRACT(QUARTER FROM date)
ORDER BY
    Year, Quarter;

# deaths per case, by quarter
-- shows the likelihood of dying if you contract covid
SELECT 
    EXTRACT(YEAR FROM date) AS Year, 
    EXTRACT(QUARTER FROM date) AS Quarter,
    ROUND((SUM(new_deaths) / SUM(new_cases)) * 100, 2) AS deaths_per_case
FROM 
    deaths
GROUP BY
    EXTRACT(YEAR FROM date),
    EXTRACT(QUARTER FROM date)
ORDER BY
    Year, Quarter;

##############################################################################################################

-- SECOND ROUND OF ASSESSMENTS --

###############################################################################################################

# max tests, by date
-- shows the date with the most tests performed
SELECT
  date,
  MAX(CAST(new_tests as dec)) AS tests 
FROM
  vaccinations
GROUP BY
  date
ORDER BY
  tests DESC
LIMIT 1;

# max vaccinations, by date
-- shows the date with the most vaccinations given
SELECT
  date,
  MAX(CAST(new_vaccinations as dec)) AS vaccinations 
FROM
  vaccinations
GROUP BY
  date
ORDER BY
  vaccinations DESC
LIMIT 1;

# total tested and percentage, by quarter
-- shows the total number of tests performed
-- shows what percentage of the population was tested for covid
SELECT 
    EXTRACT(YEAR FROM deaths.date) AS Year, 
    EXTRACT(QUARTER FROM deaths.date) AS Quarter,
    SUM(vaccinations.new_tests) AS total_tests,
    ROUND((SUM(vaccinations.new_tests) / AVG(deaths.population)) * 100, 2) AS tests_percentage
FROM 
    covid.deaths 
JOIN 
    covid.vaccinations
ON 
    deaths.date = vaccinations.date
WHERE
    vaccinations.new_tests IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM deaths.date),
    EXTRACT(QUARTER FROM deaths.date)
ORDER BY
    Year, Quarter;
    
# total vaccinated and percentage, by quarter
-- shows the total number of vaccinations given
-- shows what percentage of the population was vaccinated
SELECT 
    EXTRACT(YEAR FROM deaths.date) AS Year, 
    EXTRACT(QUARTER FROM deaths.date) AS Quarter,
    SUM(vaccinations.new_vaccinations) AS total_vaccinations,
    ROUND((SUM(vaccinations.new_vaccinations) / AVG(deaths.population)) * 100, 2) AS vaccination_percentage
FROM 
    covid.deaths 
JOIN 
    covid.vaccinations
ON 
    deaths.date = vaccinations.date
WHERE
    vaccinations.new_vaccinations IS NOT NULL
GROUP BY
    EXTRACT(YEAR FROM deaths.date),
    EXTRACT(QUARTER FROM deaths.date)
ORDER BY
    Year, Quarter;