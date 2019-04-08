# Stored Procedure for Generating Random Passwords

Use this code to create a stored procedure for generating complex random passwords of desired length (@pass_len), from the list of valid password characters (@ValidChar):
```
CREATE PROCEDURE usp_RandomPassword (@pass_len AS int, @password nvarchar(400) OUTPUT)
AS
DECLARE @ValidChar AS nvarchar(400)
SET @ValidChar = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ01234567890~!@#$%^&*()_-+={}[]\|:;"<>,.?/'
DECLARE @counter int
SET @counter = 0
SET @password = ''
WHILE @counter < @pass_len 
BEGIN 
  SELECT @password = @password + SUBSTRING(@ValidChar, (CONVERT(int, (LEN(@ValidChar) * RAND() + 1))), 1) SET @counter += 1 
END; 
```

To use the stored procedure to get a 10 characters long password:
```
DECLARE @new_password varchar(50)
EXEC dbo.usp_RandomPassword @pass_len = 10, @password = @new_password out
SELECT @new_password
```

To use the stored procedure to get a 12 characters long password:
```
DECLARE @new_password varchar(50)
EXEC dbo.usp_RandomPassword @pass_len = 12, @password = @new_password out
SELECT @new_password
```
