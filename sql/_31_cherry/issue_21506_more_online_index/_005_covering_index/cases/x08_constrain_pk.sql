--+ holdcas on;
set system parameters 'dont_reuse_heap_file=yes';

create table tb (a int primary key, b int);
create index i_tb_all on tb(a,b) with online;
create index i_tb_b on tb(b) with online;
create index i_tb_a on tb(a) with online;
insert into tb values (1,1);
insert into tb values (2,2);
insert into tb values (3,3);
insert into tb values (4,null);
select /*+ recompile */ * from tb where a is null;
select /*+ recompile */ * from tb where b is null or b is not null;
select /*+ recompile */ b from tb where b >0;

drop table tb;

set system parameters 'dont_reuse_heap_file=no';
commit;
--+ holdcas off;
