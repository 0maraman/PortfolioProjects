--COVID DEATH DATA BREAKDOWN--
select * from PortfolioProject..Deaths
order by 3,4

--select * from PortfolioProject..Vacs
--order by 3,4

-- Select data you want to use.
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Deaths
order by 1,2

-- Total cases vs. total deaths - displays the likelihood of death per nation using "where location like commnand"
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Deaths
where location like 'pakistan'
order by 1,2

-- Total cases vs. population
select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..Deaths
where location like '%states%'
order by 1,2

--Countries with highest infection rates (descending)
select location, population, max(total_cases) as HighestCases, max((total_cases/population))*100 as InfectionRate
from PortfolioProject..Deaths
group by location, population
order by InfectionRate desc

-- Countries with highest death count per population
-- Issue wih column data type. Had to use "cast" and "as int" function to display it as a numeric. 
-- Also removed continents using the "is not null" command
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Deaths
where continent is not null
group by location
order by TotalDeathCount desc

--Continents with highest death count per population
-- DO NOT USE THIS THOUGH... USE BELOW THE CODE INSTEAD!***
--select location, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..Deaths
--where continent is null	
--group by location
--order by TotalDeathCount desc

--Continents with highest death count per population***
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Deaths
where continent is not null
group by continent
order by TotalDeathCount desc 

-- Global breakdown by date
-- Again, using SUM(CAST + AS INT to display data as number since column format on raw data is incompatiable
select date, sum(new_cases) AS TotalCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..Deaths 
where continent is not null
group by date
order by 1,2

-- Global breakdown
-- Again, using SUM(CAST + AS INT to display data as number since column format on raw data is incompatiable
select sum(new_cases) AS TotalCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..Deaths 
where continent is not null
order by 1,2

--Joining data with another dataset (Covid Vacs)
--Total population vs. vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..Deaths dea
join PortfolioProject..Vacs vac
	on dea.location = vac.location
	and dea.date = vac.date	
where dea.continent is not null
order by 2,3

--USING THE ABOVE WITH A CTE
with PopvsVacs (continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..Deaths dea
join PortfolioProject..Vacs vac
	on dea.location = vac.location
	and dea.date = vac.date	
where dea.continent is not null
--order by 2,3
)
select *, (RollingVaccinations/population)*100 from PopvsVacs

-- DOING THE ABOVE WITH AS A TEMP TABLE
-- DOESN'T WORK!!! (1hr 5mins)
drop table if exists #PercentageOfPeopleVaccinated
create table #PercentageOfPeopleVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingVaccinations numeric
)
insert into #PercentageOfPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..Deaths dea
join PortfolioProject..Vacs vac
	on dea.location = vac.location
	and dea.date = vac.date	
where dea.continent is not null
--order by 2,3

select *, (RollingVaccinations/population)*100 from #PercentageOfPeopleVaccinated


-- Creating Views for Data Visualisation
create view PeopleVaccinatedPerecentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..Deaths dea
join PortfolioProject..Vacs vac
	on dea.location = vac.location
	and dea.date = vac.date	
where dea.continent is not null
--order by 2,3
