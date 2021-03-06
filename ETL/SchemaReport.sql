SET ANSI_WARNINGS OFF
SET NOCOUNT ON

DECLARE @t NVARCHAR(100) = 'OurTable'
DECLARE @loop TABLE (LoopID INT IDENTITY(1,1), ColumnName NVARCHAR(100))

INSERT INTO @loop (ColumnName)
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @t

DECLARE @c NVARCHAR(100), @b INT = 1, @m INT, @s NVARCHAR(MAX)
SELECT @m = MAX(LoopID) FROM @loop

WHILE @b <= @m
BEGIN
	SELECT @c = ColumnName FROM @loop WHERE LoopID = @b
	SET @s = 'DECLARE @cnt INT
	;WITH CTE AS(
		SELECT DISTINCT ' + QUOTENAME(@c) + ' AS CountValue
		FROM ' + QUOTENAME(@t) + '
	)
	SELECT @cnt = COUNT(CountValue) FROM CTE
	IF @cnt <= 3
	BEGIN
		PRINT ''' + QUOTENAME(@c) + ' is a possible Y/N/Unknown column.''
	END
	ELSE IF @cnt BETWEEN 4 AND 1000
	BEGIN
		PRINT ''' + QUOTENAME(@c) + ':''
		PRINT @cnt
	END'
	--PRINT @s
	EXECUTE sp_executesql @s
	SET @b = @b + 1
END
