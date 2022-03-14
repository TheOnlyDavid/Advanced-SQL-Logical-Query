-- The right way - Set Operators
SELECT	Name, Species
FROM	Animals
EXCEPT	
SELECT	Name, Species
FROM	Adoptions;

-- Animals that were adopted and vaccinated at least twice
SELECT	Name, Species
FROM	Adoptions
INTERSECT
SELECT	Name, Species
FROM	Vaccinations
GROUP BY Name, Species
HAVING	COUNT(*) > 1;

-- The elegant solution, Breeds that were never adopted
SELECT	Species, Breed
FROM	Animals
EXCEPT	
SELECT	AN.Species, AN.Breed 
FROM	Animals AS AN
		INNER JOIN
		Adoptions AS AD
		ON	AN.Species = AD.Species
			AND
			AN.Name = AD.Name;
