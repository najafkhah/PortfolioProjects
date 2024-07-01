SELECT *
FROM PortfolioCovidProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4;


--SELECT *
--FROM PortfolioCovidProject..CovidVaccination
--ORDER BY 3,4;

SElECT location, date, new_cases,total_cases,population, total_deaths
FROM PortfolioCovidProject..CovidDeath
ORDER BY 1,2;

-- looking at Total cases VS Total Deaths AS death_rate
-- Showing the likelihood of dying in countries

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
	CASE 
		WHEN total_cases= 0 THEN 0
		ELSE 
		(CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100
	END AS death_rate

FROM 
    PortfolioCovidProject..CovidDeath
	WHERE location LIKE '%states%'
	ORDER BY 1,2;

-- looking total cases against population
-- showing what percentage of population got Covid

SELECT 
    location, 
    date, 
    total_cases, 
    population, 
	CASE 
		WHEN total_cases= 0 THEN 0
		ELSE 
		(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100
	END AS Population_rate

FROM 
    PortfolioCovidProject..CovidDeath
	WHERE location LIKE '%states%'
	ORDER BY 1,2;

-- looking at countries with highest infection rate compared to population
SELECT 
    location, 
    MAX(total_cases) AS highestinfection, 
    population, 
	CASE 
		WHEN MAX(total_cases)= 0 THEN 0
		ELSE 
		MAX(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100
	END AS populationinfected

FROM 
    PortfolioCovidProject..CovidDeath
	GROUP BY location, population
	ORDER BY populationinfected DESC;

-- showing countries with highest death count per population
SELECT 
    location, 
    MAX(CAST (total_deaths AS INT)) AS totaldeathcount
FROM 
    PortfolioCovidProject..CovidDeath
	WHERE continent IS NOT NULL 
	GROUP BY location
	ORDER BY totaldeathcount DESC;


	-- showing continents with highest death count per population
SELECT 
    continent, 
    MAX(CAST (total_deaths AS INT)) AS totaldeathcount
FROM 
    PortfolioCovidProject..CovidDeath
	WHERE continent IS NOT NULL AND continent!= ''
	GROUP BY continent
	ORDER BY totaldeathcount DESC;

-- Global numbers
SELECT 
    date, 
    SUM(CAST(new_cases AS INT)) As totalcases,  
	SUM(CAST(new_deaths AS INT)) AS totalnewdeath, 
	CASE 
		WHEN SUM(CAST(new_cases AS INT))=0 THEN 0 
		ELSE (SUM(CAST(new_deaths AS INT))*100)/ SUM(CAST(new_cases AS INT)) END AS deathpercent
FROM 
    PortfolioCovidProject..CovidDeath
	GROUP BY date
	ORDER BY 1 DESC;

-- looking at total population VS vaccination
SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations
FROM PortfolioCovidProject..CovidDeath AS death
JOIN PortfolioCovidProject..CovidVaccination AS vac
	ON death.location= vac.location
	AND death.date= vac.date
	WHERE death.continent IS NOT NULL AND death.continent !='' 
	ORDER BY 1,2,3; 

	---
	SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.location ORDER BY death.date)AS rollingpeoplevaccinated
FROM PortfolioCovidProject..CovidDeath AS death
JOIN PortfolioCovidProject..CovidVaccination AS vac
	ON death.location= vac.location
	AND death.date= vac.date
	WHERE death.continent IS NOT NULL AND death.continent !='' 
	ORDER BY 2,3; 

	--- Using CTE to divid rollingpeoplevaccinated into population

	WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccination) 
	AS(
		SELECT death.continent, death.location,death.date, death.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)AS rollingpeoplevaccinated
FROM PortfolioCovidProject..CovidDeath AS death
JOIN PortfolioCovidProject..CovidVaccination AS vac
	ON death.location= vac.location
	AND death.date= vac.date
	WHERE death.continent IS NOT NULL AND death.continent !='' 
	)
	SELECT *, (rollingpeoplevaccination/population)*100.0 AS raterollingpeoplevaccination
	FROM popvsvac
	; 

	
