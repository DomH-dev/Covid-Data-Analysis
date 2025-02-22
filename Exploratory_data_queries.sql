SELECT
    *
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null
ORDER BY
    3,
    4


SELECT
    *
FROM
    PortfolioProject.dbo.CovidVaccinations
WHERE
    continent is not null
ORDER BY
    3,
    4


SELECT
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null
ORDER BY
    1,
    2

-- Total Cases vs New Cases

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths as int) / NULLIF(CAST(total_cases as int), 0)) * 100 AS Death_percentage
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    location like '%states%'
    and continent is not null
ORDER BY
    1,
    2

-- Total Cases vs Population
-- Shows what percentage of the population got covid

SELECT
    location,
    date,
    population,
    total_cases,
    (CAST(total_cases as int) / CAST(population as int)) * 100 AS Case_to_Population_Ratio
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null
ORDER BY
    1,
    2

-- Countries with Highest Infection Rate compared to the Population

SELECT
    location,
    population,
    MAX(total_cases) as MaxInfectionCount,
    MAX((total_cases / population)) * 100 AS Percent_of_Population_infected
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null
Group by
    location,
    population
ORDER BY
    Percent_of_Population_infected desc

-- Countries with Highest Death Count per Population

SELECT
    location,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null
Group by
    location
ORDER BY
    TotalDeathCount desc

-- Showing Continents with the Highest Death Count per Population

SELECT
    location,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    location in ('Europe', 'North America', 'South America', 'Asia', 'Africa', 'Oceania')
Group by
    location
ORDER BY
    TotalDeathCount desc

-- Global Numbers

SELECT
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as int)) as total_deaths,
    (SUM(CAST(new_deaths as int)) / SUM(New_Cases)) * 100 AS DeathPercentage
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null
ORDER BY
    1,
    2

-- Total Population vs Vaccinations

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as int)) OVER (
        Partition by dea.location
        ORDER BY
            dea.location,
            dea.date
    ) as RollingPeopleVaccinated
FROM
    PortfolioProject.dbo.CovidDeaths dea
    Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
    and dea.date = vac.date
WHERE
    dea.continent is not null
ORDER BY
    2,
    3

-- Using Common Table Expression (CTE) to perform Calculation on Partition By in previous query

WITH PopvsVac (
    Continent,
    Location,
    Date,
    Population,
    New_Vaccinations,
    RollingPeopleVaccinated
) as (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int)) OVER (
            Partition by dea.location
            ORDER BY
                dea.location,
                dea.date
        ) as RollingPeopleVaccinated
    FROM
        PortfolioProject.dbo.CovidDeaths dea
        Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
        and dea.date = vac.date
    WHERE
        dea.continent is not null
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
FROM
    PopvsVac
ORDER BY
    2,
    3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int)) OVER (
            Partition by dea.location
            ORDER BY
                dea.location,
                dea.date
        ) as RollingPeopleVaccinated
    FROM
        PortfolioProject.dbo.CovidDeaths dea
        Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
        and dea.date = vac.date
    WHERE
        dea.continent is not null

SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
FROM
    #PercentPopulationVaccinated
ORDER BY
    2,
    3

-- Create view to store data for use in Tableau dashboard

CREATE View PercentPopulationVaccinated as
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as int)) OVER (
        Partition by dea.location
        ORDER BY
            dea.location,
            dea.date
    ) as RollingPeopleVaccinated
FROM
    PortfolioProject.dbo.CovidDeaths dea
    Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
    and dea.date = vac.date
WHERE
    dea.continent is not null

-- Creating view for the Global Numbers from dataset

CREATE view GlobalNumbers as
SELECT
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as int)) as total_deaths,
    (SUM(CAST(new_deaths as int)) / SUM(New_Cases)) * 100 AS DeathPercentage
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null

-- Create view for continental death counts

CREATE view ContinentalDeathCounts as
SELECT
    location as Continent,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    location in ('Europe', 'North America', 'South America', 'Asia', 'Africa', 'Oceania')
GROUP BY
    location

-- Creating view for the percent of the population that was infected

CREATE view PercentPopulationInfected as
SELECT
    location,
    population,
    MAX(total_cases) as MaxInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationinfected
FROM
    PortfolioProject.dbo.CovidDeaths
WHERE
    continent is not null
Group by
    location,
    population
ORDER BY
    Percent_of_Population_infected desc