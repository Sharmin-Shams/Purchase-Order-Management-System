-- Team Bravo Generation And Seed Data

USE master;
GO

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CapstoneProject')
BEGIN

    ALTER DATABASE CapstoneProject SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

	DROP DATABASE CapstoneProject;  
END
GO

CREATE DATABASE CapstoneProject;
GO

USE CapstoneProject
GO

---- BEGIN TABLE CREATION ----

CREATE TABLE Job (
    ID		INT				NOT NULL	IDENTITY(1,1),
	[Name]	NVARCHAR(255)	NOT NULL,

	CONSTRAINT PK_Job PRIMARY KEY(ID)
)
GO

CREATE TABLE Department (
    ID				INT				NOT NULL	IDENTITY(1,1),
	[Name]			NVARCHAR(128)	NOT NULL,
	[Description]	NVARCHAR(512)	NOT NULL,
	InvocationDate	DATE			NOT NULL,
	RowVer			ROWVERSION,

	CONSTRAINT PK_Department PRIMARY KEY(ID),
	CONSTRAINT UQ_Department_Name UNIQUE([Name])
)
GO

CREATE TABLE Employee (
    ID				INT				NOT NULL	IDENTITY(1,1),
	FirstName		NVARCHAR(50)	NOT NULL,
	LastName		NVARCHAR(50)	NOT NULL,
	MiddleInitial	NCHAR(1)		NULL,
	StreetAddress	NVARCHAR(255)	NOT NULL,
	City			NVARCHAR(255)	NOT NULL,
	PostalCode		NVARCHAR(7)		NOT NULL,
	DOB				DATE			NOT NULL,
	[SIN]			NVARCHAR(11)	NOT NULL,
	SeniorityDate	DATE			NOT NULL,
	JobStartDate	DATE			NOT NULL,
	WorkPhone		NVARCHAR(14)	NOT NULL,
	CellPhone		NVARCHAR(14)	NOT NULL,
	Email			NVARCHAR(255)	NOT NULL,
	IsSupervisor	BIT				NULL,
	OfficeLocation	NVARCHAR(255)	NOT NULL,
	[Status]		NVARCHAR(20)	NOT NULL,
	JobID			INT				NOT NULL,
	SupervisorID	INT				NULL,
	DepartmentID	INT				NULL,
	PasswordHash	NVARCHAR(64)	NOT NULL,
	PasswordSalt	BINARY(16)		NOT NULL,
	RetirementDate	DATE			NULL,
	TerminationDate	DATE			NULL,
	RowVer			ROWVERSION

    CONSTRAINT PK_Employee PRIMARY KEY(ID),
	CONSTRAINT FK_Employee_Job FOREIGN KEY (JobID) REFERENCES Job(ID),
	CONSTRAINT FK_Employee_Employee_SupervisorID FOREIGN KEY (SupervisorID) REFERENCES Employee(ID),
	CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentID) REFERENCES Department(ID),
	CONSTRAINT UQ_Employee_SIN UNIQUE([SIN])
)
GO

CREATE TABLE Rating (
	ID			INT				NOT NULL	IDENTITY(1,1),
	[Name]		NVARCHAR(25)	NOT NULL,

	CONSTRAINT PK_Rating PRIMARY KEY(ID),
)
GO

CREATE TABLE ReviewReminderLog (
	ReminderSentDate	Date	NOT NULL,

	CONSTRAINT UQ_ReviewReminderLog_ReminderSentDate UNIQUE(ReminderSentDate)
)
GO

CREATE TABLE Review (
	ID				INT				NOT NULL	IDENTITY(1,1),
	EmployeeID		INT				NOT NULL,
	SupervisorID	INT				NOT NULL,
	RatingID		INT				NOT NULL,
	[Year]			INT				NOT NULL,
	[Quarter]		TINYINT			NOT NULL,
	Comment			NVARCHAR(MAX)	NOT NULL,
	ReviewDate		DATE			NOT NULL,
	IsRead			BIT				NULL

	CONSTRAINT PK_Review PRIMARY KEY(ID),
	CONSTRAINT FK_Review_Employee_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES Employee(ID),
	CONSTRAINT FK_Review_Employee_SupervisorID FOREIGN KEY (SupervisorID) REFERENCES Employee(ID),
	CONSTRAINT FK_Review_Rating FOREIGN KEY (RatingID) REFERENCES Rating(ID),
	CONSTRAINT UQ_Review_EmployeeID_SupervisorID_Year_Quarter UNIQUE(EmployeeID,SupervisorID,[Year],[Quarter])
)
GO

CREATE TABLE PurchaseOrderStatus (

    ID			INT				PRIMARY KEY IDENTITY(1,1),

    StatusName	NVARCHAR(25)	NOT NULL
)
GO

CREATE TABLE PurchaseOrder (
    PurchaseOrderNumber INT PRIMARY KEY IDENTITY(00000101,1) ,
    EmployeeID INT NOT NULL,
    CreationDate DATE NOT NULL,
	RecordVersion ROWVERSION NOT NULL,
    TaxRate DECIMAL(5,2) NOT NULL,
    PurchaseOrderStatusID INT NOT NULL,
	LastModified DateTime ,

    CONSTRAINT FK_PurchaseOrder_Employee FOREIGN KEY (EmployeeID) REFERENCES Employee(ID),

	CONSTRAINT FK_PurchaseOrder_PurchaseOrderStatus FOREIGN KEY (PurchaseOrderStatusID) REFERENCES PurchaseOrderStatus(ID)
)
GO

CREATE TABLE PurchaseOrderItemStatus (
    ID INT PRIMARY KEY IDENTITY(1,1),
    StatusName NVARCHAR(25) NOT NULL
)
GO

CREATE TABLE PurchaseOrderItem (
    ID INT PRIMARY KEY IDENTITY(1,1),
    PurchaseOrderID INT NOT NULL,
    ItemName NVARCHAR(45) NOT NULL,
    ItemDescription NVARCHAR(255) NOT NULL,
    ItemQuantity INT NOT NULL ,
    ItemPrice MONEY NOT NULL ,
    ItemJustification NVARCHAR(255) NOT NULL,
    ItemPurchaseLocation NVARCHAR(255) NOT NULL,
    RecordVersion ROWVERSION NOT NULL,
    PurchaseOrderItemStatusID INT NOT NULL,
	DenialReason NVARCHAR(255) NULL,
	ModificationReason NVARCHAR(255) NULL,
    CONSTRAINT FK_PurchaseOrderItem_PurchaseOrder FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrder(PurchaseOrderNumber),
    CONSTRAINT FK_PurchaseOrderItem_PurchaseOrderItemStatus FOREIGN KEY (PurchaseOrderItemStatusID) REFERENCES PurchaseOrderItemStatus(ID)
)
GO



--- SEED DATA ---
INSERT INTO Job ([Name])
VALUES 
	('CEO'),
	('HR Manager'),
	('Project Manager'),
	('Product Manager'),
	('Developer Manager'),
	('Infrastructure Manager'),
	('Solution Architect'),
	('Software Engineer'),
	('Network Engineer'),
	('Database Administrator'),
	('Cybersecurity Specialist'),
	('QA Engineer'),
	('Technical Support Engineer'),
	('DevOps Engineer'),
	('UI/UX Designer')
GO

INSERT INTO Department ([Name], [Description], InvocationDate)
VALUES 
	('Executive', 'Oversees company strategy, decision-making, and overall operations.', CAST(GETDATE() AS DATE)),
	('Human Resources', 'Manages hiring, employee relations, benefits, and organizational culture.', CAST(GETDATE() AS DATE)),
	('Project/Product Management', 'Plans, coordinates, and manages projects/products from start to finish.', CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)),
	('Infrastructure / IT', 'Manages IT systems, networks, hardware, and ensures operational uptime.', CAST(DATEADD(MONTH, -1, GETDATE()) AS DATE)),
	('Development / Engineering', 'Builds and maintains software, systems, and technical solutions.', CAST(DATEADD(YEAR, -1, GETDATE()) AS DATE)),
	('Research and Development (R&D)', 'Focuses on creating and improving products and researching new technologies.', CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)),	-- INACTIVE
	('Data Science / Analytics', 'Analyzes data to generate insights, trends, and support business decisions.', CAST(DATEADD(YEAR, 1, GETDATE()) AS DATE))			-- INACTIVE
GO

INSERT INTO Rating ([Name])
VALUES 
	('Below Expectations')
	,('Meets Expectations')
	,('Exceeds Expectations')
GO

----- EMPLOYEE SEED DATA -----
INSERT INTO Employee (
	FirstName, 
	LastName, 
	MiddleInitial,
	StreetAddress,
	City, 
	PostalCode, 
	DOB, 
	[SIN], 
	SeniorityDate, 
	JobStartDate, 
	WorkPhone, 
	CellPhone, 
	Email,
	IsSupervisor, 
	OfficeLocation, 
	[Status],
	JobID, 
	SupervisorID, 
	DepartmentID,
	PasswordHash, 
	PasswordSalt, 
	TerminationDate,
	RetirementDate
)
VALUES 
	('Alan' , 'Smith' , 'A' , 'Gilbert St' , 'Moncton' , 'E1C 2A6'
	, CAST(DATEADD(YEAR, -25, GETDATE()) AS DATE) , '123 456 789'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(416) 555-1234' , '(780) 654-3210' , 'ceo@codenb.com' 
	, 1 , 'A123' , 'ACTIVE' , 1 , NULL , NULL
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Seul' , 'Woo' , 'Y' , 'Hastings' , 'Moncton' , 'E1C 2T6'
	, CAST(DATEADD(YEAR, -25, GETDATE()) AS DATE) , '234 567 891'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(902) 321-4567' , '(613) 789-9876' , 'seulwoohr@codenb.com'
	, 1 , 'T001' , 'ACTIVE' , 2 , 1 , 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Jae' , 'Yoo' , 'W' , 'Hastings' , 'Moncton' , 'E1C 2T6'
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE) , '708 678 902' --SIN
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(587) 777-8888' , '(204) 222-3344' , 'jaeyoohr@codenb.com'
	, 1 , 'T001' , 'ACTIVE'
	, 2	-- jobId
	, 1	-- supervisorId
	, 2 -- departmentId
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c' -- Password123!
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	-- 10 employees under EmpId 2

	,('Liam' , 'Smith' , 'A' , 'Maple St' , 'Toronto' , 'M5V 2N8'
	, CAST(DATEADD(YEAR, -30, GETDATE()) AS DATE) , '980 678 902'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(416) 555-1234' , '(647) 222-3344' , 'liamsmithhr@codenb.com'
	, 0 , 'T001' , 'ACTIVE' , 2 , 2 , 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)
	
	,('Noah' , 'Peters' , 'B' , 'Oak St' , 'Toronto' , 'M5V 1K4'
	, CAST(DATEADD(YEAR, -29, GETDATE()) AS DATE) , '567 456 789'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(416) 123-4567' , '(647) 111-2222' , 'noahpetershr@codenb.com'
	, NULL , 'T001' , 'ACTIVE' , 2 , 2 , 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)
	
	,('Emily' , 'Garcia' , 'L' , 'Cedar Rd' , 'Toronto' , 'M5V 3L9'
	, CAST(DATEADD(YEAR, -26, GETDATE()) AS DATE) , '234 567 890'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(416) 987-6543' , '(647) 333-2221' , 'emilygarciahr@codenb.com'
	, 0 , 'T001' , 'ACTIVE' , 2 , 2 , 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Lucas' , 'Brown' , 'T' , 'Birch Ave' , 'Toronto' , 'M5V 4T1'
	, CAST(DATEADD(YEAR, -35, GETDATE()) AS DATE) , '345 678 901'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(416) 222-3844' , '(647) 555-8888' , 'lucasbrownhr@codenb.com'
	, 0 , 'T001' , 'ACTIVE' , 2 , 2 , 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)
	
	,('Sophia' , 'Reed' , NULL , 'Maple Grove' , 'Toronto' , 'M5V 6Y2'
	, CAST(DATEADD(YEAR, -22, GETDATE()) AS DATE) , '456 789 012'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(416) 888-7707' , '(647) 409-6666' , 'sophiareedhr@codenb.com'
	, NULL , 'T001' , 'ACTIVE' , 2 , 2 , 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Mason' , 'Clark' , 'D', 'Willow St', 'Toronto', 'M5V 0A1'
	, CAST(DATEADD(YEAR, -28, GETDATE()) AS DATE), '567 890 123'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	,'(416) 321-9876', '(647) 777-9999', 'masonclarkhr@codenb.com'
	, 0, 'T001', 'ACTIVE', 2, 2, 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Ava', 'Davis', 'S', 'Spruce Rd', 'Toronto', 'M5V 2R9'
	, CAST(DATEADD(YEAR, -33, GETDATE()) AS DATE), '678 901 234'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(416) 654-0987', '(647) 222-1111', 'avadavishr@codenb.com'
	, NULL, 'T001', 'ACTIVE', 2, 2, 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Ethan', 'Wong', 'J', 'Hemlock Blvd', 'Toronto', 'M5V 5B2'
	, CAST(DATEADD(YEAR, -40, GETDATE()) AS DATE), '789 012 345'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(416) 111-2233', '(647) 123-4567', 'ethanwonghr@codenb.com'
	, 0, 'T001', 'ACTIVE', 2, 2, 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Isla', 'Nguyen', 'E', 'Aspen Dr', 'Toronto', 'M5V 8L6'
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE), '890 123 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(416) 567-4321', '(647) 888-9999', 'islanguyenhr@codenb.com'
	, NULL, 'T001', 'ACTIVE', 2, 2, 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Islette', 'Nguyen', 'E', 'Aspen Dr', 'Toronto', 'M5V 8L6'
	, CAST(DATEADD(YEAR, -36, GETDATE()) AS DATE), '455 554 667'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(416) 567-4321', '(647) 888-9999', 'isletteguyenhr@codenb.com'
	, NULL, 'T001', 'ACTIVE', 2, 2, 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL) -- 10th HR

	,('Inac', 'Tive', 'E', 'Brady', 'Moncton', 'M6V 9L6'
	, CAST(DATEADD(YEAR, -17, GETDATE()) AS DATE), '998 554 667'
	, CAST(DATEADD(DAY, -2, GETDATE()) AS DATE), CAST(DATEADD(DAY, -2, GETDATE()) AS DATE)
	, '(416) 567-3345', '(647) 888-9999', 'inactivehr@codenb.com'
	, 1, 'T001', 'TERMINATED', 2, 1, 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, CAST(DATEADD(DAY, -1, GETDATE()) AS DATE), NULL) -- TERMINATED HR EMP

	,('Scooter', 'Braun', NULL, 'Addison Lee', 'Toronto', 'M5V 8L6'
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE), '271 111 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(278) 567-4321', '(334) 888-9999', 'scooterregsv@codenb.com'
	, 1, 'R001', 'ACTIVE', 5, 1, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL) -- REGULAR SV

	,('Re', 'Tired', NULL, 'Mapleton', 'Moncton', 'M1V 7Z6'
	, CAST(DATEADD(YEAR, -65, GETDATE()) AS DATE), '280 554 667'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(416) 567-2341', '(647) 888-9999', 'retiredhrsv@codenb.com'
	, NULL, 'T002', 'RETIRED', 2, 2, 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, CAST(GETDATE() AS DATE)) -- RETIRED REG HR



 ------ MORE DATA FOR NON HR STAFF (TOTAL OF 2 NON HR SUPERVISORS WHERE 1 ALREADY HAVE 10 EMPLOYEES -------------------- 

	--FirstName,  --LastName,  --MiddleInitial, --StreetAddress, --City,  --PostalCode, 
	--DOB,  --[SIN], 
	--SeniorityDate,  --JobStartDate, 
	--WorkPhone,  --CellPhone,  --Email,
	--IsSupervisor,  --OfficeLocation,  --[Status], --JobID,  --SupervisorID,  --DepartmentID,
	--PasswordHash, 
	--PasswordSalt,  --TerminationDate, --RetirementDate

 	,('Tay', 'Swift', NULL, '245 King St W', 'Toronto', 'K2B 3H7'
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE), '789-012-345'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '416 582 7341', '(334) 888-9999', 'taytayregsv@codenb.com'
	, 1, 'R001', 'ACTIVE', 5, 1, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL) -- REGULAR SUPERVISOR (ID 17 WILL HAVE 10 EMPLOYEES)

	,('Emma', 'Reid', NULL, '87 17th Ave SW', 'Calgary', 'L5N 4T2'   ---- 1st REGULAR NON SV
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE), '436-012-345'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '604 321 8974', '(334) 888-9999', 'emmareg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Liam', 'Patterson', NULL, '1020 rue Sainte-Catherine O', 'Montréal', 'M4C 2W9'
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE), '678-901-234'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '403 776 1285', '(334) 888-9999', 'liamreg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Olivia', 'Tremblay', NULL, '550 Broadway Ave', 'Winnipeg', 'V6E 1L3'
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE), '102-938-475'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '902 445 9832', '(334) 888-9999', 'oliviareg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Noah', 'Singh', NULL, '33 Hollis St', 'Halifax', 'H3Z 2A8'
	, CAST(DATEADD(YEAR, -24, GETDATE()) AS DATE), '281 111 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(278) 567-4321', '514 672 4409', 'nsinghreg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Yoonchae', 'Jeung', NULL, '19 Rideau St', 'Ottawa', 'T5J 4Y1'
	, CAST(DATEADD(YEAR, -17, GETDATE()) AS DATE), '271 161 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(278) 567-4321', '613 829 3145', 'yoonchaereg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Megan', 'Skiendiel', NULL, '414 1st Ave N', 'Saskatoon', 'R2M 5B6'
	, CAST(DATEADD(YEAR, -19, GETDATE()) AS DATE), '271 111 656'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(278) 567-4321', '204 319 6720', 'meganreg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Daniela', 'Avanzini', NULL, '1085 Douglas St', 'Victoria', 'K2B 3H7'
	, CAST(DATEADD(YEAR, -20, GETDATE()) AS DATE), '271 181 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(278) 567-4321', '867 336 9082', 'danireg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Lara', 'Raj', NULL, 'Addison Lee', 'Toronto', 'S7K 3P4'
	, CAST(DATEADD(YEAR, -19, GETDATE()) AS DATE), '171 111 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '514 672 4409', '(334) 888-9999', 'larareg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Manon', 'Bannerman', NULL, '12 Water St', 'St. John''s', 'B3J 1V2'
	, CAST(DATEADD(YEAR, -22, GETDATE()) AS DATE), '256 111 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(278) 567-4321', '(334) 888-9999', 'mannonreg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	,('Sophia', 'Laforteza', NULL, '380 Smythe St', 'Fredericton', 'E1C 4K5'
	, CAST(DATEADD(YEAR, -22, GETDATE()) AS DATE), '242 111 456'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(278) 567-4321', '(334) 888-9999', 'sophreg@codenb.com'
	, NULL, 'R001', 'ACTIVE', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)   ---- 10th REGULAR NON SV

	,('Term', 'Minated', 'E', 'Main St', 'Moncton', 'M6V 9L6'
	, CAST(DATEADD(YEAR, -17, GETDATE()) AS DATE), '971 554 667'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(416) 567-3345', '(647) 888-9999', 'termregsv@codenb.com'
	, 1, 'R002', 'TERMINATED', 5, 1, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, CAST(GETDATE() AS DATE), NULL) -- TERMINATED REGULAR SV

	,('Sen', 'Niyor', NULL, 'Lockhart', 'Moncton', 'M5V 7Z6'
	, CAST(DATEADD(YEAR, -65, GETDATE()) AS DATE), '233 554 667'
	, CAST(GETDATE() AS DATE), CAST(GETDATE() AS DATE)
	, '(567) 211-2341', '(647) 888-9999', 'senyorreg@codenb.com'
	, NULL, 'R001', 'RETIRED', 5, 17, 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, CAST(GETDATE() AS DATE))  -- RETIRED REGULAR NON SV

	--- ADDED ONE EMP FOR HR SV 3
	,('Subin' , 'Chung' , 'H' , 'Maple St' , 'Toronto' , 'M5V 2N8'
	, CAST(DATEADD(YEAR, -30, GETDATE()) AS DATE) , '212 322 902'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(324) 111-2321' , '(257) 321-542' , 'subinjhr@codenb.com'
	, NULL , 'T001' , 'ACTIVE' , 2 , 3 , 2
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)

	--- ADDED ONE EMP FOR NON HR SV 15
	,('Hyeri' , 'Lee' , 'H' , 'Maple St' , 'Toronto' , 'M5V 2N8'
	, CAST(DATEADD(YEAR, -30, GETDATE()) AS DATE) , '213 323 903'
	, CAST(GETDATE() AS DATE) , CAST(GETDATE() AS DATE)
	, '(456) 555-2321' , '(435) 896-542' , 'heyheyhyerihr@codenb.com'
	, NULL , 'R001' , 'ACTIVE' , 5 , 15 , 5
	, '4da08134ef6e26a3345bbf5987d5eeb635f9f3ac063bdc76e08c45952042511c'
	, 0xE4FF57F1751B857509AF340C8A2DD09E, NULL, NULL)
GO

----- REVIEW SEED DATA -----
INSERT INTO Review (
	EmployeeID, 
	SupervisorID, 
	[Year], 
	[Quarter], 
	RatingID,
	Comment,
	ReviewDate, 
	IsRead
)
VALUES 
	-- Last year, This year's Q
	(4, 2
	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
	, 2, 'Good! hr 4'
	, DATEADD(YEAR, -1, GETDATE()), 1)

	,(5, 2
	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
	, 2, 'Good! hr 5'
	, DATEADD(YEAR, -1, GETDATE()), NULL)
	

	-- This year (or last), PREVIOUS quarter from today
	,(4, 2
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up hr 4'
	, DATEADD(MONTH, -3, GETDATE()), 1)

	,(5, 2
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up hr 5'
	, DATEADD(MONTH, -3, GETDATE()), NULL)

	-- This year, CURRENT quarter
	,(4, 2
	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	, 3, 'Amazing! hr 4'
	, GETDATE(), 1)

	,(5, 2
	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	, 3, 'Amazing! hr 5'
	, GETDATE(), NULL)

--  ONE REVIEW HR SV 3 FOR EMPLOYEE 30

-- Date in Q1 of last year
	,(30, 3
	, YEAR(DATEADD(YEAR, -1, GETDATE()))         -- Year = last year
	, 1                                          -- Quarter = Q1
	, 2, 'Keep it up hr 30'
	, DATEFROMPARTS(YEAR(DATEADD(YEAR, -1, GETDATE())), 1, 15), 1)     

	-- Last year, This year's Q
	,(30, 3
	, YEAR(GETDATE()) - 1
	, 2
	, 3, 'Amazing! hr 30'
	, DATEADD(YEAR, -1, GETDATE()), 1)

	-- Last year, This year's Q3
	,(30, 3
	, YEAR(GETDATE()) - 1      -- Last year
	, 3                       -- Quarter = Q3
	, 2, 'Keep it up hr 30'
	, DATEFROMPARTS(YEAR(GETDATE()) - 1, 8, 15), 1) 

-- This year (or last), PREVIOUS quarter from today
	,(30, 3
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up hr 30'
	, DATEADD(MONTH, -3, GETDATE()), NULL)

-- This year, CURRENT quarter
	--,(30, 3
	--, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	--, 3, 'Amazing! hr 30'
	--, GETDATE(), 1)

--- RETIRED EMP
	-- Last year, This year's Q
	,(16, 2
	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
	, 2, 'Good! retired hr 16'
	, DATEADD(YEAR, -1, GETDATE()), 1)

	-- This year, CURRENT quarter
	,(16, 2
	, YEAR(DATEADD(DAY, -1, GETDATE())), DATEPART(QUARTER, DATEADD(DAY, -1, GETDATE()))
	, 3, 'Amazing! retired hr 16'
	, GETDATE(), NULL)

	--EmployeeID, 
	--SupervisorID, 
	--[Year], 
	--[Quarter], 
	--RatingID,
	--Comment,
	--ReviewDate, 
	--IsRead

----- Supervisor EMP
	-- This year (or last), PREVIOUS quarter from today
	,(2, 1
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up hr sv 2'
	, DATEADD(MONTH, -3, GETDATE()), 1)

	,(3, 1
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up hr sv 3'
	, DATEADD(MONTH, -3, GETDATE()), NULL)

	-- This year, CURRENT quarter
	,(2, 1
	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	, 3, 'Amazing! hr sv 2'
	, GETDATE(), 1)

	,(3, 1
	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	, 3, 'Amazing! hr sv 3'
	, GETDATE(), NULL)

------------------- NON HR REVIEWS ------------------------------
	-- Last year, This year's Q
	,(20, 17
	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
	, 2, 'Good! reg 20'
	, DATEADD(YEAR, -1, GETDATE()), NULL)

	,(21, 17
	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
	, 2, 'Good! reg 21'
	, DATEADD(YEAR, -1, GETDATE()), 1)
	
	-- This year (or last), PREVIOUS quarter from today
	,(20, 17
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up reg 20'
	, DATEADD(MONTH, -3, GETDATE()), NULL)

	,(21, 17
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up reg 21'
	, DATEADD(MONTH, -3, GETDATE()), 1)

	-- This year, CURRENT quarter
	,(20, 17
	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	, 3, 'Amazing! reg 20'
	, GETDATE(), NULL)

	,(21, 17
	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	, 3, 'Amazing! reg 21'
	, GETDATE(), 1)

---- TERMINATED emp
	-- Last year, This year's Q
	,(28, 1
	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
	, 1, 'Needs Improvement reg terminated 28'
	, DATEADD(YEAR, -1, GETDATE()), NULL)

	-- This year, CURRENT quarter
	,(28, 1
	, YEAR(DATEADD(DAY, -1, GETDATE())), DATEPART(QUARTER, DATEADD(DAY, -1, GETDATE()))
	, 1, 'Needs Improvement reg terminated 28'
	, GETDATE(), 1)

----- Supervisor EMP
	-- This year (or last), PREVIOUS quarter from today
	,(17, 1
	, YEAR(DATEADD(MONTH, -3, GETDATE()))
	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
	, 2, 'Keep it up reg sv 17'
	, DATEADD(MONTH, -3, GETDATE()), NULL)

	-- This year, CURRENT quarter
	,(17, 1
	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
	, 3, 'Amazing! reg sv 17'
	, GETDATE(), 1)

--  ONE REVIEW NON HR SV 15 FOR EMPLOYEE 31
	-- Last year, This year's Q
	,(31, 15
	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
	, 3, 'Amazing! reg 31'
	, DATEADD(YEAR, -1, GETDATE()), 1)

GO

-- Insert into PurchaseOrderStatus
INSERT INTO PurchaseOrderStatus ( StatusName)
VALUES 
    ( 'Pending'),
    ( 'Approved'),
    ( 'Denied'),
	('Under Review'),
	('Closed');

	GO
-- Insert into PurchaseOrderItemStatus
INSERT INTO PurchaseOrderItemStatus (StatusName)
VALUES 
     ( 'Pending'),
    ( 'Approved'),
    ( 'Denied'),
	('Under Review'),
	('Closed');
GO

INSERT INTO PurchaseOrder (EmployeeID, CreationDate, TaxRate, PurchaseOrderStatusID)
VALUES
    (1, '2025-04-01', 0.15, 1),
    (2, '2025-04-03', 0.15, 4),
    (3, '2025-03-30', 0.15, 4),
    (4, '2025-03-25', 0.15, 5),
    (5, '2025-03-20', 0.15, 4),
    (8, '2025-03-15', 0.15, 1),
    (2, '2025-03-10', 0.15, 1),
    (3, '2025-03-05', 0.15, 4),
    (15, '2025-02-28', 0.15, 4),
    (8, '2025-02-22', 0.15, 4),
    (15, '2025-02-18', 0.15, 5),
    (8, '2025-02-10', 0.15, 1),
    (3, '2025-02-02', 0.15, 5),
    (4, '2025-01-28', 0.15, 4),
    (8, '2025-01-20', 0.15, 5);
GO
	-- Insert into PurchaseOrderItem 
INSERT INTO PurchaseOrderItem (PurchaseOrderID, ItemName, ItemDescription, ItemQuantity, ItemPrice, ItemJustification, ItemPurchaseLocation, PurchaseOrderItemStatusID)
VALUES
    (101, 'Laptop', 'Dell Latitude 5540', 2, 1250.00, 'New employee equipment', 'Walmart', 1),
    (101, 'Mouse', 'Wireless Optical Mouse', 5, 25.00, 'Office supplies', 'Best Buy', 1),
    (102, 'Monitor', '24" Full HD Monitor', 4, 200.00, 'Expand workstation', 'Walmart', 2),
    (103, 'Keyboard', 'Mechanical Keyboard', 3, 90.00, 'Workstation upgrade', 'Best Buy', 1),
    (104, 'Printer', 'HP LaserJet Pro', 1, 400.00, 'Office printing needs', 'Walmart', 3),
    (105, 'Tablet', 'iPad Air', 2, 600.00, 'Mobile presentations', 'Walmart', 2),
    (106, 'Desk Chair', 'Ergonomic Chair', 5, 300.00, 'New office setup', 'Best Buy', 1),
    (107, 'Desk', 'Standing Desk', 2, 450.00, 'Office upgrade', 'Best Buy', 1),
    (108, 'Software License', 'MS Office 365', 10, 120.00, 'Software for new hires', 'Costco', 1),
    (109, 'External Hard Drive', '2TB Backup Drive', 4, 150.00, 'Data backup', 'Costco', 2),
    (110, 'Webcam', 'HD Webcam', 6, 80.00, 'Virtual meetings', 'Costco', 2),
    (111, 'Conference Phone', 'Polycom IP Phone', 1, 700.00, 'Meeting room upgrade', 'Staples', 2),
    (112, 'Whiteboard', 'Magnetic Whiteboard', 3, 150.00, 'Meeting room upgrade', 'Staples', 1),
    (113, 'Coffee Machine', 'Commercial Coffee Maker', 1, 900.00, 'Employee lounge', 'Staples', 2),
    (114, 'Server Rack', 'Network Server Rack', 1, 1200.00, 'Data center expansion', 'Walmart', 3),
    (115, 'Firewall Appliance', 'Enterprise Firewall', 1, 350.00, 'Network security', 'Staples', 2),
    (102, 'Desk Lamp', 'LED Desk Lamp', 4, 40.00, 'Workstation lighting', 'Best Buy', 1),
    (103, 'Shredder', 'Cross-cut Paper Shredder', 2, 250.00, 'Secure document disposal', 'Best Buy', 2),
    (104, 'Router', 'Business-Class Router', 1, 600.00, 'Internet upgrade', 'Walmart', 3),
    (105, 'Scanner', 'Duplex Document Scanner', 1, 450.00, 'Digital archiving', 'Costco', 2),
    (106, 'Smart TV', '75" Smart TV', 1, 1200.00, 'Conference room display', 'Walmart', 1),
    (107, 'HDMI Cable', '6ft HDMI Cable', 10, 15.00, 'Accessory for TV/Projectors', 'Staples', 1),
    (108, 'Projector', 'Business Projector', 1, 900.00, 'Meeting presentations', 'Best Buy', 2),
    (109, 'Backup Generator', 'Industrial Generator', 1, 5000.00, 'Power backup', 'Costco', 3),
	(110, 'Laptop', 'Dell Latitude 5540', 2, 1250.00, 'New employee equipment', 'Costco', 1),
    (101, 'Mouse', 'Wireless Optical Mouse', 5, 25.00, 'Office supplies', 'Best Buy', 1),
    (110, 'Monitor', '24" Full HD Monitor', 4, 200.00, 'Expand workstation', 'Costco', 1),
    (101, 'Security Camera', 'IP Security Camera', 5, 250.00, 'Office surveillance', 'Best Buy', 1);

GO
-----------employee 5----------------
INSERT INTO PurchaseOrder (EmployeeID, CreationDate, TaxRate, PurchaseOrderStatusID)
VALUES
(5, '2024-06-15', 0.15, 5),
(5, '2024-07-15', 0.15, 5),
(5, '2024-08-15', 0.15, 5),
(5, '2024-09-15', 0.15, 5),
(5, '2024-10-15', 0.15, 5),
(5, '2024-11-15', 0.15, 5),
(5, '2024-12-15', 0.15, 5),
(5, '2025-01-15', 0.15, 5),
(5, '2025-02-15', 0.15, 5),
(5, '2025-03-15', 0.15, 5),
(5, '2025-04-15', 0.15, 5),
(5, '2025-05-15', 0.15, 5);
-----------------------Employee 2-----------------
INSERT INTO PurchaseOrder (EmployeeID, CreationDate, TaxRate, PurchaseOrderStatusID)
VALUES
(2, '2024-06-20', 0.15, 5),
(2, '2024-07-20', 0.15, 5),
(2, '2024-08-20', 0.15, 5),
(2, '2024-09-20', 0.15, 5),
(2, '2024-10-20', 0.15, 5),
(2, '2024-11-20', 0.15, 5),
(2, '2024-12-20', 0.15, 5),
(2, '2025-01-20', 0.15, 5),
(2, '2025-02-20', 0.15, 5),
(2, '2025-03-20', 0.15, 5),
(2, '2025-04-20', 0.15, 5),
(2, '2025-05-20', 0.15, 5);

----------item employee-8----------
INSERT INTO PurchaseOrderItem (PurchaseOrderID, ItemName, ItemDescription, ItemQuantity, ItemPrice, ItemJustification, ItemPurchaseLocation, PurchaseOrderItemStatusID)
VALUES
(116, 'Notepad', 'A5 Notepad', 10, 3.00, 'Meeting notes', 'Staples', 2),
(116, 'Pen Set', 'Pack of pens', 5, 5.00, 'Writing tools', 'Staples', 3),
(117, 'Office Chair', 'Mesh Chair', 1, 180.00, 'Seating', 'Walmart', 2),
(117, 'Footrest', 'Ergonomic Footrest', 1, 40.00, 'Comfort', 'Amazon', 3),
(118, 'Paper Ream', '500 sheets A4', 10, 6.00, 'Printing', 'Costco', 2),
(118, 'Binder', '2-inch binders', 3, 4.00, 'Filing', 'Staples', 3),
(119, 'Monitor Arm', 'Adjustable arm', 2, 60.00, 'Ergonomic setup', 'Best Buy', 2),
(119, 'Keyboard Tray', 'Slide tray', 1, 30.00, 'Typing posture', 'Best Buy', 3),
(120, 'HDMI Cable', '10ft HDMI', 3, 12.00, 'Connection', 'Amazon', 2),
(120, 'Laptop Stand', 'Aluminum Stand', 2, 35.00, 'Screen height', 'Walmart', 3),
(121, 'Desk Organizer', 'Office tray', 1, 20.00, 'Desk cleanup', 'Staples', 2),
(121, 'Stapler', 'Heavy Duty', 1, 10.00, 'Documents', 'Staples', 3),
(122, 'USB Hub', '4-Port USB 3.0', 2, 18.00, 'Port expansion', 'Amazon', 2),
(122, 'Mouse Pad', 'Gel wrist', 2, 8.00, 'Comfort', 'Walmart', 3),
(123, 'Label Maker', 'Labeler', 1, 40.00, 'Labeling', 'Best Buy', 2),
(123, 'Filing Cabinet', 'Metal 2-drawer', 1, 120.00, 'Storage', 'Walmart', 3),
(124, 'Extension Cord', '6-outlet', 2, 15.00, 'Power', 'Staples', 2),
(124, 'Tape Dispenser', 'Heavy', 1, 7.00, 'Packaging', 'Costco', 3),
(125, 'Wireless Mouse', 'Bluetooth mouse', 1, 25.00, 'Navigation', 'Amazon', 2),
(125, 'Whiteboard Markers', 'Pack of 5', 1, 10.00, 'Meetings', 'Walmart', 3),
(126, 'Trash Bin', 'Office bin', 1, 12.00, 'Cleanup', 'Staples', 2),
(126, 'Air Duster', 'Compressed Air', 2, 6.00, 'Cleaning', 'Best Buy', 3),
(127, 'Backup Battery', 'UPS 600VA', 1, 80.00, 'Power backup', 'Amazon', 2),
(127, 'Network Cable', 'Cat6 25ft', 1, 10.00, 'Networking', 'Costco', 3);

------------------item employee-2------------------
INSERT INTO PurchaseOrderItem (PurchaseOrderID, ItemName, ItemDescription, ItemQuantity, ItemPrice, ItemJustification, ItemPurchaseLocation, PurchaseOrderItemStatusID)
VALUES
(128, 'Router', 'Wireless Router', 1, 90.00, 'Internet', 'Best Buy', 2),
(128, 'Modem', 'Cable modem', 1, 70.00, 'ISP connection', 'Best Buy', 3),
(129, 'Storage Box', 'Plastic', 3, 10.00, 'Storage', 'Costco', 2),
(129, 'Clips', 'Binder clips', 10, 0.80, 'Docs', 'Staples', 3),
(130, 'Chair Mat', 'Floor mat', 1, 30.00, 'Protection', 'Walmart', 2),
(130, 'Pen Holder', 'Desk organizer', 1, 5.00, 'Pens', 'Amazon', 3),
(131, 'Sticky Notes', '3x3 pads', 6, 1.00, 'Quick notes', 'Staples', 2),
(131, 'Clipboard', 'A4 board', 2, 4.00, 'Writing', 'Walmart', 3),
(132, 'Portable Fan', 'USB fan', 1, 18.00, 'Cooling', 'Best Buy', 2),
(132, 'Notebook Stand', 'Adjustable', 1, 32.00, 'Ergonomic', 'Costco', 3),
(133, 'Bookend', 'Metal stand', 2, 6.00, 'Shelving', 'Staples', 2),
(133, 'Envelope Pack', '100 pcs', 1, 10.00, 'Mailing', 'Amazon', 3),
(134, 'Wipes', 'Cleaning wipes', 3, 5.00, 'Sanitation', 'Walmart', 2),
(134, 'Desk Clock', 'Digital', 1, 15.00, 'Time', 'Costco', 3),
(135, 'USB-C Cable', 'Fast charge', 2, 12.00, 'Charging', 'Amazon', 2),
(135, 'Smart Plug', 'WiFi plug', 1, 20.00, 'Automation', 'Walmart', 3),
(136, 'Bluetooth Speaker', 'Portable', 1, 40.00, 'Audio', 'Best Buy', 2),
(136, 'Laser Pointer', 'Presentation', 1, 10.00, 'Meeting', 'Staples', 3),
(137, 'File Folders', '25-pack', 1, 20.00, 'Filing', 'Costco', 2),
(137, 'Wall Calendar', 'Monthly', 1, 12.00, 'Schedule', 'Amazon', 3),
(138, 'Notebook Pack', '3-pack', 1, 8.00, 'Notes', 'Staples', 2),
(138, 'Flash Drive', '64GB', 2, 18.00, 'Storage', 'Best Buy', 3),
(139, 'Cable Organizer', 'Zip ties', 1, 6.00, 'Wiring', 'Amazon', 2),
(139, 'Whiteboard Eraser', 'Magnetic', 1, 4.00, 'Whiteboard', 'Walmart', 3);

-----------------------------------------------
IF NOT EXISTS(SELECT 1 FROM sys.types WHERE name = 'PurchaseOrderItemTableType' AND is_table_type = 1)
BEGIN
    CREATE TYPE PurchaseOrderItemTableType AS TABLE
    (	ID INT,
        ItemName NVARCHAR(45),
        ItemDescription NVARCHAR(255),
        ItemQuantity INT,
        ItemPrice MONEY,
        ItemJustification NVARCHAR(255),
        ItemPurchaseLocation NVARCHAR(255)
    )
END
GO

CREATE OR ALTER PROCEDURE spCreatePurchaseOrderWithItems
    @PurchaseOrderNumber INT OUTPUT,
    @RecordVersion ROWVERSION OUTPUT,
    @EmployeeID INT,
     @TaxRate DECIMAL(5,2),
    @PurchaseOrderStatusID INT,
	@PurchaseOrderItemStatusID INT,
	@PurchaseOrderItem PurchaseOrderItemTableType READONLY
AS
BEGIN
 IF NOT EXISTS (SELECT 1 FROM @PurchaseOrderItem)
    BEGIN
  
        SET @PurchaseOrderNumber = 0;
        SET @RecordVersion = NULL;
		
        RETURN;
    END
    BEGIN TRY
        BEGIN TRAN;

       
        INSERT INTO PurchaseOrder (EmployeeID, CreationDate, TaxRate, PurchaseOrderStatusID)
        VALUES (@EmployeeID, GETDATE(), @TaxRate, @PurchaseOrderStatusID);

        SET @PurchaseOrderNumber = SCOPE_IDENTITY();

     
        INSERT INTO PurchaseOrderItem (
            PurchaseOrderID,
            ItemName,
            ItemDescription,
            ItemQuantity,
            ItemPrice,
            ItemJustification,
            ItemPurchaseLocation,
            PurchaseOrderItemStatusID
        )
        SELECT
            @PurchaseOrderNumber,
            ItemName,
            ItemDescription,
            ItemQuantity,
            ItemPrice,
            ItemJustification,
            ItemPurchaseLocation,
            @PurchaseOrderItemStatusID
        FROM @PurchaseOrderItem;

        -- Get the RowVersion for concurrency
        SET @RecordVersion = (SELECT RecordVersion FROM PurchaseOrder WHERE PurchaseOrderNumber = @PurchaseOrderNumber);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
	IF @@TRANCOUNT >0
        ROLLBACK TRAN;
        THROW;
    END CATCH
END

GO


CREATE OR ALTER PROCEDURE spSearchPurchaseOrdersByDepartment
    @DepartmentId INT
AS
BEGIN
    SELECT
        po.PurchaseOrderNumber,
        po.CreationDate,
        sup.FirstName + 
		  CASE 
			WHEN sup.MiddleInitial IS NOT NULL AND sup.MiddleInitial <> '' 
			THEN ' ' + sup.MiddleInitial 
			ELSE '' 
		  END + 
		  ' ' + sup.LastName AS SupervisorName,
        pos.StatusName AS PurchaseOrderStatus
    FROM PurchaseOrder po
    INNER JOIN Employee e ON po.EmployeeID = e.ID
    INNER JOIN Department d ON e.DepartmentID = d.ID
    INNER JOIN Employee sup ON e.SupervisorID = sup.ID
    INNER JOIN PurchaseOrderStatus pos ON po.PurchaseOrderStatusID = pos.ID
    WHERE (pos.ID=1 OR pos.ID=4)
      AND d.ID = @DepartmentId AND d.InvocationDate<= CAST(GETDATE() AS DATE)
    ORDER BY po.CreationDate ASC;
END
GO

CREATE OR ALTER PROCEDURE spSearchPurchaseOrdersByEmployee
    @EmployeeID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @PurchaseOrderNumber INT = NULL
