# SQL Server Style Guide

## Overview

You can use this set of guidelines, [fork them][fork] or make your own - the key here is that you pick a style and stick to it. To suggest changes or fix bugs please open an [issue][issue] or [pull request][pull] on GitHub.

These guidelines are designed to be compatible with Microsoft SQL Server and used in conjunction with Red Gate SQL Tooling [SQL Prompt][sql-prompt] and [SQL Source Control][sql-source-control].

They use standard Microsoft naming conventions that will assist when coding in ORM's such as NHIBERNATE, PLINQO, LINQ2SQL or EntityFramework i.e. convention over configuration. Also when using SSRS, SSAS & Tabluar data models the Table and Column naming standards will assist the UI layouts.

It is easy to include this guide in [Markdown format][dl-md] as a part of a project's code base or reference it here for anyone on the project to freely read—much harder with a physical book.

The format is based on some of the work at [http://www.sqlstyle.guide][sqlstyleguide].

SQL Server Style Guide by [The Data Crew][thedatacrew] is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License][licence].

Based on a work at [http://www.sqlstyle.guide][sqlstyleguide].


## General ##

### Do

- Use consistent and descriptive identifiers and names.
- Use SQL Prompt Formatting Style which make SQL code formatted to the standard required and easier to read.
- Use Source Control, commit regularly & document your changes
- Document your functional code blocks in Procedures and Functions but don't document change history in there, that's what source control is for.
- Run a **Find Invalid Objects** on the database before a commit to source control.
- Remove redundant code, don't just comment it out. Track the history in source control.
- Document your columns use extened properties.

### Avoid

- Creating copy's of database objects to track history, keep the database clean.
- Don't commit a broken database to source control.
- Using abbreviations for names.

## Naming conventions

### General

- Ensure the name is unique and does not exist as a reserved keyword.
- Names must begin with a letter and should be as short as possible but self descriptive.
- Only use letters, numbers in names.
- Avoid the use of multiple consecutive underscores—these can be hard to read.
- Be descriptive and avoid abbreviations and if you have to use them make sure they are commonly understood.
- When joining tables use short aliases i.e. 

```sql
SELECT I.InvoiceItemID
      ,P.ProductID
FROM   InvoiceItems AS II
       INNER JOIN Product AS P ON II.InvoiceID = P.ProductID; 
```

### Tables

- Use Pascal Casing where you would naturally include a space in the name i.e. My Field Name = MyFieldName
- Use a collective table name in a singular form. i.e. Invoice, Order, OrderItem. 
- Do not prefix any objects with tbl, vw or any other such descriptive prefix or Hungarian notation.
- Do not name a table the same as one of its columns and vice-versa.
- When creating a Many-Many relationship table, create the name of a relationship table as PrimaryTableSecondaryTable in a singular naming i.e. Customer.
- Where possible use a natural key for the primary key from the data set rather than a surrogate key.

#### Columns

- Always use the singular name.
- Do not add a column with the same name as its table and vice versa.
- With string data types, VARCHAR, NVARCHAR, CHAR, NCHAR specify the length on a byte boundary. i.e. to the nearest 8 BITS. It makes the SQL easier to read, allows you to easily remember data sizes and looks nice :wink:.

```sql
	[InvoiceBK] [NVARCHAR](32) NULL,
	[InvoiceTypeBK] [NVARCHAR](64) NULL,
	[LegalEntityBK] [NVARCHAR](16) NULL,
	[CountryBK] [NVARCHAR](2) NOT NULL,
	[CurrencyBK] [NVARCHAR](8) NULL,
	[CountryName] [NVARCHAR](64) NOT NULL,
	[IsoCode] [NVARCHAR](2) NOT NULL,
	[UnCode] [NVARCHAR](4) NOT NULL,
	[NumericCode] [NVARCHAR](4) NOT NULL,
	[IsEuMember] [BIT] NOT NULL,
	[Continent] [NVARCHAR](64) NULL,
	[Region] [NVARCHAR](64) NULL,	
```

- Always use PascalCase except where you have more than 1 Foreign Key Reference to the same table. use an underscore to highlight its function i.e. CustomerID_Order and CustomerID_Invoice both reference the Customer table and the column CustomerID
 
```sql
CREATE TABLE [dbo].[Invoice](
	[InvoiceID] [INT] IDENTITY(1,1) NOT NULL,
	[InvoiceTypeID] [INT] NOT NULL,
	[LegalEntityID] [INT] NOT NULL,
	[CurrencyID] [INT] NOT NULL,
	[CustomerID_Order] [INT] NULL,
	[CustomerID_Invoice] [INT] NULL,
	[CustomerID_Reporting] [INT] NULL,
	[SourceSystemID] [INT] NULL,
	[InvoiceBK] [NVARCHAR](32) NULL,
	[InvoiceTypeBK] [NVARCHAR](64) NULL,
	[LegalEntityBK] [NVARCHAR](16) NULL,
	[CurrencyBK] [NCHAR](10) NOT NULL,
	[CustomerBK_Order] [NVARCHAR](32) NULL,
	[CustomerBK_Invoice] [NVARCHAR](32) NOT NULL,
	[DiscountType] [NVARCHAR](32) NULL,
	[InvoiceNumber] [NVARCHAR](32) NOT NULL,
	[OrderReference] [NVARCHAR](32) NULL,
	[RmaReference] [NVARCHAR](32) NULL,
	[InvoiceDate] [DATE] NOT NULL,
	[SalesTaxAmount] [MONEY] NULL,
	[SalesDiscount] [MONEY] NULL,
	[SalesNetAmount] [MONEY] NULL,
	[SalesGrossAmount] [MONEY] NULL,
	[BaseTaxAmount] [MONEY] NULL,
	[BaseDiscount] [MONEY] NULL,
	[BaseNetAmount] [MONEY] NULL,
	[BaseGrossAmount] [MONEY] NULL,
	[GbpTaxAmount] [MONEY] NULL,
	[GbpDiscount] [MONEY] NULL,
	[GbpNetAmount] [MONEY] NULL,
	[GbpGrossAmount] [MONEY] NULL,
	[RowHashType1] [binary] (32) NOT NULL,
	[LoadedOn] [datetime2] (0) NOT NULL,
	[LoadedBy] [nvarchar] (64) NOT NULL,
	[CreatedOn] [datetime2] NOT NULL,
	[CreatedBy] [nvarchar] (64) NOT NULL,
	[ModifiedOn] [datetime2] NOT NULL,
	[ModifiedBy] [nvarchar] (64) NOT NULL
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
```

- The primary identifier for the table must be TableNameID with ID in uppercase. This is a standard notation used by many ORM's to identify Primary & Foreign Keys by Convention. 
- When used a business Key identifier for the table where surrogate keys are used must be TableNameBK with BK in uppercase.
- Every table must contain the following date fields for audit purposes.

```sql
[CreatedOn] [datetime2] NOT NULL,
[CreatedBy] [nvarchar] (64) NOT NULL,
[ModifiedOn] [datetime2] NOT NULL,
[ModifiedBy] [nvarchar] (64) NOT NULL
```
- If you are building a Data Warehouse platform every table shoudld also have the following date fields for ETL audit purposes.

```sql
[LoadedOn] [datetime2] (0) NOT NULL,
[LoadedBy] [nvarchar] (64) COLLATE Latin1_General_CI_AS NOT NULL,
```
- If you are building a Data Warehouse platform every table shoudld also have the following Hash fields for ETL audit purposes.

```sql
[RowHashType1] [binary] (32) NOT NULL, -- SCD (Slowly Changing Dimension) Type 1 Changes Hash
[RowHashType2] [binary] (32) NOT NULL, -- SCD (Slowly Changing Dimension) Type 2 Changes Hash
```
- Use HASHBYTES & 'SHA2_256' as a minimum Hasing

- The PrimaryKey must be first in the table followed by the Foreign Keys in alphabetical order. i.e. followed by the Business Key's in alphabetical order
- Avoid GUID's as primary keys unless yoiu specifically require them. The performance as a clustered index isn't good. 

```sql
CREATE TABLE [dbo].[Country](
	[CountryID] [INT] NOT NULL,
	[CurrencyID] [INT] NULL,
	[CountryBK] [NVARCHAR](2) NOT NULL,
	[CurrencyBK] [NVARCHAR](8) NULL,
	[CountryName] [NVARCHAR](64) NOT NULL,
	[IsoCode] [NVARCHAR](2) NOT NULL,
	[UnCode] [NVARCHAR](4) NOT NULL,
	[NumericCode] [NVARCHAR](4) NOT NULL,
	[IsEuMember] [BIT] NOT NULL,
	[Continent] [NVARCHAR](64) NULL,
	[Region] [NVARCHAR](64) NULL,
	[RowHashType1] [binary] (32) NOT NULL,
	[LoadedOn] [datetime2] (0) NOT NULL,
	[LoadedBy] [nvarchar] (64) NOT NULL,
	[CreatedOn] [datetime2] NOT NULL,
	[CreatedBy] [nvarchar] (64) NOT NULL,
	[ModifiedOn] [datetime2] NOT NULL,
	[ModifiedBy] [nvarchar] (64) NOT NULL
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
```

### SCD (Slowly Changing Dimension) Type 2 Columns

For tables that track changes the following columns must be included.

```sql
[RowHashType1] [binary] (32) NULL,
[RowHashType2] [binary] (32) NULL,
[LoadedOn] [datetime2] (0) NOT NULL,
[LoadedBy] [nvarchar] (64) NOT NULL,
[CreatedOn] [datetime2] (0) NOT NULL,
[CreatedBy] [nvarchar] (64) NOT NULL,
[ModifiedOn] [datetime2] (0) NOT NULL,
[DateValidFrom] [datetime2] (0) NOT NULL,
[DateValidTo] [datetime2] (0) NOT NULL,
[IsCurrent] [nchar] (10) NOT NULL
```

e.g. An Employee Table that tracks Type1 & Type 2 Changes may look like this.

```sql
CREATE TABLE [Dimension].[Employee]
(
[EmployeeID] [int] NOT NULL,
[EmployeeID_Manager] [int] NULL,
[TeamID] [int] NULL,
[SourceSystemID] [int] NULL,
[Title] [nvarchar] (32) NULL,
[Firstname] [nvarchar] (32) NULL,
[Lastname] [nvarchar] (32) NULL,
[Employee Name] [nvarchar] (64) NULL,
[Team] [nvarchar] (64) COLLATE NULL,
[Department] [nvarchar] (64) NULL,
[Date Employment Started] [date] NULL,
[Date Employment Ended] [date] NULL,
[Job Title] [nvarchar] (128) NULL,
[Holiday Entitlement] [decimal] (3, 1) NULL,
[Holiday Adjustment] [decimal] (3, 1) NULL,
[Holiday Purchased Adjustment] [decimal] (3, 1) NULL,
[Extension] [nvarchar] (16) NULL,
[Internal Email] [nvarchar] (128) NULL,
[RowHashType1] [binary] (32) NULL,
[RowHashType2] [binary] (32) NULL,
[LoadedOn] [datetime2] (0) NOT NULL,
[LoadedBy] [nvarchar] (64) NOT NULL,
[CreatedOn] [datetime2] (0) NOT NULL,
[CreatedBy] [nvarchar] (64) NOT NULL,
[ModifiedOn] [datetime2] (0) NOT NULL,
[DateValidFrom] [datetime2] (0) NOT NULL,
[DateValidTo] [datetime2] (0) NOT NULL,
[IsCurrent] [nchar] (10) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dimension].[Employee] ADD CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED  ([EmployeeID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'User that Created the Record on the Source System.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'CreatedBy'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the Record was Created on the Source System.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'CreatedOn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date Employee ended in the Business.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Date Employment Ended'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date Employee started in the Business.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Date Employment Started'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the record is valid from.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'DateValidFrom'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the record is valid to.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'DateValidTo'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Department that the Employee is a member of in the Business.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Department'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Standard formated full name of the Employee i.e. Lastname, Firstname Title.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Employee Name'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee Surrogate Primary Key from the Data Warehouse.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'EmployeeID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee Foreign Key for the manager from the Data Warehouse.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'EmployeeID_Manager'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee''s internal telephone extension number.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Extension'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Firstname / Given name of the Employee.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Firstname'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Annual Holiday Adjustment in days (e.g. increased with length of service).', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Holiday Adjustment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Annual Holiday Entitlement in days.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Holiday Entitlement'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Annual Holiday Purchased Adjustment (employee has purchased additional days).', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Holiday Purchased Adjustment'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Employee''s internal email address.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Internal Email'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Flag to mark the current valid record.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'IsCurrent'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Job Title.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Job Title'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Lastname / Surname of the Employee.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Lastname'
GO
EXEC sp_addextendedproperty N'MS_Description', N'User for the ETL System that Loaded or Modified the Record.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'LoadedBy'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the ETL System Loaded or Modified the Record.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'LoadedOn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Date the Record was Modified on the Source System.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'ModifiedOn'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A SHA2-256 Hash of the SCD Type 1 Columns in the Table.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'RowHashType1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'A SHA2-256 Hash of the SCD Type 2 Columns in the Table.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'RowHashType2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Source System Foreign Key.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'SourceSystemID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Team that the Employee is a member of in the Business.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Team'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Team Foreign Key.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'TeamID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Title (Mr,Ms,Mrs,Miss,Dr,Prof.) etc of the Employee.', 'SCHEMA', N'Dimension', 'TABLE', N'Employee', 'COLUMN', N'Title'
GO
```

### Uniform suffixes

The following suffixes have a universal meaning ensuring the columns can be read and understood easily from SQL code. Use the correct suffix where appropriate

Suffix  | Description
------------- | -------------
ID |  a unique identifier such as a column that is a primary key.
Status | value or some other status of any type such as publication_status.
Total | the total or sum of a collection of values.
Num | denotes the field contains any kind of number.
Name | signifies a name such as first_name.
Sequence | contains a contiguous sequence of values.
Date | denotes a column that contains the date of something.
Tally | a count.
Size | the size of something such as a file size or clothing.


### Views

- Use Pascal Casing where you would naturally include a space in the name i.e. My Field Name = MyFieldName
- Use a collective table name in a singular form. i.e. Invoice, Order, OrderItem. 
- Do not prefix any objects with tbl, vw or any other such descriptive prefix or Hungarian notation.
- Do not name a table the same as one of its columns and vice-versa.
- When creating a Many-Many view, create the name of a relationship view as PrimaryTableSecondaryTable in a singular naming.
- Don't nest views in views. A view should target underlying tables only otherwise too many dependence exists and one change can break multiple things.
- Alias for Columns should be a Single Word i.e. MyColumnAlias or if spaces are required quoted with [My Column Alias]. String literals 'MyColumnAlias' or 'My Column Alias' or "MyColumnAlias" or "My Column Alias" are deprecated and should not be used. Any existing deprecated String literals shoudl be replaced.

### Stored procedures

- The name must be descriptive and easily understood
- prefix with usp_
- Use get, update, remove, delete & list in the name to denote function. i.e. `EXEC dbo.usp_get_country_by_name`

### Functions

- The name must be descriptive and easily understood
- prefix with ufn_
- Use get, update, remove, delete & list in the name to denote function. i.e. `SELECT dbo.ufn_get_discount(CustomerID) FROM Customer`

### Foreign Keys

- Always create a foreign key with related data.
- Where possible make sure cascade updates and cascade deletes are disabled as they have a negative performance impact.
- Use the following naming convention FK_ForiegnKeyTable_PrimaryKeyTable_KeyColumn
- Implement the store procedure [usp_implement_naming_standard.sql][usp-implement-naming-standard-sql] which will automatically name all the foreign keys.

```sql
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Country_CountryID] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([CountryID])
```

## Query syntax


## The 10 Basic Concepts of T-SQL

[Written By: Matan Yungman][10-basic-concepts-t-sql] 

1. Think in sets, not in rows
2. Every part of your query is a table result, and can be referenced as such by later parts of the query
3. Know the logical processing order of queries: From -> Join -> Where -> Group By -> Having -> Select -> Distinct -> Order By -> Offset/Fetch
4. The more you prepare in advance, and the less calculations you perform on the fly, the better the query will run. Don’t take it to the extreme, of course
5. Avoid user-defined functions as much as possible. Take the function logic out and use a set-based solution, or use an inline table-valued function if you want to keep the reuse and encapsulation a function gives you.
6. Views can be evil (or to be more accurate, the way people use them). If you see a view that already queries from many tables and other views, consider whether you really want to use it, because in many cases, such views generate poor performing queries
7. Keep queries simple. Don’t write “the mother of all queries”. If it’s complicated, break it down to smaller ones and use temp tables for temporary results
8. In 99% of cases, temp tables are better than table variables
9. Indexes will help your queries (but make sure there aren’t too many of them). Statistics will help them too
10. Beware of things that prevent SQL Server from using an index, like wrapping a column with a function, using Like with % at the start of the predicate, or performing a manipulation of a column you filter on.


## Indexing

- [The Basics][sqlskills-sql101-indexing]
- [Other Indexing resources][sqlskills-sql101-indexing-other]

[thedatacrew]: https://thedatacrew.com
    "TheDataCrew.com"
[issue]: https://github.com/thedatacrew/SqlServer.Coding.Standards/issues
    "SQL style guide issues on GitHub"
[fork]: https://github.com/thedatacrew/SqlServer.Coding.Standards/fork/
    "Fork SQL style guide on GitHub"
[pull]: https://github.com/thedatacrew/SqlServer.Coding.Standards/pulls/
    "SQL style guide pull requests on GitHub"
[dl-md]: https://raw.githubusercontent.com/thedatacrew/SqlServer.Coding.Standards/master/documentation/sqlstyle.guide.md?token=AAWHBHEB1sXiN2_KVOjGU-nF5TrXnuIMks5Zt4rOwA%3D%3D
    "Download the guide in Markdown format"
[reserved-keywords]: #reserved-keyword-reference
    "Reserved keyword reference" 
[sqlstyleguide]: http://www.sqlstyle.guide
    "SQL style guide by Simon Holywell"
[sqlserverstyleguide]: http://www.thedatacrew.com/sqlserverstyleguide
    "SQL Server Style Guide by The Data Crew"
[licence]: http://creativecommons.org/licenses/by-sa/4.0/
    "Creative Commons Attribution-ShareAlike 4.0 International License"
[sql-prompt]: http://www.red-gate.com/products/sql-development/sql-prompt/
	"Red Gate SQL Prompt - Write, format, share and refactor your SQL effortlessly"
[sql-source-control]: https://www.red-gate.com/products/sql-development/sql-source-control/ 
	"SQL Source Control - Connect your database to your version control system"
[10-basic-concepts-t-sql]: http://www.madeiradata.com/10-basic-concepts-t-sql/
	"The 10 Basic Concepts of T-SQL, Written By: Matan Yungman"
[sqlskills-sql101-indexing-other]: https://www.sqlskills.com/blogs/kimberly/category/indexes/
	"Kimberly L. Tripp - Improving my SQL skills through your questions!"
[sqlskills-sql101-indexing]: https://www.sqlskills.com/blogs/kimberly/sqlskills-sql101-indexing/
	"Kimberly L. Tripp - Improving my SQL skills through your questions!"
[usp-implement-naming-standard-sql]: https://github.com/thedatacrew/SqlServer.Coding.Standards/blob/master/tools/usp_implement_naming_standard.sql
	"usp_implement_naming_standard.sql"
