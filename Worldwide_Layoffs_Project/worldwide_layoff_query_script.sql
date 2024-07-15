-- Worldwide Layoffs Data Cleaning Project

-- First of all looking at all values in the table;

Select *
from layoffs_raw_data;


-- Following Data Cleaning steps are done:

-- 1. Removing duplicates
-- 2. Standarizing the data
-- 3. Updating Null / Unknown and Blank values
-- 4. Removing unnecessary rows / columns

-- Creating a Staging Table as a Backup table:

create table layoffs_staging
like layoffs_raw_data; 

select *
from layoffs_staging;

-- Inserting data into staging table:

insert layoffs_staging
select *
from layoffs_raw_data;


-- 1. Removing Duplicates

-- we use ROW NUMBER and CTE to  figure out duplicate rows in the table:

with duplicate_cte as
(
select *, 
	row_number() over ( partition by 'date', company, location, industry, stage, country, total_laid_off, percentage_laid_off, funds_raised_millions) row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num >1;

-- Checking whether duplicates really exists:

select *
from layoffs_staging
where company like 'Booking.com'


-- Removing Duplicates

CREATE TABLE `duplicates_layoffs_staging` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from duplicates_layoffs_staging;

insert into duplicates_layoffs_staging
select *, 
	row_number() over ( partition by 'date', company, location, industry, stage, country, total_laid_off, percentage_laid_off, funds_raised_millions) row_num
from layoffs_staging;

delete
from duplicates_layoffs_staging
where row_num > 1;



-- Checking for removal of duplicates:

select *
from duplicates_layoffs_staging
where row_num > 1;
