-- DB 사용 선언
-- 실행 : ctrl + 엔터
use db_basic;

-- 테이블 생성하기 : users_info
create table users_info(
	id int primary key auto_increment,
	username varchar(255),
	email varchar(255),
	phone varchar(20),
	website varchar(255),
	regdate datetime
);

-- 테이블 생성하기 : users_info2
create table users_info2(
	id int primary key auto_increment,
	username varchar(255),
	email varchar(255),
	phone varchar(20),
	website varchar(255),
	regdate datetime
);

-- 테이블 삭제(drop)
drop table users_info2;

-- DML: data create
insert into users_info
	(id, username, email, phone, website, regdate)
	value(1, 'kim', 'kim@cozlab.com', '010-1234-5678', 'cozlab.com', '2020-10-24 00:00:00');

insert into users_info
	(id, username, email, phone, website, regdate)
	value(2, 'joy', 'joy@cozlab.com', '010-1234-5008', 'cozlab.com', '2020-10-24 00:00:00');
insert into users_info
	(id, username, email, phone, website, regdate)
	value(3, 'jong', 'jong@cozlab.com', '010-1004-5678', 'cozlab.com', '2020-10-24 00:00:00');
insert into users_info
	(id, username, email, phone, website, regdate)
	value(4, 'lim', 'lim@cozlab.com', '010-1034-5998', 'cozlab.com', '2020-10-24 00:00:00');

-- DML - Read(데이터 읽기)
-- users_info 테이블의 모든 데이터 읽기
select *
from users_info;


-- 특정 컬럼 데이터 읽기
select username, phone
from users_info as ui

-- DML - Update(특정 컬럼 데이터 수정)
update users_info ui 
set email = 'kim@google.com',
	phone = '010-8888-5555',
	regdate = '2025-10-22'
where id = 1;

-- DML - Delete(특정 레코드 데이터 삭제)
delete from  users_info
where id = 3;

-- DML - 테이블 내 데이터 모두 삭제, 테이블은 존재
delete from users_info ;


-- DDL - 테이블 삭제
drop table users_info ;