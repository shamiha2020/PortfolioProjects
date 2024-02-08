SELECT *
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PorfolioProject..CovidVaccinations
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
ORDER BY 1,2


-- looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
-- shows what percentage of population contracted covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 AS PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- showing countries with highest death count per Population

Select location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Let's break things by contintent

Select continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing continents with highest death count per population

Select continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths AS dea
JOIN PorfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths AS dea
JOIN PorfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths AS dea
JOIN PorfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths AS dea
JOIN PorfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated
