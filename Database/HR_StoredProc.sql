USE CapstoneProject
GO

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
				THEN ' ' + e.MiddleInitial + '.'
				ELSE '' 
			END + ' ' + e.LastName AS [EmployeeName],

		d.[Name] AS [DepartmentName],

		s.FirstName + 
        CASE 
            WHEN s.MiddleInitial IS NOT NULL AND s.MiddleInitial <> '' 
            THEN ' ' + s.MiddleInitial + '.' 
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

---------------- SPRINT 3 ---------------------------------

--IF OBJECT_ID('dbo.Review', 'U') IS NOT NULL
--	DROP TABLE dbo.Review;
--GO

--IF OBJECT_ID('dbo.Rating', 'U') IS NOT NULL
--	DROP TABLE dbo.Rating;
--GO

--IF OBJECT_ID('dbo.ReviewReminderLog', 'U') IS NOT NULL
--	DROP TABLE dbo.ReviewReminderLog;
--GO

--CREATE TABLE Rating (
--	ID			INT				NOT NULL	IDENTITY(1,1),
--	[Name]		NVARCHAR(25)	NOT NULL,

--	CONSTRAINT PK_Rating PRIMARY KEY(ID),
--)
--GO

--CREATE TABLE ReviewReminderLog (
--	ReminderSentDate	Date	NOT NULL,

--	CONSTRAINT UQ_ReviewReminderLog_ReminderSentDate UNIQUE(ReminderSentDate)
--)
--GO

--INSERT INTO Rating ([Name])
--VALUES 
--	('Below Expectations')
--	,('Meets Expectations')
--	,('Exceeds Expectations')
--GO

--CREATE TABLE Review (
--	ID				INT				NOT NULL	IDENTITY(1,1),
--	EmployeeID		INT				NOT NULL,
--	SupervisorID	INT				NOT NULL,
--	RatingID		INT				NOT NULL,
--	[Year]			INT				NOT NULL,
--	[Quarter]		TINYINT			NOT NULL,
--	Comment			NVARCHAR(MAX)	NOT NULL,
--	ReviewDate		DATE			NOT NULL,
--	IsRead			BIT				NULL

--	CONSTRAINT PK_Review PRIMARY KEY(ID),
--	CONSTRAINT FK_Review_Employee_EmployeeID FOREIGN KEY (EmployeeID) REFERENCES Employee(ID),
--	CONSTRAINT FK_Review_Employee_SupervisorID FOREIGN KEY (SupervisorID) REFERENCES Employee(ID),
--	CONSTRAINT FK_Review_Rating FOREIGN KEY (RatingID) REFERENCES Rating(ID),
--	CONSTRAINT UQ_Review_EmployeeID_SupervisorID_Year_Quarter UNIQUE(EmployeeID,SupervisorID,[Year],[Quarter])
--)
--GO

--INSERT INTO Review (
--	EmployeeID, 
--	SupervisorID, 
--	[Year], 
--	[Quarter], 
--	RatingID,
--	Comment,
--	ReviewDate, 
--	IsRead
--)
--VALUES 
--	-- Last year, This year's Q
--	(4, 2
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 2, 'Good! hr 4'
--	, DATEADD(YEAR, -1, GETDATE()), 1)

--	,(5, 2
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 2, 'Good! hr 5'
--	, DATEADD(YEAR, -1, GETDATE()), NULL)
	

--	-- This year (or last), PREVIOUS quarter from today
--	,(4, 2
--	, YEAR(DATEADD(MONTH, -3, GETDATE()))
--	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
--	, 2, 'Keep it up hr 4'
--	, DATEADD(MONTH, -3, GETDATE()), 1)

--	,(5, 2
--	, YEAR(DATEADD(MONTH, -3, GETDATE()))
--	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
--	, 2, 'Keep it up hr 5'
--	, DATEADD(MONTH, -3, GETDATE()), NULL)

--	-- This year, CURRENT quarter
--	,(4, 2
--	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
--	, 3, 'Amazing! hr 4'
--	, GETDATE(), 1)

--	,(5, 2
--	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
--	, 3, 'Amazing! hr 5'
--	, GETDATE(), NULL)

