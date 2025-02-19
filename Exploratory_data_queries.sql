Select
    *
From
    PortfolioProject.dbo.CovidDeaths
Where
    continent is not null
order by
    3,
    4


Select
    *
From
    PortfolioProject.dbo.CovidVaccinations
Where
    continent is not null
order by
    3,
    4


Select
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
From
    PortfolioProject.dbo.CovidDeaths
Where
    continent is not null
order by
    1,
    2

-- Total Cases vs New Cases

Select
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths as int) / NULLIF(CAST(total_cases as int), 0)) * 100 AS Death_percentage
From
    PortfolioProject.dbo.CovidDeaths
Where
    location like '%states%'
    and continent is not null
order by
    1,
    2

-- Total Cases vs Population
-- Shows what percentage of the population got covid

Select
    location,
    date,
    population,
    total_cases,
    (CAST(total_cases as int) / CAST(population as int)) * 100 AS Case_to_Population_Ratio
From
    PortfolioProject.dbo.CovidDeaths
Where
    continent is not null
order by
    1,
    2

-- Countries with Highest Infection Rate compared to the Population

Select
    location,
    population,
    MAX(total_cases) as MaxInfectionCount,
    MAX((CAST(total_cases as int) / CAST(population as int))) * 100 AS Percent_of_Population_infected
From
    PortfolioProject.dbo.CovidDeaths
Where
    continent is not null
Group by
    location,
    population
order by
    Percent_of_Population_infected desc

-- Countries with Highest Death Count per Population

Select
    location,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
From
    PortfolioProject.dbo.CovidDeaths
Where
    continent is not null
Group by
    location
order by
    TotalDeathCount desc

-- Showing Continents with the Highest Death Count per Population

Select
    continent,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
From
    PortfolioProject.dbo.CovidDeaths
Where
    continent is not null
Group by
    continent
order by
    TotalDeathCount desc

-- Global Numbers

Select
    SUM(new_cases) as total_cases,
    SUM(CAST(new_deaths as int)) as total_deaths,
    (SUM(CAST(new_deaths as int)) / SUM(New_Cases)) * 100 AS DeathPercentage
From
    PortfolioProject.dbo.CovidDeaths
Where
    continent is not null
order by
    1,
    2

-- Total Population vs Vaccinations

Select
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as int)) OVER (
        Partition by dea.location
        Order by
            dea.location,
            dea.date
    ) as RollingPeopleVaccinated
From
    PortfolioProject.dbo.CovidDeaths dea
    Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
    and dea.date = vac.date
Where
    dea.continent is not null
order by
    2,
    3

-- Using Common Table Expression (CTE) to perform Calculation on Partition By in previous query

With PopvsVac (
    Continent,
    Location,
    Date,
    Population,
    New_Vaccinations,
    RollingPeopleVaccinated
) as (
    Select
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int)) OVER (
            Partition by dea.location
            Order by
                dea.location,
                dea.date
        ) as RollingPeopleVaccinated
    From
        PortfolioProject.dbo.CovidDeaths dea
        Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
        and dea.date = vac.date
    Where
        dea.continent is not null
)
Select
    *,
    (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
From
    PopvsVac
order by
    2,
    3

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int)) OVER (
            Partition by dea.location
            Order by
                dea.location,
                dea.date
        ) as RollingPeopleVaccinated
    From
        PortfolioProject.dbo.CovidDeaths dea
        Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
        and dea.date = vac.date
    Where
        dea.continent is not null

Select
    *,
    (RollingPeopleVaccinated / Population) * 100 as VaccinatedPercentage
From
    #PercentPopulationVaccinated
order by
    2,
    3

-- Create view to store data for use in Tableau dashboard

--Create View PercentPopulationVaccinated as
Select
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as int)) OVER (
        Partition by dea.location
        Order by
            dea.location,
            dea.date
    ) as RollingPeopleVaccinated
From
    PortfolioProject.dbo.CovidDeaths dea
    Join PortfolioProject.dbo.CovidVaccinations vac On dea.location = vac.location
    and dea.date = vac.date
Where
    dea.continent is not null