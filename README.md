# COVID Data Analysis Project

## Introduction
A comprehensive SQL-based analysis of COVID-19 data examining global infection rates, vaccination progress, and mortality patterns. This project uses SQL queries to explore and visualize relationships between various COVID-19 metrics across different geographical locations and time periods.

## Why This Project?
The COVID-19 pandemic has generated an unprecedented amount of public health data. This project aims to:
- Provide clear insights into the pandemic's global impact
- Track vaccination progress across different regions  
- Analyse mortality rates and infection patterns
- Create a foundation for data-driven public health decisions

## Key Insights

### Global Statistics
- Calculated total cases, deaths, and global death percentage
- Created views for efficient data visualization in Tableau
- Tracked the progression of cases and deaths over time

### Vaccination Analysis
- Monitored vaccination rollout across different locations
- Calculated rolling counts of vaccinated people
- Analyzed the percentage of vaccinated population by country

### Regional Impact
- Identified countries with highest infection rates relative to population
- Analysed continental death counts
- Tracked infection patterns across different geographical regions

### Technical Highlights
- Utilized Common Table Expressions (CTEs) for complex calculations
- Implemented temporary tables for performance optimization
- Created views for persistent data access
- Joined multiple COVID-19 data tables for comprehensive analysis
- Employed window functions for rolling calculations

## Tools Used
- Microsoft SQL Server
- SQL
- Tableau (for visualization)
<!--- Tableau dashboard visuals to be added soon --->

## Database Structure
- CovidDeaths table: Contains mortality and infection data
- CovidVaccinations table: Contains vaccination-related metrics

## Views Created
- PercentPopulationVaccinated
- GlobalNumbers
- ContinentalDeathCounts
- PercentPopulationInfected

This project serves as a valuable resource for understanding the pandemic's impact through data analysis and visualization.
