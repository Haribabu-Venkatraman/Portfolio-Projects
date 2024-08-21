-- People Depression Project

-- Creating Table views for Visualizations in Tableau:

use People_Depression_database;


-- Total number of People based Age Bucket:

Create view Total_Number_Age_Bucket as 
Select age_bucket, count(age_bucket) Count_Age_Group
from depression_staged_main
group by age_bucket
--order by age_bucket asc;

create view  Percent_Total_Number_Age_Bucket as
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
--order by age_bucket


-- Total people by Marital_Status:

create view Total_Number_Marital_Status as
select Marital_Status, count(Marital_Status) Count_Marital
from depression_staged_main
group by Marital_Status
-- order by Count_Marital;

create view Percent_Total_Number_Marital_Status as
with Percent_ms as
(
Select Marital_Status, 
	   count(Marital_Status) Count_Marital
from depression_staged_main
group by Marital_Status
)
select Marital_Status, Count_Marital, round(cast(Count_Marital as float)/cast(sum(Count_Marital) over () as float),3) as Percent_Marital_Status
from Percent_ms
--order by Marital_Status



-- Employment Status and Education Level:

create view Percent_Employment_Education as
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
--order by Count_Ed_Emp desc,Employment_Status


create view Percent_Job_Status_Education as
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


-- Income Bucket:

create view Total_Annual_Income_Bucket as
select distinct(Income_Bucket), count(Income_Bucket) Total_Count
from depression_staged_main
group by Income_Bucket
--order by Total_Count desc

create view Income_bestcase as
select Income_Bucket,count(Income_Bucket) Total_count
from depression_staged_main
where 
	Physical_Activity_Level like 'Active' and Dietary_Habits like 'Healthy' and Sleep_Patterns like 'Good'
--	Physical_Activity_Level like 'Sedentary' and Dietary_Habits like 'Unhealthy' and Sleep_Patterns like 'Poor'
group by Income_Bucket 
--order by Total_count desc

create view Income_worstcase as
select Income_Bucket,count(Income_Bucket) Total_count
from depression_staged_main
where 
--	Physical_Activity_Level like 'Active' and Dietary_Habits like 'Healthy' and Sleep_Patterns like 'Good'
	Physical_Activity_Level like 'Sedentary' and Dietary_Habits like 'Unhealthy' and Sleep_Patterns like 'Poor'

group by Income_Bucket 
--order by Total_count desc


-- Alcohol Consumption:

create view percent_Alcohol_Consumption as
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
--order by Total_Count


-- History of Violence:

Create view Family_History as
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


-- Substance Abuse:

Create view Substance_Abuse as
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


Create view HAS_Combined as
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
