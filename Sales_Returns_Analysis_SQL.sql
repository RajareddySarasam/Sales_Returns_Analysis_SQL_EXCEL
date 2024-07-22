CREATE DATABASE INTERNSHIP;

USE INTERNSHIP;

SELECT * FROM dbo.Sales;

SELECT * FROM dbo.Returns;

-- 1. What % of sales result in a return?

-- Performing a LEFT JOIN to include all sales and check if they have corresponding returns
SELECT * FROM dbo.Sales S LEFT JOIN dbo.Returns R
ON S.OrderID = R.OrderID;


-- Counting distinct OrderIDs in Returns and divide by the total distinct OrderIDs in Sales,
-- then multiply by 100 to get the % of Returns.

SELECT (COUNT(DISTINCT R.OrderID) * 100.0 / COUNT(DISTINCT S.OrderID)) AS PercentageOfSalesWithReturns
FROM dbo.Sales S LEFT JOIN dbo.Returns R
ON S.OrderID = R.OrderID;

--Answer is : 4.2309 %

--2. What % of returns are full returns?

--Using an inner join on the OrderID column of both tables to get corresponding sales data for each return.

SELECT * FROM dbo.Sales S Inner join dbo.Returns R
on S.OrderID = R.OrderID;

-- Full Returns are returns,Where ReturnSales amount is equal to the Sales amount.
SELECT S.OrderID, CASE WHEN R.ReturnSales = S.Sales THEN 1 END AS FULLRETURNS
FROM dbo.Sales S Inner join dbo.Returns R
on S.OrderID = R.OrderID;

-- AS COUNT STATEMENT DOESN'T COUNT THE NULL ENTRIES.LET'S USE THE COUNT ON FULLRETURNS
--TO GET THE % OF FULLRETURNS, DIVIDING THE COUNT OF FULLRETURNS BY TOTALRETURNS AND MULTIPLYING THE 100.

SELECT (COUNT(CASE WHEN R.ReturnSales = S.Sales THEN 1 END) * 100.0 / COUNT(R.OrderID)) AS PercentageOfFullReturns
FROM dbo.Returns R INNER JOIN dbo.Sales S
ON R.OrderID = S.OrderID;

--Answer is: 18.1469%

--3. What is the average return % amount (return % of original sale)?

SELECT * FROM dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID ;

--Calculating the REturn Amount %

SELECT S.Sales,R.ReturnSales,(R.ReturnSales*100.0 /S.Sales)As PercentageOfReturns
FROM dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID ;

--Now,Average Return amount%

SELECT AVG(R.ReturnSales*100.0 /S.Sales)As AvgPercentageOfReturns
FROM dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID;

--Answer is : 52.809 %

-- 4. What % of returns occur within 7 days of the original sale?

select S.TransactionDate,R.ReturnDate from dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID;

-- Calaculating the Dates Difference betwween transaction and Return

select S.TransactionDate,R.ReturnDate,DATEDIFF(DAY,S.TransactionDate,R.ReturnDate) As DatesDifference
from dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID;

-- Checking if the DatesDifference is lessthan or equals to 7

select S.TransactionDate,R.ReturnDate,DATEDIFF(DAY,S.TransactionDate,R.ReturnDate) As DatesDifference,
CASE WHEN DATEDIFF(DAY,S.TransactionDate,R.ReturnDate)<=7 THEN 1 END AS WITHIN7DAYS
from dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID;

--Calculating the percentage of returns that occur within 7 days of the original sale

select (COUNT(CASE WHEN DATEDIFF(DAY,S.TransactionDate,R.ReturnDate)<=7 THEN 1 END)* 100.0 / COUNT(R.OrderID)) AS PercentageOfReturnsWithin7Days
from dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID;

--Answer is : 40.25%

--5. What is the average number of days for a return to occur?

select S.TransactionDate,R.ReturnDate,DATEDIFF(DAY,S.TransactionDate,R.ReturnDate) As DatesDifference
from dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID;

--Average DatesDifference
select AVG(DATEDIFF(DAY,S.TransactionDate,R.ReturnDate)) As AvgDaysToReturn
from dbo.Sales S inner join dbo.Returns R
on S.OrderID = R.OrderID;

--Answer is: 78

--6. Using this data set, how would you approach and answer the question, who is our most valuable customer?

--Total Sales by Each Customer
SELECT CustomerID,SUM(Sales) AS TotalSales
FROM dbo.Sales 
GROUP BY CustomerID;

--Total Returns By each Customer
SELECT CustomerID,Sum(ReturnSales) As TotalReturns
FROM dbo.Returns 
GROUP BY CustomerID;

-- Using CTE(Common Table Expression) for Most Valuable Customer Based on 'Highest TotalNetSales'

With TotalSales As(
	SELECT CustomerID,SUM(Sales) AS TotalSales
	FROM dbo.Sales 
	GROUP BY CustomerID
),
--select * From TotalSales
TotalReturns As(
	SELECT CustomerID,Sum(ReturnSales) As TotalReturns
	FROM dbo.Returns 
	GROUP BY CustomerID	
),
--Select * From TotalReturns
--Handle missing returns by setting return values to zero

TotalSalesAndReturns As(
SELECT TS.CustomerID,TS.TotalSales,ISNULL(TR.TotalReturns, 0) AS TotalReturns
FROM TotalSales TS LEFT JOIN TotalReturns TR
ON TS.CustomerID = TR.CustomerID 
--order by TotalReturns Desc
)
--Select * From TotalSalesAndReturns

SELECT TOP 1 CustomerID,TotalSales - TotalReturns AS NetTotalSales
FROM TotalSalesAndReturns
ORDER BY NetTotalSales DESC 

--Answer is: The Most  Valuable Customer is 'RIVES87271'




