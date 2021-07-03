select *
from PortfolioProject1.coviddeaths
WHERE COALESCE(continent, '') != ''
order by 3,4;

# select  *
# from PortfolioProject1.covidvaccinations
# order by 3,4;

#Select data that we will be using

Select location, date, total_cases,new_cases,total_deaths, population
from PortfolioProject1.coviddeaths
order by 1,2;

#Looking at Total Cases vs Total Deaths
#Shows likeihood if dying if you have covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1.coviddeaths
Where location like "Hong Kong"
order by 1,2;

#Looking at total cases VS population
#Shows the percentage of population that got infected with covid
Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject1.coviddeaths
#Where location like "Hong Kong"
order by 1,2;

#Looking an countries with highest infection rate comparing to population
Select location, MAX(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 as InfectionRate
from PortfolioProject1.coviddeaths
group by location,population
order by 4 desc;

#Showing the countries with highest Death count per population
Select location, max(total_deaths) as TotalDeathCount
from PortfolioProject1.coviddeaths
group by location
order by TotalDeathCount desc;

#Let's break this down into continents
Select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject1.coviddeaths
WHERE continent != ""
group by continent
order by TotalDeathCount desc;

#Global numbers
Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(New_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject1.coviddeaths
where continent !=""
#group by date
order by 1,2;

#Looking at Total Population vs Vaccinations
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (vac.new_vaccinations, decimal)) OVER  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1.coviddeaths dea
join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location 
    and dea.date = vac.date
where dea.continent !=""
order by 2,3;

#Use CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (vac.new_vaccinations, decimal)) OVER  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1.coviddeaths dea
join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location 
    and dea.date = vac.date
where dea.continent !=""
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac;

#Use TEMP Table
Drop table if exists PercentPopulationVaccinated;
Create table PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
);

insert into PercentPopulationVaccinated
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (vac.new_vaccinations, decimal)) OVER  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1.coviddeaths dea
join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location 
    and dea.date = vac.date
where dea.continent !="";

Select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated;

#Creating View to store data for data viz
Create View PercentPopulationVaccinated as 
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (vac.new_vaccinations, decimal)) OVER  (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject1.coviddeaths dea
join PortfolioProject1.covidvaccinations vac
	On dea.location = vac.location 
    and dea.date = vac.date
where dea.continent !="";

Select *
From PercentPopulationVaccinated