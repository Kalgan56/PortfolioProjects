-- Data exploration program for SQL table
-- Data is the covid death and vaccintation tables
-- Project from FreeCodeCamp https://youtu.be/PSNXoAs2FtQ?si=vhHq1Z8iU0PQzlbn&t=12841

-- Data tables: CovidDeaths, CovidVaccinations

SELECT * FROM CovidDeaths
    order by 3,4
SELECT * FROM CovidVaccinations
    order by 3,4

select Location, date,total_cases, new_cases, total_deaths,population
    From CovidDeaths
    order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select Location, date,total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
    From CovidDeaths
    where location like '%states%'
    order by 1,2

-- Looking at Total cases vs Population
-- Shows the percentage of the population that got covid
select Location, date,total_cases, population,(total_cases/population)*100 as PercentPopInf
    From CovidDeaths
    where location like '%states%'
    order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInf
    From CovidDeaths
--   where location like '%states%'
    Group By Location, Population
    order by PercentPopInf Desc

-- Looking at Countries with Highest Death Count per Population
SELECT Location, MAX(Total_deaths) AS TotalDeathCount
    From CovidDeaths
        WHERE Continent is not NULL
        GROUP BY Location, population
        ORDER BY TotalDeathCount desc

-- Looking at Continents with Highest Death Count per Population
SELECT Continent, MAX(Total_deaths) AS TotalDeathCount
    From CovidDeaths
        WHERE Continent is not NULL
        GROUP BY Continent
        ORDER BY TotalDeathCount desc


-- Global Numbers
-- Shows total new case, total new deaths, and death percentage, across the world each day
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPerc
    FROM CovidDeaths
        WHERE continent is not NULL
        GROUP BY date
        ORDER BY 1,2


-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    FROM CovidDeaths dea JOIN CovidVaccinations vac
    ON dea.location=vac.location
    AND dea.date=vac.date
        WHERE dea.continent is not NULL
        ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingVacc
    FROM CovidDeaths dea JOIN CovidVaccinations vac
    ON dea.location=vac.location
    AND dea.date=vac.date
        WHERE dea.continent is not NULL
        ORDER BY 2,3


-- USE CTE to get rolling Population vs vaccination 

WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingVacc)
    AS
    (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingVacc
    FROM CovidDeaths dea JOIN CovidVaccinations vac
    ON dea.location=vac.location
    AND dea.date=vac.date
        WHERE dea.continent is not NULL
        --ORDER BY 2,3
    )
SELECT *, (RollingVacc/Population)*100 FROM PopvsVac


-- Doing the same as above but with a TEMP table

DROP Table if exists #PercentPopVac
CREATE TABLE #PercentPopVac
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVac
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingVacc
    FROM CovidDeaths dea JOIN CovidVaccinations vac
    ON dea.location=vac.location
    AND dea.date=vac.date
        WHERE dea.continent is not NULL
        --ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM #PercentPopVac


-- Create View to store data for later visualizations

CREATE VIEW PercentPopVacc AS 
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION By dea.location ORDER BY dea.location, dea.date) as RollingVacc
    FROM CovidDeaths dea JOIN CovidVaccinations vac
    ON dea.location=vac.location
    AND dea.date=vac.date
        WHERE dea.continent is not NULL
        --ORDER BY 2,3