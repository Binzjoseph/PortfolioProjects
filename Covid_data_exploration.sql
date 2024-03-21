-- Covid Data exploration using SQL 
-- Skills displayed: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data types
-- Looking at total cases vs total deaths in United States
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 deathpercentage
from Coviddeaths
where location ='United States'
order by deathpercentage desc;

-- Looking at total cases vs population in United States
-- Shows the percentage of population that got covid
select location, date, total_cases, population, (total_cases/population)*100 infectionrate
from Coviddeaths
where location ='United States';


-- Looking at countries with highest infection rate compared to the population
select location, population, max(total_cases) as maxcases, max((total_cases/population))*100 as infectionrate
from Coviddeaths
where location ='United States'
group by location, population
order by infectionrate desc;


-- Showing countries with highest death counts per population
-- Here the total_deaths was in varchar format hence the orderby was not working so we converted the data type to int
-- the where condition is used because where continent is null the location = continent so to avoid such discrepancies we used this where condition
select location, max(cast(total_deaths as int)) as highestdeathcount
from coviddeaths
where continent is not null
group by location
order by highestdeathcount desc;


-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as highestdeathcount
from coviddeaths
where continent is not null
group by continent
order by highestdeathcount desc;

-- death percentage overall
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total deaths,
sum(cast(new_deaths as int))/sum(new_cases) as deathpercent
from coviddeaths

-- Shows rolling count of vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 