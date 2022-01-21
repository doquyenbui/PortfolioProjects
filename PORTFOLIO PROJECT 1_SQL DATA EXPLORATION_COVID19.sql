SELECT *
FROM CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows death rate of infected people

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM CovidDeaths
WHERE location LIKE '%united%'
ORDER BY 1,2

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRate
FROM CovidDeaths
WHERE location LIKE 'singapore'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid-19

SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS InfectionRate
FROM CovidDeaths
WHERE location LIKE 'singapore'
ORDER BY 1,2

--Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE 'singapore'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest death count per population

SELECT location, MAX(total_deaths) AS MaxDeathCount
FROM CovidDeaths
GROUP BY location
ORDER BY MaxDeathCount DESC

SELECT location, MAX(CAST(total_deaths AS int)) AS MaxDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

--Looking at max, total death count by country and continent

SELECT location, continent, MAX(CAST(total_deaths AS int)) AS MaxDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent, location
ORDER BY MaxDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS int)) AS MaxDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY MaxDeathCount DESC

SELECT continent, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT Date, SUM(new_cases) AS Sum_Cases, SUM(CAST(new_deaths as int)) AS Sum_Deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 AS NewDeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2

SELECT SUM(new_cases) AS Sum_Cases, SUM(CAST(new_deaths as int)) AS Sum_Deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Population vs Vaccinations using CTE

SELECT *
FROM CovidVaccinations
ORDER BY location, date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

--Using CTE

WITH PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VacRate
FROM PopulationVsVaccinations


WITH FullyVaccination (location, date, population, people_fully_vaccinated)
AS
(
SELECT dea.location, dea.date, dea.population, vac.people_fully_vaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (people_fully_vaccinated/population)*100 AS FulVacRate
FROM FullyVaccination
WHERE location = 'Singapore'
ORDER BY location, date

--Using Temp table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS VacRate
FROM #PercentPopulationVaccinated
WHERE Location = 'united states'
ORDER BY 2,3

--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *
FROM PercentPopulationVaccinated