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


# weather
SELECT 
	wt.city,
	wt.date,
	wt.avg_day_temp,
	wr.rain_24h,
	wr.gust_wind
FROM 
		(SELECT 
				city, 
				`date`, 
				ROUND(AVG(temp), 2) AS avg_day_temp
			FROM weather
			WHERE 1=1
				AND `hour` IN (9,12,15,18)
				AND `date`>= '2020-01-22'
			GROUP BY city, `date`) AS wt
INNER JOIN
		(SELECT 
				city, 
				`date`, 
				SUM(CASE WHEN rain > 0 THEN 3 ELSE 0 END) AS rain_24h,
				MAX(gust) AS gust_wind
		FROM weather
		WHERE 1=1
			AND `date`>= '2020-01-22'
		GROUP BY city, `date`) AS wr
	ON wt.city = wr.city AND wt.`date` = wr.`date`
;

SELECT 
			(CASE
					WHEN w.city='Athens' THEN 'Athenai'
					WHEN w.city='Brussels' THEN 'Bruxelles [Brussel]'
					WHEN w.city='Bucharest' THEN 'Bucuresti'
					WHEN w.city='Helsinki' THEN 'Helsinki [Helsingfors]'
					WHEN w.city='Kiev' THEN 'Kyiv'
					WHEN w.city='Lisbon' THEN 'Lisboa'
					WHEN w.city='Luxembourg' THEN 'Luxembourg [Luxemburg/L'
					WHEN w.city='Prague' THEN 'Praha'
					WHEN w.city='Rome' THEN 'Roma'
					WHEN w.city='Vienna' THEN 'Wien'
					WHEN w.city='Warsaw' THEN 'Warszawa'
					ELSE w.city END) AS city,
					w.`date`,
					ROUND(AVG(w.temp), 2) AS avg_day_temp
		FROM weather w
		WHERE w.`date`>= '2020-01-22'
		GROUP BY w.city, w.`date`;










