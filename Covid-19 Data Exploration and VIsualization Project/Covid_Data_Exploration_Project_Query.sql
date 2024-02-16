-- -------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------

--                                                     COVID-19 DATA EXPLORATION PROJECT  

-- -------------------------------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------------


-- SQL SKILLS USED: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

-- Looking at tables we are going to use

select *
from Portfolio_Projects..CovidDeaths
order by 3,4;

select *
from Portfolio_Projects..CovidDeaths
order by 3,4;


-- altering datatype of table column for exploration

Alter Table Portfolio_Projects..CovidDeaths
ALTER COLUMN new_deaths int


--Selecting Data that we are going to be using

select location, date, population, total_cases, new_cases, total_deaths
from Portfolio_Projects..CovidDeaths
order by 1, 2;

-- Total Cases Vs Total Deaths
-- shows total percentage of people died contracting COVID

select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Total_Death_Percentage
from Portfolio_Projects..CovidDeaths
where location like '%India%'
order by 1, 2


-- Total Cases Vs Total population
-- shows percentage of population got infected

select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as Infected_Population_Percentage
from Portfolio_Projects..CovidDeaths
where location like '%India%'
order by 1, 2


-- Highest Infection Rate  vs Population

select location, date, population, Max(total_cases) as Highest_Infection_Count,  
       Max((total_cases/population)*100) as Highest_Infection_Rate

from Portfolio_Projects..CovidDeaths
--where location like '%India%'
group by location, population, date 
order by Highest_Infection_Rate desc


-- Creating View to store data for Visualization

create view Highest_Infection_Rate as
select location, date, population, Max(total_cases) as Highest_Infection_Count,  
       Max((total_cases/population)*100) as Highest_Infection_Rate

from Portfolio_Projects..CovidDeaths
--where location like '%India%'
group by location, population, date 
--order by Highest_Infection_Rate desc


-- countries with Highest Death Rate 

select location, max(total_cases) as Highest_Infection_Rate, max(total_deaths) as Highest_Death_Rate, (max(total_deaths)/max(total_cases)*100) as Total_Death_Percentage
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by location
order by Total_Death_Percentage desc


-- Country with highest death count

select location, max(cast (total_deaths as int)) as Highest_Death_count
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by location
order by Highest_Death_count desc


-- Creating View to store data for Visualization

create view Country_Highest_deathcount as
select location, max(cast (total_deaths as int)) as Highest_Death_count
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by location
--order by Highest_Death_count desc



-- BREAKING DOWN BY CONTINENT
-- continent with Highest Death Count

select continent, max(cast (total_deaths as int)) as Highest_Death_count
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by continent
order by Highest_Death_count desc

-- Creating View to store data for Visualization

create view continent_death_count as
select continent, max(cast (total_deaths as int)) as Highest_Death_count
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by continent
--order by Highest_Death_count desc




-- Total Death Count by  Location

select Location, SUM(new_deaths) as TotalDeathCount
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null and location not in ('World','European Union', 'International')
group by location
order by TotalDeathCount desc


-- Creating View to store data for Visualization

create view Totaldeathcountry as
select Location, SUM(new_deaths) as TotalDeathCount
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null and location not in ('World','European Union', 'International')
group by location
--order by TotalDeathCount desc




-- looking at GLOBAL NUMBERS

select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)*100/SUM(new_cases) as Death_Percentage
from Portfolio_Projects..CovidDeaths
--where location like '%India%'
where continent is not NULL
--group by [date]
order by 1, 2

-- Creating View to store data for Visualization

create view global_numbers as
select SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)*100/SUM(new_cases) as Death_Percentage
from Portfolio_Projects..CovidDeaths
--where location like '%India%'
where continent is not NULL
--group by [date]
--order by 1, 2



-- Total population vs Vaccinations per Day

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as vaccinated_rolling
from Portfolio_Projects..CovidDeaths cd
join Portfolio_Projects..CovidVaccinations cv
  ON cd.location = cv.location 
  and cd.date = cv.[date]
where cd.continent is not NULL
order by 1,2


-- Using CTE: Total population vs Vaccinations per Day

with popvsvac(continent, location, date, population, new_vaccinations,vaccinated_rolling)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as vaccinated_rolling
from Portfolio_Projects..CovidDeaths cd
join Portfolio_Projects..CovidVaccinations cv
  ON cd.location = cv.location 
  and cd.date = cv.date
where cd.continent is not NULL
--order by 1,2
)        
select (vaccinated_rolling)*100/(population) as   vaccinated_rolling_percent
from popvsvac


-- CTE: POPULATION AGED 65~70 AND OLDER VS TOTAL DEATHS

with popvstotaldeath(Continent,location,date,total_deaths,aged_65_rolling,aged_70_rolling,total_deaths_rolling)
as
(
select cd.continent, cd.location, cd.date, cd.total_deaths,
       SUM(cv.aged_65_older) over(partition by cd.location order by cd.location, cd.date) as aged_65_rolling,
       SUM(cv.aged_70_older) over(partition by cd.location order by cd.location, cd.date) as aged_70_rolling, 
       SUM(cd.total_deaths) over(partition by cd.location order by cd.location, cd.date) as total_deaths_rolling
from Portfolio_Projects..CovidDeaths cd
join Portfolio_Projects..CovidVaccinations cv
 on cd.location = cv.location
 and cd.date = cv.date
where cd.continent is not null
)
select *, ((aged_65_rolling)+(aged_70_rolling))/(total_deaths_rolling)*100 as popvstotaldeath
from popvstotaldeath


-- Creating View to store data for Visualization

create view popvstotaldeath as
select cd.continent, cd.location, cd.date, cd.total_deaths,
       SUM(cv.aged_65_older) over(partition by cd.location order by cd.location, cd.date) as aged_65_rolling,
       SUM(cv.aged_70_older) over(partition by cd.location order by cd.location, cd.date) as aged_70_rolling, 
       SUM(cd.total_deaths) over(partition by cd.location order by cd.location, cd.date) as total_deaths_rolling
from Portfolio_Projects..CovidDeaths cd
join Portfolio_Projects..CovidVaccinations cv
 on cd.location = cv.location
 and cd.date = cv.date
where cd.continent is not null




--  TEMP TABLE 
-- making calculations using  TEMP TABLE 

drop table if exists #popvac_percentage
Create table #popvac_percentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population Numeric,
new_vaccinations Numeric,
vaccinated_rolling numeric
)
Insert into #popvac_percentage
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as vaccinated_rolling
from Portfolio_Projects..CovidDeaths cd
join Portfolio_Projects..CovidVaccinations cv
  ON cd.location = cv.location 
  and cd.date = cv.date
where cd.continent is not NULL
--order by 1,2
select *
from #popvac_percentage



-- Creating View to store data for Visualization

create view popvac_percentage as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
       SUM(cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as vaccinated_rolling
from Portfolio_Projects..CovidDeaths cd
join Portfolio_Projects..CovidVaccinations cv
  ON cd.location = cv.location 
  and cd.date = cv.date
where cd.continent is not NULL
--order by 1,2
