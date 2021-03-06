--error case testing with delete clause

autocommit off;


create table t1(id int primary key, name varchar(20) not null);
create table t2(id int, name varchar(20) unique);

insert into t1 values(1,'aaa'), (2,'bbb'), (3, 'ccc'), (4, 'ddd'), (5, 'eee');
insert into t2 values(1,'bbb'),(2,'ccc'),(3,'aaa'), (8, 'inserted');


--TEST: create triggers
create table trigger_actions(id smallint auto_increment, info varchar);

create trigger trigg1 before update on t1 execute insert into trigger_actions(info) values ('before update');
create trigger trigg2 after update on t2 execute insert into trigger_actions(info) values ('after update');
create trigger trigg3 before insert on t1 execute insert into trigger_actions(info) values ('before insert');
create trigger trigg4 after insert on t2 execute insert into trigger_actions(info) values ('after insert');
create trigger trigg5 before delete on t1 execute insert into trigger_actions(info) values ('before delete');
create trigger trigg6 after delete on t2 execute insert into trigger_actions(info) values ('after delete');


commit;

-- ######################### CASE 1 ############################### --
--TEST: error, pk violation error in insert clause
merge into t1
using t2
on (t1.id=t2.id)
when matched then
update
set t1.name='updated'
where t2.id < 3
delete where t2.id=2
when not matched then 
insert
values((t2.id-3), t2.name)
where t2.id < 10;

--TEST: check update result
select * from t1 order by 1,2;
select if(count(*)=0, 'ok', 'nok') from t1 where name in ('George', 'Laura');
select if(count(*)=0, 'ok', 'nok') from trigger_actions;

rollback;


-- ######################### CASE 2 ############################### --
--TEST: error, pk violation error in update clause
merge into t1
using t2
on (t1.name=t2.name)
when matched then
update
set t1.id=100 where t2.id < 10
delete where t2.id=2
when not matched then
insert
values(t2.id, t2.name)
where t2.id < 10;

--TEST: check update result
select * from t1 order by 1,2;
select if(count(*)=0, 'ok', 'nok') from t1 where name in ('George', 'Laura');
select if(count(*)=0, 'ok', 'nok') from trigger_actions;

rollback;



-- ######################### CASE 3 ############################### --
--TEST: error, unique violation error in update clause
merge into t2
using t1
on (t1.id=t2.id)
when matched then 
update
set t2.name='updated'
delete where t2.id < 10
when not matched then 
insert
values(t1.id, t1.name);

--TEST: check update result
select if(count(*)=0, 'ok', 'nok') from t2 where name='updated';
select if(count(*)=4, 'ok', 'nok') from t2;
select if(count(*)=0, 'ok', 'nok') from trigger_actions;

rollback;


-- ######################### CASE 4 ############################### --
--TEST: error, unique violation error in insert clause
merge into t2
using t1
on (t1.name=t2.name)
when matched then
update
set t2.id=t1.id
delete where t2.id < 10
when not matched then
insert
values(t1.id, 'INSERTED');

--TEST: check update result
select if(count(*)=0, 'ok', 'nok') from t2 where name='updated';
select if(count(*)=4, 'ok', 'nok') from t2;
select if(count(*)=0, 'ok', 'nok') from trigger_actions;

rollback;


-- ######################### CASE 5 ############################### --
--TEST: error, not null violation error in update clause
merge into t1
using t2
on (t1.id=t2.id)
when matched then
update
set t1.name=null
delete where t1.id < 10
when not matched then
insert
values(t2.id, t2.name);

--TEST: check update result
select * from t1 order by 1,2;
select if(count(*)=0, 'ok', 'nok') from t1 where name=null;
select if(count(*)=5, 'ok', 'nok') from t1;
select if(count(*)=0, 'ok', 'nok') from trigger_actions;

rollback;


-- ######################### CASE 6 ############################### --
--TEST: error, not null violation error in insert clause
merge into t1
using t2
on (t1.id=t2.id)
when matched then
update
set t1.name='updated'
delete where t1.id < 10
when not matched then
insert
values(t2.id, null);

--TEST: check update result
select * from t1 order by 1,2;
select if(count(*)=0, 'ok', 'nok') from t1 where name='updated';
select if(count(*)=5, 'ok', 'nok') from t1;
select if(count(*)=0, 'ok', 'nok') from trigger_actions;

rollback;



drop trigger trigg1, trigg2, trigg3, trigg4, trigg5, trigg6;
drop table t2, t1, trigger_actions;

commit;


autocommit on;
