SELECT 
	cbd.country,
	cbd.date,
	CASE 
		WHEN WEEKDAY(cbd.`date`) IN (0, 1, 2, 3, 4) THEN 1
		WHEN WEEKDAY(cbd.`date`) IN (5, 6) THEN 0
		ELSE 'ERROR'
		END AS 'workday/weekday',
	CASE 
		WHEN MONTH(cbd.`date`) IN (3, 4, 5) THEN 0
		WHEN MONTH(cbd.`date`) IN (6, 7, 8) THEN 1
		WHEN MONTH(cbd.`date`) IN (9, 10, 11) THEN 2
		WHEN MONTH(cbd.`date`) IN (12, 1, 2) THEN 3
		END AS 'season',
	cbd.confirmed,
	ct.tests_performed, 
	c.population_density,
	ROUND(e.GDP/ e.population, 2) AS GDP_per_capita,
	egini.gini,
	e.mortaliy_under5,
	c.median_age_2018,
	r.religion,
	ROUND((r.population / c.population) * 100, 2) AS percent_relig_popul,
	le.diff_life_expectancy,
	ww.avg_day_temp,
	ww.rain_24h,
	ww.gust_wind
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
LEFT JOIN (SELECT 
							(CASE
								WHEN wt.city='Athens' THEN 'Athenai'
								WHEN wt.city='Brussels' THEN 'Bruxelles [Brussel]'
								WHEN wt.city='Bucharest' THEN 'Bucuresti'
								WHEN wt.city='Helsinki' THEN 'Helsinki [Helsingfors]'
								WHEN wt.city='Kiev' THEN 'Kyiv'
								WHEN wt.city='Lisbon' THEN 'Lisboa'
								WHEN wt.city='Luxembourg' THEN 'Luxembourg [Luxemburg/L'
								WHEN wt.city='Prague' THEN 'Praha'
								WHEN wt.city='Rome' THEN 'Roma'
								WHEN wt.city='Vienna' THEN 'Wien'
								WHEN wt.city='Warsaw' THEN 'Warszawa'
								ELSE wt.city END) AS city,
							wt.`date`,
							wt.avg_day_temp,
							wr.rain_24h,
							wr.gust_wind
						FROM 
								(SELECT 
										w1.city, 
										w1.`date`, 
										ROUND(AVG(w1.temp), 2) AS avg_day_temp
									FROM weather w1
									WHERE 1=1
										AND w1.`hour` IN (9,12,15,18)
										AND w1.`date`>= '2020-01-22'
									GROUP BY w1.city, w1.`date`) AS wt
						INNER JOIN
								(SELECT 
										w2.city, 
										w2.`date`, 
										SUM(CASE WHEN w2.rain > 0 THEN 3 ELSE 0 END) AS rain_24h,
										MAX(w2.gust) AS gust_wind
								FROM weather w2
								WHERE 1=1
									AND w2.`date`>= '2020-01-22'
								GROUP BY w2.city, w2.`date`) AS wr
							ON wt.city = wr.city AND wt.`date` = wr.`date`) AS ww
	ON cbd.`date` = ww.date 
		AND c.capital_city = ww.city
LEFT JOIN covid19_tests ct 
	ON lt.iso3 = ct.ISO 
		AND cbd.`date` = ct.`date`
WHERE 1=1
	AND lt.province IS NULL
	AND e.`year` = 2019
	AND r.`year` = 2020
; 

