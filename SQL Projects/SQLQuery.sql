select *
from Portfolio_Projects..CovidDeaths
order by 3,4;

--select *
--from Portfolio_Projects..CovidDeaths
--order by 3,4;


-- altering datatype of table column for exploration

--Alter Table Portfolio_Projects..CovidDeaths
--ALTER COLUMN new_cases integer


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

select location, population, Max(total_cases) as Highest_Infection_Count,  
       Max((total_cases/population)*100) as Highest_Infection_Rate

from Portfolio_Projects..CovidDeaths
--where location like '%India%'
group by location, population 
order by Highest_Infection_Rate desc


-- countries with Highest Death Rate 

select location, max(total_cases) as Highest_Infection_Rate, max(total_deaths) as Highest_Death_Rate, (max(total_deaths)/max(total_cases)*100) as Total_Death_Percentage
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by location
order by Total_Death_Percentage desc


-- Country with highest death count

select location, max(cast (total_deaths as int)) as Highest_Death_Rate
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by location
order by Highest_Death_Rate desc


-- BREAKING DOWN BY CONTINENT
-- continent with Highest Death Count

select continent, max(cast (total_deaths as int)) as Highest_Death_Rate
from Portfolio_Projects..CovidDeaths
--where location like '%India%' 
where continent is not null
group by continent
order by Highest_Death_Rate desc

-- looking at GLOBAL NUMBERS

select date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, 
             (SUM(new_cases)/SUM(new_deaths)*100) as Death_Percentage
from Portfolio_Projects..CovidDeaths
--where location like '%India%'
where continent is not NULL
group by [date]
order by 1, 2

-- Total population vs Vaccinations per Day

select cd.continent, cd.[location],cd.[date], cd.population, cv.new_vaccinations
from Portfolio_Projects..CovidDeaths cd
join Portfolio_Projects..CovidVaccinations cv
  ON cd.[location] = cd.[location] 
  and cd.[date] = cv.[date]
where cd.continent is not NULL
order by 1, 2  