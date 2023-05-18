SELECT *
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM dbo.CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select the data that we are going to use

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Compare total cases to total deaths
-- Using LIKE command to fetch location of your choice in case don't know the exact country name

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercent
FROM dbo.CovidDeaths
WHERE location like '%king%'
ORDER BY 1,2

-- Compare total cases to population

SELECT location,date,total_cases,population,(total_cases/population)*100 as populationpercent
FROM dbo.CovidDeaths
WHERE location like '%king%'
ORDER BY 1,2

-- Find countries with the highest number of cases in terms of population

SELECT location,MAX(total_cases) as highestcases,population,MAX((total_cases/population))*100 as populationpercent
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
--ORDER BY location,population 
ORDER BY populationpercent DESC

--Find countries with the highest number of deaths in terms of population

SELECT location,population,MAX(cast(total_deaths as int)) as highestdeaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
--ORDER BY location,population 
ORDER BY highestdeaths DESC

--Find the highest number of deaths in terms of Continent

SELECT continent,MAX(cast(total_deaths as int)) as highestdeaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY highestdeaths DESC

--Find total new cases vs total new deaths

SELECT SUM(new_cases) as total_newCases,SUM(cast(new_deaths as float)) as total_newDeaths,(SUM(cast(new_deaths as float))/SUM(new_cases))*100 as Deathpercent
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

--Find Global stats

SELECT date,SUM(new_cases) as total_newCases,SUM(cast(new_deaths as float)) as total_newDeaths,(SUM(cast(new_deaths as float))/SUM(new_cases))*100 as Deathpercent
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 2 DESC

-- Find total population against vaccination

SELECT cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
SUM(CONVERT(float,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as cumulativeNewVaccination --cast(cv.new_vaccinations as float)
FROM dbo.CovidDeaths cd
JOIN dbo.CovidVaccinations cv
ON cd.date = cv.date
AND cd.location = cv.location
WHERE cd.continent IS NOT NULL
--GROUP BY cd.continent,cd.location,cd.date,population,cv.new_vaccinations
ORDER BY 2,3

-- Generate Temporary Table using CTE(Common Table Expression)

WITH PopVac(continent,location,date,population,new_vaccinations,cumulativeNewVaccinations) as
	(
	SELECT cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
	SUM(CONVERT(float,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as cumulativeNewVaccinations
	FROM dbo.CovidDeaths cd
	JOIN dbo.CovidVaccinations cv
	ON cd.date = cv.date
	AND cd.location = cv.location
	WHERE cd.continent IS NOT NULL
	--ORDER BY 2,3
	)
SELECT *,(cumulativeNewVaccinations/population)*100 as cumVacPercent
FROM PopVac

--Create TEMP TABLE

DROP TABLE if exists PopVac2 -- When modify data in the existing table use DROP TABLE command*
CREATE TABLE PopVac2 
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population float,
	new_vaccinations float,
	cumulativeNewVaccinations float
	)
INSERT INTO PopVac2 
	SELECT cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
	SUM(CONVERT(float,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as cumulativeNewVaccinations
	FROM dbo.CovidDeaths cd
	JOIN dbo.CovidVaccinations cv
	ON cd.date = cv.date
	AND cd.location = cv.location
	--WHERE cd.continent IS NOT NULL*
	--ORDER BY 2,3

SELECT *,(cumulativeNewVaccinations/population)*100 as cumVacPercent
FROM PopVac2		

-- Create VIEW to store data for final visualisations

CREATE VIEW cumNewVacPercent as
	SELECT cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
	SUM(CONVERT(float,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) as cumulativeNewVaccinations
	FROM dbo.CovidDeaths cd
	JOIN dbo.CovidVaccinations cv
	ON cd.date = cv.date
	AND cd.location = cv.location
	WHERE cd.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *
FROM cumNewVacPercent

