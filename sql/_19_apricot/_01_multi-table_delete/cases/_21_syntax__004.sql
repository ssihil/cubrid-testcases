--CLIENT
create class t_tr(i int);

create class t (i int, j int);
create trigger tr before delete on t execute insert into t_tr values(obj.i);

insert into t values (1, 4);
insert into t values (2, 5);
insert into t values (3, 6);
insert into t values (4, 7);
insert into t values (5, 8);

delete t1, t2 from t as t1 inner join t as t2 on t1.i=t2.j;
select * from t order by 1;
select * from t_tr order by 1;

drop class t;
drop class t_tr;