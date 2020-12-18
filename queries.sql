--Question 1-What effect does the background education (specifically post-secondary degree) of the startup members have on the success of the start-up?

--Label 1
--This view is used to combine the information from people, degree and startup tables and get affiliation_name of the company that the members work in, degree type, entity_id and person_id

create view degreeType as 
select distinct c.person_id,c.affiliation_name,degree_type,entity_id 
from startups, people as c, degrees 
where c.person_id=degrees.person_id and startups.affiliation_name=c.affiliation_name;

--Label 2
--This view is used to get the total amount of money invested in each company from different funding rounds. 

create view companyInvestment as 
select entity_id, sum(raised_amount_usd) 
from fundingrounds group by entity_id;

--Label 3
--This query is used to calculate the average money invested in companies

select avg(sum) from companyInvestment;

--Label 4
--This view is used to combine the information about the amount of money invested in a company and the people that work in the company.

create view inter as select  distinct c.person_id,c.affiliation_name,c.degree_type, t.sum as Investment from degreetype as c, companyInvestment as t where t.entity_id=c.entity_id;


--Label 5
--This view categorizes companies based on how much money was invested in the company. If the amount of money invested in the company is greater than  $18673046, then this company is categorized as "Above average" and if the money invested is less than $18673046 then this company is categorized as "Below average". 

create view AboveBelowAverage as 
SELECT person_id,affiliation_name,degree_type,Investment,
CASE
    WHEN Investment >'18673046.3094463' THEN 'Above Average'
    WHEN Investment<'18673046.3094463' THEN 'Below Average'
END AS Success
FROM inter ORDER BY degree_type,Success;




--Label 6
select degree_type,count(success) as people,success from AboveBelowAverage  group by degree_type,success having count(*)>5;
----------------------------------------------------------------------------------

--EXTENSION QUESTIONS --

--1. Which post-secondary majors lead to the greatest number of successful startups
--Label 7
--This view is used to combine the information from people, degree and startup tables and get affiliation_name of the company that the members work in, degree subject, entity_id and person_id

create view degreeType2 as 
select distinct c.person_id,c.affiliation_name,subject,entity_id 
from startups, people as c, degrees where c.person_id=degrees.person_id and startups.affiliation_name=c.affiliation_name;

--Label 8
--This view is used to get the total amount of money invested in each company from different funding rounds. 

create view companyInvestment2 as 
select entity_id, sum(raised_amount_usd) 
from fundingrounds 
group by entity_id;

--Label 9
--This view is used to combine the information about the amount of money invested in a company and the people that work in the company.

create view inter2 as 
select  distinct c.person_id,c.affiliation_name,c.subject, t.sum as Investment 
from degreetype2 as c, companyInvestment2 as t where t.entity_id=c.entity_id;

--Label 10
--This view categorizes companies based on how much money was invested in the company. If the amount of money invested in the company is greater than  $18673046, then this company is categorized as "Above average" and if the money invested is less than $18673046 then this company is categorized as "Below average". 


create view AboveBelowAverage2 as 
SELECT person_id,affiliation_name,subject,Investment,
CASE
    WHEN Investment >'18673046.3094463' THEN 'Above Average'
    WHEN Investment<'18673046.3094463' THEN 'Below Average'
END AS Success
FROM inter2 ORDER BY subject,Success;


--Label 11
--This query is used to get the startups that are above average and combine it with the number of members with a certain post-secondary major 

select subject,count(success) as numberOfPeople,success
from AboveBelowAverage2 where success='Above Average'
group by subject,success having count(*)>3 order by numberOfPeople;

--Question 2-What aspects(city,company type) lead to a successful start-up capable of being acquired?

--Label 13
--This query is used to find the number of startups acquired based on the city the startup was founded in

select city,count(city) as NumOfPeople
from offices as o,startups
where o.entity_id=startups.entity_id and  status='acquired' group by city having count(*)>3 order by NumOfPeople;

--Label 14
--This query is used to find number of startups acquired based on the category_code of the startup

select category_code,count(category_code) as NumOfPeople
from offices as o,startups
where o.entity_id=startups.entity_id and  status='acquired'
group by category_code
order by NumOfPeople;

