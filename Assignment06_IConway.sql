--*************************************************************************--
-- Title: Assignment06
-- Author: IngridConway
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,IngridConway,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_IConway')
	 Begin 
	  Alter Database [Assignment06DB_IConway] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_IConway;
	 End
	Create Database Assignment06DB_IConway;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_IConway;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--'NOTES------------------------------------------------------------------------------------ 
 --1) You can use any name you like for you views, but be descriptive and consistent
 --2) You can use your working code from assignment 5 for much of this assignment
 --3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


--DROP VIEW Assignment06DB_IConway.vCatView;
--GO
--DROP VIEW Assignment06DB_IConway.vPrdView;
--GO
--DROP VIEW Assignment06DB_IConway.vInvView;
--DROP VIEW Assignment06DB_IConway.vEmpView;
--GO

USE Assignment06DB_IConway;
GO
CREATE
VIEW CatView
WITH SCHEMABINDING
AS
	SELECT CategoryID, CategoryName
	FROM dbo.Categories;
GO

USE Assignment06DB_IConway;
GO
CREATE
VIEW PrdView
WITH SCHEMABINDING
AS
	SELECT ProductID, ProductName, CategoryID, UnitPrice
	FROM dbo.Products;
GO

USE Assignment06DB_IConway;
GO
CREATE
VIEW InvView
WITH SCHEMABINDING
AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	FROM dbo.Inventories;
GO

USE Assignment06DB_IConway;
GO
CREATE
VIEW EmpView
WITH SCHEMABINDING
AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM dbo.Employees;
GO
-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

USE Assignment06DB_IConway;
GO
DENY SELECT ON Categories to PUBLIC;
DENY SELECT ON Products to PUBLIC;
DENY SELECT ON Inventories to PUBLIC;
DENY SELECT ON Employees to PUBLIC
GRANT SELECT ON CatView to PUBLIC;
GRANT SELECT ON PrdView to PUBLIC;
GRANT SELECT ON InvView to PUBLIC;
GRANT SELECT ON EmpView to PUBLIC;

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


--SELECT * FROM Categories
--SELECT * FROM Products

USE Assignment06DB_IConway;
GO
CREATE VIEW CatPrd
WITH SCHEMABINDING
	AS
		SELECT Categories.CategoryName, Products.ProductName, Products.UnitPrice
		FROM dbo.Products JOIN dbo.Categories
		ON Products.CategoryID = Categories.CategoryID;
GO
SELECT * FROM CatPrd
		ORDER BY CatPrd.CategoryName, CatPrd.ProductName;
GO
	

-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

SELECT * FROM Inventories
SELECT * FROM Products

USE Assignment06DB_IConway;
GO
CREATE VIEW PrdInv
WITH SCHEMABINDING
	AS
		SELECT Products.ProductName, Inventories.[Count], Inventories.InventoryDate
		FROM dbo.Inventories JOIN dbo.Products
		ON Products.ProductID = Inventories.ProductID;
GO
SELECT * FROM PrdInv
		ORDER BY PrdInv.ProductName , PrdInv.InventoryDate, PrdInv.[Count];
GO
	

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth
--DROP VIEW InvEmp;
--GO 

SELECT * FROM Inventories
SELECT * FROM Employees

USE Assignment06DB_IConway;
GO
CREATE VIEW InvEmp
WITH SCHEMABINDING
	AS
		SELECT Inventories.InventoryDate, Employees.EmployeeLastName, Employees.EmployeeFirstName, Employees.EmployeeID
		FROM dbo.Employees JOIN dbo.Inventories
		ON Employees.EmployeeID = Inventories.EmployeeID;
GO
SELECT DISTINCT (InventoryDate), EmployeeLastName, EmployeeFirstName, EmployeeID FROM InvEmp
		ORDER BY InvEmp.InventoryDate;
GO
	

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

SELECT * FROM Inventories
SELECT * FROM Products
SELECT * FROM Categories

USE Assignment06DB_IConway;
GO
CREATE VIEW CPIC
WITH SCHEMABINDING
	AS
		SELECT Categories.CategoryID, Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count]
		FROM dbo.Inventories JOIN dbo.Products
		ON Products.ProductID = Inventories.ProductID
		JOIN dbo.Categories
		ON Categories.CategoryID = Products.CategoryID;
GO
SELECT * FROM CPIC
		ORDER BY CPIC.CategoryName, CPIC.ProductName , CPIC.InventoryDate, CPIC.[Count];
GO
	

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


USE Assignment06DB_IConway;
GO
CREATE VIEW EmpCount
WITH SCHEMABINDING
	AS
		SELECT TOP 500
		Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeFirstName, Employees.EmployeeLastName
		FROM dbo.Categories JOIN dbo.Products
		ON Categories.CategoryID = Products.CategoryID
		JOIN dbo.Inventories 
		ON Products.ProductID = Inventories.ProductID
		JOIN dbo.Employees
		ON Inventories.EmployeeID = Employees.EmployeeID
	ORDER BY Inventories.InventoryDate, Categories.CategoryName, Products.ProductName, Employees.EmployeeFirstName, Employees.EmployeeLastName;
GO  

SELECT * FROM EmpCount;
GO
	

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

DROP VIEW CPIC_chai;
GO

USE Assignment06DB_IConway;
GO
CREATE VIEW CPIC_chai
WITH SCHEMABINDING
	AS
	SELECT
	Categories.CategoryName, Products.ProductName, Inventories.InventoryDate, Inventories.[Count], Employees.EmployeeLastName
			FROM dbo.Categories JOIN dbo.Products
			ON Categories.CategoryID = Products.CategoryID
		JOIN dbo.Inventories 
		ON Products.ProductID = Inventories.ProductID
		JOIN dbo.Employees
		ON Inventories.EmployeeID = Employees.EmployeeID
WHERE Products.ProductID IN 
(SELECT Products.ProductID FROM dbo.Products WHERE Products.ProductName = 'Chai' OR Products.ProductName ='Chang')
GO

SELECT * FROM CPIC_chai;
GO

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


DROP VIEW EmpMan;
GO

USE Assignment06DB_IConway;
GO
CREATE VIEW EmpMan
WITH SCHEMABINDING
	AS
	SELECT TOP 500 
	Mgr.EmployeeFirstName AS 'ManagerFirstName', Mgr.EmployeeLastName AS 'ManagerLastName', Emp.EmployeeLastName, Emp.EmployeeFirstName
	FROM dbo.Employees as Emp INNER JOIN dbo.Employees as Mgr
		ON Emp.ManagerID = Mgr.EmployeeID
ORDER BY Mgr.EmployeeFirstName;
GO

SELECT * FROM EmpMan;
GO

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].CatView
Select * From [dbo].PrdView
Select * From [dbo].InvView
Select * From [dbo].EmpView





USE Assignment06DB_IConway;
GO
CREATE VIEW FourViews
WITH SCHEMABINDING
	AS
	SELECT  CatView.CategoryID, CatView.CategoryName, PrdView.ProductID, PrdView.ProductName, PrdView.UnitPrice,
		InvView.[Count], InvView.InventoryDate, InvView.InventoryID, EmpView.EmployeeFirstName, EmpView.EmployeeLastName
		, EmpView.ManagerID, EmpView.EmployeeID
		FROM dbo.CatView JOIN dbo.PrdView
		ON CatView.CategoryID = PrdView.CategoryID
		JOIN dbo.InvView
		ON PrdView.ProductID = InvView.ProductID
		JOIN dbo.EmpView
		ON InvView.EmployeeID = EmpView.EmployeeID;
GO

SELECT * FROM FourViews

/***************************************************************************************/