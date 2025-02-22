select*
from PortofolioProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--from PortofolioProject..CovidDeaths
--order by 3, 4

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1, 2


--Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

--looking at the total cases vs population
-- shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
from PortofolioProject..CovidDeaths
where location like '%states%'
order by 1, 2

select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
from PortofolioProject..CovidDeaths
where location like '%romania%'
order by 1, 2

--looking at Countries with Highest Infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentofPopulationInfected
from PortofolioProject..CovidDeaths
where continent is not null
--where location like '%romania%'
group by Location, Population
order by 1, 2


select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentofPopulationInfected
from PortofolioProject..CovidDeaths
where continent is not null
--where location like '%romania%'
group by Location, Population
order by PercentofPopulationInfected desc

--showing the countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
--where location like '%romania%'
group by Location
order by TotalDeathCount desc

--let's break thingd down by continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
--where location like '%romania%'
group by continent
order by TotalDeathCount desc


select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is null
--where location like '%romania%'
group by location
order by TotalDeathCount desc


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
--where location like '%romania%'
group by continent
order by TotalDeathCount desc


--showing the continent with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
--where location like '%romania%'
group by continent
order by TotalDeathCount desc


--global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by date
order by 1, 2

--total cases in world

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1, 2



select *
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
, (rollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3

-- use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
---, (rollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2, 3
)

select*, (rollingPeopleVaccinated/population)*100
from PopvsVac


---TEMPTABLE


drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
---, (rollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2, 3

select*, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating view to stare data for later visualisations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
---, (rollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join PortofolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2, 3


Select *
from PercentPopulationVaccinated


