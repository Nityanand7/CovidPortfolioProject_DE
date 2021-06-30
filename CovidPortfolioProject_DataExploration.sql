/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select * from PortfolioProj..CovidDeaths order by 3,4

--select * from PortfolioProj..CovidVaccinations order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProj..CovidDeaths 
order by 1,2

--Total cases vs Total Deaths

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProj..CovidDeaths 
Where location like '%India%'
order by 1,2

--Total cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProj..CovidDeaths 
--Where location like '%India%'
order by 1,2

--Countries with highest Infection rate

select location, Population, Max(total_cases), MAX((total_cases/population))*100 as InfectionPercentage
from PortfolioProj..CovidDeaths 
--Where location like '%India%'
Group by Location, Population
order by InfectionPercentage Desc

--Countries with highest Death Count

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProj..CovidDeaths 
--Where location like '%India%'
where continent is not null
Group by Location
order by TotalDeathCount Desc

--The same above data by continent

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProj..CovidDeaths 
--Where location like '%India%'
where continent is null
Group by location
order by TotalDeathCount Desc

--Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortfolioProj..CovidDeaths 
--Where location like '%India%'
where continent is not null
Group by date
order by 1,2

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortfolioProj..CovidDeaths 
--Where location like '%India%'
where continent is not null
--Group by date
order by 1,2


-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as AggregatePeopleVaccinated
from PortfolioProj..CovidDeaths dea
join PortfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (continent, location, date, Population, new_vaccinations, AggregatePeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as AggregatePeopleVaccinated
from PortfolioProj..CovidDeaths dea
join PortfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (AggregatePeopleVaccinated/population)*100
from PopvsVac
Order by 2,3


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
AggregatePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as AggregatePeopleVaccinated
from PortfolioProj..CovidDeaths dea
join PortfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (AggregatePeopleVaccinated/population)*100
from #PercentPopulationVaccinated
Order by 2,3


--creating views for Data Visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as AggregatePeopleVaccinated
from PortfolioProj..CovidDeaths dea
join PortfolioProj..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
From PercentPopulationVaccinated
order by 2,3




create view TotalCases as
select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from PortfolioProj..CovidDeaths 


select * 
From TotalCases
order by 1,2



create view GlobalNumbers as
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortfolioProj..CovidDeaths 
where continent is not null
Group by date

select * 
From GlobalNumbers
order by 1


create view FinalNumbers as
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from PortfolioProj..CovidDeaths 
where continent is not null

select * 
From FinalNumbers

