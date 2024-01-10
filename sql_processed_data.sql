# add column called 'commute_distance_miles'
ALTER TABLE python_processed_data ADD COLUMN commute_distance_miles varchar(30);

# extract the values from the commute_distance_km column by converting the km to mi
-- SELECT 
--     commute_distance_km,
--     round((SUBSTRING_INDEX(commute_distance_km, '-', 1) * 0.6213), 4) AS first_part,
--     round((SUBSTRING_INDEX(commute_distance_km, '-', -1) * 0.6213), 4) AS last_part,
--     LENGTH(commute_distance_km) - LENGTH(REPLACE(commute_distance_km, '-', '')) + 1 AS parts_count,
--     concat(round((SUBSTRING_INDEX(commute_distance_km, '-', 1) * 0.6213), 4), '-', round((SUBSTRING_INDEX(commute_distance_km, '-', -1) * 0.6213), 4)) as COMBI, 
--     case when LENGTH(commute_distance_km) - LENGTH(REPLACE(commute_distance_km, '-', '')) + 1 = 2 
--     then concat(round((SUBSTRING_INDEX(commute_distance_km, '-', 1) * 0.6213), 4), '-', round((SUBSTRING_INDEX(commute_distance_km, '-', -1) * 0.6213), 4))
-- 	else round((SUBSTRING_INDEX(commute_distance_km, '-', 1) * 0.6213), 4) end as com_dis_mile
-- FROM python_processed_data;

# set the new values extracted from the 'commute_distance_km' to 'commute_distance_miles
UPDATE python_processed_data
SET python_processed_data.commute_distance_miles = case when LENGTH(commute_distance_km) - LENGTH(REPLACE(commute_distance_km, '-', '')) + 1 = 2 
    then concat(round((SUBSTRING_INDEX(commute_distance_km, '-', 1) * 0.6213), 2), '-', round((SUBSTRING_INDEX(commute_distance_km, '-', -1) * 0.6213), 2))
	else round((SUBSTRING_INDEX(commute_distance_km, '-', 1) * 0.6213), 2) end;
    
# move the 'commute_distance_miles' between the 'purchased_bike' and 'commute_distance_km column'
ALTER TABLE python_processed_data
MODIFY COLUMN commute_distance_miles varchar(30)
AFTER purchased_bike;

# add another column 'avg_commute_distance_miles' and put it next to 'commute_distance_miles' column
ALTER TABLE python_processed_data ADD COLUMN avg_commute_distance_miles double after commute_distance_miles;

# extract the first all the numeric values from the commute_distance_miles column
-- select commute_distance_miles, 
-- 		SUBSTRING_INDEX(commute_distance_miles, '-', 1) as first_val, 
-- 		SUBSTRING_INDEX(commute_distance_miles, '-', 1) as final_val,
-- 		((SUBSTRING_INDEX(commute_distance_miles, '-', 1) + SUBSTRING_INDEX(commute_distance_miles, '-', -1)) / 2) as average
-- from data_processed_using_python;

# set the new values for avg extracted from the 'commute_distance_miles' column
update python_processed_data
set avg_commute_distance_miles = (SUBSTRING_INDEX(commute_distance_miles, '-', 1) + SUBSTRING_INDEX(commute_distance_miles, '-', -1)) / 2;

# value of avg_commute_distance_km with only four decimal points
select round(avg_commute_distance_km, 4) from python_processed_data;

# fix the decimal points of 'avg_commute_distance_km' column to 4 decimal points only
update python_processed_data
set avg_commute_distance_km = (round(avg_commute_distance_km, 4));

# add new column called 'single_parent' put it next to 'children' column
ALTER TABLE python_processed_data ADD COLUMN single_parent varchar(5) after children;

-- BELOW IS THE CONTENT OF 'VIEW_SINGLE_PARENT', I DID THIS FOR THE SAKE OF VIEWING IT IN THE GITHUB
-- SELECT 
--         `python_processed_data`.`id` AS `id`,
--         `python_processed_data`.`gender` AS `gender`,
--         `python_processed_data`.`marital_status` AS `marital_status`,
--         `python_processed_data`.`children` AS `children`,
--         (CASE
--             WHEN
--                 ((`python_processed_data`.`marital_status` = 'Single')
--                     AND (`python_processed_data`.`children` <> 0))
--             THEN
--                 'Yes'
--             WHEN
--                 ((`python_processed_data`.`marital_status` = 'Single')
--                     AND (`python_processed_data`.`children` = 0))
--             THEN
--                 'No'
--             WHEN (`python_processed_data`.`marital_status` = 'Married') THEN 'NA'
--         END) AS `single_parent`
--     FROM
--         `python_processed_data`;

# set new values to 'single_parent' by importing the values from the view
UPDATE python_processed_data
JOIN view_single_parent ON python_processed_data.id = view_single_parent.id
SET python_processed_data.single_parent = view_single_parent.single_parent;

# add new column called 'senior_citizen'
alter table python_processed_data add column senior_citizen varchar(10) after age;

