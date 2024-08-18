-- Patient Depression EDA Project --

-- As a First step of analysing any data, Data needs to be cleaned.
-- The following Data Cleaning steps are standard for any dataset:

-- 1. Removing Duplicates
-- 2. Standardizing The Data
-- 3. Updating Nulls / Unknown Values
-- 4. Removing Unnecessary Rows and Columns

create database People_Depression_database;

-- Looking at all values in the table:

use People_Depression_database;

select *
from People_Depression_database..depression_data_raw;


-- Creating a Staging table :

-- Using SELECT INTO to create and copy data in one step

SELECT *
INTO depression_staged
FROM People_Depression_database..depression_data_raw
where 1=0;

-- Copying the data

INSERT INTO depression_staged
SELECT *
FROM People_Depression_database..depression_data_raw;


select *
from depression_staged

with duplicate_cte as
(
select *, ROW_NUMBER() over (partition by Name, age, marital_status, Education_level, number_of_children order by name, age) as rn
from depression_staged
)
select *
from duplicate_cte

SELECT *
INTO depression_staged_main
FROM People_Depression_database..depression_staged
where 1=0;

alter table depression_staged_main
add rn int

-- Copying the data

INSERT INTO depression_staged_main
select *, ROW_NUMBER() over (partition by Name, age, marital_status, Education_level, number_of_children order by name, age) as rn
from depression_staged


-- checking whether duplicates exists:

select *
from depression_staged_main
where rn>1


-- deleting duplicates values

delete
from depression_staged_main
where rn >1


-- 2. standardizing name column: (Removing titles like Dr., Ph.D etc.,)

select distinct(name)
from depression_staged_main
--where name like 'Ms.%'

select distinct(name), replace (name, 'Ms. ', '')
from depression_staged_main
where name like 'Mrs.%'

update depression_staged_main
set name = replace(name,'Mr. ','')
where name like 'Mr.%'

update depression_staged_main
set name = replace(name,'Mrs. ','')
where name like 'Mrs.%'

update depression_staged_main
set name = replace(name,'Ms. ','')
where name like 'Ms.%'

update depression_staged_main
set name = replace(name,'Dr. ','')
where name like 'Dr.%'

update depression_staged_main
set name = replace(name,' PhD','')
where name like '%PhD'

update depression_staged_main
set name = replace (name, ' MD', '')
where name like '%MD'

-- Using Substring to remove characters:

SELECT DISTINCT(SUBSTRING(name, CHARINDEX('', name) -3, LEN(name))) AS name_trimmed, name
FROM depression_staged_main
WHERE name LIKE '%DDS'
order by name asc;

update depression_staged_main
SET NAME = SUBSTRING(name, CHARINDEX('', name) -3, LEN(name))
WHERE name LIKE '%DDS'

SELECT DISTINCT(SUBSTRING(name, CHARINDEX('', name) -3, LEN(name))) AS name_trimmed, name
FROM depression_staged_main
WHERE name LIKE '%DVM'
order by name asc;

update depression_staged_main
SET NAME = SUBSTRING(name, CHARINDEX('', name) -3, LEN(name))
WHERE name LIKE '%DVM'

SELECT DISTINCT(NAME) , TRIM (NAME)
FROM depression_staged_main

update depression_staged_main
SET NAME = TRIM (NAME)


use People_Depression_database
select *
from depression_staged_main
