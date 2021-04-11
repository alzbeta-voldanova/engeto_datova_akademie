# casove promenne
SELECT 
	cbd.`date`,
	CASE 
		WHEN WEEKDAY(`date`) IN (0, 1, 2, 3, 4) THEN 1
		WHEN WEEKDAY(`date`) IN (5, 6) THEN 0
		ELSE 'ERROR'
		END AS 'workday/weekday',
	CASE 
		WHEN MONTH(`date`) IN (3, 4, 5) THEN 0
		WHEN MONTH(`date`) IN (6, 7, 8) THEN 1
		WHEN MONTH(`date`) IN (9, 10, 11) THEN 2
		WHEN MONTH(`date`) IN (12, 1, 2) THEN 3
		END AS 'season'
FROM covid19_basic_differences cbd 
ORDER BY `date` DESC;


# Promenne specificke pro dany stat

SELECT DISTINCT country FROM covid19_basic_differences ORDER BY country; #189 zemi
SELECT DISTINCT country FROM lookup_table ORDER BY country; # 194 zemi
SELECT DISTINCT country FROM countries; #244 zemi
SELECT DISTINCT country FROM economies; # 264 zemi
SELECT DISTINCT country FROM covid19_tests; # 110 zemi 


# hlavni select
SELECT 
	cbd.country,
	cbd.date,
	cbd.confirmed, 
	c.population_density,
	ROUND(e.GDP/ e.population, 2) AS GDP_per_capita,
	egini.gini,
	e.mortaliy_under5,
	c.median_age_2018,
	r.religion,
	ROUND((r.population / c.population) * 100, 2) AS procentnin_podil_celkove_populace,
	le.diff_life_expectancy
FROM covid19_basic_differences cbd 
LEFT JOIN lookup_table lt 
	ON cbd.country = lt.country 
LEFT JOIN countries c 
	ON lt.iso3 = c.iso3
LEFT JOIN economies e 
	ON c.country = e.country
LEFT JOIN (SELECT 
							e2.country, 
							ROUND(AVG(e2.gini), 2) AS gini
						FROM economies e2 
						WHERE 1=1
							AND e2.`year` >= 2010 
							AND e2.`year` <= 2017 
							AND e2.gini IS NOT NULL
						GROUP BY e2.country) AS egini
	ON c.country = egini.country
LEFT JOIN religions r
	ON c.country = r.country
LEFT JOIN (SELECT 
							l1.iso3,
							l1.life_expectancy - l2.life_expectancy AS diff_life_expectancy
						FROM life_expectancy l1 
						LEFT JOIN life_expectancy l2 
							ON l1.iso3 = l2.iso3 
						WHERE 1=1
							AND l1.`year` = 2015
							AND l2.`year` = 1965) AS le
	ON lt.iso3 = le.iso3	
WHERE 1=1
	AND lt.province IS NULL
	AND e.`year` = 2019
	AND r.`year` = 2020
	AND cbd.country IN ('Czechia', 'US')
	AND cbd.`date` >= '2020-10-01' AND cbd.`date` < '2020-11-01'
;


SELECT DISTINCT iso3, iso2 FROM lookup_table;
SELECT DISTINCT ISO FROM covid19_tests;
SELECT DISTINCT iso3 FROM life_expectancy ORDER BY iso3;



