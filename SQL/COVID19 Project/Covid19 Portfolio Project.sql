-- Gather Data --

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location = 'united states'
and continent is not null
order by 1,2

-- Total Cases VS Population
-- Shows what percentage of population contracted covid in your country

select location, date, total_cases, population, (total_cases/population)*100 as ContractedPercentage
from PortfolioProject..CovidDeaths$
where location = 'united states'
and continent is not null
order by 1,2


-- Countries with Highest Infection Rate Compared to Population

select location,MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where continent is not null
group by location
order by TotalDeathCount desc


-- Highest Death per Population by Continent 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2



-- Total Population Vs Vaccinations

select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  and vac.new_vaccinations is not null
)
select *,(rolling_people_vaccinated/population)*100 as percentage_people_vaccinated
from PopvsVac


-- Temp Table Instead

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

select *,(rolling_people_vaccinated/population)*100 as percentage_people_vaccinated
from #PercentPopulationVaccinated


-- Creating Views to Store Data for Future Visualizations

create view PercentPopulationVaccinated as 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated
