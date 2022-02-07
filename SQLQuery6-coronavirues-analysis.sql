--Select *
--From portfolioproject..[covid-dead]

--select data we are using
--Select location, date, total_cases,total_deaths,population
--From portfolioproject ..[covid-dead]
--order by 1,2

--looking at total cases vs total death

--Select location, date, total_cases,total_deaths , (total_deaths/total_cases)*100 as Deathpercentage
--From portfolioproject ..[covid-dead]
--Where location like '%state%'
--order by 1,2

--looking at countries with highest infected rate compared to population
Select Location, Population, Max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as
   percentpopulationeffect
From portfolioproject .. [covid-dead]
Group by Location, Population
order by percentpopulationeffect desc


--showing continents with higeser death
Select continent, Max(cast (Total_deaths as int)) as totaldeathcount
From portfolioproject ..[covid-dead]
Where continent is not null
Group by continent
order by totaldeathcount desc

--showing countries with highest death
Select location, Max(cast (Total_deaths as int)) as totaldeathcount
From portfolioproject ..[covid-dead]
Where continent is not null
Group by location
order by totaldeathcount desc

--Global numbers
Select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From portfolioproject .. [covid-dead]
Where continent is not null
group by date
order by 1,2

--looking at total vaccination vs total population

with popvsvac(continent, date, location, new_vaccinations,population, rollingpeoplevaccination)
as
(
Select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location, dea.date) as 
rollingpeoplevaccination
From portfolioproject .. [covid-dead]  dea
join portfolioproject .. [covid-vacsination] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null

)
select *, (rollingpeoplevaccination/NULLIF(population,0) )*100 
From popvsvac

--temp tamble
--Drop table if exists #percentpopvac
create table #percentpopvac
(
continent nvarchar(255),
location nvarchar(255),
Date nvarchar(255),
population numeric,
new_vaccinations numeric,
rollingpeoplevaccination numeric
)
insert into #percentpopvac
Select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccination
From portfolioproject .. [covid-dead]  dea
join portfolioproject .. [covid-vacsination] vac
   on dea.location = vac.location
   and dea.date = vac.date
select *, (rollingpeoplevaccination/NULLIF(population,0) )*100 
From #percentpopvac

--drop table #percentpopvac

--create view
--USE tempdb
Go
CREATE VIEW percentpopvac 
as
Select dea.location, dea.date, dea.continent, dea.population, vac.new_vaccinations 
,sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccination
From portfolioproject .. [covid-dead]  dea
join portfolioproject .. [covid-vacsination] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null


select *
from percentpopvac