----  ONE REVIEW HR SV 3 FOR EMPLOYEE 30
--	-- Last year, This year's Q
--	,(30, 3
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 3, 'Amazing! hr 30'
--	, DATEADD(YEAR, -1, GETDATE()), 1)


----- RETIRED EMP
--	-- Last year, This year's Q
--	,(16, 2
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 2, 'Good! retired hr 16'
--	, DATEADD(YEAR, -1, GETDATE()), 1)

--	-- This year, CURRENT quarter
--	,(16, 2
--	, YEAR(DATEADD(DAY, -1, GETDATE())), DATEPART(QUARTER, DATEADD(DAY, -1, GETDATE()))
--	, 3, 'Amazing! retired hr 16'
--	, GETDATE(), NULL)

--	--EmployeeID, 
--	--SupervisorID, 
--	--[Year], 
--	--[Quarter], 
--	--RatingID,
--	--Comment,
--	--ReviewDate, 
--	--IsRead

------- Supervisor EMP
--	-- This year (or last), PREVIOUS quarter from today
--	,(2, 1
--	, YEAR(DATEADD(MONTH, -3, GETDATE()))
--	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
--	, 2, 'Keep it up hr sv 2'
--	, DATEADD(MONTH, -3, GETDATE()), 1)

--	,(3, 1
--	, YEAR(DATEADD(MONTH, -3, GETDATE()))
--	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
--	, 2, 'Keep it up hr sv 3'
--	, DATEADD(MONTH, -3, GETDATE()), NULL)

--	-- This year, CURRENT quarter
--	,(2, 1
--	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
--	, 3, 'Amazing! hr sv 2'
--	, GETDATE(), 1)

--	,(3, 1
--	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
--	, 3, 'Amazing! hr sv 3'
--	, GETDATE(), NULL)

--------------------- NON HR REVIEWS ------------------------------
--	-- Last year, This year's Q
--	,(20, 17
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 2, 'Good! reg 20'
--	, DATEADD(YEAR, -1, GETDATE()), NULL)

--	,(21, 17
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 2, 'Good! reg 21'
--	, DATEADD(YEAR, -1, GETDATE()), 1)
	
--	-- This year (or last), PREVIOUS quarter from today
--	,(20, 17
--	, YEAR(DATEADD(MONTH, -3, GETDATE()))
--	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
--	, 2, 'Keep it up reg 20'
--	, DATEADD(MONTH, -3, GETDATE()), NULL)

--	,(21, 17
--	, YEAR(DATEADD(MONTH, -3, GETDATE()))
--	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
--	, 2, 'Keep it up reg 21'
--	, DATEADD(MONTH, -3, GETDATE()), 1)

--	-- This year, CURRENT quarter
--	,(20, 17
--	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
--	, 3, 'Amazing! reg 20'
--	, GETDATE(), NULL)

--	,(21, 17
--	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
--	, 3, 'Amazing! reg 21'
--	, GETDATE(), 1)

------ TERMINATED emp
--	-- Last year, This year's Q
--	,(28, 1
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 1, 'Needs Improvement reg terminated 28'
--	, DATEADD(YEAR, -1, GETDATE()), NULL)

--	-- This year, CURRENT quarter
--	,(28, 1
--	, YEAR(DATEADD(DAY, -1, GETDATE())), DATEPART(QUARTER, DATEADD(DAY, -1, GETDATE()))
--	, 1, 'Needs Improvement reg terminated 28'
--	, GETDATE(), 1)

------- Supervisor EMP
--	-- This year (or last), PREVIOUS quarter from today
--	,(17, 1
--	, YEAR(DATEADD(MONTH, -3, GETDATE()))
--	, DATEPART(QUARTER, DATEADD(MONTH, -3, GETDATE()))
--	, 2, 'Keep it up reg sv 17'
--	, DATEADD(MONTH, -3, GETDATE()), NULL)

--	-- This year, CURRENT quarter
--	,(17, 1
--	, YEAR(GETDATE()), DATEPART(QUARTER, GETDATE())
--	, 3, 'Amazing! reg sv 17'
--	, GETDATE(), 1)

