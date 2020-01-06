CREATE TABLE MEMBER_ACCUMULATION2 
(
  MEMBER_ID number 
, RX_TOTAL NUMBER 
, MED_TOTAL NUMBER 
, MET_DEDUCTABLE VARCHAR2(1) DEFAULT 'N' 
, MET_DEDUCTABLE_DATE DATE 
);

insert into MEMBER_ACCUMULATION2 (SELECT
    (
        SELECT
            member_id
        FROM
            members
        WHERE
            member_name = a.member_id
    ),
    a.RX_TOTAL,
    a.MED_TOTAL,
    a.MET_DEDUCTABLE,
    a.MET_DEDUCTABLE_DATE
FROM
    MEMBER_ACCUMULATION a);

    drop table MEMBER_ACCUMULATION;

    alter table "ACCUMS"."MEMBER_ACCUMULATION2" rename to MEMBER_ACCUMULATION;