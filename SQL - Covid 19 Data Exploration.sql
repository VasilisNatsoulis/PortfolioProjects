/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4




-- Select Data that we are going to be starting with

SELECT location,date,total_cases, total_deaths,population
FROM PortfolioProject..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2




-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE location LIKE '%Canada%'
AND continent IS NOT NULL
ORDER BY 1,2




-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,date,population,total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..covid_deaths
WHERE location LIKE '%Canada%'
ORDER BY 1,2




-- Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases) AS Highest_infection_Count,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..covid_deaths
--WHERE location like '%Canada%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC




-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..covid_deaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC




-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
--Where location like '%states%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC




-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases,SUM(cast(new_deaths AS int)) as total_deaths, (SUM(cast(new_deaths AS int))/SUM(new_cases) )*100 AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null 
ORDER BY 1,2




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine 
-- Some data,around 2021-05 and later are innacurate due to the fact that new vaccinations got recorded multiple times for the same people who got their second vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and new_vaccinations is not null
ORDER BY 2,3




-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.location like '%canada%'
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinated
FROM PopvsVac
WHERE DATE < '2021-05-05 00:00:00.000'
ORDER BY 3




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location Nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..covid_deaths AS dea
JOIN PortfolioProject..covid_vaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.location LIKE '%canada%'
--order by 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinated
FROM #PercentPopulationVaccinated
WHERE date < '2021-05-05 00:00:00.000' and New_vaccinations IS NOT NULL
ORDER BY 3




-- Creating View to store data for later visualizations

CREATE VIEW TotalDeaths
AS
SELECT location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..covid_deaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC








