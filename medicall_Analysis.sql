select * from dwh.medicall;
--
SELECT COUNT(*) FROM dwh.medicall;
--
SELECT * FROM dwh.medicall WHERE age IS NULL;
-----
SELECT age,
		COUNT(*) 
FROM dwh.medicall 
GROUP BY age 
HAVING COUNT(*) > 1;
----

select region ,
		sex , 
		count(*)
from dwh.medicall
where region = 'northwest' and sex = 'female'
group by region , sex 
having count(*)>1;

----

select region ,
		sex ,
		count(*)
from dwh.medicall
where region = 'southeast' and sex = 'female'
group by region , sex 
having count(*)>1;

----
select charges,
		age,
		smoker
from dwh.medicall
group by smoker,charges,age
order by charges desc;
----

select bmi, 
	   smoker, 
	   age,
	   first_value (bmi) Over (partition by age order by smoker)As first_bmi
from dwh.medicall;

--
select bmi ,
	   smoker,
	   age
from dwh.medicall
where age = 18
group by smoker,bmi,age
order by bmi desc;

----
select bmi ,
	   smoker,
	   age
from dwh.medicall
group by smoker,bmi,age
order by age desc;

----

select Avg(bmi) As average_bmi,
	   region,
	   smoker,
	   charges
from dwh.medicall
group by smoker,region,charges
order by charges desc;

----

select region , 
		count(Case when smoker = 'yes'then 1 End) As yes_smoker,
		count(Case when smoker = 'no' then 1 End) As no_smoker
from dwh.medicall
group by region
having 
	Count(Case when smoker = 'yes'then 1 End)> 0 
Or  
	Count(Case when smoker = 'no' then 1 End)> 0 ;
----

select count(children) As count_child,
		smoker,
		region
from dwh.medicall
group by smoker,region
having count(children)>0;

----

select charges,
		smoker
from dwh.medicall
group by smoker, charges
order by charges Desc;
----

select charges ,
		age,
		region,
		smoker,
		children,
		Dense_RAnk() Over (partition by children order by region ) As Rank_charges
from dwh.medicall
order by charges Desc;

----