AS
BEGIN
    SELECT
        po.PurchaseOrderNumber,
        po.CreationDate,
        pos.StatusName AS PurchaseOrderStatus,

        -- Exclude denied items from financial totals
        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN i.ItemPrice * i.ItemQuantity ELSE 0 END) AS Subtotal,
        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN i.ItemPrice * i.ItemQuantity * po.TaxRate ELSE 0 END) AS TaxTotal,
        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN i.ItemPrice * i.ItemQuantity * (1 + po.TaxRate) ELSE 0 END) AS GrandTotal

    FROM PurchaseOrder po
    INNER JOIN PurchaseOrderStatus pos ON po.PurchaseOrderStatusID = pos.ID
    INNER JOIN PurchaseOrderItem i ON po.PurchaseOrderNumber = i.PurchaseOrderID
    INNER JOIN PurchaseOrderItemStatus pis ON i.PurchaseOrderItemStatusID = pis.ID

    WHERE po.EmployeeID = @EmployeeID
        AND (@StartDate IS NULL OR po.CreationDate >= @StartDate)
        AND (@EndDate IS NULL OR po.CreationDate <= @EndDate)
        AND (@PurchaseOrderNumber IS NULL OR po.PurchaseOrderNumber = @PurchaseOrderNumber)

    GROUP BY po.PurchaseOrderNumber, po.CreationDate, pos.StatusName, po.TaxRate
    ORDER BY po.CreationDate DESC;
END
GO

GO

CREATE OR ALTER PROCEDURE spGetPurchaseOrderDetails
    @PurchaseOrderNumber INT
AS
BEGIN
    SELECT
        po.PurchaseOrderNumber,
        po.CreationDate,
        e.FirstName + 
            CASE 
                WHEN e.MiddleInitial IS NOT NULL AND e.MiddleInitial <> '' 
                THEN ' ' + e.MiddleInitial 
                ELSE '' 
            END + 
            ' ' + e.LastName AS EmployeeFullName,

        d.Name AS DepartmentName,

        s.FirstName + 
            CASE 
                WHEN s.MiddleInitial IS NOT NULL AND s.MiddleInitial <> '' 
                THEN ' ' + s.MiddleInitial 
                ELSE '' 
            END + 
            ' ' + s.LastName AS SupervisorFullName,

        ps.StatusName,
        po.TaxRate,
        po.RecordVersion,
		po.EmployeeID,
        i.ID,
        i.ItemName,
        i.ItemDescription,
        i.ItemQuantity,
        i.ItemPrice,
        i.RecordVersion,
        i.ItemJustification,
        i.ItemPurchaseLocation,
		i.DenialReason,
		i.ModificationReason,
        pis.StatusName AS ItemStatus,

        (i.ItemPrice * i.ItemQuantity) AS ItemSubtotal,
        (i.ItemPrice * i.ItemQuantity) * po.TaxRate AS ItemTaxTotal,
        (i.ItemPrice * i.ItemQuantity) * (1 + po.TaxRate) AS ItemGrandTotal,

        -- Updated total calculations: only include items that are NOT denied
        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN i.ItemPrice * i.ItemQuantity ELSE 0 END) 
            OVER() AS PurchaseSubtotal,

        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN i.ItemPrice * i.ItemQuantity * po.TaxRate ELSE 0 END) 
            OVER() AS PurchaseTaxTotal,

        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN i.ItemPrice * i.ItemQuantity * (1 + po.TaxRate) ELSE 0 END) 
            OVER() AS PurchaseGrandTotal

    FROM PurchaseOrder po
    INNER JOIN Employee e ON po.EmployeeID = e.ID
    LEFT JOIN Department d ON e.DepartmentID = d.ID
    LEFT JOIN Employee s ON e.SupervisorID = s.ID
    INNER JOIN PurchaseOrderStatus ps ON po.PurchaseOrderStatusID = ps.ID
    INNER JOIN PurchaseOrderItem i ON i.PurchaseOrderID = po.PurchaseOrderNumber
    INNER JOIN PurchaseOrderItemStatus pis ON i.PurchaseOrderItemStatusID = pis.ID
    WHERE po.PurchaseOrderNumber = @PurchaseOrderNumber;
END
GO
CREATE OR ALTER PROCEDURE spSearchPurchaseOrdersBySupervisorByDepartment
    @EmployeeID INT,
    @PONumber NVARCHAR(8) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @POStatus NVARCHAR(50) = NULL, 
    @EmployeeFullName NVARCHAR(150) = NULL
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Employee WHERE ID = @EmployeeID AND IsSupervisor = 1
    )
    BEGIN
        THROW 50002, 'Access denied: the employee is not a supervisor.', 1;
    END

    DECLARE @DepartmentID INT;

    -- Get the department of the supervisor
    SELECT @DepartmentID = DepartmentID
    FROM Employee
    WHERE ID = @EmployeeID;

    -- If no department found, exit
    IF @DepartmentID IS NULL RETURN;

    SELECT 
        po.PurchaseOrderNumber AS [PONumber],
        po.CreationDate AS [POCreationDate],

        LTRIM(RTRIM(
            e.FirstName + ' ' +
            CASE 
                WHEN e.MiddleInitial IS NOT NULL AND e.MiddleInitial <> '' 
                    THEN e.MiddleInitial + ' ' 
                ELSE ''
            END +
            e.LastName
        )) AS EmployeeFullName,

        pos.StatusName AS [PO Status],

        -- Exclude Denied items from totals
        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN poi.ItemQuantity * poi.ItemPrice ELSE 0 END) AS SubTotal,
        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN poi.ItemQuantity * poi.ItemPrice * po.TaxRate ELSE 0 END) AS TaxTotal,
        SUM(CASE WHEN pis.StatusName <> 'Denied' THEN poi.ItemQuantity * poi.ItemPrice * (1 + po.TaxRate) ELSE 0 END) AS GrandTotal

    FROM PurchaseOrder po
    INNER JOIN Employee e ON po.EmployeeID = e.ID
    INNER JOIN PurchaseOrderStatus pos ON po.PurchaseOrderStatusID = pos.ID
    INNER JOIN PurchaseOrderItem poi ON po.PurchaseOrderNumber = poi.PurchaseOrderID
    INNER JOIN PurchaseOrderItemStatus pis ON poi.PurchaseOrderItemStatusID = pis.ID

    WHERE
        e.DepartmentID = @DepartmentID
        AND (
            @PONumber IS NULL 
            OR RIGHT('00000000' + CAST(po.PurchaseOrderNumber AS VARCHAR(8)), 8) = RIGHT('00000000' + @PONumber, 8)
        )
        AND (@StartDate IS NULL OR po.CreationDate >= @StartDate)
        AND (@EndDate IS NULL OR po.CreationDate <= @EndDate)
        AND (@POStatus IS NULL OR @POStatus = 'All' OR pos.StatusName = @POStatus)
        AND (
            @EmployeeFullName IS NULL 
            OR LTRIM(RTRIM(
                e.FirstName + ' ' +
                CASE 
                    WHEN e.MiddleInitial IS NOT NULL AND e.MiddleInitial <> '' 
                        THEN e.MiddleInitial + ' ' 
                    ELSE ''
                END +
                e.LastName
            )) LIKE '%' + @EmployeeFullName + '%'
        )

    GROUP BY 
        po.PurchaseOrderNumber,
        po.CreationDate,
        e.FirstName,
        e.MiddleInitial,
        e.LastName,
        pos.StatusName,
        po.TaxRate

    ORDER BY po.CreationDate ASC;
END
GO

---sp2---
--------------------Item decision---------------
CREATE OR ALTER PROCEDURE spProcessItemDecisionAndCheckLast
    @ItemID INT,
    @UpdatedItemsStatusID INT,
    @DenialReason NVARCHAR(255),
    @IsLastItem BIT OUTPUT
AS
BEGIN
    DECLARE @PONumber INT;

    -- Get the PO number for the item
    SELECT TOP 1 @PONumber = PurchaseOrderID
    FROM PurchaseOrderItem
    WHERE ID = @ItemID;

    -- Prevent updates if PO is already closed
    IF EXISTS (
        SELECT 1 FROM PurchaseOrder
        WHERE PurchaseOrderNumber = @PONumber
        AND PurchaseOrderStatusID = 5
    )
    BEGIN
        THROW 50000, 'Cannot process item on a closed purchase order.', 1;
    END

    -- Update item status
    UPDATE PurchaseOrderItem
    SET PurchaseOrderItemStatusID = @UpdatedItemsStatusID,
        DenialReason = CASE WHEN @UpdatedItemsStatusID = 3 THEN @DenialReason ELSE NULL END
    WHERE ID = @ItemID;

    -- Set PO to Under Review if currently Pending
    UPDATE PurchaseOrder
    SET PurchaseOrderStatusID = 4
    WHERE PurchaseOrderNumber = @PONumber AND PurchaseOrderStatusID = 1;

    -- Check if this was the last unprocessed item
    IF EXISTS (
        SELECT 1 FROM PurchaseOrderItem
        WHERE PurchaseOrderID = @PONumber AND PurchaseOrderItemStatusID = 1 -- Pending
    )
        SET @IsLastItem = 0;
    ELSE
        SET @IsLastItem = 1;
END
GO

----------CLOSE PO--------

CREATE OR ALTER PROCEDURE spClosePurchaseOrder
    @PONumber INT
AS
BEGIN
    -- Step 1: Check if any items are still pending
    IF EXISTS (
        SELECT 1 
        FROM PurchaseOrderItem 
        WHERE PurchaseOrderID = @PONumber AND PurchaseOrderItemStatusID = 1
    )
    BEGIN
        -- Fail if any items are pending
        THROW 50000, 'Cannot close PO. One or more items are still pending.', 1;
    END

    -- Step 2: Close the PO only if not already closed
    UPDATE PurchaseOrder
    SET PurchaseOrderStatusID = 5-- Closed
    WHERE PurchaseOrderNumber = @PONumber AND PurchaseOrderStatusID != 5;
END
GO

CREATE OR ALTER PROCEDURE spGetEmployeeEmailForPO
    @PONumber INT
AS
BEGIN
    SELECT E.Email
    FROM PurchaseOrder PO
    INNER JOIN Employee E ON PO.EmployeeID = E.ID
    WHERE PO.PurchaseOrderNumber = @PONumber;
END
GO
----------------------update item---------------


IF NOT EXISTS(SELECT 1 FROM sys.types WHERE name = 'PurchaseOrderItemUpdateTableType' AND is_table_type = 1)
BEGIN


CREATE TYPE PurchaseOrderItemUpdateTableType AS TABLE
(
    ID INT,
    PurchaseOrderID INT,
    ItemName NVARCHAR(45),
    ItemDescription NVARCHAR(255),
    ItemQuantity INT ,
    ItemPrice MONEY ,
    ItemJustification NVARCHAR(255),
    ItemPurchaseLocation NVARCHAR(255),
    PurchaseOrderItemStatusID INT,
	DenialReason NVARCHAR(255),
	ModificationReason NVARCHAR(255),
	RecordVersion BINARY(8) 
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'DeletedItemIdTableType' AND is_table_type = 1)
BEGIN
    CREATE TYPE DeletedItemIdTableType AS TABLE (
        ID INT
    );
END
GO

CREATE OR ALTER PROCEDURE spUpdatePurchaseOrderWithItems
    @PurchaseOrderRecordVersion ROWVERSION OUTPUT,
    @PurchaseOrderNumber INT,
    @UpdatedItems PurchaseOrderItemUpdateTableType READONLY,
	@DeletedItemIds DeletedItemIdTableType READONLY
