--Explore information from table CovidDeaths


Select*
From PortofolioProject..CovidDeaths


--Explore information from table CovidVaccinations


Select *
From PortofolioProject..CovidVaccinations


--Select data from CovidDeaths where we have information about continent


Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent IS NOT NULL
Order By 3, 4


Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Where continent IS NOT NULL
Order By 1,2


--Look at Total_Cases vs Total_Deaths 
--shows likelihood of dying if you contract covid in your country


Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like 'Romania'
Order By 1, 2


--Looking at the total_cases vs population
-- Shows what percentage of population got covid


Select location, date, population, total_cases, (total_cases/population)*100 AS PercentofPopulationInfected
From PortofolioProject..CovidDeaths
Where location like 'Romania'
order by 1, 2


--Looking at Countries with Highest Infection rate compared to population


Select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentofPopulationInfected
From PortofolioProject..CovidDeaths
where continent is not null
Group By location, population
Order By 1, 2


Select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentofPopulationInfected
From PortofolioProject..CovidDeaths 
Where continent is not null 
Group By location, population
Order By PercentofPopulationInfected Desc


--Showing the countries with Highest Death Count per Population


Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount Desc


--Showing the continent with Highest Death Count per Population


Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount Desc


-- Global numbers


Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where continent is not null
Group By date,
Order By 1, 2


--Total cases in world


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where continent is not null
Order By 1, 2


--Looking at population vs no of vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
On dea.location=vac.location
And dea.date=vac.date
Where dea.continent is not null
Order By 2, 3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
On dea.location=vac.location
And dea.date=vac.date
Where dea.continent is not null
Order by 2, 3


--the same using CTE


With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location=vac.location
	And dea.date=vac.date
Where dea.continent is not null
)

Select*, (rollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac


--using TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
On dea.location=vac.location and dea.date=vac.date
Where dea.continent is not null

Select*, (rollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to stare data for later visualisations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location=vac.location
	And dea.date=vac.date
Where dea.continent is not null
Select *
from PercentPopulationVaccinated