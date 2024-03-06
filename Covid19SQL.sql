select *
from PortfolioProjects..CovidDeaths$
order by 3, 4

--select *
--from PortfolioProjects..CovidVaccinations$
--order by 3, 4

-- select the Data we  are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProjects..CovidDeaths$
order by 1, 2

-- Looking at the total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageDeath
from PortfolioProjects..CovidDeaths$
where location like '%Nigeria%'
order by 1, 2

-- Looking at the total cases vs population
-- Showing what percentage of the population got covid

select location, date, population, total_cases, (total_deaths/population)*100 as PercentagePopulationInfected
from PortfolioProjects..CovidDeaths$
-- where location like '%Nigeria%'
order by 1, 2

-- Countries with highest infection rate compared to population

select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_deaths/population))*100 as PercentagePopulationInfected
from PortfolioProjects..CovidDeaths$
-- where location like '%Nigeria%'
group by location, population
order by PercentagePopulationInfected DESC

-- showing countries with the highest Death count per Population

select location, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths$
-- where location like '%Nigeria%'
where continent is not null
group by location
order by TotalDeathCount DESC

-- Breaking it down to continent

select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths$
-- where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- showing the continent with the highest Death count per population

select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths$
-- where location like '%Nigeria%'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Global Numbers

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths$
-- where location like '%Nigeria%'
where continent is not null
-- group by date
order by 1, 2


-- Total populations vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--USE CTE

WITH popvsvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3
)
select *, (RollingPeopleVaccinated/Population)*100
from popvsvac

-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
-- order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store date 

Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
-- order by 2, 3

select *
from PercentagePopulationVaccinated