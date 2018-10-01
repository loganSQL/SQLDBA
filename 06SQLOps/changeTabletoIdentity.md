# changeTabletoIdentity

The following script demonstrates how to change table Test (without identity field <id>) to Test2 (with identity field <id>) by using partition SWITCH for schema swapping. 

This method works well when you have millions of records inside the table. There will no data movement at all.

```
use tempdb
go

CREATE TABLE Test
(
    id int NOT NULL,
   somecolumn varchar(10)

);

INSERT INTO Test VALUES (1,'Hello');
INSERT INTO Test VALUES (2,'World');
go

-- copy the table. use same schema, but no identity
CREATE TABLE Test2
(
   id int identity(1,1),
   somecolumn varchar(10)
);
go


ALTER TABLE Test SWITCH TO Test2;
go

-- drop the original (now empty) table
DROP TABLE Test;

-- rename new table to old table's name
EXEC sp_rename 'Test2','Test';

-- update the identity seed
DBCC CHECKIDENT('Test');

-- see same records
SELECT * FROM Test; 
go

```