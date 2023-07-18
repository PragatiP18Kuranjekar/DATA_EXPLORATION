--COVID DEATHS
select *
from portfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--select *
--from portfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeaths
where continent is not null 
order by 1,2 

--Looking at Total cases vs total deaths
--shows likehood of dying if you contract covid in your country
--shows whats percentage of total deaths got in covid
select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from portfolioProject..CovidDeaths
where location like '%state%'
and continent is not null 
order by 1,2 


--Looking at Total cases vs population
--shows whats percentage of population got in covid
select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from portfolioProject..CovidDeaths
--where location like '%state%'
order by 1,2 


--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_cases/population)*100 as PercentpopulationInfected
from portfolioProject..CovidDeaths
--where location like '%state%'
group by location, population
order by PercentpopulationInfected desc

--OEDER BY CHANGE
Select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_cases/population)*100 as PercentpopulationInfected
from portfolioProject..CovidDeaths
--where location like '%state%'
group by location, population
order by 1,2





--shows countries with HighestDeathCount per population
Select location, MAX(total_deaths) as TotalDeathCount 
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null 
group by location
order by TotalDeathCount desc

--LET'S BREAKS THINGS DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null 
group by location
order by TotalDeathCount desc

--CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null 
group by continent
order by TotalDeathCount desc

--CONTINENT WITH IS NULL
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is  null 
group by continent
order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is null 
group by location
order by TotalDeathCount desc


--showing continents with highest death count per population
select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null 
order by DeathPercentage desc

--Remove location
select date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null 
order by DeathPercentage desc

--GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null 
group by date
order by 1, 2

--REMOVE DATE
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
from portfolioProject..CovidDeaths
--where location like '%state%'
where continent is not null 
--group by date
order by 1, 2



--COVID VACCINATION

--JOINS with vaccination
Select *
from portfolioProject..CovidVaccinations vac
join portfolioProject..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date

--Looking at Total population vs Vaccinations 
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations
from portfolioProject..CovidVaccinations vac
join portfolioProject..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date


--CONTINENT
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,  SUM(cast(vac.new_vaccinations as int))over (partition by dea.location order by dea.location, dea.date)
from portfolioProject..CovidVaccinations vac
join portfolioProject..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--CONVERT
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,  SUM(convert(int, vac.new_vaccinations ))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,RollingPeopleVaccinated/population *100
from portfolioProject..CovidVaccinations vac
join portfolioProject..CovidDeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--WITH CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations ))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,RollingPeopleVaccinated/population*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

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


select *, (RollingPeopleVaccinated/population)*100
from #percentagepopulationvaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISULIZATION
create view vaccinatedpeople as
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations ))over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,RollingPeopleVaccinated/population*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from vaccinatedpeople