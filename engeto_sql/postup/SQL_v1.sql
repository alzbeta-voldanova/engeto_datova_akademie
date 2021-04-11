SELECT * FROM countries;
SELECT * FROM economies;
SELECT * FROM life_expectancy;
SELECT * FROM religions;
SELECT * FROM covid19_tests;
SELECT * FROM covid19_basic_differences;
SELECT * FROM weather;
SELECT * FROM lookup_table;


# 1. casove promenne
# 	A) binarni promenna pro vikend/ pracovni den 
# 		pracovni den = 1
#			vikend = 0
SELECT 
	DISTINCT `date`,
	CASE 
		WHEN WEEKDAY(`date`) IN (0, 1, 2, 3, 4) THEN 1
		WHEN WEEKDAY(`date`) IN (5, 6) THEN 0
		ELSE 'ERROR'
		END AS 'workday_1/weekday_0'
FROM covid19_basic_differences cbd 
ORDER BY `date` DESC;

#		B) rocni obdobi - meteorologické ro?ní období
#			jaro = 0		; 1. brezna - 31. kvetna
#			leto = 1		;	1. cervna - 31. srpna
#			podzim = 2	;	1. zari - 30. listopadu	
#			zima = 3		;	1. prosince - 28. unora (29.unora)
# 	období	m?síce

SELECT 
	DISTINCT `date`, 
	CASE 
		WHEN MONTH(`date`) IN (3, 4, 5) THEN 0
		WHEN MONTH(`date`) IN (6, 7, 8) THEN 1
		WHEN MONTH(`date`) IN (9, 10, 11) THEN 2
		WHEN MONTH(`date`) IN (12, 1, 2) THEN 3
		END AS 'season'
FROM covid19_basic_differences cbd 
;


# 2. Promenne specificke pro dany stat
#		A) hustota zalidneni - ve statech s vyssi hustotou zalidneni se nakaza muze sirit rychleji
				# country - 244 radku
SELECT 
	DISTINCT country, 
	population_density
FROM countries
ORDER BY country;

#		B) HDP na obyvatele - pouzijeme jako indikator ekonomicke vyspelosti statu
			# vybrat pouze zeme - shodne s tabulkou countries nebo look up table, nebo covid basic diff
			# hdp - pouze za rok 2019 - nejaktualnejsi data, rok 2020 uz v tabulce economies neni
			
SELECT 
	country,
	`year`, 
	population, 
	GDP,
	ROUND(GDP/ population, 2) 
FROM economies
WHERE `year` = 2015 AND country = 'United States';

SELECT DISTINCT country FROM economies;
SELECT DISTINCT country, gini FROM economies;
SELECT * FROM economies;

#		C) GINI koeficient - ma majetkova nerovnost vliv na sireni koronaviru?
# nejednotnost dat, nejaktualnejsi hodnoty gini z roku 2018, ale pouze pro maly pocet zemi
# -> proto kompromis mezi presnosti a obsazenosti tabulky -> AVG(gini) z let 2010 - 2017
SELECT 
	country,
	gini 
FROM economies
where `year` = 2018 or year = 2017 and gini is not null
order by country;


SELECT COUNT(1) FROM economies WHERE `year` = 2017 AND GINI IS NOT NULL;
SELECT COUNT(1) FROM economies WHERE `year` = 2016 AND GINI IS NOT NULL;
SELECT COUNT(1) FROM economies WHERE `year` = 2015 AND GINI IS NOT NULL;
SELECT COUNT(1) FROM economies WHERE `year` = 2014 AND GINI IS NOT NULL;
SELECT COUNT(1) FROM economies WHERE `year` = 2013 AND GINI IS NOT NULL;
SELECT COUNT(1) FROM economies WHERE `year` = 2012 AND GINI IS NOT NULL;
SELECT COUNT(1) FROM economies WHERE `year` = 2011 AND GINI IS NOT NULL;
SELECT COUNT(1) FROM economies WHERE `year` = 2010 AND GINI IS NOT NULL;

SELECT distinct country FROM economies e 
WHERE `year` >=2010 AND `year` <=2017 AND gini IS NOT NULL;

SELECT country, ROUND(AVG(gini), 2) FROM economies e2 
WHERE 1=1
AND `year` >= 2010 
AND `year` <= 2017 
AND gini IS NOT NULL
GROUP BY country;


#		D) detska umrtnost - pouzijeme jako indikator kvality zdravotnictvi
SELECT 
	country,
	`year`, 
	mortaliy_under5 
FROM economies;

SELECT distinct country FROM economies e 
WHERE `year` = 2019
AND mortaliy_under5 IS NULL;

#		E) median veku obyvatel v roce 2018 - staty se starsim obyvatelstvem mohou byt postizeny vice
SELECT country, median_age_2018 FROM countries
ORDER BY median_age_2018 DESC;


#		F) podily jednotlivych nabozenstvi - pouzijeme jako proxy promennou pro kulturni specifika. 
#				Pro kazde nabozenstvi v danem state bych chtel procentni podil jeho prislusniku na celkovem obyvatelstvu
SELECT 
	*
FROM religions
WHERE country = 'Czech Republic'
AND `year` = 2020;

SELECT DISTINCT country FROM religions;

SELECT 
	c.country, 
	r.religion,
	c.population,
	r.population, 
	ROUND((r.population / c.population) * 100, 2) AS procentnin_podil_celkove_populace 
FROM countries c
LEFT JOIN religions r
ON c.country = r.country 
WHERE r.`year` = 2020
;

# Celkova populace casto nizsi nez prevazujici nabozenstvi -> soucet populace u nabozenstvi?
SELECT * FROM religions r 
WHERE country != 'All Countries'
AND `year` = 2020
ORDER BY country;

#		G) rozdil mezi ocekavanou dobou doziti v roce 1965 a v roce 2015 - staty, ve kterych probehl rychly rozvoj mohou reagovat jinak 
#		nez zeme, ktere jsou vyspele uz delsi dobu
SELECT * FROM life_expectancy;

SELECT DISTINCT iso3 FROM lookup_table lt;
SELECT DISTINCT iso3 FROM life_expectancy;

SELECT country, iso3, population FROM lookup_table WHERE province IS NULL;

SELECT 
	l1.iso3,
	l1.life_expectancy - l2.life_expectancy 
FROM life_expectancy l1 
LEFT JOIN life_expectancy l2 ON l1.iso3 = l2.iso3 
WHERE 1=1
	AND l1.`year` = 2015
	AND l2.`year` = 1965;

SELECT iso3, life_expectancy 
FROM life_expectancy le 
WHERE iso3  = 'CZE' AND `year` IN (1965, 2015);


#  Pocasi (ovlivnuje chovani lidi a take schopnost sireni viru)
			# SEZNAM MEST A ZEMI PRIHODIT 
#			prumerna denni (nikoli nocni!) teplota
# 					DENNI TEPLOTA - prumer hodnot mezi 9. a 18. hodinou 
#			pocet hodin v danem dni, kdy byly srazky nenulove
#			maximalni sila vetru v narazech behem dne - gust = naraz
SELECT * FROM weather;
SELECT MAX(`date`), MIN(`date`) FROM covid19_basic_differences; #2021-04-06, 2020-01-22
SELECT DISTINCT city FROM weather w2 WHERE `date`>= '2020-01-22';


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
		GROUP BY w.city, w.`date`
;		

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

# kontrola
SELECT *
FROM weather w 
WHERE city = 'Brussels' AND `date` = '2020-02-20';