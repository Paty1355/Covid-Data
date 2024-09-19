USE CovidProject

-- Selecting Data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.dbo.CovidDeaths
ORDER BY 3,4

-- Total Cases vs Total Deaths
-- Likehood of dying in country when have covid
SELECT Location,date, total_cases, total_deaths,ROUND((total_deaths/cast(total_cases as float))*100,2) AS DeathPercentage
FROM CovidProject.dbo.CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2

--Total Cases vs Population
--What Percentage of Population got Covid
SELECT Location,date, total_cases, Population,ROUND((total_cases/cast(population as float))*100,2) AS PercentPopulationInfected
FROM CovidProject.dbo.CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2

--Countries with Highest Infection Rate compared to Population
SELECT Location,Population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/cast(population as float)))*100,2) AS PercentPopulationInfected
FROM CovidProject.dbo.CovidDeaths
WHERE population <> 0
GROUP BY Location,Population
ORDER BY PercentPopulationInfected DESC

--Countries with Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount --Cast Data
FROM CovidProject.dbo.CovidDeaths
WHERE Location not in ('World', 'Europe', 'North America', 'South America', 'European Union')
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Continent with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount --Cast Data
FROM CovidProject.dbo.CovidDeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT SUM(CAST(new_cases AS int)) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, ROUND(SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS float))*100,2) AS DeathPercentage
FROM CovidProject.dbo.CovidDeaths
--GROUP BY date
HAVING SUM(CAST(new_cases AS int)) <> 0
ORDER BY 1,2


--Total Population vs Vaccinations - CTE
With PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
SELECT *,  ROUND((RollingPeopleVaccinated/CAST(Population as float))*100,2) AS PercentVaccinatedPopulation
FROM PopsVac
WHERE Population <> 0

--VIEW
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
