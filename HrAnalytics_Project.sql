Create database HrAnalytics

use HrAnalytics

--Best practice to optimize performance
  SELECT TOP 10 age_band ,education ,job_role
FROM employee_trends 
ORDER BY job_satisfaction; 

--Task  1 : Count the number of employees in each department

select department ,
       count(emp_no) as No_of_employee
from employee_trends
group by department 

--Task 2 : Calculate the average age for each department

select department , 
       avg(age) avg_age
from employee_trends
group by department

--Task 3 : Identify the most common job roles in each department

with common_role as
(
select department,
	   job_role,
	   count(*) Cnt_role
from employee_trends
group by department,
	     job_role 
),
max_common_role as
(
select department,
	   job_role,
	   Cnt_role,
row_number() over(partition by department order by cnt_role desc) as rn
from common_role
)
select department,
	   job_role,
	   Cnt_role
from max_common_role
where rn = 1

--Task 4 : Calculate the average job satisfaction for each education level

Select education_field ,
	   avg(job_satisfaction) avg_jobsatisfaction
from employee_trends
group by education_field

--Task 5 : Determine the average age for employees with different levels of job satisfaction

select job_satisfaction ,
	   avg(age) avg_age 
from employee_trends
group by job_satisfaction 

--Task 6 : Calculate the attrition rate for each age band 

with temp_att as 
(
select age,
       count(*) as total_cnt,
	   sum(case when attrition = 1 then 1 else 0 end ) as att_cnt
from employee_trends
group by age
)
select age,
       round((att_cnt * 100 / total_cnt),2) as Att_rate
from temp_att
	  
--Task 7 : Identify departments with the highest and lowest average job satisfaction

with avg_temp as
(
select department,
	   avg(job_satisfaction) avg_job_satisfaction
from employee_trends
group by department
)
select * from (
    select top 1 department, avg_job_satisfaction
    from avg_temp
    order by avg_job_satisfaction asc
) as lowest
union all
select * from (
    select top 1 department, avg_job_satisfaction
    from avg_temp
    order by avg_job_satisfaction desc
) as highest;

--Task 8 :Find the age band with the highest attrition rate, attrition percentage mong employees with a specific education level

with age_att as
(
select education ,
	   age_band,
	 sum(case when attrition = 1 then 1 else 0 end) as Total_attrition,
	 cast(1.0 * sum(case when attrition = 1 then 1 else 0 end) / count(*) as decimal (5,2))as attrition_rate,
	 concat(cast(100.0 * sum(case when attrition = 1 then 1 else 0 end) / count(*) as decimal (5,2)),'%') as [attrition percentage]
from Employee_Trends
group by 
education,
	   age_band
),
edu_att as
(
select education ,
	   age_band,
	   Total_attrition,
	   attrition_rate,
	   [attrition percentage],
	Row_number() over(partition by education order by total_attrition desc) row_num
from age_att
) 
select education ,
	   age_band,
	   Total_attrition ,
	   attrition_rate,
	   [attrition percentage]
from edu_att 
where row_num = 1

--Task 9 : Find the education level with the highest job satisfaction among frequent travelers

with job_temp as
(
select education ,
	 avg(job_satisfaction) as Total_job_satisfaction
from Employee_Trends
where business_travel = 'travel_frequently'
group by education 
),
win_temp as
(
select education ,
	   Total_job_satisfaction,
     row_number() over(order by total_job_satisfaction desc) as Row_num
from job_temp
)
select education ,
	   Total_job_satisfaction
from win_temp
where Row_num = 1

--Task 10 : Identify the age band with the highest job satisfaction among married employees

with jb_temp as
(
select age_band,
	avg(job_satisfaction) as total_satisfaction
from Employee_Trends
where marital_status = 'Married'
group by age_band
),
marital_temp as
(
select age_band,
	   total_satisfaction,
	row_number() over(order by total_satisfaction desc) as row_num
from jb_temp
)
select age_band,
	   total_satisfaction
from marital_temp 
where row_num = 1







	      








