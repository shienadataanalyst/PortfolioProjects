
Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidDeaths
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
Order by 1,2

-- Total Cases v.s. Total Deaths (Shows the likelihood of dying if you contract covid in PH)
-- Use CONVERT and NULLIF since there are zero values

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Philippines%'
ORDER BY 1,2;

-- Total Cases v.s. Population (Shows the percentage of population that contracted covid in PH)

SELECT location, date, population, total_cases, (NULLIF(CONVERT(float, total_cases),0)/population ) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%Philippines%'
ORDER BY 1,2;

-- Countries with highest infection rate v.s. Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (NULLIF(CONVERT(float, MAX(total_cases)),0)/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with highest death count v.s. Population
-- Use CAST to convert values 

SELECT location, population, MAX(CAST(total_deaths AS bigint)) AS HighestDeathCount, (NULLIF(CONVERT(float, MAX(total_deaths)),0)/population) * 100 AS PercentPopulationDeath
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL -- Some continents are included in the location
GROUP BY location, population
ORDER BY PercentPopulationDeath DESC;

-- Total death count per continent

SELECT continent, SUM(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Continents with the highest death count per population

SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Global Numbers
-- Total of new cases and new deaths of all countries per day

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- GROUP BY date
ORDER BY 1,2;


-- Total Population v.s. Total Vaccination
-- Join the CovidDeaths and CovidVaccinations tables
-- SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) to get the ROLLIING SUM

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Creating CTE to get the percentage of rolling people vaccinated v.s population

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
)

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac;


-- Creating TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated;

-- Creating VIEW to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;

