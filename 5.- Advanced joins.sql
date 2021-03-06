-- Retrieve most recent animal vaccinations (3)
-- This is what we logically need, but it doesn't work
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		CROSS JOIN 
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY
		) AS Last_Vaccinations
ORDER BY 	A.Name, 
			Vaccination_Time;

/* PostgreSQL:
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		CROSS JOIN LATERAL
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			LIMIT 3 OFFSET 0
		) AS Last_Vaccinations
ORDER BY 	A.Name, 
			Vaccination_Time;


SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		LEFT OUTER JOIN LATERAL
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			LIMIT 3 OFFSET 0
		) AS Last_Vaccinations
			ON TRUE
ORDER BY 	A.Name, 
			Vaccination_Time;
*/

-- CROSS APPLY
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		CROSS APPLY
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
		) AS Last_Vaccinations
ORDER BY 	A.Name, 
			Vaccination_Time;

-- OUTER APPLY
SELECT	A.Name,
		A.Species,
		A.Primary_Color,
		A.Breed,
		Last_Vaccinations.*
FROM	Animals AS A
		OUTER APPLY
		(
			SELECT	V.Vaccine, 
					V.Vaccination_Time
			FROM	Vaccinations AS V
			WHERE	V.Name = A.Name
					AND
					V.Species = A.species
			ORDER BY V.Vaccination_Time DESC
			OFFSET 0 ROWS FETCH NEXT 3 ROW ONLY
		) AS Last_Vaccinations
ORDER BY 	A.Name, 
			Vaccination_Time;

-- Invocation wisdom
-- PostgreSQL
/*
SELECT	* 
FROM	Staff AS S 
		CROSS JOIN LATERAL 
		(SELECT random() AS Y) AS B;

SELECT	* 
FROM	Staff AS S 
		CROSS JOIN LATERAL 
		(SELECT random() AS Y WHERE S.Email IS NOT NULL) AS B;

SELECT	*, random()
FROM	Staff;
*/

-- SQL Server
SELECT	* 
FROM	Staff AS S
		CROSS APPLY
		(SELECT RAND() AS Y WHERE S.Email IS NOT NULL) AS B;

SELECT	RAND() AS 'Random???'
FROM	Staff;

SELECT	* 
FROM	Staff AS S 
		CROSS APPLY
		(SELECT NEWID() AS Y) AS B;






-- Find purebred candidates of the same species and breed - Solution with > shortcut 
-- 	  !!! Only works if collation is dictionary based, and if case insensitive or casing is consistent !!!
SELECT	A1.Species,
		A1.Breed AS Breed,
		A1.Name AS Male,
		A2.Name AS Female
FROM	Animals AS A1
		INNER JOIN
		Animals AS A2
		ON	A1.Species = A2.Species
			AND
			A1.Breed = A2.Breed -- Removes NULL breeds
			AND
			A1.Name <> A2.Name
			AND
			A1.Gender > A2.Gender
ORDER BY 	A1.Species, 
			A1.Breed;