-- BELOW IS THE CONTENT OF 'VIEW_SENIOR_CITIZEN', I DID THIS FOR THE SAKE OF VIEWING IT IN THE GITHUB
-- SELECT 
--         `python_processed_data`.`id` AS `id`,
--         `python_processed_data`.`gender` AS `gender`,
--         `python_processed_data`.`occupation` AS `occupation`,
--         `python_processed_data`.`age` AS `age`,
--         (CASE
--             WHEN (`python_processed_data`.`age` >= 60) THEN 'Yes'
--             ELSE 'Not Yet'
--         END) AS `senior_citizen`
--     FROM
--         `python_processed_data`;

# put values according to the age of people using the values from the view
update python_processed_data
join view_senior_citizen on python_processed_data.id = view_senior_citizen.id
set python_processed_data.senior_citizen = view_senior_citizen.senior_citizen;

# add 'house_status' column right after the 'home_owner' column
alter table python_processed_data add column house_status varchar(20) after home_owner;

-- BELOW IS THE CONTENT OF 'VIEW_HOUSE_STATUS', I DID THIS FOR THE SAKE OF VIEWING IT IN THE GITHUB
-- SELECT 
--         `python_processed_data`.`id` AS `id`,
--         `python_processed_data`.`income` AS `income`,
--         `python_processed_data`.`home_owner` AS `home_owner`,
--         `python_processed_data`.`marital_status` AS `marital_status`,
--         (CASE
--             WHEN
--                 ((`python_processed_data`.`income` >= 70000)
--                     AND (`python_processed_data`.`home_owner` = 'Yes')
--                     AND (`python_processed_data`.`marital_status` = 'Married'))
--             THEN
--                 'Fully-Paid'
--             WHEN
--                 ((`python_processed_data`.`income` >= 60000)
--                     AND (`python_processed_data`.`home_owner` = 'Yes')
--                     AND (`python_processed_data`.`marital_status` = 'Single'))
--             THEN
--                 'Fully-Paid Solo'
--             WHEN
--                 ((`python_processed_data`.`income` < 70000)
--                     AND (`python_processed_data`.`home_owner` = 'Yes')
--                     AND (`python_processed_data`.`marital_status` = 'Married'))
--             THEN
--                 'Installment'
--             WHEN
--                 ((`python_processed_data`.`income` <= 50000)
--                     AND (`python_processed_data`.`home_owner` = 'Yes')
--                     AND (`python_processed_data`.`marital_status` = 'Single'))
--             THEN
--                 'Installment Solo'
--             WHEN (`python_processed_data`.`home_owner` = 'No') THEN 'Not Applicable'
--         END) AS `house_status`
--     FROM
--         `python_processed_data`;

# put values to the 'house_status' column
update python_processed_data
join view_house_status on python_processed_data.id = view_house_status.id
set python_processed_data.house_status = view_house_status.house_status;



# ------------- QUERIES -------------- #
# get the number of people who owns a house that is fully-paid
select count(*) count from python_processed_data where house_status = 'Fully-Paid';

# occupations that can pay full a house alone and has one or more cars
select distinct(occupation) from python_processed_data where house_status = 'Fully-Paid Solo' and cars > 0;

# get people's job and salary that is above average of the record's income
select avg(income) from python_processed_data; -- this is the avg income based from the record
select occupation, income from python_processed_data where income > (select avg(income) from python_processed_data) order by income desc;

# occupation of people who finish their education in bachelor level
select  occupation, count(*) as 'Count of People' from python_processed_data where education = 'Bachelors' group by occupation order by 2 desc;

# number of people who finished masteral and worked as professional or manager
select count(*) as Count from python_processed_data where education = 'Graduate Degree' and occupation in ('Professional', "Management");

# number of people who didn't finish high school but still worked as professional or manager
select count(*) as Count from python_processed_data where education = 'Partial High School' and occupation in ("Professional", "Management");

# which region has the most number of married man and woman
select region, gender, count(*) Count from python_processed_data where marital_status = 'Married' group by region, gender order by 3 desc;

# which region has the most number of single man and woman
select region, gender, count(*) Count from python_processed_data where marital_status = "Single" group by region, gender order by 3 desc;

# what job has the largest salary and purchased a bike?
select occupation from python_processed_data where purchased_bike = 'Yes' and income = (select max(income) from python_processed_data);

# get the number of male who are married has 2 or more children
select count(*) Count from python_processed_data where gender = 'Male' and marital_status = 'Married' and children >= 2;

# get the number of female who are married has 2 or more children
select count(*) Count from python_processed_data where gender = 'Female' and marital_status = 'Married' and children >= 2;

# get the number of female who are single but has 1 or more children
select count(*) Count from python_processed_data where marital_status = 'Single' and gender = 'Female' and children >= 1;

# most common age of women who are single and no child
select age, count(*) Count from python_processed_data where marital_status = 'Single' and children = 0 and gender = 'Female' group by age order by 2 desc limit 1;

# most common age of men who are single and no child
select age, count(*) Count from python_processed_data where marital_status = 'Single' and children = 0 and gender = 'Male' group by age order by 2 desc limit 1;

# who buys bike more, men or women
select gender, count(*) as "Buyer's Count" from python_processed_data where purchased_bike = 'Yes' group by gender order by 2 desc;

# number of professional who has no car and bike
select occupation, count(*) Count from python_processed_data where cars = 0 and purchased_bike = 'No' and occupation = 'Professional';

# people's occupation who has both car and bike
select occupation, count(*) Count from python_processed_data where cars > 0 and purchased_bike = 'Yes' group by occupation order by 2 desc;