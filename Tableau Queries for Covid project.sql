-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High Income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

--5
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%' and continent is not null 
--Group By date
order by 1,2

--6
Select population, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Nigeria%'and continent is not null
Group by population
order by PercentPopulationInfected desc


--with PopvsVac (location, date, population, new_vaccinations, RollingTotalVaccinated)
--as
--(
--select dea.location, dea.date, dea.population, vac.new_vaccinations, 
--sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
--dea.date) as RollingTotalVaccinated
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVacinnations vac
	--on dea.location = vac.location
	--and dea.date = vac.date
--where dea.location like '%Nigeria%'
--Group by dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3
)
--select *, (RollingTotalVaccinated/population)*100 as PercentageVaccinated
--from PopvsVac

with PopvsVacc (population, new_vaccinations, RollingTotalVaccinated)
as
(
select dea.population, Max(vac.new_vaccinations), 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinnations vac
	on dea.location = vac.location
where dea.location like '%Nigeria%'
Group by dea.location, dea.population, vac.new_vaccinations
--order by 2,3
)
select *, (RollingTotalVaccinated/population)*100 as PercentageVaccinated
from PopvsVacc