----  ONE REVIEW NON HR SV 15 FOR EMPLOYEE 31
--	-- Last year, This year's Q
--	,(31, 15
--	, YEAR(GETDATE()) - 1, DATEPART(QUARTER, DATEADD(YEAR, -1, GETDATE()))
--	, 3, 'Amazing! reg 31'
--	, DATEADD(YEAR, -1, GETDATE()), 1)
--GO

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
--exec spGetPendingEmployeeReviews @SupervisorID = 3
--GO
--CREATE OR ALTER PROCEDURE spGetPendingEmployeeReviewsTEST
--    @SupervisorID INT = NULL,
--    @StartYear INT = NULL
--AS
--BEGIN
--    SET NOCOUNT ON ;

--    -- Use the current year and quarter for calculating the end date
--    DECLARE @CurrentYear INT = YEAR(GETDATE());
--    DECLARE @CurrentQuarter INT = 
--        CASE 
--            WHEN MONTH(GETDATE()) BETWEEN 1 AND 3 THEN 1
--            WHEN MONTH(GETDATE()) BETWEEN 4 AND 6 THEN 2
--            WHEN MONTH(GETDATE()) BETWEEN 7 AND 9 THEN 3
--            ELSE 4
--        END ;

--    -- If no @StartYear is provided, default to last year
--    IF @StartYear IS NULL
--    BEGIN
--        SET @StartYear = @CurrentYear - 1;
--    END

--    -- Generate list of quarters from @StartYear to current quarter
--    ; WITH YearQuarter AS (
--        SELECT @StartYear AS [Year], 1 AS Quarter
--        UNION ALL
--        SELECT 
--            CASE WHEN Quarter = 4 THEN [Year] + 1 ELSE [Year] END,
--            CASE WHEN Quarter = 4 THEN 1 ELSE Quarter + 1 END
--        FROM YearQuarter
--        WHERE [Year] < @CurrentYear OR ([Year] = @CurrentYear AND Quarter < @CurrentQuarter)
--    ),

--	  PendingReviews AS (
--        SELECT 
--            e.ID AS EmployeeID,
--            e.FirstName AS EmployeeFirstName,
--            e.LastName AS EmployeeLastName,
--            e.SupervisorID,
--			s.Email AS [SupervisorEmail],
--            s.LastName AS [SupervisorLastName],
--			s.FirstName AS [SupervisorFirstName],
--            yq.[Year],
--            yq.Quarter
--        FROM Employee e
--        JOIN YearQuarter yq ON 1 = 1
--        LEFT JOIN Review r 
--            ON r.EmployeeID = e.ID AND r.Year = yq.Year AND r.Quarter = yq.Quarter
--        JOIN Employee s ON s.ID = e.SupervisorID
--        WHERE 
--            e.[Status] = 'ACTIVE' AND
--            r.ID IS NULL AND
--            (@SupervisorID IS NULL OR e.SupervisorID = @SupervisorID)
--    )

--    SELECT 
--        SupervisorID,
--        SupervisorLastName,
--        SupervisorFirstName,
--        [Year],
--        [Quarter],
--        EmployeeID,
--        EmployeeLastName,
--        EmployeeFirstName
--    FROM PendingReviews
--    ORDER BY 
--        [Year] DESC, 
--        [Quarter] DESC, 
--        SupervisorLastName, 
--        SupervisorFirstName, 
--        EmployeeLastName, 
--        EmployeeFirstName
--END
--GO
--exec spGetPendingEmployeeReviews @SupervisorID = 3
----exec spGetPendingEmployeeReviewsTEST @SupervisorID = 3
--GO

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

--exec spCheckIfReviewCanBeAdded 	
--	@EmployeeID = 31,
--	@SupervisorID =15,
--	@Year  = 2024,
--	@Quarter  = 2
--GO
--exec spGetPendingEmployeeReviews @SupervisorID = 3
--GO
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

--exec spMarkReviewAsRead @ID = 1
--GO
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
--EXEC spGetPendingReviewsForReminder @Today = '2025-04-01'; 
--GO
--EXEC spGetPendingReviewsForReminder @Today = '2025-04-01'; -- 
--GO

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

--EXEC spGetAllEmployees @DepartmentID=2

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