-- People Depression EDA Project --


use People_Depression_database;


-- Total number of people based on Age category:

select *
from depression_staged_main

select age, count(age) as Age_count
from depression_staged_main
group by age
order by age;

-- Creating a Age bucket to standardize:

select age,
	Case when age < 20 then 'Under 20'
		 when age between 21 and 30 then '21-30'
		 when age between 31 and 40 then '31-40'
		 when age between 41 and 50 then '41-50'
		 when age between 51 and 60 then '51-60'
		 when age between 61 and 70 then '61-70'
		 when age between 71 and 80 then '71-80'
		 when age > 80 then 'Above 80'
	END as Age_Bucket
from depression_staged_main
order by age asc;


-- Update table with "Age_Bucket" column

alter table depression_staged_main
add Age_Bucket varchar(255);

update depression_staged_main
set Age_Bucket = (Case when age < 21 then 'Under 20'
		 when age between 21 and 30 then '21-30'
		 when age between 31 and 40 then '31-40'
		 when age between 41 and 50 then '41-50'
		 when age between 51 and 60 then '51-60'
		 when age between 61 and 70 then '61-70'
		 when age between 71 and 80 then '71-80'
		 when age > 80 then 'Above 80'
	END)


Select count(*)
from depression_staged_main

-- Total number of People based Age Bucket:

Select age_bucket, count(age_bucket) Count_Age_Group
from depression_staged_main
group by age_bucket
order by age_bucket asc;


-- Percent of people Depressed by Age group to total count:

with Percent_age_cte as
(
Select age_bucket, 
	   count(age_bucket) count_age_group, 
	   count(age) total_count
from depression_staged_main
group by age_bucket
)
select age_bucket, Count_Age_Group, round(cast(Count_Age_Group as float)/cast(sum(total_count) over () as float),3) as Percent_age_group
from Percent_age_cte
order by age_bucket




