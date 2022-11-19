1.
--Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
--group by date
order by 1,2

2.
-- Contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount, sum(population) as Populationpercontinent
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

3.
--Percent Population Infected Per Country

select location, population,max(cast(total_cases as int)) as HighestInfectionCount, max(cast(total_cases as int)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population 
order by PercentPopulationInfected desc

4.
--Percent Population Infected

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

5.
--Total cases per country

select location, max(total_cases) as Totalcases
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by Totalcases desc