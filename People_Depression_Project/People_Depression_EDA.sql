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
	Case when age < 20 then '18-20'
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
set Age_Bucket = (Case when age < 21 then '18-20'
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


-- Depression rate based on Income:


select distinct(income), count(income)
from depression_staged_main
group by income
order by income desc
--order by income asc

-- Creating a Income Group for further analysis:

select Income,
	Case when Income between 0 and 4000 then 'Under 5k'
		 when Income between 4000 and 8000 then '4k-8k'
		 when Income between 8001 and 12000 then '8k-12k'
		 when Income between 12001 and 16000 then '12k-16k'
		 when Income between 16001 and 20000 then '16k-20k'
		 when Income > 20000 then 'Above 20K'
	END as Income_Bucket
from depression_staged_main
order by Income asc;

alter table depression_staged_main
add Income_Bucket varchar(255);

update depression_staged_main
set Income_Bucket = (Case when Income between 0 and 10000 then '0-10k'
		 when Income between 10000 and 20000 then '10k-20k'
		 when Income between 20000 and 30000 then '20k-30k'
		 when Income between 30000 and 40000 then '30k-40k'
		 when Income between 40000 and 50000 then '40k-50k'
		 when Income between 50000 and 60000 then '50k-60k'
		 when Income between 60000 and 70000 then '60k-70k'
		 when Income between 70000 and 80000 then '70k-80k'
		 when Income between 80000 and 90000 then '80k-90k'
		 when Income between 90000 and 100000 then '90k-100k'
		 when income between 100000 and 150000 then '100k-150k'
		 when income between 150000 and 200000 then '150k-200k'
		 when income > 200000 then 'Above 200k'
	END)

select distinct(Income_Bucket), count(Income_Bucket) Total_Count
from depression_staged_main
group by Income_Bucket
order by Total_Count desc


-- Checking Whether Higher income affects physical activity, Dietary_Habits, Sleep_Patterns (Best Case):

select Income_Bucket,count(Income_Bucket) Total_count
from depression_staged_main
where 
	Physical_Activity_Level like 'Active' and Dietary_Habits like 'Healthy' and Sleep_Patterns like 'Good'
--	Physical_Activity_Level like 'Sedentary' and Dietary_Habits like 'Unhealthy' and Sleep_Patterns like 'Poor'
group by Income_Bucket 
order by Total_count desc


-- Checking Whether Higher income affects physical activity, Dietary_Habits, Sleep_Patterns (Worst Case):

select Income_Bucket,count(Income_Bucket) Total_count
from depression_staged_main
where 
--	Physical_Activity_Level like 'Active' and Dietary_Habits like 'Healthy' and Sleep_Patterns like 'Good'
	Physical_Activity_Level like 'Sedentary' and Dietary_Habits like 'Unhealthy' and Sleep_Patterns like 'Poor'

group by Income_Bucket 
order by Total_count desc



-- Smoking and Alcohol Consumption:

with percent_Smoking_Status as
(
select Smoking_Status, 
	   count(Smoking_Status) Total_Count
from depression_staged_main
group by Smoking_Status
)
select Smoking_Status, 
	   Total_Count,
	   round(cast(Total_Count as float)/cast(sum(Total_Count) over () as float),3) as Percent_Smoking_Status
from percent_Smoking_Status
order by Total_Count



with percent_Alcohol_Consumption as
(
select Alcohol_Consumption,
	   count(Alcohol_Consumption) Total_Count
from depression_staged_main
group by Alcohol_Consumption
)
select Alcohol_Consumption,
	   Total_Count,
	   round(cast(Total_Count as float)/cast(sum(Total_Count) over () as float),3) as Percent_Smoking_Status
from percent_Alcohol_Consumption
order by Total_Count


-- FAMLIY HISTORY:

select Family_History_of_Depression, count(Family_History_of_Depression) Total_Count
from depression_staged_main
group by Family_History_of_Depression;


With percent_History as
(
select Family_History_of_Depression, count(Family_History_of_Depression) Total_Count
from depression_staged_main
group by Family_History_of_Depression
)
select Family_History_of_Depression, 
	   Total_Count,
	   round(cast(Total_Count as float)/cast(sum(Total_Count) over () as float),3) as Percent_Family_History_of_Depression
from percent_History

-- SUBSTANCE ABUSE:

select History_of_Substance_Abuse, count(History_of_Substance_Abuse) Total_Count
from depression_staged_main
group by History_of_Substance_Abuse;


With percent_History_of_Substance_Abuse as
(
select History_of_Substance_Abuse, count(History_of_Substance_Abuse) Total_Count
from depression_staged_main
group by History_of_Substance_Abuse
)
select History_of_Substance_Abuse, 
	   Total_Count,
	   round(cast(Total_Count as float)/cast(sum(Total_Count) over () as float),3) as Percent_History_of_Substance_Abuse
from percent_History_of_Substance_Abuse



with Combine_Data as
(
SELECT Family_History_of_Depression,
		History_of_Substance_Abuse,
		Alcohol_Consumption,
		Smoking_Status,
		count (*) Total_Count
from depression_staged_main
where Family_History_of_Depression = 'Yes' and
		History_of_Substance_Abuse = 'Yes' and
		Alcohol_Consumption = 'High' and
		Smoking_Status = 'Current'
group by Family_History_of_Depression,
		History_of_Substance_Abuse,
		Alcohol_Consumption,
		Smoking_Status

union all

SELECT Family_History_of_Depression,
		History_of_Substance_Abuse,
		Alcohol_Consumption,
		Smoking_Status,
		count (*) Total_Count
from depression_staged_main
where Family_History_of_Depression = 'No' and
		History_of_Substance_Abuse = 'No' and
		Alcohol_Consumption = 'low' and
		Smoking_Status = 'Non-smoker'
group by Family_History_of_Depression,
		History_of_Substance_Abuse,
		Alcohol_Consumption,
		Smoking_Status
)
select Family_History_of_Depression,
		History_of_Substance_Abuse,
		Alcohol_Consumption,
		Smoking_Status,
		Total_Count,
	    round(cast(Total_Count as float)/cast(sum(Total_Count) over () as float),3) as Percent_total
from Combine_Data
