/*
Test Case: update in trigger & select
Priority: 1
Reference case:
Author: Lily

Test Point:
when trigger is called, update statement is executed

NUM_CLIENTS = 2
C1: start transaction;
C2: SELECT * FROM hi order by id;
C1: insert into tt1 to fire a trigger to update a row into hi; --ready
*/

MC: setup NUM_CLIENTS = 2;
C1: set transaction lock timeout INFINITE;
C1: set transaction isolation level repeatable read;
C2: set transaction lock timeout INFINITE;
C2: set transaction isolation level repeatable read;

/* preparation */
C1: DROP TABLE IF EXISTS tt1;
C1: DROP TABLE IF EXISTS hi;
C1: CREATE TABLE hi( id INT PRIMARY KEY, col VARCHAR(10));
C1: INSERT INTO hi VALUES(1,'111'),(2,'222');
C1: CREATE TABLE tt1( id INT, col VARCHAR(10));
C1: CREATE TRIGGER tt1_insert AFTER INSERT ON tt1 EXECUTE UPDATE hi SET col = NULL WHERE id=obj.id;
C1: commit work;

/* test case */
C1: INSERT INTO hi VALUES(3,'333');
MC: wait until C1 ready;
C2: SELECT * FROM hi ORDER BY id;
MC: wait until C2 ready;
C1: INSERT INTO tt1 VALUES(1,'call');
MC: wait until C1 ready;
C2: SELECT * FROM hi ORDER BY id;
MC: wait until C2 ready;
C1: commit;
C1: SELECT * FROM hi order by id;
MC: wait until C1 ready;
C2: commit;
C2: SELECT * FROM hi order by id;
C2: commit;
C1: commit;
C2: quit;
C1: quit;
