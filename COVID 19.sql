 /*
COVID-19 DATA EXPLORATION PROJECY
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/



select *
from PortfolioProject..CovidVaccinations
order by 3,4

--Selecting Data to start with


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths 
-- Shows the likelihood of death if contracted by coronavirus

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
order by 1,2

--Total Cases vs Population
--Shows the percentage of population infected with Covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2


--Countries with the highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectioinCount, max((total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

--Countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



--EXPLORING DATA BASED ON CONTINENTS

--Continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2


 --Total population vs Vaccinations
--Shows the percentage of population that has received atleast one dose of Covid Vaccine


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Using CTE to perform calculation on Partion by in the previous query 
with PopvsVac (continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
 as (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 )

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Using Temp Table to perform Calculation on Partition By in the previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- 2. 

-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc













