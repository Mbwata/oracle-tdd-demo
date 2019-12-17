alter session set "_ORACLE_SCRIPT"=true;

create user accums identified by passord;
 
alter user accums default tablespace USERS;
 
grant create session, create table, create procedure, create sequence to accums;
 
alter user accums quota unlimited on users;