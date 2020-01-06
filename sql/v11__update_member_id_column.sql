  CREATE TABLE "MEMBERS2" 
   (	"MEMBER_ID" VARCHAR2(20 BYTE), 
	"DEDUCTIBLE_THRESHOLD" NUMBER
   ) ;

   insert into members2 (select * from members);

drop table members;

  CREATE TABLE "MEMBERS" 
   (	"MEMBER_ID" number,
   member_name VARCHAR2(20 BYTE),
	"DEDUCTIBLE_THRESHOLD" NUMBER
   ) ;

      insert into members (select member_seq.nextval, MEMBER_ID, DEDUCTIBLE_THRESHOLD from members2);

  drop table MEMBERS2;    