AS
BEGIN
    BEGIN TRY
        -- Concurrency check for the purchase order
        IF @PurchaseOrderRecordVersion <> (
            SELECT RecordVersion 
            FROM PurchaseOrder 
            WHERE PurchaseOrderNumber = @PurchaseOrderNumber
        )
        BEGIN
            THROW 51001, 'The purchase order has been updated since you last retrieved it.', 1;
        END

        -- Concurrency check for updated items
        IF EXISTS (
            SELECT 1
            FROM PurchaseOrderItem i
            INNER JOIN @UpdatedItems u ON i.ID = u.ID
            WHERE i.RecordVersion <> u.RecordVersion
        )
        BEGIN
            THROW 51002, 'Items have been updated since you last retrieved them.', 1;
        END

        BEGIN TRAN;

        -- Update existing items (if status is Pending)
        UPDATE i
        SET 
            i.ItemName = u.ItemName,
            i.ItemDescription = u.ItemDescription,
            i.ItemQuantity = u.ItemQuantity,
            i.ItemPrice = u.ItemPrice,
            i.ItemJustification = u.ItemJustification,
            i.ItemPurchaseLocation = u.ItemPurchaseLocation,
            i.PurchaseOrderItemStatusID = u.PurchaseOrderItemStatusID,
            i.DenialReason = u.DenialReason,
			i.ModificationReason = u.ModificationReason
			
			
        FROM PurchaseOrderItem i
        INNER JOIN @UpdatedItems u ON i.ID = u.ID
        WHERE i.PurchaseOrderID = @PurchaseOrderNumber
          AND i.PurchaseOrderItemStatusID = 1;

        -- Insert new items (ID = 0)
        INSERT INTO PurchaseOrderItem (
            PurchaseOrderID,
            ItemName,
            ItemDescription,
            ItemQuantity,
            ItemPrice,
            ItemJustification,
            ItemPurchaseLocation,
            PurchaseOrderItemStatusID,
            DenialReason,
			ModificationReason
        )
        SELECT
            u.PurchaseOrderID,
            u.ItemName,
            u.ItemDescription,
            u.ItemQuantity,
            u.ItemPrice,
            u.ItemJustification,
            u.ItemPurchaseLocation,
            u.PurchaseOrderItemStatusID,
            u.DenialReason,
			u.ModificationReason
        FROM @UpdatedItems u
        WHERE u.ID = 0;


		----delete item
		DELETE FROM PurchaseOrderItem
			WHERE ID IN (SELECT ID FROM @DeletedItemIds)
			AND PurchaseOrderID = @PurchaseOrderNumber;
        --- update to PurchaseOrder so RecordVersion changes
        UPDATE PurchaseOrder
        SET LastModified = GETDATE()
        WHERE PurchaseOrderNumber = @PurchaseOrderNumber;

        COMMIT TRAN;

        -- Return the updated record version
        SET @PurchaseOrderRecordVersion = (
            SELECT RecordVersion 
            FROM PurchaseOrder 
            WHERE PurchaseOrderNumber = @PurchaseOrderNumber
        );
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO
-------------Dashboard----------------------

CREATE OR ALTER PROCEDURE spGetEmployeeMonthlyExpenses
    @EmployeeID INT
AS
BEGIN
    SELECT 
        FORMAT(po.CreationDate, 'yyyy-MM') AS Month,
        SUM(CASE 
                WHEN pis.StatusName <> 'Denied' 
                THEN poi.ItemQuantity * poi.ItemPrice * (1 + po.TaxRate) 
                ELSE 0 
            END) AS ExpenseTotal
    FROM PurchaseOrder po
    JOIN PurchaseOrderItem poi ON po.PurchaseOrderNumber = poi.PurchaseOrderID
    JOIN PurchaseOrderItemStatus pis ON poi.PurchaseOrderItemStatusID = pis.ID
    WHERE po.EmployeeID = @EmployeeID
	AND	po.PurchaseOrderStatusID=5
      AND po.CreationDate >= DATEADD(MONTH, -11, GETDATE())
    GROUP BY FORMAT(po.CreationDate, 'yyyy-MM')
    ORDER BY Month
END


GO
-----------------
CREATE OR ALTER PROCEDURE spGetSupervisorMonthlyExpenses
    @EmployeeID INT
AS
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM Employee WHERE ID = @EmployeeID AND IsSupervisor = 1
    )
    BEGIN
        THROW 50001, 'The given EmployeeID is not a supervisor.', 1;
    END

    SELECT
        FORMAT(po.CreationDate, 'yyyy-MM') AS [Month],
        SUM(poi.ItemQuantity * poi.ItemPrice * (1 + po.TaxRate)) AS ExpenseTotal
    FROM PurchaseOrder po
    JOIN PurchaseOrderItem poi ON po.PurchaseOrderNumber = poi.PurchaseOrderID
    JOIN Employee e ON po.EmployeeID = e.ID
    JOIN PurchaseOrderItemStatus pis ON poi.PurchaseOrderItemStatusID = pis.ID
    WHERE e.SupervisorID = @EmployeeID
	AND po.PurchaseOrderStatusID=5
      AND po.CreationDate >= DATEADD(MONTH, -11, GETDATE())
      AND pis.StatusName <> 'Denied'
    GROUP BY FORMAT(po.CreationDate, 'yyyy-MM')
    ORDER BY [Month];
END
GO



--------------------------------------

------supervisor dashboard-------------


--------Supervisor pending PO------

CREATE OR ALTER PROCEDURE spGetPendingPOCount
    @EmployeeID INT
AS
BEGIN
  

    IF NOT EXISTS (
        SELECT 1 FROM Employee WHERE ID = @EmployeeID AND IsSupervisor = 1
    )
    BEGIN
        THROW 50003, 'Access denied: the given EmployeeID is not a supervisor.', 1;
    END

    
    SELECT COUNT(*)
    FROM PurchaseOrder po
    INNER JOIN Employee e ON po.EmployeeID = e.ID
    WHERE e.SupervisorID = @EmployeeID
      AND(po.PurchaseOrderStatusID =1 OR po.PurchaseOrderStatusID= 4); -- 1: Pending, 4: Under Review
END
GO

-----------------
CREATE OR ALTER PROCEDURE spGetPendingReviewToCreateList
    @EmployeeID INT,
    @StartYear INT = NULL
AS
BEGIN
    -- Default to 2024 
    SET @StartYear = ISNULL(@StartYear, 2024);

    -- Ensure Employee is a supervisor
    IF NOT EXISTS (
        SELECT 1 FROM Employee WHERE ID = @EmployeeID AND IsSupervisor = 1
    )
    BEGIN
        THROW 50001, 'The given EmployeeID is not a supervisor.', 1;
    END

    -- Generate all quarters from @StartYear up to the current quarter
    ;WITH Quarters AS (
        SELECT 
            1 AS QuarterNum,
            @StartYear AS YearNum
        UNION ALL
        SELECT 
            CASE WHEN QuarterNum < 4 THEN QuarterNum + 1 ELSE 1 END,
            CASE WHEN QuarterNum < 4 THEN YearNum ELSE YearNum + 1 END
        FROM Quarters
        WHERE (YearNum < YEAR(GETDATE()))
           OR (YearNum = YEAR(GETDATE()) AND QuarterNum < DATEPART(QUARTER, GETDATE()))
    )

    SELECT 
        COUNT(*) AS TotalPendingQuarterlyReviews
    FROM Employee e
    CROSS JOIN Quarters q
    WHERE e.SupervisorID = @EmployeeID
      AND e.Status = 'Active'
      AND NOT EXISTS (
          SELECT 1
          FROM Review r
          WHERE r.EmployeeID = e.ID
            AND r.SupervisorID = @EmployeeID
            AND YEAR(r.ReviewDate) = q.YearNum
            AND DATEPART(QUARTER, r.ReviewDate) = q.QuarterNum
      );
END
GO

-------

CREATE OR ALTER PROCEDURE spGetTotalSupervisedEmployees
    @EmployeeID INT
AS
BEGIN
    SELECT COUNT(*)
    FROM Employee e
    WHERE e.SupervisorID =@EmployeeID AND Status='Active'
END

GO

-----
CREATE OR ALTER PROCEDURE spGetUnreadReviewCountSupervisor
    @EmployeeID INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM Employee WHERE ID = @EmployeeID AND IsSupervisor = 1
    )
    BEGIN
        THROW 50002, 'The given EmployeeID is not a supervisor.', 1;
    END

    
    SELECT COUNT(*)
    FROM Review r 
    WHERE r.SupervisorID = @EmployeeID
      AND ( r.IsRead = 0 OR IsRead IS  Null)
      AND r.ReviewDate >= DATEADD(MONTH, -12, GETDATE());
END
GO



GO
CREATE OR ALTER PROCEDURE spGetUnreadEmployeeReviewCount
    @EmployeeID INT
AS
BEGIN
    SELECT COUNT(*)
    FROM Review
    WHERE EmployeeID = @EmployeeID AND( IsRead = 0 OR IsRead IS  Null)
	AND ReviewDate >= DATEADD(MONTH, -11, (GETDATE()))

END
Go

------

-------------------- HR --------------------------------------
CREATE OR ALTER PROCEDURE spGetAllDepartments
AS
BEGIN
	SELECT 
		ID, 
		[Name]
	FROM Department
	WHERE InvocationDate <= CAST(GETDATE() AS DATE)
	ORDER BY [Name]
END
GO

CREATE OR ALTER PROCEDURE spInsertDepartment
	@ID INT OUTPUT,
	@RowVer ROWVERSION OUTPUT,
	@Name NVARCHAR(128),
	@Description NVARCHAR(512),
	@InvocationDate DATE
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Department ([Name], [Description], InvocationDate)
			VALUES (@Name, @Description, @InvocationDate)

			SET @ID = SCOPE_IDENTITY()
			SET @RowVer = (SELECT RowVer FROM Department WHERE Id = @ID)

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE spGetEmployeeAssignment
	@ID INT
AS
BEGIN
	SELECT 
		e.FirstName + 
			CASE 
				WHEN e.MiddleInitial IS NOT NULL AND e.MiddleInitial <> '' 
				THEN ' ' + e.MiddleInitial 
				ELSE '' 
			END + ' ' + e.LastName AS [EmployeeName],

		d.[Name] AS [DepartmentName],

		s.FirstName + 
        CASE 
            WHEN s.MiddleInitial IS NOT NULL AND s.MiddleInitial <> '' 
            THEN ' ' + s.MiddleInitial 
            ELSE '' 
        END + ' ' + s.LastName AS [SupervisorName]
		
	FROM Employee e
		LEFT JOIN Department d 
			ON e.DepartmentID = d.ID
		LEFT JOIN Employee s 
			ON e.SupervisorID = s.ID
	WHERE e.ID = @ID
END
GO

CREATE OR ALTER PROCEDURE spFilterEmployees
	@DepartmentID INT = NULL,
	@EmployeeID INT = NULL,
	@LastName NVARCHAR(50) = NULL
AS
BEGIN
	SELECT 
		e.ID,
		e.LastName, 
		e.FirstName,
		e.WorkPhone,
		e.OfficeLocation,
		j.[Name] AS [Position]
	FROM Employee e
	INNER JOIN Job j ON j.ID = e.JobID
	WHERE 
		e.[Status] = 'ACTIVE' AND
		(@DepartmentID IS NULL OR e.DepartmentID = @DepartmentID) AND
        (@EmployeeID IS NULL OR e.ID = @EmployeeID) AND
        (@LastName IS NULL OR e.LastName LIKE '%' + @LastName + '%')
	ORDER BY e.LastName, e.FirstName
END
GO

CREATE OR ALTER PROCEDURE spGetAllJobs
AS
BEGIN
	SELECT 
		ID, 
		[Name]
	FROM Job
	ORDER BY [Name]
END
GO

CREATE OR ALTER PROCEDURE spValidateSINUnique
    @SIN	NVARCHAR(11),
    @ID		INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM Employee
                WHERE REPLACE(REPLACE([SIN], '-', ''), ' ', '') = @SIN
                   AND (@ID IS NULL OR ID <> @ID)
            )
            THEN CAST(0 AS BIT)
            ELSE CAST(1 AS BIT)
        END AS [IsUnique] ;
END
GO

CREATE OR ALTER PROCEDURE spCountEmployeesBySupervisor
    @SupervisorID	INT,
	@ID				INT = NULL
AS
BEGIN
	SELECT COUNT(*)
    FROM Employee
    WHERE 
		SupervisorID = @SupervisorID AND
		(@ID IS NULL OR ID <> @ID) AND
		[Status] = 'ACTIVE'
END
GO

CREATE OR ALTER PROCEDURE spGetAllSupervisors
AS
BEGIN
	SELECT 
		ID, 
		LastName,
		FirstName,
		MiddleInitial
	FROM Employee
	WHERE 
		IsSupervisor IS NOT NULL AND
		IsSupervisor = 1 AND
		[Status] = 'ACTIVE'
	ORDER BY LastName, FirstName
END
GO

CREATE OR ALTER PROCEDURE spGetJobByEmployeeId
    @ID INT
AS
BEGIN
	SELECT j.ID, j.[Name]
	FROM Employee e
	INNER JOIN Job j
		ON e.JobID = j.ID
	WHERE e.ID =  @ID ;
END
GO

CREATE OR ALTER PROCEDURE spValidateSupervisorWithinDepartment
    @SupervisorID INT,
	@DepartmentID INT
AS
BEGIN
	SET NOCOUNT ON ;

	SELECT 
        CASE 
			WHEN EXISTS (
				SELECT 1 
				FROM Employee s
				WHERE 
					s.ID = @SupervisorID AND
					s.DepartmentID = @DepartmentID
			)
			THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
		END AS [IsValid] ;
END
GO

CREATE OR ALTER PROCEDURE spInsertEmployee
	@ID INT OUTPUT,
	@RowVer ROWVERSION OUTPUT,
	@FirstName NVARCHAR(50),
	@LastName NVARCHAR(50),
	@MiddleInitial NCHAR(1),
	@StreetAddress NVARCHAR(255),
	@City NVARCHAR(255),
	@PostalCode NVARCHAR(7),
	@DOB DATE,
	@SIN NVARCHAR(11),
	@SeniorityDate DATE,
	@JobStartDate DATE,
	@WorkPhone NVARCHAR(14),
	@CellPhone NVARCHAR(14),
	@Email NVARCHAR(255),
	@IsSupervisor BIT,
	@OfficeLocation NVARCHAR(255),
	@Status NVARCHAR(20),
	@JobID INT,
	@SupervisorID INT,
	@DepartmentID INT,
	@PasswordHash NVARCHAR(64),
	@PasswordSalt BINARY(16)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Employee (
				 [FirstName]
				,[LastName]
				,[MiddleInitial]
				,[StreetAddress]
				,[City]
				,[PostalCode]
				,[DOB]
				,[SIN]
				,[SeniorityDate]
				,[JobStartDate]
				,[WorkPhone]
				,[CellPhone]
				,[Email]
				,[IsSupervisor]
				,[OfficeLocation]
				,[Status]
				,[JobID]
				,[SupervisorID]
				,[DepartmentID]
				,[PasswordHash]
				,[PasswordSalt]
			)
			VALUES (
				 @FirstName
				,@LastName
				,@MiddleInitial
				,@StreetAddress
				,@City
				,@PostalCode
				,@DOB
				,@SIN
				,@SeniorityDate
				,@JobStartDate
				,@WorkPhone
				,@CellPhone
				,@Email
				,@IsSupervisor
				,@OfficeLocation
				,UPPER(@Status)
				,@JobID
				,@SupervisorID
				,@DepartmentID
				,@PasswordHash
				,@PasswordSalt
			)

			SET @ID = SCOPE_IDENTITY()
			SET @RowVer = (SELECT RowVer FROM Employee WHERE Id = @ID)

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE spGetSaltByEmployeeId
	@ID INT
AS
BEGIN
	SELECT 
		PasswordSalt
	FROM Employee
	WHERE ID = @ID
END
GO

CREATE OR ALTER PROCEDURE spLogin
	@ID INT,
	@HashedPassword NVARCHAR(64)
AS
BEGIN
	BEGIN TRY
		SELECT
			ID,
			LastName,
			FirstName,
			CASE 
				WHEN JobID = 1 THEN 'CEO'
				WHEN JobID = 2 AND IsSupervisor = 1 THEN 'HRSupervisor'
				WHEN JobID = 2 AND (IsSupervisor IS NULL OR IsSupervisor = 0) THEN 'HREmployee'
				WHEN JobID BETWEEN 3 AND 15 AND IsSupervisor = 1 THEN 'RegularSupervisor'
				WHEN JobID BETWEEN 3 AND 15 AND (IsSupervisor IS NULL OR IsSupervisor = 0) THEN 'RegularEmployee'
			END AS [Role]
		FROM Employee
		WHERE
			ID = @ID AND 
			PasswordHash = @HashedPassword AND
			[Status] = 'ACTIVE'
	END TRY
	BEGIN CATCH
		;THROW
	END CATCH
END
GO

--------------------------- SPRINT 2 HR -------------------------------
CREATE OR ALTER PROCEDURE spGetEmployeeDetails
	@EmployeeID INT
AS
BEGIN
	SELECT
		e.ID,
		e.FirstName,
		e.MiddleInitial,
		e.LastName,
		e.StreetAddress + ', ' + e.City + ' ' + e.PostalCode AS MailingAddress,
		e.WorkPhone,
		e.CellPhone,
		e.Email
	FROM Employee e
	WHERE 
        e.ID = @EmployeeID
END
GO

CREATE OR ALTER PROCEDURE spSearchEmployees
	@EmployeeID INT = NULL,
	@LastName NVARCHAR(50) = NULL
AS
BEGIN
	SELECT 
		e.ID,
		e.LastName,
		e.FirstName,
		e.MiddleInitial,
		e.StreetAddress + ', ' + e.City + ' ' + e.PostalCode AS MailingAddress,
		e.WorkPhone,
		e.CellPhone,
		e.Email
	FROM Employee e
	INNER JOIN Job j ON j.ID = e.JobID
	WHERE 
        (@EmployeeID IS NULL OR e.ID = @EmployeeID) AND
        (@LastName IS NULL OR e.LastName LIKE '%' + @LastName + '%')
	ORDER BY e.LastName, e.FirstName
END
GO

CREATE OR ALTER PROCEDURE spGetAllDepartmentsWithDetails
AS
BEGIN
	SELECT 
		ID,
		[Name],
		[Description],
		InvocationDate,
		RowVer
	FROM Department
	ORDER BY [Name]
END
GO

CREATE OR ALTER PROCEDURE spUpdateDepartment
	@ID INT,
	@Name NVARCHAR(128),
	@Description NVARCHAR(512),
	@InvocationDate DATE,
	@RowVer BINARY(8)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			IF @RowVer <> (SELECT RowVer FROM Department WHERE Id = @ID)
			THROW 50001, 'Concurrency conflict: data has changed.', 1

			UPDATE Department 
			SET [Name] = @Name,
				[Description] = @Description,
				InvocationDate = @InvocationDate
			WHERE ID = @ID

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE spGetEmployeeById
    @ID INT
AS
BEGIN
    BEGIN TRY
        SELECT 
            [ID],
            [FirstName],
            [LastName],
            [MiddleInitial],
            [StreetAddress],
            [City],
            [PostalCode],
            [DOB],
            [SIN],
            [SeniorityDate],
            [JobStartDate],
            [WorkPhone],
            [CellPhone],
            [Email],
            [IsSupervisor],
			[OfficeLocation],
            [Status],
            [JobID],
            [SupervisorID],
            [DepartmentID],
            [PasswordHash],
			[PasswordSalt],
            [TerminationDate],
            [RetirementDate],
			[RowVer]

        FROM Employee
        WHERE ID = @ID

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE spUpdateEmployee
	@ID INT,
	@FirstName NVARCHAR(50),
	@LastName NVARCHAR(50),
	@MiddleInitial NCHAR(1),
	@StreetAddress NVARCHAR(255),
	@City NVARCHAR(255),
	@PostalCode NVARCHAR(7),
	@DOB DATE,
	@SIN NVARCHAR(11),
	@SeniorityDate DATE,
	@JobStartDate DATE,
	@WorkPhone NVARCHAR(14),
	@CellPhone NVARCHAR(14),
	@Email NVARCHAR(255),
	@IsSupervisor BIT,
	@OfficeLocation NVARCHAR(255),
	@Status NVARCHAR(20),
	@JobID INT,
	@SupervisorID INT,
	@DepartmentID INT,
	@PasswordHash NVARCHAR(64),
	@PasswordSalt BINARY(16),
	@TerminationDate DATE,
	@RetirementDate DATE,
	@RowVer BINARY(8)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			IF @RowVer <> (SELECT RowVer FROM Employee WHERE Id = @ID)
			THROW 50001, 'Concurrency conflict: data has changed.', 1

			UPDATE Employee
			SET
				[FirstName] = @FirstName,
				[LastName] = @LastName,
				[MiddleInitial] = @MiddleInitial,
				[StreetAddress] = @StreetAddress,
				[City] = @City,
				[PostalCode] = @PostalCode,
				[DOB] = @DOB,
				[SIN] = @SIN,
				[SeniorityDate] = @SeniorityDate,
				[JobStartDate] = @JobStartDate,
				[WorkPhone] = @WorkPhone,
				[CellPhone] = @CellPhone,
				[Email] = @Email,
				[IsSupervisor] = @IsSupervisor,
				[OfficeLocation] = @OfficeLocation,
				[Status] = UPPER(@Status),
				[JobID] = @JobID,
				[SupervisorID] = @SupervisorID,
				[DepartmentID] = @DepartmentID,
				[PasswordHash] = @PasswordHash,
				[PasswordSalt] = @PasswordSalt,
				[TerminationDate] = @TerminationDate,
				[RetirementDate] = @RetirementDate
			WHERE ID = @ID

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE spUpdatePersonalInfo
	@ID INT,
	@FirstName NVARCHAR(50),
	@LastName NVARCHAR(50),
	@MiddleInitial NCHAR(1),
	@StreetAddress NVARCHAR(255),
	@City NVARCHAR(255),
	@PostalCode NVARCHAR(7),
	@PasswordHash NVARCHAR(64),
	@PasswordSalt BINARY(16),
	@RowVer BINARY(8)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			IF @RowVer <> (SELECT RowVer FROM Employee WHERE Id = @ID)
			THROW 50001, 'Concurrency conflict: data has changed.', 1

			UPDATE Employee
			SET
				[FirstName] = @FirstName,
				[LastName] = @LastName,
				[MiddleInitial] = @MiddleInitial,
				[StreetAddress] = @StreetAddress,
				[City] = @City,
				[PostalCode] = @PostalCode,
				[PasswordHash] = @PasswordHash,
				[PasswordSalt] = @PasswordSalt
			WHERE ID = @ID

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

