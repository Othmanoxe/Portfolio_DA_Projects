Select *
From PortfolioProject..CovidDeaths
Order by 3, 4

Select *
From PortfolioProject..CovidVaccinations
Order by 3, 4

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--Order by 1, 2

-- Looking at the total cases vs total deaths
-- This is to forcast the percentage of kicking the bucket if you got covid in Morocco 
SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_deaths / total_cases) * 100 
    END AS DeathsPercentageInMorocco
FROM 
    PortfolioProject..CovidDeaths
	Where location like '%Morocco%'
ORDER BY 
    1, 2;


-- Looking at the total cases vs the population
-- Forecasts the percentage of people who got covid from the whole population 
SELECT 
    Location, 
    date, 
    total_cases, 
    population, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_cases / population) * 100 
    END AS CovidInfectersInMorocco
FROM 
    PortfolioProject..CovidDeaths
	Where location like '%Morocco%'
ORDER BY 
    1, 2;

-- Looking at the countries with the highest infection rate 

SELECT 
    Location,  
    MAX(total_cases) AS HighestInfectionCount, 
    population, 
    MAX(CASE 
        WHEN population = 0 THEN 0 
        ELSE (total_cases / population) * 100 
    END) AS PercentPopulationInfected
FROM 
    PortfolioProject..CovidDeaths
GROUP BY 
    Location, population
ORDER BY 
    PercentPopulationInfected desc;



-- Looking at the countries with the highest Death rate per Population

SELECT 
    Location,  
    MAX(total_deaths) AS DeathCount, 
    MAX(population) AS Population, 
    (SUM(total_deaths) * 100.0 / MAX(population)) AS PercentPopulationDead
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    population > 0 -- Ensure no division by zero
GROUP BY 
    Location
ORDER BY 
    PercentPopulationDead DESC;


-- Looking at countries with highest Death Count per Population
SELECT 
    Location,  
    MAX(CAST(total_deaths AS INT)) AS DeathsCount
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    Location
ORDER BY 
    DeathsCount DESC;

-- Breaking this down by continent   

SELECT 
    continent,  
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;


-- Global Covid Numbers

SELECT
    --date, 
    SUM(new_cases) AS TotalNewCases,  
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    (SUM(CAST(new_deaths AS INT)) * 1.0 / NULLIF(SUM(new_cases), 0)) * 100 AS DeathPercentage
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    continent IS NOT NULL
--GROUP BY date
ORDER BY 
    1,2;


--Looking at Total Population vs Vaccinations

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalPeoplevaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    2,3;


-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, TotalPeopleVaccinated) AS
(
   SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalPeoplevaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL
--order by 2,3
	)

	Select *, (TotalPeopleVaccinated/ Population)*100
	From PopvsVac


-- TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continen nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
totalPeoplevaccinated numeric,
)


Insert into #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalPeoplevaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL
--order by 2,3
Select *, (TotalPeopleVaccinated/ Population)*100
	From #PercentPopulationVaccinated




-- Creating a Few Views for Later Vis

-- 1ST ONE: PercentPopulationVaccinated

Create View PercentPopulationVaccinated AS 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS totalPeoplevaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date 
WHERE 
    dea.continent IS NOT NULL
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated

-- 2ND ONE: DeathsPercentageInMorocco

CREATE VIEW DeathsPercentageInMorocco AS
SELECT 
    Location, 
    Date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE (total_deaths / total_cases) * 100 
    END AS DeathsPercentageInMorocco
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    location LIKE '%Morocco%';

GO -- To ensure seperate commands

SELECT *
FROM DeathsPercentageInMorocco
ORDER BY Location, Date;

-- 3RD ONE: PercentPopulationDead

CREATE VIEW PercentPopulationDead AS

SELECT 
    Location,  
    MAX(total_deaths) AS DeathCount, 
    MAX(population) AS Population, 
    (SUM(total_deaths) * 100.0 / MAX(population)) AS PercentPopulationDead
FROM 
    PortfolioProject..CovidDeaths
WHERE 
    population > 0 -- Ensure no division by zero
GROUP BY 
    Location
-- ORDER BY PercentPopulationDead DESC;