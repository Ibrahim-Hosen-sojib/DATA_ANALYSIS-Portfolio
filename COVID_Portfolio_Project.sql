
SELECT *
FROM portFolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM portFolio..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT  Location, date, total_cases, new_cases, total_deaths, population
FROM portFolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total deaths
--Shows the likelihood of dying if you contrast


SELECT  Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM portFolio..CovidDeaths
WHERE Location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs population
--Shows what percentage of population got covid

SELECT  Location, date,  population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM portFolio..CovidDeaths
WHERE Location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT  Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portFolio..CovidDeaths
--WHERE Location LIKE '%anglades%'
WHERE continent IS NOT NULL
GROUP BY Location,  population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest death count  per population

SELECT  location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portFolio..CovidDeaths
--WHERE Location LIKE '%anglades%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LETS BREAK DOWN BY CONTINENT

SELECT  continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM portFolio..CovidDeaths
--WHERE Location LIKE '%anglades%'
WHERE continent IS NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



--SHOWING THE CONTINENTS WITH HIGHEST DEATH COUNT


--GLOBAL NUMBERS

SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, 
       SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM portFolio..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at total population and vaccination(USE CTE)
 
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations ,RollingPeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
FROM portFolio..CovidDeaths dea
JOIN portFolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--USE TEMP TABLE


DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
FROM portFolio..CovidDeaths dea
JOIN portFolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 as RolPeoVac
FROM #PercentagePopulationVaccinated



--CREATING A VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentagePopulationVaccinated
AS 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations AS int)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
---(RollingPeopleVaccinated/population)*100
FROM portFolio..CovidDeaths dea
JOIN portFolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentagePopulationVaccinated
