select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
where continent is not null
order by 3,4


--Data that we are going to start with

select location, date, population, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--Highest number of cases vs Population for each country

select location, max(total_cases) as Totalcases, max(population) as Totalpopulation
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by Totalcases desc


-- Shows the deathpercentage for Covid in each country

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


-- Shows percentage of population infected with Covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


-- Highest number of new cases and Total cases in India

select location, max(total_cases) as Highest_Total_Cases, max(new_cases) as Highest_New_Cases
from PortfolioProject..CovidDeaths$
where location='India'
group by location


-- Highest number of New cases and Total cases in India with date

select location, date, new_cases
from PortfolioProject..CovidDeaths$
where location='India' and new_cases=(select max(new_cases) as Newcases from PortfolioProject..CovidDeaths$ where location='India')

select location, date, total_cases
from PortfolioProject..CovidDeaths$
where location='India' and total_cases=(select max(total_cases) as totalcases from PortfolioProject..CovidDeaths$ where location='India')


--Percent Population Infected Per Country

select location, population,max(cast(total_cases as int)) as HighestInfectionCount, max(cast(total_cases as int)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population 
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount, sum(population) as Populationpercontinent
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2

--Shows relation between poverty rate and vaccination rate

select location, max(cast(people_vaccinated_per_hundred as numeric)) as peoplevaccinated, max(cast(extreme_poverty as numeric)) as PovertyPerCountry
from PortfolioProject..CovidVaccinations$
where continent is not null
and people_vaccinated_per_hundred is not null
group by location
order by PovertyPerCountry desc

--Shows relation between percentage of people 65 and older and vaccination rate

select location, max(cast(people_vaccinated_per_hundred as numeric)) as peoplevaccinated, max(cast(aged_65_older as numeric)) as aged65older
from PortfolioProject..CovidVaccinations$
where continent is not null
and people_vaccinated_per_hundred is not null
group by location
order by  aged65older desc

--Joining two tables

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null

--Shows percentage of total vaccinations compared to population

select dea.location, dea.population, max(convert(int, vac.total_vaccinations)) as Totalvaccinations, 
(max(convert(int, vac.total_vaccinations))/ dea.population)*100 as totalvaccinationspercentage
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
where dea.continent is not null
group by dea.location, dea.population
order by 1,2

-- Summing new vaccinations on daily basis


select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
Over(partition by dea.location, dea.population order by dea.location, dea.date) as Rollingnewvaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--and dea.location='Canada'
and dea.date>='2020-12-12 00:00:00.000'
--group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2,3

--Use CTE

WITH PopvsVac(continent, location,date, population,new_vaccinations, RollingNewVaccinations)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
Over(partition by dea.location, dea.population order by dea.location, dea.date) as RollingNewVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--and dea.location='Canada'
and dea.date>='2020-12-12 00:00:00.000'
--group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3
)
Select *, (RollingNewVaccinations/population)*100 as Percentpopulationvaccinated
from PopvsVac

--temp table

drop table if exists #Percentpopulationvaccinated
create table #Percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingNewVaccinations numeric)
Insert into #Percentpopulationvaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
Over(partition by dea.location, dea.population order by dea.location, dea.date) as RollingNewVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--and dea.location='Canada'
and dea.date>='2020-12-12 00:00:00.000'
--group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3

Select *, (RollingNewVaccinations/population)*100 as Percentpopulationvaccinated
from #Percentpopulationvaccinated

--create view for storing data for later visualization

create view Percentpopulationvaccinated as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
Over(partition by dea.location, dea.population order by dea.location, dea.date) as RollingNewVaccinations
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--and dea.location='Canada'
and dea.date>='2020-12-12 00:00:00.000'
--group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3

Select *
from Percentpopulationvaccinated