----------------------------------------------------------------------------------

--EXTENSION QUESTIONS --
--1. What aspects(city, company type) led to a closure of a start-up?


--Label 15
--This query is used to find the number of startups closed down based on the city the startup was founded in
select city,count(city) as NumOfPeople
from offices as o,startups
where o.entity_id=startups.entity_id and  status='closed' group by city having count(*)>2 order by NumOfPeople;


--Label 16
--This query is used to find number of startups closed down based on the category_code of the startup

select category_code,count(category_code) 
from offices as o,startups 
where o.entity_id=startups.entity_id and  status='closed' 
group by category_code 
order by count;


--Question 3 - Which investors consistently make the right decisions to invest in startups that ended up being successful?

--Label 17
--The startups that had an IPO, essentially the startups who were "successful"

create view success_ipos as select entity_id from ipos;

--Label 18
--All the startups where they were acquired 
create view acq_startups as select entity_id from startups where status = 'acquired';

--Label 19
--All the startups that were either acquired or have an IPO

create view total_success as (select * from acq_startups) union (select * from success_ipos);


--Label 20
--The investors that had invested any money into the successful startups

create view success_investor as select * from total_success natural join investments;


--Label 21
--The investors, startups, and the amount that the investors invested into the startups at various funding rounds

create view invest_funding as select success_investor.entity_id, fundingrounds.funding_round_id, fundingrounds.funded_at, fundingrounds.raised_amount_usd, success_investor.investor_object_id from fundingrounds natural join success_investor;

--Label 22
--Grouping by the investors, finding the investors, the amount of "successful" startups they invested, as well as how much money was invested

create view finalq3 as select investor_object_id, count(entity_id), sum(raised_amount_usd) from invest_funding group by investor_object_id order by count desc;

--Label 23
--The investors, as well as the investor name

create view finalq3_names as select finalq3.investor_object_id, finalq3.count, finalq3.sum,startups.affiliation_name from finalq3, startups where finalq3.investor_object_id = startups.entity_id order by count desc;

--Label 24
--The investor, investor name, the amount of successful startups they invested in, and total amount invested

select * from finalq3_names;

----------------------------------------------------------------------------------

--EXTENSION QUESTIONS --

--1. What is the total amount of money invested in startups that were acquired or had an IPO?
--Label 25
--The total amount of money invested in successful startups

select sum(sum) from finalq3_names;

----------------------------------------------------------------------------------

--2. What is the average amount of money invested in startups that ended up closing?
--Label 26
--All the entities from startups where it only lists the startups, and not investors, or people

create view all_startups as select entity_id from startups where entity_id like 'c%';

--Label 27
--All the startups who didn't go public, or who haven't gone public yet

create view non_public as (select * from all_startups) except (select * from success_ipos);

--Label 28
--All the startups where they closed 

create view closed_startups as select entity_id from startups where status = 'closed';

--Label 29
--All the startups that closed, and did not go public at all

create view c_not_p as (select * from closed_startups) except (select * from success_ipos);

--Label 30
--All the closed startups, as well as the investors that invested in them

create view invest_closed_startups as select * from c_not_p natural join investments;

--Label 31
--The closed startup, and the total amount of money that was invested in their startup

create view closed_sum as select entity_id, sum(raised_amount_usd) from invest_closed_startups natural join fundingrounds group by entity_id;

--Label 31
select * from closed_sum;

--Label 32
--Average amount invested in a startup that eventually closed

select avg(sum) as average_invested from closed_sum;

----------------------------------------------------------------------------------

--3. Which investors consistently invested in "failed" startups?
--Label 33
--Startups that were closed, and the investors that invested in them


create view closed_inv_name as select i.entity_id, i.investor_object_id, s.affiliation_name from invest_closed_startups as i, startups as s where i.investor_object_id = s.entity_id;

--Label 34
--The investors, and the amount of failed startups they invested in

create view inv_name_count as select affiliation_name, count(*) as num_failed_investments from closed_inv_name group by affiliation_name order by num_failed_investments desc;

--Label 35
select * from inv_name_count;



