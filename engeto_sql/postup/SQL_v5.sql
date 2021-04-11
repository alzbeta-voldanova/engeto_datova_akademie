# join s covid_tests
SELECT distinct country FROM covid19_tests ct;
select distinct country from covid19_basic_differences cbd;

SELECT * FROM covid19_tests ct
where country = 'Czechia';

SELECT * FROM covid19_tests ct WHERE country = 'Czechia';

SELECT 
	cbd.country,
	cbd.date,
	ct.* 
FROM covid19_basic_differences cbd 
LEFT JOIN lookup_table lt 
	ON cbd.country = lt.country 
LEFT JOIN countries c 
	ON lt.iso3 = c.iso3
LEFT JOIN covid19_tests ct 
ON lt.iso3 = ct.ISO AND cbd.`date` = ct.`date`
where cbd.country = 'Czechia';


