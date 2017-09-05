# SQL Server Style Guide

## Overview

You can use this set of guidelines, [fork them][fork] or make your own - the key here is that you pick a style and stick to it. To suggest changes or fix bugs please open an [issue][issue] or [pull request][pull] on GitHub.

These guidelines are designed to be compatible with Microsoft SQL Server and used in conjunction with Red Gate SQL Tooling [SQL Prompt][sql-prompt] and [SQL Source Control][sql-source-control].

They use some standard Microsoft naming conventions that will assist when coding in ORM's such as LINQ2SQL or EntityFramework i.e. conventions over configurations. Also when using SSRS, SSAS & Tabluar data models the Table and Column naming standards will assist the UI layouts.

It is easy to include this guide in [Markdown format][dl-md] as a part of a project's code base or reference it here for anyone on the project to freely read—much harder with a physical book.

The format is based on some of the work at [http://www.sqlstyle.guide][sqlstyleguide].

SQL Server Style Guide by [The Data Crew][thedatacrew] is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License][licence].

Based on a work at [http://www.sqlstyle.guide][sqlstyleguide].


## General ##

### Do

- Use consistent and descriptive identifiers and names.
- Use SQL Prompt DataCrew Formatting Style which make SQL code formatted to the standard required and easier to read.
- Use Source Control, commit regularly & document your changes
- Document your functional code blocks in Procedures and Functions but don't document change history in there, that's what source control is for.
- Run a **Find Invalid Objects** on the database before a commit to source control.
- Remove redundant code, don't just comment it out. Track the history in source control.

### Avoid

- Creating copy's of database objects to track history, keep the database clean.
- Don't commit a broken database to source control.

## Naming conventions

### General

- Ensure the name is unique and does not exist as a reserved keyword.
- Names must begin with a letter and should be as short as possible but self descriptive.
- Only use letters, numbers in names.
- Avoid the use of multiple consecutive underscores—these can be hard to read.
- Be descriptive and avoid abbreviations and if you have to use them make sure they are commonly understood.
- When joining tables use short aliases i.e. 

```sql
SELECT I.InvoiceItemID<BR>
      ,P.ProductID
FROM   InvoiceItems AS II
       INNER JOIN Product AS P ON II.InvoiceID = P.ProductID; 
```

### Tables

- Use Pascal Casing where you would naturally include a space in the name i.e. My Field Name = MyFieldName
- Use a collective table name in a singular form. i.e. Invoice, Order, OrderItem. 
- Do not prefix any objects with tbl, vw or any other such descriptive prefix or Hungarian notation.
- Do not name a table the same as one of its columns and vice-versa.
- When creating a Many-Many relationship table, create the name of a relationship table as PrimaryTableSecondaryTable in a singular naming.

#### Columns

- Always use the singular name.
- Do not add a column with the same name as its table and vice versa.
- Always use PascalCase except where you have more than 1 Foreign Key Reference to the same table. use an underscore to highlight its function i.e. CustomerID_Order and CustomerID_Invoice both refernece the Customer table and the column CustomerID
 
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
	[RowHashType1] [BINARY](32) NULL,
	[DateLastModified] [DATETIME2](0) NOT NULL,
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
```

- The primary identifier for the table must be TableNameID with ID in uppercase.
- When used a business Key identifier for the table where surrogate keys are used must be TableNameBK with BK in uppercase.
- Every table must contain the fields LastModifiedBy, DateLastModified for audit purposes.
- The PrimaryKey must be first in the table followed by the Foreign Keys in alphabetical order. i.e. followed by the Business Key's in alphabetical order

```sql
CREATE TABLE [dbo].[Country](
	[CountryID] [INT] NOT NULL,
	[CurrencyID] [INT] NULL,
	[CountryBK] [NVARCHAR](2) NOT NULL,
	[CurrencyBK] [NCHAR](10) NULL,
	[CountryName] [NVARCHAR](64) NOT NULL,
	[IsoCode] [NVARCHAR](2) NOT NULL,
	[UnCode] [NVARCHAR](4) NOT NULL,
	[NumericCode] [NVARCHAR](4) NOT NULL,
	[IsEuMember] [BIT] NOT NULL,
	[Continent] [NVARCHAR](64) NULL,
	[Region] [NVARCHAR](64) NULL,
	[LastModifiedBy] [NVARCHAR](64) NULL,
	[DateLastModified] [DATETIME2](0) NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
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
Sequance | contains a contiguous sequence of values.
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

### Stored procedures

- The name must be descriptive and easily understood
- prefix with usp_
- Use get, update, remove, delete & list in the name to dentote function. i.e. `EXEC dbo.usp_get_country_by_name`

### Functions

- The name must be descriptive and easily understood
- prefix with ufn_
- Use get, update, remove, delete & list in the name to dentote function. i.e. `SELECT dbo.ufn_get_discount(CustomerID) FROM Customer`

### Foreign Keys 


## Query syntax

[thedatacrew]: https://thedatacrew.com
    "TheDataCrew.com"
[issue]: https://github.com/thedatacrew/SqlServer.Coding.Standards/issues
    "SQL style guide issues on GitHub"
[fork]: https://github.com/thedatacrew/SqlServer.Coding.Standards/fork/
    "Fork SQL style guide on GitHub"
[pull]: https://github.com/thedatacrew/SqlServer.Coding.Standards/pulls/
    "SQL style guide pull requests on GitHub"
[dl-md]: https://raw.githubusercontent.com/thedatacrew/SqlServer.Coding.Standards/master/documentation/sqlstyle.guide.md
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