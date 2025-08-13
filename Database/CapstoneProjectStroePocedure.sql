USE CapstoneProject
GO

GO

USE CapstoneProject
GO


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
    @EmployeeID INT
AS
BEGIN
    -- Ensure Employee is a supervisor
    IF NOT EXISTS (
        SELECT 1 FROM Employee WHERE ID = @EmployeeID AND IsSupervisor = 1
    )
    BEGIN
        THROW 50001, 'The given EmployeeID is not a supervisor.', 1;
    END

    -- Generate last 4 quarters
    ;WITH LastFourQuarters AS (
        SELECT 
            DATEPART(QUARTER, DATEADD(QUARTER, -n, GETDATE())) AS QuarterNum,
            YEAR(DATEADD(QUARTER, -n, GETDATE())) AS YearNum
        FROM (VALUES (0), (1), (2), (3)) AS Offset(n)
    )

    SELECT 
        COUNT(*) AS TotalPendingQuarterlyReviews
    FROM Employee e
    CROSS JOIN LastFourQuarters q
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
