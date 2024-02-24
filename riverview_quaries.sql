USE Riverview
GO

--1)	What Phone Number contain the group of numbers 87 next to each other? (Owner table)
SELECT O.Phone
FROM OwnerODS O
WHERE O.Phone LIKE '%87%'
OR O.Phone LIKE '%78%'

--2)	What animals have not had a visit?
SELECT A.AnimalID, COUNT(V.VisitID) AS numofvisits
FROM ((OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID) 
	FULL OUTER JOIN VisitODS V ON A.AnimalID = V.AnimalID)
GROUP BY A.AnimalID
HAVING COUNT(V.VisitID) = 0

--3)	Who is our best customer based on how much they have spent and paid?  Only show the amount if it is over $500
SELECT TOP 1 O.OwnerID, SUM(B.InvoiceAmt) AS amt
FROM ((OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID) 
	INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID) INNER JOIN BillingODS B ON V.VisitID = B.VisitID
WHERE B.InvoicePaid != 0 
GROUP BY O.OwnerID
ORDER BY SUM(B.InvoiceAmt) DESC

--4)	What dogs were born between 1/1/2013 and 12/31/2014, have an Animal Breed name that ends in “d”?  Include Animal Name, Animal Breed, and Birth Year
SELECT A.AnimalName, A.AnimalBreed, YEAR(A.AnimalBirthDate) AS Birthyear
FROM AnimalODS A
WHERE A.AnimalBirthDate > '20130101' AND A.AnimalBirthDate < '20141231'
AND A.AnimalType = 'Dog'
AND A.AnimalBreed LIKE '%d'

--5)	Who owns the youngest animal?
SELECT TOP 1 O.FirstName, O.LastName, A.AnimalName, A.AnimalBirthDate
FROM OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID
ORDER BY A.AnimalBirthDate DESC
-- Richie Upton does.

--6)	What city has the most animals?
SELECT TOP 1 O.City, COUNT(A.AnimalID) AS numofanimals
FROM OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID
GROUP BY O.City
ORDER BY numofanimals DESC
-- Cody does.

--7)	What is our chant?
-- Primary key of the one becomes foreign key of the many.

--8)	What owners have the same number of letters in their first name as in their last name?
SELECT O.FirstName, O.LastName, LEN(O.Firstname) AS lenoffirst, LEN(O.LastName) AS lenoflast
FROM OwnerODS O
WHERE LEN(O.Firstname) = LEN(O.LastName)

--9)	What owes us money for visits with reason code “vaccination”, where the animals are not farm animals (Bison, Cattle, Sheep)?  Create a full name like “lastname, firstname”
SELECT CONCAT(O.LastName, ' ', O.FirstName) AS full_name, O.FirstName, O.LastName, B.InvoicePaid, V.Reason, A.AnimalType
FROM ((OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID) 
	INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID) INNER JOIN BillingODS B ON V.VisitID = B.VisitID
WHERE B.InvoicePaid = 0 AND V.Reason = 'Vaccinations' 
AND A.AnimalType NOT IN ('Bison', 'Cattle', 'Sheep');

--10)	What is the largest invoice amount by animal type?
SELECT A.AnimalType, MAX(B.InvoiceAmt) AS max_ivo_amt
FROM ((OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID) 
	INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID) INNER JOIN BillingODS B ON V.VisitID = B.VisitID
GROUP BY A.AnimalType

--11)	What is the most popular day for a visit?
SELECT TOP 1 DATENAME(WEEKDAY, V.VisitDate) AS theday, COUNT(V.VisitID) AS numofvisits
FROM ((OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID) 
	INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID) INNER JOIN BillingODS B ON V.VisitID = B.VisitID
GROUP BY DATENAME(WEEKDAY, V.VisitDate)
ORDER BY numofvisits DESC
-- Friday.

--12)	Create a mailing list that sets up an appointment one year from the last visit
SELECT CONCAT(O.FirstName, ' ', O.LastName) AS FullName, A.AnimalID, 
	MAX(V.VisitDate) AS lastvisit, DATEADD(year, 1, MAX(V.VisitDate)) AS appointment,
	O.Email
FROM ((OwnerODS O INNER JOIN AnimalODS A ON O.OwnerID = A.OwnerID) 
	INNER JOIN VisitODS V ON A.AnimalID = V.AnimalID) INNER JOIN BillingODS B ON V.VisitID = B.VisitID
GROUP BY O.FirstName, O.LastName, O.Email, A.AnimalID

--13)	What are my pets names?
-- Runt, Nala, Jojo
