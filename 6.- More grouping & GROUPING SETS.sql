-- String aggregate
SELECT	Adoption_Date,
		SUM(Adoption_Fee) AS Total_Fee,
		STRING_AGG(CONCAT(Name, ' the ',  Species), ', ') 
		WITHIN GROUP (ORDER BY Species, Name) AS Adopted_Animals
FROM	Adoptions
GROUP BY Adoption_Date
HAVING	COUNT(*) > 1;

/* PostgreSQL STRING_AGG is not an ordered set function as there is no order...
SELECT	Adoption_Date,
		SUM(Adoption_Fee) AS Total_Fee,
		STRING_AGG(CONCAT(Name, ' the ',  Species), ', ') AS Adopted_Animals
FROM	Adoptions
GROUP BY Adoption_Date
HAVING	COUNT(*) > 1;
*/

-- Beware of NULL concatenation
SELECT	'X' + NULL, 
		CONCAT('X', NULL);

/* PotgreSQL
-- Beware of NULL concatenation
SELECT	'X' || NULL, 
		CONCAT('X', NULL);
*/

-- Add breed to animal's string description
SELECT	Adoption_Date,
		SUM(Adoption_Fee) AS Total_Fee,
		STRING_AGG(CONCAT(AN.Name, ' the ',  AN.Breed, ' ', AN.Species), ', ')
		WITHIN GROUP (ORDER BY AN.Species, AN.Breed, AN.Name) AS Using_CONCAT,
		STRING_AGG(AN.Name + ' the ' +  AN.Breed + ' ' + AN.Species, ', ')
		WITHIN GROUP (ORDER BY AN.Species, AN.Breed, AN.Name) AS Using_Plus
FROM	Adoptions AS AD
		INNER JOIN
		Animals AS AN
			ON 	AN.Name = AD.Name 
				AND 
				AN.Species = AD.Species
GROUP BY Adoption_Date
HAVING	COUNT(*) > 1;

-- Hypothetical set and inverse distribution functions
/* PostgreSQL
WITH Vaccination_Ranking
AS
(
SELECT	Name, 
		Species,
		COUNT(*) AS Number_Of_Vaccinations
FROM	Vaccinations
GROUP BY Name, Species
)
SELECT  Species,
        MAX(Number_Of_Vaccinations) AS MAX_Vaccinations,
        MIN(Number_Of_Vaccinations) AS MIN_Vaccinations,
        CAST(AVG(Number_Of_Vaccinations) AS DECIMAL(9,2)) AS AVG_Vaccinations,
        DENSE_RANK(5)	
		WITHIN GROUP (ORDER BY Number_Of_Vaccinations DESC) AS How_Would_X_Rank,
        PERCENT_RANK(5) 
		WITHIN GROUP (ORDER BY Number_Of_Vaccinations DESC) AS How_Would_X_Rank_Percent_Wise,
        PERCENTILE_CONT(0.333) 
		WITHIN GROUP (ORDER BY Number_Of_Vaccinations DESC) AS Inverse_Continous,
        PERCENTILE_DISC(0.333) 
		WITHIN GROUP (ORDER BY Number_Of_Vaccinations DESC) AS Inverse_Discrete
FROM    Vaccination_Ranking
GROUP BY Species;





-- Multi level aggregates
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date), MONTH(Adoption_Date);

SELECT	YEAR(Adoption_Date) AS Year,
		COUNT(*) AS Annual_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date);

SELECT	COUNT(*) AS Total_Adoptions
FROM	Adoptions
GROUP BY ();

-- Add UNION ALL... no good
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Number_Of_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date), MONTH(Adoption_Date)
UNION ALL
SELECT	YEAR(Adoption_Date) AS Year,
		COUNT(*) AS Annual_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date)
UNION ALL
SELECT	COUNT(*) AS Total_Adoptions
FROM	Adoptions
GROUP BY ();

-- Try string placeholders... no good
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Number_Of_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date), MONTH(Adoption_Date)
UNION ALL
SELECT	YEAR(Adoption_Date) AS Year,
		'All Months' AS Month,
		COUNT(*) AS Annual_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date)
UNION ALL
SELECT	'All Years' AS Year,	
		'All Months' AS Month,
		COUNT(*) AS Total_Adoptions
FROM	Adoptions
GROUP BY ()
ORDER BY Year, Month;

-- Use NULL placeholders... very good!
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date), MONTH(Adoption_Date)
UNION ALL
SELECT	YEAR(Adoption_Date) AS Year,
		NULL AS Month,
		COUNT(*) AS Annual_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date)
UNION ALL
SELECT	NULL AS Year,	
		NULL AS Month,
		COUNT(*) AS Total_Adoptions
FROM	Adoptions
GROUP BY ()
ORDER BY Year, Month;

-- Reuse lowest granularity aggregate in WITH clause
WITH Aggregated_Adoptions
AS
(
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY YEAR(Adoption_Date), MONTH(Adoption_Date)
)
SELECT	*
FROM	Aggregated_Adoptions
UNION ALL
SELECT	Year,
		NULL,
		COUNT(*)
FROM	Aggregated_Adoptions
GROUP BY Year
UNION ALL
SELECT	NULL,
		NULL,
		COUNT(*)
FROM	Aggregated_Adoptions
GROUP BY ();


/* PostgreSQL
-- Reuse lowest granularity aggregate in WITH clause
WITH Aggregated_Adoptions
AS
(
SELECT	EXTRACT(year FROM Adoption_Date) AS Year,
		EXTRACT(month FROM Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY EXTRACT(year FROM Adoption_Date) , EXTRACT(month FROM Adoption_Date)
)
SELECT	*
FROM	Aggregated_Adoptions
UNION ALL
SELECT	Year,
		NULL,
		COUNT(*)
FROM	Aggregated_Adoptions
GROUP BY Year
UNION ALL
SELECT	NULL,
		NULL,
		COUNT(*)
FROM	Aggregated_Adoptions
GROUP BY ();
*/

