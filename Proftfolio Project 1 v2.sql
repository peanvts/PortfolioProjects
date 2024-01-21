Select*
From PortfolioProject..CovidDeaths
order by 3,4

Select*
From PortfolioProject..CovidVaccinations
order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, ((CONVERT(float,total_deaths))/(CONVERT(float,total_cases)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

--Likelihood  of dying if contracted with covid in your country (ex: United States)

Select Location, date, total_cases, total_deaths, ((CONVERT(float,total_deaths))/(CONVERT(float,total_cases)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null
order by 1,2

--Total Cases vs Population
--Shows what percentage of Population got Covid
Select Location, date, Population, total_cases, ((CONVERT(float,total_cases))/(CONVERT(float,Population)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2

Select Location, date, Population, total_cases, ((CONVERT(float,total_cases))/(CONVERT(float,Population)))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Breakdown by Continent (Not that accurate)

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Breakdown by Continent (correct way to drill down)

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


-- showing the continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as NewCases
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases) as toatal_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
  dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3