--*************************************************************************--
-- Title: Assignment06
-- Author: Aiden Lee
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-05-17,Aiden Lee,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AidenLee')
	 Begin 
	  Alter Database [Assignment06DB_AidenLee] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AidenLee;
	 End
	Create Database Assignment06DB_AidenLee;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_AidenLee;

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
,[UnitPrice] [mOney] NOT NULL
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
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
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
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
go
Create View dbo.vProducts With SchemaBinding
As
Select ProductID, ProductName, CategoryID, UnitPrice 
From dbo.Products
go

Create View dbo.vCategories With SchemaBinding
As
Select CategoryID, CategoryName
From dbo.Categories
go

Create View dbo.vEmployees With SchemaBinding
As
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
From dbo.Employees
go

Create View dbo.vInventories With SchemaBinding
As
Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
From dbo.Inventories
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On dbo.Products to Public;
Grant Select On dbo.vProducts to Public;

Deny Select On dbo.Categories to Public;
Grant Select On dbo.vCategories to Public;

Deny Select On dbo.Employees to Public;
Grant Select On dbo.vEmployees to Public;

Deny Select On dbo.Inventories to Public;
Grant Select On dbo.vInventories to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
go
Create View dbo.[vProductsByCategories] With SchemaBinding
As
Select TOP 1000000000 CategoryName, ProductName, UnitPrice 
From dbo.Categories as c
Join dbo.Products as p On c.CategoryID = p.CategoryID
Order By c.CategoryName, p.ProductName;
go

-- Verify the result
Select * from dbo.[vProductsByCategories];

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
go
Create View dbo.[vInventoriesByProductsByDates] With SchemaBinding
As
Select TOP 1000000000 dbo.Products.ProductName,  dbo.Inventories.InventoryDate, dbo.Inventories.Count
From dbo.Products 
Join dbo.Inventories ON dbo.Products.ProductID = dbo.Inventories.ProductID
Order By dbo.Products.ProductName, dbo.Inventories.InventoryDate, dbo.Inventories.Count
go

-- Verify the result
Select * from [dbo].[vInventoriesByProductsByDates]


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

go
Create View [dbo].[vInventoriesByEmployeesByDates] With SchemaBinding
As
Select Distinct TOP 1000000000 dbo.Inventories.InventoryDate, dbo.Employees.EmployeeFirstName + ' ' + dbo.Employees.EmployeeLastName AS Employee_Name
From dbo.Inventories
Join dbo.Employees ON dbo.Inventories.EmployeeID = dbo.Employees.EmployeeID
Order By dbo.Inventories.InventoryDate;
go

-- Verify the result
Select * From [dbo].[vInventoriesByEmployeesByDates]

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
go
Create View [dbo].[vInventoriesByProductsByCategories] With SchemaBinding
As
Select TOP 1000000000 [dbo].Categories.CategoryName, [dbo].Products.ProductName, [dbo].Inventories.InventoryDate, [dbo].Inventories.Count
From [dbo].Categories
Join [dbo].Products ON [dbo].Products.CategoryID = [dbo].Categories.CategoryID
Join [dbo].Inventories ON [dbo].Inventories.ProductID = [dbo].Products.ProductID
Order By [dbo].Categories.CategoryName, [dbo].Products.ProductName, [dbo].Inventories.InventoryDate, [dbo].Inventories.Count
go

-- Verify results
Select * From [dbo].[vInventoriesByProductsByCategories]

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
go
Create View [dbo].[vInventoriesByProductsByEmployees] With SchemaBinding
As 
Select TOP 1000000000 [dbo].Categories.CategoryName, [dbo].Products.ProductName, [dbo].Inventories.InventoryDate, [dbo].Inventories.Count, [dbo].Employees.EmployeeFirstName + ' ' + [dbo].Employees.EmployeeLastName AS EmployeeName
From [dbo].Categories
Join [dbo].Products ON [dbo].Products.CategoryID = [dbo].Categories.CategoryID
Join [dbo].Inventories ON [dbo].Inventories.ProductID = [dbo].Products.ProductID
Join [dbo].Employees ON [dbo].Employees.EmployeeID = [dbo].Inventories.EmployeeID
Order By [dbo].Inventories.InventoryDate, [dbo].Categories.CategoryName, [dbo].Products.ProductName, [dbo].Employees.EmployeeFirstName + ' ' + [dbo].Employees.EmployeeLastName
go