----------------------SPRINT 3 HR ------------------------------------
CREATE OR ALTER PROCEDURE spCheckIfDepartmentCanBeDeleted
	@ID INT
AS
BEGIN
	SET NOCOUNT ON ;
	
	SELECT
		CASE
			WHEN EXISTS (
				SELECT 1
				FROM Employee
				WHERE DepartmentID = @ID
			)
			THEN CAST(0 AS BIT)
            ELSE CAST(1 AS BIT)
        END AS [CanBeDeleted] ;
END
GO

CREATE OR ALTER PROCEDURE spDeleteDepartment
	@ID INT,
	@RowVer BINARY(8)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			IF @RowVer <> (SELECT RowVer FROM Department WHERE ID = @ID)
			THROW 50001, 'Concurrency Conflict: Data has changed.', 1

			DELETE FROM Department
			WHERE ID = @ID

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE spGetPendingEmployeeReviews
    @SupervisorID INT = NULL,
    @StartYear INT = NULL
AS
BEGIN
    SET NOCOUNT ON ;

    -- Use the current year and quarter for calculating the end date
    DECLARE @CurrentYear INT = YEAR(GETDATE());
    DECLARE @CurrentQuarter INT = 
        CASE 
            WHEN MONTH(GETDATE()) BETWEEN 1 AND 3 THEN 1
            WHEN MONTH(GETDATE()) BETWEEN 4 AND 6 THEN 2
            WHEN MONTH(GETDATE()) BETWEEN 7 AND 9 THEN 3
            ELSE 4
        END ;

    -- If no @StartYear is provided, default to last year
    IF @StartYear IS NULL
    BEGIN
        SET @StartYear = @CurrentYear - 1;
    END

    -- Generate list of quarters from @StartYear to current quarter
    ; WITH YearQuarter AS (
        SELECT @StartYear AS [Year], 1 AS Quarter
        UNION ALL
        SELECT 
            CASE WHEN Quarter = 4 THEN [Year] + 1 ELSE [Year] END,
            CASE WHEN Quarter = 4 THEN 1 ELSE Quarter + 1 END
        FROM YearQuarter
        WHERE [Year] < @CurrentYear OR ([Year] = @CurrentYear AND Quarter < @CurrentQuarter)
    ),

	  PendingReviews AS (
        SELECT
			e.SupervisorID,
			RTRIM(
				s.LastName + ', ' + s.FirstName + 
				CASE 
					WHEN s.MiddleInitial IS NOT NULL AND s.MiddleInitial <> '' 
						THEN ' ' + s.MiddleInitial + '.' 
					ELSE '' 
				END
			) AS [SupervisorName],
			s.Email AS [SupervisorEmail],
			yq.[Year],
            yq.[Quarter],
            e.ID AS [EmployeeID],
            e.LastName AS [EmployeeLastName],
            e.FirstName AS [EmployeeFirstName]
        FROM Employee e
        JOIN YearQuarter yq ON 1 = 1
        LEFT JOIN Review r 
            ON 
				r.EmployeeID = e.ID AND 
				r.[Year] = yq.[Year] AND 
				r.Quarter = yq.Quarter
        JOIN Employee s ON s.ID = e.SupervisorID
        WHERE 
            e.[Status] = 'ACTIVE' AND
            r.ID IS NULL AND
            (@SupervisorID IS NULL OR e.SupervisorID = @SupervisorID)
    )

    SELECT
		SupervisorID,
		SupervisorName,
		SupervisorEmail,
        [Year],
        [Quarter],
        EmployeeID,
		EmployeeLastName,
        EmployeeFirstName
    FROM PendingReviews
    ORDER BY 
        [Year] DESC, 
        [Quarter] DESC, 
        EmployeeLastName, 
        EmployeeFirstName
END
GO

CREATE OR ALTER PROCEDURE spCheckIfReviewCanBeAdded
	@EmployeeID INT,
	@SupervisorID INT,
	@Year INT,
	@Quarter INT
AS
BEGIN
	SET NOCOUNT ON ;
	
	SELECT
		CASE
			WHEN EXISTS (
				SELECT 1
				FROM Review
				WHERE 
					EmployeeID = @EmployeeID AND 
					SupervisorID = @SupervisorID AND
					[Year] = @Year AND
					[Quarter] = @Quarter
			)
			THEN CAST(0 AS BIT)
            ELSE CAST(1 AS BIT)
        END AS [CanBeAdded] ;
END
GO

CREATE OR ALTER PROCEDURE spInsertReview
	@ID INT OUTPUT,
	@EmployeeID INT,
	@SupervisorID INT,
	@RatingID INT,
	@Year INT,
	@Quarter INT,
	@Comment NVARCHAR(MAX),
	@ReviewDate DATE
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO Review (
				[EmployeeID], 
				[SupervisorID],
				[RatingID],
				[Year],
				[Quarter],
				[Comment],
				[ReviewDate]
			)
			VALUES (
				@EmployeeID, 
				@SupervisorID, 
				@RatingID,
				@Year,
				@Quarter,
				@Comment,
				@ReviewDate
			)

			SET @ID = SCOPE_IDENTITY()

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE spGetReviews
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

	SELECT 
		r.ID,
		r.[Year],
		r.[Quarter],
		r.ReviewDate,
		s.LastName + ', ' + s.FirstName + 
			CASE 
				WHEN s.MiddleInitial IS NOT NULL
				THEN ' ' + s.MiddleInitial + '.' 
				ELSE '' 
			END AS [SupervisorName] ,
		r.Comment,
		rt.[Name] AS [Rating],
		r.IsRead
	FROM 
		Review r
	JOIN Employee s 
		ON r.SupervisorID = s.ID
	LEFT JOIN Rating rt 
		ON r.RatingID = rt.ID
	WHERE 
		r.EmployeeID = @EmployeeID
	ORDER BY 
		r.[Year] DESC, 
		r.[Quarter] DESC ;
END
GO

CREATE OR ALTER PROCEDURE spMarkReviewAsRead
	@ID INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN

			UPDATE Review
			SET [IsRead] = 1
			WHERE ID = @ID

		COMMIT TRAN ;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE CheckIfReminderSentToday
AS
BEGIN
	SELECT
		CASE
			WHEN EXISTS (
				SELECT 1
				FROM ReviewReminderLog
				WHERE ReminderSentDate = CAST(GETDATE() AS DATE)
			)
			THEN CAST(1 AS BIT)
			ELSE CAST(0 AS BIT)
		END AS [IsSent] ;
END
GO

CREATE OR ALTER PROCEDURE InsertReminderLog
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO ReviewReminderLog (ReminderSentDate)
        VALUES (CAST(GETDATE() AS DATE));

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		;THROW
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE spGetPendingReviewsForReminder
    @Today DATE = NULL 
AS
BEGIN
    SET NOCOUNT ON;

    -- Use passed-in date or current date
    SET @Today = ISNULL(@Today, CAST(GETDATE() AS DATE));

    -- Determine previous quarter and year
    DECLARE @PrevQuarter INT;
    DECLARE @PrevYear INT;

    IF MONTH(@Today) IN (1,2,3) -- Q1 => previous is Q4 last year
    BEGIN
        SET @PrevQuarter = 4;
        SET @PrevYear = YEAR(@Today) - 1;
    END
    ELSE
    BEGIN
        SET @PrevQuarter = ((MONTH(@Today) - 1) / 3);
        SET @PrevYear = YEAR(@Today);
    END

    -- Calculate quarter end date for previous quarter
    DECLARE @QuarterEndDate DATE =
        CASE @PrevQuarter
            WHEN 1 THEN DATEFROMPARTS(@PrevYear, 3, 31)
            WHEN 2 THEN DATEFROMPARTS(@PrevYear, 6, 30)
            WHEN 3 THEN DATEFROMPARTS(@PrevYear, 9, 30)
            WHEN 4 THEN DATEFROMPARTS(@PrevYear, 12, 31)
        END;

    -- Calculate days overdue from quarter end
    DECLARE @DaysSinceQuarterEnd INT = DATEDIFF(DAY, @QuarterEndDate, @Today);

    -- Determine if outstanding (30+ days past quarter end)
    DECLARE @IsOutstanding BIT = CASE WHEN @DaysSinceQuarterEnd >= 30 THEN 1 ELSE 0 END;

    -- Only start sending emails the calendar day after quarter ends
    IF @Today <= @QuarterEndDate
    BEGIN
        RETURN; -- no reminders yet
    END

    SELECT
        e.ID AS EmployeeID,
        e.LastName AS EmployeeLastName,
        e.FirstName AS EmployeeFirstName,
        e.SupervisorID,
        RTRIM(s.LastName + ', ' + s.FirstName +
            CASE WHEN s.MiddleInitial IS NOT NULL AND s.MiddleInitial <> '' THEN ' ' + s.MiddleInitial + '.' ELSE '' END) AS SupervisorName,
        s.Email AS SupervisorEmail,
        @PrevYear AS [Year],
        @PrevQuarter AS [Quarter],
        @IsOutstanding AS IsOutstanding,
        @QuarterEndDate AS QuarterEndDate, -- For testing
        @DaysSinceQuarterEnd AS DaysSinceQuarterEnd -- For testing
    FROM Employee e
    LEFT JOIN Review r
        ON r.EmployeeID = e.ID
        AND r.[Year] = @PrevYear
        AND r.Quarter = @PrevQuarter
    JOIN Employee s ON s.ID = e.SupervisorID
    WHERE e.[Status] = 'ACTIVE'
      AND r.ID IS NULL
    ORDER BY e.SupervisorID, e.LastName, e.FirstName;
END
GO

CREATE OR ALTER PROCEDURE spGetAllEmployees
    @DepartmentID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.ID,
		e.FirstName,
		e.MiddleInitial,
		e.LastName,
		e.StreetAddress + ', ' + e.City + ' ' + e.PostalCode AS MailingAddress,
		e.WorkPhone,
		e.CellPhone,
		e.Email
    FROM 
        Employee e
    WHERE 
        [Status] = 'ACTIVE'
        AND (@DepartmentID IS NULL OR DepartmentID = @DepartmentID)
END
GO

----------------------------END OF HR-------------------------------------
