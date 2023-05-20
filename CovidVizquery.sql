--Find total new cases vs total new deaths

SELECT SUM(new_cases) as total_newCases,SUM(cast(new_deaths as float)) as total_newDeaths,(SUM(cast(new_deaths as float))/SUM(new_cases))*100 as Deathpercent
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 

--Find countries with respective total death count  

SELECT location,SUM(cast(new_deaths as float)) as total_newDeaths
FROM dbo.CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World','European Union','International')
GROUP BY location
ORDER BY total_newDeaths DESC

-- Find countries with the highest number of cases in terms of population

SELECT location,population,MAX(total_cases) as highestcases,MAX((total_cases/population))*100 as populationpercent
FROM dbo.CovidDeaths
--WHERE continent IS NOT NULL
GROUP BY location,population
--ORDER BY location,population 
ORDER BY populationpercent DESC


SELECT location,date,population,MAX(total_cases) as highestcases,MAX((total_cases/population))*100 as populationpercent
FROM dbo.CovidDeaths
--WHERE continent IS NOT NULL
GROUP BY location,date,population
--ORDER BY location,population 
ORDER BY populationpercent DESC

SELECT location,date,population,MAX(total_cases) as highestcases,MAX((total_cases/population))*100 as populationpercent
FROM dbo.CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World','European Union','International')
--WHERE continent IS NOT NULL
GROUP BY location,date,population
--ORDER BY location,population 
ORDER BY populationpercent DESC