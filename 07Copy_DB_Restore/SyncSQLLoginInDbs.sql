
-- generate 'select 'user1' union statement
-- select 'select '''+name+''''+' union'  from syslogins where isntuser=0 and isntgroup=0 and name not like '##%' and name <>'sa'

declare @users table(idx int identity(1,1),uname varchar(100))

-- put all the sql logins name into @users
insert into @users (uname)
select 'user1' union
select 'user2' union
-- ...
select 'userZ'

declare @i int
declare @cnt int
declare @uname varchar(100)
DECLARE @command varchar(1000)

select @i = min(idx) - 1, @cnt = max(idx) from @users

while @i < @cnt
begin
    select @i = @i + 1
    select @uname=uname from @users where idx = @i
    print @uname

	SELECT @command = 'USE ? alter user ['+@uname+'] with login=['+@uname+']; select db_name()' 
	print @command

    -- run in all database
	EXEC sp_MSforeachdb @command 
end

