SELECT *
FROM localhost..CovidDeaths1$
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM localhost..CovidVax1$
--ORDER BY 3,4

--Select Data we are using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM localhost..CovidDeaths1$
ORDER BY 1,2

--Looking at total cases vs total deaths
--Shows liklihood of dying from COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM localhost..CovidDeaths1$
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at total cases vs total population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Sick_Percent
FROM localhost..CovidDeaths1$
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at countries with highest infection rates compared to population

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS Sick_Percent
FROM localhost..CovidDeaths1$
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY Sick_Percent DESC

--Looking for countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS Death_Count
FROM localhost..CovidDeaths1$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Death_Count DESC

--Look at it by continent

SELECT continent, MAX(cast(total_deaths as int)) AS Death_Count
FROM localhost..CovidDeaths1$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Death_Count DESC



--Ranking global numbers

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM localhost..CovidDeaths1$
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vax

SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM localhost..CovidDeaths1$ dea
JOIN localhost..CovidVax1$ vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
	


SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM localhost..CovidDeaths1$ dea
JOIN localhost..CovidVax1$ vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE

WITH popvsvac (continent, location, date, population, new_vaccinations,rolling_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM localhost..CovidDeaths1$ dea
JOIN localhost..CovidVax1$ vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (rolling_vaccinations/population)*100
FROM popvsvac


--Temp Table
DROP TABLE IF #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
rolling_vaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM localhost..CovidDeaths1$ dea
JOIN localhost..CovidVax1$ vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *, (rolling_vaccinations/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later
DROP VIEW PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(CONVERT(INT,vax.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM localhost..CovidDeaths1$ dea
JOIN localhost..CovidVax1$ vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated

