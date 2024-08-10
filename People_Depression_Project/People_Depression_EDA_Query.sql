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


Select *
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


-- Total people by Marital_Status:

select Marital_Status, count(Marital_Status) Count_Marital
from depression_staged_main
group by Marital_Status
order by Count_Marital;

-- Percent of total people depressed by Marital_Status:

with Percent_ms as
(
Select Marital_Status, 
	   count(Marital_Status) Count_Marital
from depression_staged_main
group by Marital_Status
)
select Marital_Status, Count_Marital, round(cast(Count_Marital as float)/cast(sum(Count_Marital) over () as float),3) as Percent_Marital_Status
from Percent_ms
order by Marital_Status


-- Employeed Vs Unemployeed:

select Employment_Status, count(Employment_Status) Count_Emp
from depression_staged_main
group by Employment_Status
order by Count_Emp desc,Employment_Status


-- Employment Status and Education Level:

select Education_Level,Employment_Status, count(Education_Level) Count_Ed_Emp
from depression_staged_main
group by Education_Level,Employment_Status
order by Count_Ed_Emp desc,Employment_Status


with percent_Edu_Emp as
(
select Education_Level,
	   Employment_Status, 
	   count(Education_Level) Count_Ed_Emp
from depression_staged_main
group by Education_Level,Employment_Status
)
select Education_Level,
	   Employment_Status,
	   Count_Ed_Emp,
	   round(cast(Count_Ed_Emp as float)/cast(sum(Count_Ed_Emp) over () as float),3) as Percent_Ed_Emp
from percent_Edu_Emp
order by Count_Ed_Emp desc,Employment_Status


-- Graduates with Job vs Graduates without Job :

-- Graduates with No Job:

with grad_njb as
(
select Education_Level,
	   Employment_Status, 
	   count(Education_Level) Count_Ed_unEmp
from depression_staged_main
where Employment_Status like 'Unemployed'
group by Education_Level,Employment_Status
),
rolling_sum_grad_njb as
(
select *,
	  sum(Count_Ed_unEmp) over(partition by Employment_Status order by Education_Level) rolling_sum_unEmp
from grad_njb
),
percent_grad_njb as
(
select *,
	  round(cast(rolling_sum_unEmp as float)/cast(sum(Count_Ed_unEmp) over (partition by Employment_Status) as float),3) as Percent_Grad_njb
from rolling_sum_grad_njb
),

-- Graduates with Job:

grad_jb as
(
select Education_Level,
	   Employment_Status, 
	   count(Education_Level) Count_Ed_Emp
from depression_staged_main
where Employment_Status like 'Employed'
group by Education_Level,Employment_Status
),
rolling_sum_grad_jb as
(
select *,
	  sum(Count_Ed_Emp) over(partition by Employment_Status order by Education_Level) rolling_sum_emp
from grad_jb
),
percent_grad_jb as
(
select *,
	  round(cast(rolling_sum_emp as float)/cast(sum(Count_Ed_Emp) over (partition by Employment_Status) as float),3) as Percent_Grad_jb
from rolling_sum_grad_jb
)

select 
	   case when a.Education_Level is not null then a.Education_Level else b.Education_Level end as Education_Level,
       a.Employment_Status as Employment_Status_01,
	   a.Count_Ed_unEmp,
	   a.rolling_sum_unEmp,
	   a.Percent_Grad_njb,
	   b.Employment_Status as Employment_Status_02, 
	   b.Count_Ed_Emp,
	   b.rolling_sum_emp,
	   b.Percent_Grad_jb
from percent_grad_njb a
full outer join percent_grad_jb b
on a.education_level = b.education_level

-- Using Union

with grad_njb as
(
select Education_Level,
	   Employment_Status, 
	   count(Education_Level) Count_Ed_unEmp
from depression_staged_main
where Employment_Status like 'Unemployed'
group by Education_Level,Employment_Status
),
rolling_sum_grad_njb as
(
select *,
	  sum(Count_Ed_unEmp) over(partition by Employment_Status order by Education_Level) rolling_sum_unEmp
from grad_njb
),
percent_grad_njb as
(
select *,
	  round(cast(rolling_sum_unEmp as float)/cast(sum(Count_Ed_unEmp) over (partition by Employment_Status) as float),3) as Percent_Grad_njb
from rolling_sum_grad_njb
),

-- Graduates with Job:

grad_jb as
(
select Education_Level,
	   Employment_Status, 
	   count(Education_Level) Count_Ed_Emp
from depression_staged_main
where Employment_Status like 'Employed'
group by Education_Level,Employment_Status
),
rolling_sum_grad_jb as
(
select *,
	  sum(Count_Ed_Emp) over(partition by Employment_Status order by Education_Level) rolling_sum_emp
from grad_jb
),
percent_grad_jb as
(
select *,
	  round(cast(rolling_sum_emp as float)/cast(sum(Count_Ed_Emp) over (partition by Employment_Status) as float),3) as Percent_Grad_jb
from rolling_sum_grad_jb
)

select *
from percent_grad_njb
union all
select *
from percent_grad_jb


select distinct (Income), count(Income) countt
from depression_staged_main
group  by income
having count(Income) > 1
order by countt desc