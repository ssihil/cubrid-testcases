--TEST: test with tables with triggers
--+holdcas on;
set system parameters 'dont_reuse_heap_file=yes';

create table stddev_samp_trigger(
	col1 bit(20),
	col2 bit varying, 
	col3 blob,
	col4 clob,
	col5 short
);


create table stddev_samp_action(
        id int auto_increment,
        str char(20)
);


--create trigger
create trigger aft_ins after insert on stddev_samp_trigger
execute insert into stddev_samp_action(str) values ('INSERTED');


insert into stddev_samp_trigger values(B'1011', X'abc', X'0', 'cubrid', 333);
insert into stddev_samp_trigger values(B'1011', x'bcd', X'1', 'cubrid', 123);
insert into stddev_samp_trigger values(B'1011', X'abc', X'2', 'cubrid', 888);
insert into stddev_samp_trigger values(B'1011', x'bcd', X'3', 'cubrid', 666);
insert into stddev_samp_trigger values(B'1011', X'abc', X'4', 'cubrid', 222);
insert into stddev_samp_trigger values(B'1001', x'bcd', X'5', 'cubrid', 777);
insert into stddev_samp_trigger values(B'1001', X'abc', X'6', 'cubrid', 999);
insert into stddev_samp_trigger values(B'1001', X'abc', X'7', 'cubrid', 444);
insert into stddev_samp_trigger values(B'1001', X'cde', X'8', 'cubrid', 321);
insert into stddev_samp_trigger values(B'0011', X'abc', X'9', 'cubrid', 987);
insert into stddev_samp_trigger values(B'0011', X'abc', X'10', 'mysql', 555);
insert into stddev_samp_trigger values(B'0011', X'cde', X'11', 'mysql', 666);
insert into stddev_samp_trigger values(B'1010', X'abc', X'12', 'mysql', 777);
insert into stddev_samp_trigger values(B'1111', X'abc', X'13', 'mysql', 999);
insert into stddev_samp_trigger values(B'1111', x'bcd', X'14', 'mysql', 123);
insert into stddev_samp_trigger values(B'1111', X'abc', X'15', 'mysql', 555);
insert into stddev_samp_trigger values(B'1111', X'abc', X'16', 'mysql', 444);
insert into stddev_samp_trigger values(B'1111', X'cde', X'17', 'mysql', 888);
insert into stddev_samp_trigger values(B'1111', X'abc', X'18', 'mysql', 923);
insert into stddev_samp_trigger values(B'1111', X'abc', X'19', 'mysql', 234);



--TEST: OVER() clause
--TEST: bit(n) 
select col1, col2, stddev_samp(col5) over() from stddev_samp_trigger order by 1, 2;
--TEST: bit varying, with alias+all
select col2, blob_to_bit(col3), stddev_samp(all col5) over() stddev_samp from stddev_samp_trigger order by 1, blob_to_bit(col3);
--TEST: blob, with where clause
select blob_to_bit(col3), clob_to_char(col4), stddev_samp(col5) over() stddev_samp from stddev_samp_trigger where col1 > B'1011' order by blob_to_bit(col3), clob_to_char(col4);
--TEST: clob, distinct
select clob_to_char(col4), col1, stddev_samp(distinct col5) over() stddev_samp from stddev_samp_trigger order by clob_to_char(col4), 2;
--TEST: syntax error
select col1, blob_to_bit(col3), clob_to_char(distinct col5), stddev_samp(*) over stddev_samp from stddev_samp_trigger;
select col1, blob_to_bit(col3), col2, stddev_samp(col5) over(1) stddev_samp from stddev_samp_trigger;
--TEST: trigger action table
select id, str, stddev_samp(id) over() stddev_samp from stddev_samp_action order by id;



--TEST: OVER(PARTITION BY) clause
--TEST: partition by bit(n)
select col1, col2, blob_to_bit(col3), clob_to_char(col4), stddev_samp(unique col5) over(partition by col1) stddev_samp from stddev_samp_trigger order by 1, 2, blob_to_bit(col3), clob_to_char(col4);
--TEST: partition by bit varying
select col1, col2, blob_to_bit(col3), clob_to_char(col4), stddev_samp(distinct col5) over(partition by col2) stddev_samp from stddev_samp_trigger order by 2, 1, blob_to_bit(col3), clob_to_char(col4);
--TEST: partition by blob
select col1, col2, blob_to_bit(col3), clob_to_char(col4), stddev_samp(distinctrow col5) over(partition by 3) stddev_samp from stddev_samp_trigger order by blob_to_bit(col3), 1, 2, clob_to_char(col4);
--TEST: partition by clob
select col1, col2, blob_to_bit(col3), clob_to_char(col4), stddev_samp(all col5) over(partition by 4) stddev_samp from stddev_samp_trigger order by clob_to_char(col4), 1, 2, blob_to_bit(col3), 5;
--TEST: trigger action table, partition by int
select id, str, stddev_samp(id) over(partition by id) stddev_samp from stddev_samp_action order by id;
--TEST: trigger action table, partition by string
select id, str, stddev_samp(id) over(partition by str) stddev_samp from stddev_samp_action order by 1;