-- GROUPING SETS
-- Equivalent to no GROUP BY
SELECT	COUNT(*) AS Total_Adoptions
FROM	Adoptions
GROUP BY GROUPING SETS	
		(
			()
		);

-- Equivalent to GROUP BY YEAR(Adoption_Date)
SELECT	YEAR(Adoption_Date) AS Year,
		COUNT(*) AS Annual_Adoptions
FROM	Adoptions
GROUP BY GROUPING SETS	
		(
			YEAR(Adoption_Date)
		)
ORDER BY Year;

-- Equivalent to GROUP BY YEAR(Adoption_Date), MONTH(Adoption_Date)
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY GROUPING SETS	
		(
			(
				YEAR(Adoption_Date), MONTH(Adoption_Date)
			)
		)
ORDER BY Year, Month;

-- Be careful with the parentheses!
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY GROUPING SETS	
		(
			YEAR(Adoption_Date), MONTH(Adoption_Date)
		)
ORDER BY Year, Month;

-- All in one...
SELECT	YEAR(Adoption_Date) AS Year,
		MONTH(Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY GROUPING SETS	
		(
			(YEAR(Adoption_Date), MONTH(Adoption_Date)),
			YEAR(Adoption_Date),
			()
		)
ORDER BY Year, Month;

/* PostgreSQL
-- All in one...
SELECT	EXTRACT(year FROM Adoption_Date) AS Year,
		EXTRACT(month FROM Adoption_Date) AS Month,
		COUNT(*) AS Monthly_Adoptions
FROM	Adoptions
GROUP BY GROUPING SETS	
		(
			(EXTRACT(year FROM Adoption_Date), extract(month FROM Adoption_Date)),
			EXTRACT(year FROM Adoption_Date),
			()
		)
ORDER BY Year, Month;
*/

-- Non hierarchical grouping sets
SELECT	YEAR(Adoption_Date) AS Year,
		Adopter_Email,
		COUNT(*) AS Annual_Adoptions
FROM	Adoptions
GROUP BY GROUPING SETS	
		(
			YEAR(Adoption_Date),
			Adopter_Email
		);

-- Handling NULLs
SELECT	COALESCE(Species, 'All') AS Species,
		CASE 
			WHEN GROUPING(Breed) = 1
			THEN 'All'
			ELSE Breed
		END AS Breed,
		GROUPING(Breed) AS Is_This_All_Breeds,
		COUNT(*) AS Number_Of_Animals
FROM	Animals
GROUP BY GROUPING SETS 
		(
			Species,
			Breed,
			()
		)
ORDER BY Species, Breed;











-- Must use the GROUPING function to distinguish "All staff" from individuals
SELECT	COALESCE(CAST(YEAR(V.Vaccination_Time) AS VARCHAR(10)), 'All Years') AS Year,
		COALESCE(V.Species, 'All Species') AS Species,
		COALESCE(V.Email, 'All Staff') AS Email,
		CASE WHEN GROUPING(V.Email) = 0
			THEN MAX(P.First_Name) -- Dummy aggregate
			ELSE ''
			END AS First_Name,
		CASE WHEN GROUPING(V.Email) = 0
			THEN MAX(P.Last_Name) -- Dummy aggregate
			ELSE ''
			END AS Last_Name,
		COUNT(*) AS Number_Of_Vaccinations,
		MAX(YEAR(V.Vaccination_Time)) AS Latest_Vaccination_Year
FROM	Vaccinations AS V
		INNER JOIN
		Persons AS P
			ON P.Email = V.Email
GROUP BY GROUPING SETS	(
							(),
							YEAR(V.Vaccination_Time),
							V.Species,
							(YEAR(V.Vaccination_Time), V.Species),
							(V.Email),
							(V.Email, V.Species)
						)
ORDER BY Year, Species, First_Name, Last_Name;

/* PostgreSQL
SELECT	COALESCE(CAST(EXTRACT(YEAR FROM V.Vaccination_Time) AS VARCHAR(10)), 'All Years') AS Year,
		COALESCE(V.Species, 'All Species') AS Species,
		COALESCE(V.Email, 'All Staff') AS Email,
		CASE WHEN GROUPING(V.Email) = 0
			THEN MAX(P.First_Name) -- Dummy aggregate
			ELSE ' '
			END AS First_Name,
		CASE WHEN GROUPING(V.Email) = 0
			THEN MAX(P.Last_Name) -- Dummy aggregate
			ELSE ' '
			END AS Last_Name,
		COUNT(*) AS Number_Of_Vaccinations,
		MAX(EXTRACT(YEAR FROM V.Vaccination_Time)) AS Latest_Vaccination_Year
FROM	Vaccinations AS V
		INNER JOIN
		Persons AS P
			ON P.Email = V.Email
GROUP BY GROUPING SETS	(
							(),
							EXTRACT(YEAR FROM V.Vaccination_Time),
							V.Species,
							(EXTRACT(YEAR FROM V.Vaccination_Time), V.Species),
							(V.Email),
							(V.Email, V.Species)
						)
ORDER BY Year, V.Species NULLS FIRST, First_Name, Last_Name;
*/
