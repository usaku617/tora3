<chap2>
[SQLの種類]
DDL データ定義言語
  create, alter, drop, truncate　等
DML データ操作言語　
  insert.select, update. delete　等
  dmlでの操作のみロールバック可能。
DCL データ制御言語
  grant, revoke　等
[データベースを作成]
create database dbname;
[データベースを表示]
show databases;
[データベースを削除]
drop database dbname;
[ユーザーを作成]
create user myusr@localhost identified by '*****';
[ユーザーに権限付与]
grant all on dbname.* to myusr@localhost;
※grant all on *.* to myusr@localhost; と書くと現在あるすべてのDBに対して権限を与えられる。
[データベースを選択]
use dbname;
※select database();で現在使用中のDBが表示される。
<chap3>
[テーブルの作成]
create table usr (uid varchar(7), passwd varchar(15), uname varchar(20), family int);
[テーブルを表示]
show tables;
[指定テーブルのカラム情報表示]
desc usr;
show fields from usr;
[テーブルを削除]
drop table usr;
[カラム追加]
・先頭以外に追加するときはこの記述方法
alter table usr add updated date after family;
・先頭にカラムを追加する場合はこの記述方法
alter table usr add updated date first;
[カラム削除]
alter table usr drop updated;
[カラム変更]
・列名も変えたい場合
alter table usr change udated updated date;
・型だけ変えたい場合
alter table usr modify updated datetime;
--------------------------------------------------------------------------------------------------------------------
[データ追加]
・カラム名を指定する方法
insert into usr (uid, passwd, uname, family) values ('yyamada','12345','山田祥寛', 3);
・カラム名を省略する方法
insert into usr values('ssuzuki', '98765', '鈴木正一', 4);
[指定テーブルの全てのデータを表示]
select * from usr;
<chap4>
[主キー制約追加]
<alter tableで追加>
alter table usr add primary key (uid);
<テーブル作成時に指定1-各列に指定>
create table usr (uid varchar(7) primary key ,passwd varchar(15);
<テーブル作成時に指定2-最後に制約として記述>
create table usr (uid varchar(7), passwd varchar(15),primary key(uid);
[auto increment属性追加]
<alter tableで追加>
alter table schedule modify pid int auto_increment;
<テーブル作成時に指定>
create table schedule (pid int auto_increment, ...)
[not null制約追加]
alter table usr modify passwd varchar(15) not null, modify uname varchar(20) not null;
[default制約追加]
alter table usr alter uname set default "ゲスト";
[テーブル作成時にnot null制約、default制約追加]
create table usr (uid varchar(7), ... , uname varchar(20) not null default 'ゲスト', ...);
[外部キー制約追加]
<alter tableで追加>
alter table schedule add foreign key (uid) references usr (uid);
<テーブル作成時に指定>
create table schedule (pid int auto_increment, ... , primary key(pid), foreign key (uid) references usr (uid);
<chap5>
[dbをuseしている状態で、mysqlコマンド入力画面で]
source C:\practiceMySQL\basic.sql
上記のコマンドで選択しているDBにデータが復元される。
--------------------------------------------------------------------------------------------------------------------
[重複の除去]
select distinct uid from schedule;
select distinct uid, cid from schedule;[こちらはuid, cidの2つで重複していないデータが出力される。つまり、uidとcidが同じで初めて重複データとみなされる。]
[演算子]
select * from schedule where pdate = '2024-07-31';
[where以下に書ける比較演算子]
=, <>, >, >=, <, <=, [not] between A and B, [not] in (A, B, C), is [not] null, [not] like "～"[～のなかでは'%'(任意の0文字以上)や'_'(任意の1文字)が使える]
[更新]
update usr set family = 5, passwd = '999' where uid = 'yyamada';
[削除]
・dml。全データを削除。auto incrementのカウンタはリセットされない。
delete from usr where uid = 'hsugita';
・こちらはddlなのでロールバック不可。deleteより高速。
  auto incrementのカウンタもリセットされる。
truncate table テーブル名;
<chap6>
[表示数の制限(limit)]
select * from schedule order by pdate [asc], ptime desc limit 5;[ascは省略可,limitは指定した件数だけデータを出力する]
select * from schedule order by pdate, ptame desc limit 0,5;[これは上とまったく同じ/limit(先頭行,取得行数)とも書ける]
[集計関数]
select uid, count(*) from schedule group by uid;
上記のcount(*)はNULLも含めてグループ化したuidの件数を取得する。count(uid)とすればNULLは除外される。
ちなみに集計関数はグループ化しなくても使える。例は↓
select max(pdate) as MaxPDate, count(*) as 全件数 from schedule;
[asは別名を定義できるが省略可能。この場合だとasを省略して、[count(*) 全件数] でもOK。]
・その他の集計関数
AVG, COUNT, MAX, MIN, SUM
・関数
CHAR_LENGTH(str):strの文字数を取得
SUBSTRING(str, pos[, len]):strのpos(1文字目を0とする)文字からlen文字表示(lenが省略されるとpos文字から最後の文字まで表示)
REPLACE(str, from, to):fromをtoに置換
CEILING(num):小数点以下を切り上げ
FLOOR(num):小数点以下を切り捨て
SQRT(num):平方根を取得
NOW():現在日時を取得
DATEDIFF(date1, date2):日付の差を取得
DATE_FORMAT('～','%Y%m%d');
[教科書にないやつ テスト範囲外]
DATE_ADD('～', INTERVAL 1 YEAR[or MONTH or DAY]);
DATE_SUB('～', INTERVAL 1 YEAR[or MONTH or DAY]);
--------------------------------------------------------------------------------------------------------------------
<chap7>
[内部結合]
select s.subject, s.pdate, c.cname from schedule s inner join category c on s.cid = c.cid where s.uid='yyamada';
・on以下の条件で一致するデータのみを表示。
[外部結合]
select s.subject, s.pdate, u.uname from usr u left (outer) join schedule s as on u.uid=s.uid;
・左のテーブルを起点に結合。(左のデータはすべて表示される)
[サブクエリ]
(1)
select uname, family from usr where family > (select avg(family) from usr);
・比較演算子と共に使う場合は、1件だけ結果が返ってくるサブクエリ(select文)を書く。
(2)
select uid, uname from usr u where uid in (select [distinct] uid from schedule);
・distinctは別になくてもよい
・サブクエリ(()内)のselectの結果のuidに一致するデータが表示される。
[※インデックス]
create index idx_usr on usr (uname);
※フィールド名は()内にカンマ区切りで書く。
drop index idx_usr on usr;
[トランザクション]
begin, rollback, commit
  rollbackまたはcommitで完結
  beginしてcommitせずにデータベースから切断すると自動的にbeginした時点までrollbackされるので、注意。
  またrollbackてきるのはdmlでの操作のみ。
<その他 テスト範囲外>
[インデックスの確認]
select table_schema, table_name, column_name, index_name from information_schema.statistics where table_schema='basic';
