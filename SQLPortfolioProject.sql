Select *
From CovidDeaths
order by 3,4

--Select *
--From CovidVaccinations
--order by 3,4

---Select Data That We Are going to be using

Select location, date, total_cases, new_cases, total_deaths, population_density
From CovidDeaths
order by 1,2

---Looking At total cases vs total deaths
--- Shows the likelihood of  dying if you contract covid in your country

Select location, date, total_cases, total_deaths ,(total_deaths/total_cases) * 100 as DeathPercentage
From CovidDeaths
order by 1,2

Alter Table CovidDeaths
Alter Column total_cases float

Alter Table CovidDeaths
Alter Column total_deaths float

Select location, date, total_cases, total_deaths ,(total_deaths/total_cases) * 100 as DeathPercentage
From CovidDeaths
where location like '%states%'
order by 1,2

--- Looking At The total cases vs population
--- Shows what percentage of population got covid

Select location, date, total_cases, population_density ,(total_deaths/population_density)* 0.0001 as DeathPercentage
From CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

Select location, date, total_cases, population_density ,(total_deaths/population_density)* 0.0001 as DeathPercentage
From CovidDeaths
order by 1,2

--- Looking At countries with  Highest Infection Rate Compared to population

Select location, population_density, max(total_cases) as HighestInfectionCount ,max((total_deaths/population_density))* 0.0001 as InfectedPopulationPercentage
From CovidDeaths
Group by population_density,location
order by InfectedPopulationPercentage desc


---- Showing Countries with highest death count per population

--- cast = to convert nvarchar to int
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

Select *
From CovidDeaths
where continent is not null
order by 3,4

--- Let's bring things down by continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is  null
Group by continent
order by TotalDeathCount desc

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is  null
Group by location
order by TotalDeathCount desc

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

---Showing the continents with highest infection
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--- Global Numbers 

Select  date, total_cases, total_deaths ,(total_deaths/total_cases)* 0.0001 as DeathPercentage
From CovidDeaths
where continent is not null
Group by date
order by 1,2

Select  date, sum(new_cases)
From CovidDeaths
where continent is not null
Group by date
order by 1,2
                                            ---cast = convert nvarchar to int while execution
Select  date, sum(new_cases) AllCases, sum(cast(new_deaths as int)) AllDeaths
From CovidDeaths
where continent is not null
Group by date
order by 1,2

Select  date, sum(new_cases) AllCases, sum(cast(new_deaths as int)) AllDeaths, sum(new_deaths)/sum(cast(new_cases as int))*100 DeathPercentage
From CovidDeaths
where continent is not null and new_cases is not null
Group by date
order by 1,2

--- Looking at Total Population vs Vaccinations

Select *
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_people_vaccinated_smoothed
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_people_vaccinated_smoothed
, sum(cast(vac.new_people_vaccinated_smoothed as int)) over (Partition By dea.location)
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_people_vaccinated_smoothed
, sum(convert(int ,vac.new_people_vaccinated_smoothed)) over (Partition By dea.location order by dea.location,
dea.date) as RollingVACCINATEDPeople
--,(RollingVACCINATEDPeople/population) * 100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--use CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingVACCINATEDPeople)
as
(
Select dea.continent, dea.location, dea.date, dea.population_density, vac.new_people_vaccinated_smoothed
, sum(convert(int ,vac.new_people_vaccinated_smoothed)) over (Partition By dea.location order by dea.location,
dea.date) as RollingVACCINATEDPeople
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingVACCINATEDPeople/Population)
From PopvsVac

---  Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_Vaccinations numeric,
RollingVACCINATEDPeople numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, vac.population, vac.new_people_vaccinated_smoothed
, sum(convert(int ,vac.new_people_vaccinated_smoothed)) over (Partition By dea.location order by dea.location,
dea.date) as RollingVACCINATEDPeople
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingVACCINATEDPeople/Population)*100
From #PercentPopulationVaccinated

--- Creating view to stored data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, vac.population, vac.new_people_vaccinated_smoothed
, sum(convert(int ,vac.new_people_vaccinated_smoothed)) over (Partition By dea.location order by dea.location,
dea.date) as RollingVACCINATEDPeople
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date


where dea.continent is not null

Select * 
From PercentPopulationVaccinated



























































