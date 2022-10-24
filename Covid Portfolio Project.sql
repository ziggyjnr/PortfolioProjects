--Covid 19 Data Exploration

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

--Select the data to be explored from CovidDeaths Table
--EXPLORING WITH COUNTRIES

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Querying the total cases vs the total deaths in Nigeria
--This shows the likelihood of dying if you contract covid in Nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2

--Querying the total cases vs the population in Nigeria
--This shows what percentage of people in Nigeria have contracted the virus
select location, date, population, total_cases, (total_cases/population)*100 as Percentage_of_Poulation_Infected
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2

--Looking at the countries with the highest infection rate compared to its population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as Percentage_of_Poulation_Infected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Percentage_of_Poulation_Infected desc

--Looking at the countries with the highest death rate
select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

--Looking at the countries with the highest death rate compared to its population
select location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as Percentage_of_Poulation_Dead
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by Percentage_of_Poulation_Dead desc

--EXPLORING WITH CONTINENTS
--Looking at the continents with the highest death count
select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc

--Looking at the continent with the highest infection rate
select continent, MAX(total_cases) as HighestInfectionCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestInfectionCount desc

--EXPLORING THE GLOBAL DATA
--Looking at the total cases and total deaths per day globally
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Looking at the total cases and total deaths globally
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--LOOKING AT THE TOTAL POPULATION VS TOTAL VACCINATION
--Joing the CovidDeaths and CovidVaccination tables together

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingTotalVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingTotalVaccinated/population)*100 as PercentageVaccinated
from PopvsVac

--Using TEMP Table

Drop Table if exists #PercentageOfPeopleVaccinated
Create Table #PercentageOfPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingTotalVaccinated numeric
)
insert into #PercentageOfPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (RollingTotalVaccinated/population)*100 as PercentageVaccinated
from #PercentageOfPeopleVaccinated

--Create view to store data for visualization
Create View PercentageOfPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date) as RollingTotalVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinnations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create View WorldCasesandDeaths as
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--order by 1,2