Select * From [dbo].[vInventoriesByProductsByEmployees]

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
go
Create View [dbo].[vInventoriesForChaiAndChangByEmployees] With SchemaBinding
As
Select TOP 1000000000 [dbo].Categories.CategoryName, [dbo].Products.ProductName, [dbo].Inventories.InventoryDate, [dbo].Inventories.Count, [dbo].Employees.EmployeeFirstName + ' ' + [dbo].Employees.EmployeeLastName AS EmployeeName
From [dbo].Products
Join [dbo].Categories ON [dbo].Categories.CategoryID = [dbo].Products.CategoryID
Join [dbo].Inventories ON [dbo].Inventories.ProductID = [dbo].Products.ProductID
Join [dbo].Employees ON [dbo].Employees.EmployeeID = [dbo].Inventories.EmployeeID
Where [dbo].Products.ProductID IN (Select [dbo].Products.ProductID From [dbo].Products Where [dbo].Products.ProductName IN ('Chai', 'Chang' ))
Order By [dbo].Inventories.InventoryDate, [dbo].Categories.CategoryName, [dbo].Products.ProductName
go

Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
go
Create View [dbo].[vEmployeesByManager] With SchemaBinding
As
Select TOP 1000000000 m.EmployeeFirstName + ' ' + m.EmployeeLastName As Manager, e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
From dbo.Employees e
Join dbo.employees m ON e.ManagerID = m.EmployeeID
Order By m.EmployeeFirstName, e.EmployeeFirstName
go

-- Verify results
Select * From [dbo].[vEmployeesByManager]

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
go
--Create View [dbo].[vInventoriesByProductsByCategoriesByEmployees] With SchemaBinding
--As
--Select TOP 1000000000
--dbo.Categories.CategoryID, dbo.Categories.CategoryName,
--dbo.Products.ProductID, dbo.Products.ProductName, dbo.Products.UnitPrice,
--dbo.Inventories.InventoryID, dbo.Inventories.InventoryDate, dbo.Inventories.Count,
--e.EmployeeID,
--e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee, 
--m.EmployeeFirstName + ' ' + m.EmployeeLastName As Manager
--From dbo.Inventories
--Join dbo.Products ON dbo.Inventories.ProductID = dbo.Products.ProductID
--Join dbo.Categories ON dbo.Categories.CategoryID = dbo.Products.CategoryID
--Join dbo.Employees e ON e.EmployeeID = dbo.Inventories.EmployeeID
--Join dbo.Employees m ON e.ManagerID = m.EmployeeID
--Order By dbo.Categories.CategoryName, dbo.Products.ProductName, dbo.Inventories.InventoryID, e.EmployeeID
--go

Create View [dbo].[vInventoriesByProductsByCategoriesByEmployees] With SchemaBinding
As
Select TOP 1000000000
dbo.Categories.CategoryID, dbo.Categories.CategoryName,
dbo.Products.ProductID, dbo.Products.ProductName, dbo.Products.UnitPrice,
dbo.Inventories.InventoryID, dbo.Inventories.InventoryDate, dbo.Inventories.Count,
e.EmployeeID,
e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee, 
m.EmployeeFirstName + ' ' + m.EmployeeLastName As Manager
From dbo.Inventories
Join dbo.Products ON dbo.Inventories.ProductID = dbo.Products.ProductID
Join dbo.Employees e ON e.EmployeeID = dbo.Inventories.EmployeeID
Join dbo.Categories ON dbo.Products.CategoryID = dbo.Categories.CategoryID
Join dbo.Employees m ON e.ManagerID = m.EmployeeID
Order By dbo.Categories.CategoryName, dbo.Products.ProductName, dbo.Inventories.InventoryID, e.EmployeeFirstName
go


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
-- Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/