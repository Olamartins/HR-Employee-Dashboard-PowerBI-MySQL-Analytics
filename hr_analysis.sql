/* CREATE DATABASE human_resource; */
use human_resource;
select * from hr;

/* Rename the column name */
ALTER TABLE hr
change column ï»¿id emp_id VARCHAR(20) NULL;

/* Get the data type of the columns */
DESCRIBE hr;

/* getting the birthdate field and setting correct data type */
select birthdate from hr;

/* allowing safe update in the database */
set sql_safe_updates = 0;

update hr
set birthdate = case
	when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'),'%Y-%m-%d')
	when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'),'%Y-%m-%d')
    else null
end;

select birthdate from hr;
alter table hr
modify column birthdate date;
/* engineering hire_date column */
select hire_date from hr;

update hr
set hire_date = case
	when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'),'%Y-%m-%d')
	when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'),'%Y-%m-%d')
    else null
end;
alter table hr
modify column hire_date date;

/* cleaning termdate column */
select termdate from hr;
update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

alter table hr
drop column termdate;

/* Feature engineering: create age column */
alter table hr
add column age int;

update hr
set age =  timestampdiff(year, birthdate, curdate());

select * from hr;

/* get the minimum and maximum age */ 
select min(age) as minimum_age, max(age) as maximum_age from hr;
/* minimum age = -45, maximum_age = 58 */

/* Filter out the negative age values and age less than 18 years */
select * from hr
where age > 18;

/* grouping the age into age brackets */
alter table hr
add column age_group varchar(25);

update hr
set age_group = case
	when age >= 18 and age <= 24 then "18-24"
	when age >= 25 and age <= 30 then "25-30"
	when age >= 31 and age <= 34 then "31-34"
	when age >= 35 and age <= 40 then "35-40"
	when age >= 41 and age <= 50 then "41-50"
	else "above 50"
end;

/* ==== Analysis Questions ==== */
/* === Gender breakdown of employees in the company === */
select gender, count(*) as "No of Staff"
from hr where age > 18
group by gender;

/* === Race/ethnicity breakdown of employees in the company === */
select race, count(*) as "No of Staff"
from hr where age > 18
group by race;

/* === age distribution of employees in the company === */
select age_group, count(*) as "No of Staff"
from hr where age > 18
group by age_group
order by age_group asc;

/* How many employees work at headquarters against those working remotely? */
select location, count(*) as "No_of_Staff", 
concat(round(count(*)/sum(count(*)) over (), 2)*100, '%') as percentage
from hr where age > 18
group by location;

/* How does the gender distribution vary across department */
select department, gender, count(*) as "No of Empployee"
from hr
where age > 18
group by 1, 2
order by count(*) desc;

/* How does the gender distribution vary across job titles */
select jobtitle, count(*) as "No of Empployee"
from hr
where age > 18
group by 1
order by count(*) desc;

/* Distribution of em[ployees across location state and city */
select location_state, count(*) as "No of Empployee"
from hr
where age > 18
group by 1
order by "No of Empployee" desc;

/* No of employee hired in each year */
select extract(year from hire_date) as year_employed, count(*)
from hr
where age > 18
group by year_employed
order by year_employed;

/* Create a new table to be used for visualization */
create table hr_cleaned as
 (select * from hr
	where age > 18);