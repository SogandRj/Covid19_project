--------- To see the full table:
SELECT *
FROM portfolioProject..covidDeaths
--where continent is not null
order by 3, 4
SELECT *
FROM portfolioProject..covidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, CAST(total_deaths As int) as totalDeaths, population
FROM portfolioProject..covidDeaths
order by totalDeaths desc

---------  Looking at Total cases VS total Deaths:
SELECT location, date, total_cases, total_deaths, (total_deaths/CONVERT(float,total_cases))*100 AS deathRate
FROM portfolioProject..covidDeaths
order by 1,2
--** You could also use: (CAST(total_deaths AS float)/CAST(Total_cases))*100

----------Looking at total_cases and total_deaths in afghanistan on 2021-04-30:
SELECT location,date, total_cases, total_deaths
FROM portfolioProject..covidDeaths
WHERE date = '2021-04-30' AND location LIKE 'afghan%'
 OR: 
WHERE date = '2021-04-30' AND location= 'afghanistan'

--------------Looking at selected columns related to unitedstates 
SELECT location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/CONVERT(float,total_cases))*100 AS deathRate
FROM portfolioProject..covidDeaths
where location like '%states'
order by 1,2

--------------Looking at total cases vs population
SELECT location, date, total_cases, population, (CONVERT(float,total_cases) / population) * 100 as InfectionRate
FROM portfolioProject..covidDeaths
order by location, InfectionRate desc


----------------Looking at contries with highest Infection rate
SELECT location, population, MAX(CONVERT(float, total_cases)) as HighesInfectionCount , Max(CONVERT(float,total_cases)/ population) * 100 as HighestInfectionRate
FROM portfolioProject..covidDeaths
GROUP BY location , population
order by HighestInfectionRate desc


----------------Looking at contries with highest death count per population 
SELECT location, population, MAX(CONVERT(int,total_deaths)) as HighestDeathCount
FROM portfolioProject..covidDeaths
where continent is not null
GROUP BY location, population
ORDER BY HighestDeathCount desc
----** OR:
SELECT location, MAX(CASt(total_deaths as int)) as HighestDeathCount
FROM portfolioProject..covidDeaths
where continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

---------------BREAK Things By Continent (showing comtinents with highest death count per population)
SELECT continent, MAX(CAST(total_deaths as int)) as HighestDeathCount
FROM portfolioProject..covidDeaths
where continent is not null
GROUP BY continent
ORDER BY HighestDeathCount
------** More ACCURATE:
SELECT location, MAX(CASt(total_deaths as int)) as HighestDeathCount
FROM portfolioProject..covidDeaths
where continent is null
GROUP BY location
ORDER BY HighestDeathCount desc

---------------GLOBAL NUMBERS (total deaths and cases in the word per day)
SELECT date, SUM(new_cases) , SUM(new_deaths)
FROM portfolioProject..covidDeaths
GROUP BY date
HAVING SUM(new_deaths) > 0 AND SUM(new_deaths) = '0'
order by 2 desc

SELECT date, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths , CASE WHEN SUM(new_deaths)=0 THEN 0 ElSE SUM(new_deaths)/SUM(new_cases) * 100 END as DeathPercentage
FROM portfolioProject..covidDeaths
where continent is not null
GROUP BY date
order by DeathPercentage desc


SELECT *
FROM portfolioProject..covidDeaths Dea
Join portfolioProject..covidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3

--------------- Looking at total population vs vaccinations 
--USE CTE 
with PopvsVac(continent , location , date , population , new_vaccinations , RollingPeopleVaccinated)
as
(
SELECT dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations , 
SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (partition by Dea.location ORDER BY Dea.location, Dea.date ) as RollingPeopleVaccinated
FROM portfolioProject..covidDeaths Dea
Join portfolioProject..covidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3
)
SELECT * , (RollingPeopleVaccinated/population) * 100 as VaccinationRate
FROM popvsvac
order by 2,3

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations , 
SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (partition by Dea.location ORDER BY Dea.location, Dea.date ) as RollingPeopleVaccinated
FROM portfolioProject..covidDeaths Dea
Join portfolioProject..covidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
--where Dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100 as RollingPeopleVaccinatedRate
FROM #PercentPopulationVaccinated

-- Creating View:
CREATE View PercentPopulationVaccinatedView as
SELECT dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations , 
SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (partition by Dea.location ORDER BY Dea.location, Dea.date ) as RollingPeopleVaccinated
FROM portfolioProject..covidDeaths Dea
Join portfolioProject..covidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
--where Dea.continent is not null
--order by 2,3
