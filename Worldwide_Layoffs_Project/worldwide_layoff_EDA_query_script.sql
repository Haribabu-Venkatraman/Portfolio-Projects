
-- World Wide Layoffs : Exploratory Data Analysis

-- Looking at dataset

select *
from layoffs_staging_main;

select max(total_laid_off) max_layoffs, max(percentage_laid_off) max_percent_layoffs
from layoffs_staging_main;

select count(*) total_no_of_complete_layoff
from layoffs_staging_main
where percentage_laid_off = 1;

select *
from layoffs_staging_main
where percentage_laid_off = 1
order by funds_raised_millions desc, date desc;


-- Layoffs duration

select min(date) start_date, max(date) last_date
from layoffs_staging_main;

-- layoff trend besed on YEAR and MONTH:

select year(date) `year`, month(date) `month`, sum(total_laid_off) total_Layoffs
from layoffs_staging_main
group by year(date), month(date) 
order by year(date) desc;

-- Companies with higher number of Layoffs:

select company, sum(total_laid_off) total_Layoffs
from layoffs_staging_main
group by company
order by total_layoffs desc;

-- Imdustry with higher number of Layoffs:

select industry, sum(total_laid_off) total_Layoffs
from layoffs_staging_main
group by industry
order by total_layoffs desc;

-- Country with higher layoffs:

select country, sum(total_laid_off) total_Layoffs, round(sum(percentage_laid_off), 3) total_percentage_Layoffs
from layoffs_staging_main
group by country
order by total_layoffs desc;

-- Layoffs trends based on Stage:

select stage, sum(total_laid_off) total_Layoffs, round(sum(percentage_laid_off), 3) total_percentage_Layoffs
from layoffs_staging_main
group by stage
order by total_layoffs desc;


-- Stages with higher Funds:

select stage, sum(funds_raised_millions) total_funds_raised
from layoffs_staging_main
group by stage
order by total_funds_raised desc;


-- Rolling values of total layoffs based on date:

WITH Rolling_total as
(
SELECT substring(`date`,1,7) Period, sum(total_laid_off) total_Layoffs, sum(funds_raised_millions) total_funds_raised
FROM layoffs_staging_main
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY Period
order by Period asc
)
SELECT Period, total_Layoffs, 
	   SUM(total_Layoffs) over (order by Period) Rolling_total_layoffs,
       total_funds_raised,
       sum(total_funds_raised) over (order by Period) Rolling_total_funds_raised
from Rolling_total;


-- Top 5 total Layoff based on company per year:


with Rolling_company_year as
(
select company, year(date) Period, sum(total_laid_off) total_layoffs
from layoffs_staging_main
group by company, year(date)
), 
Total_layoff_ranking as
(
select *, DENSE_RANK() over (PARTITION BY Period order by total_layoffs desc) Layoff_ranking
from Rolling_company_year
where Period is not null
)
select *
from Total_Layoff_ranking
where Layoff_Ranking <= 5;


-- Companies with more frequent layoffs per year:

with frequent_layoffs as
(
select company, year(date) year_period, month(date) month_period, COUNT(total_laid_off) count_total_layoffs
from layoffs_staging_main
group by company, year(date), month(date)
order by company, year(date), month(date)
), 
rolling_count_layoff as
(
select *, 
	 SUM(count_total_layoffs) over (PARTITION BY company, year_period order by year_period, month_period) Rolling_total_layoffs
from frequent_layoffs
where year_period is not null
order by company, year_period, month_period
),
rolling_ranking as
(
select *,
DENSE_RANK() over (order by Rolling_total_layoffs) Layoff_ranking
from rolling_count_layoff
)
select *
from rolling_ranking
where count_total_layoffs > 1
order by year_period, month_period;





-- Countries with higher funds in particular industry:

with Total_funds_country as
(
select country, industry, sum(funds_raised_millions) total_funds_millions
from layoffs_staging_main
where funds_raised_millions is not null
GROUP BY country, industry
order by country, industry
)
select *, 
	   DENSE_RANK() over(order by total_funds_millions asc)
from Total_funds_country
order by country asc, total_funds_millions desc;