--TEST: OVER(ORDER BY) clause
--TEST: order by 1 column name
select col1, stddev_samp(col5) over(order by col1) stddev_samp from stddev_samp_trigger order by 1;
--TEST: order by 2 column names
select col2, blob_to_bit(col3), stddev_samp(all col5) over(order by col2, blob_to_bit(col3) asc) stddev_samp from stddev_samp_trigger order by 1;
--TEST: order by more than 2 column names
select col1, col2, blob_to_bit(col3), clob_to_char(col4), stddev_samp(unique col5) over(order by col1, col2 desc, blob_to_bit(col3), clob_to_char(col4) asc) stddev_samp from stddev_samp_trigger order by 1;
--TEST: order by columns not selected
select blob_to_bit(col3), stddev_samp(distinct col5) over(order by clob_to_char(col4) desc, col2, col1 asc) stddev_samp from stddev_samp_trigger order by 1;
--TEST: order by 1 position
select clob_to_char(col4), stddev_samp(all col5) over(order by 1) stddev_samp from stddev_samp_trigger order by 1;
--TEST: order by 3 positions
select blob_to_bit(col3), col2, stddev_samp(col5) over(order by blob_to_bit(col3), 2 desc, 3 asc) stddev_samp from stddev_samp_trigger order by 1;
--TEST: order by more than 3 positions
select col1, col2, blob_to_bit(col3), clob_to_char(col4), stddev_samp(col5) over(order by blob_to_bit(col3), 2 asc, 1 desc, clob_to_char(col4)) stddev_samp from stddev_samp_trigger order by 1;
--TEST: order by positions not existed
select col2, stddev_samp(distinct col5) over(order by 2) stddev_samp from stddev_samp_trigger order by 1;
select col1, stddev_samp(all col5) over(order by 3, 4, 1 desc) stddev_samp, col2, clob_to_char(col4) from stddev_samp_trigger order by 1;
select blob_to_bit(col3), clob_to_char(col4), stddev_samp(col5) over(order by 5) stddev_samp from stddev_samp_trigger;
select blob_to_bit(col3), col1, stddev_samp(col5) over(order by 100) stddev_samp from stddev_samp_trigger;
--TEST: order by column names and positions
select col1, col2, blob_to_bit(col3), clob_to_char(col4), stddev_samp(col5) over(order by 1, col2 desc, 3, clob_to_char(col4) asc) stddev_samp from stddev_samp_trigger order by 1;
--TEST: trigger action table
select id, str, substr(to_char(stddev_samp(id) over(order by id)), 1, 10) stddev_samp from stddev_samp_action order by 1;



--TEST: OVER(PARTITION BY ORDER BY) clause
--TEST: partition by bit(n)
select col1, col2, blob_to_bit(col3), stddev_samp(distinct col5) over(partition by col1 order by 1, 2, blob_to_bit(col3)) from stddev_samp_trigger;
--TEST: partition by bit varying
select col2, clob_to_char(col4), col1, stddev_samp(col5) over(partition by col2 order by col2, clob_to_char(col4), col1 desc) from stddev_samp_trigger;
--TEST: partition by blob
select blob_to_bit(col3), stddev_samp(all col5) over(partition by 1 order by blob_to_bit(col3), clob_to_char(col4), 3) stddev_samp, col2 from stddev_samp_trigger;
--TEST: partition by clob
select clob_to_char(col4), col1, stddev_samp(unique col5) over(partition by 1 order by clob_to_char(col4), 2 desc) stddev_samp from stddev_samp_trigger;
--TEST: syntax error
select col1, col2, stddev_samp(distinct col5) over(order by col1, col2 partition by col2) from stddev_samp_trigger;
--TEST: trigger action table, partition by int
select str, stddev_samp(id) over(partition by id order by id), id from stddev_samp_action order by 3;
--TEST: trigger action table, partition by str
select id, str, substr(to_char(stddev_samp(id) over(partition by str order by id)), 1, 10) stddev_samp from stddev_samp_action order by id;


delete from stddev_samp_trigger;
drop trigger aft_ins;
drop table stddev_samp_trigger, stddev_samp_action; 
set system parameters 'dont_reuse_heap_file=no';
--+holdcas off;














