  CREATE TABLE "STAGE_2_ARCHIVE2" 
   ("STAGE_2_ID" NUMBER,
    "CLAIM_ID" NUMBER,
   "CLAIM_TYPE" VARCHAR2(20 BYTE),  
	"CLAIM_DATE" DATE, 
	"CLAIM_AMOUNT" NUMBER, 
	"MEMBER_ID" number,
      "PROCESS_TIMESTAMP" TIMESTAMP (6)
   ) ;


insert into STAGE_2_ARCHIVE2 (SELECT
    a.stage_2_id,
    a.claim_id,
    a.claim_type,
    a.claim_date,
    a.claim_amount,
    (
        SELECT
            member_id
        FROM
            members
        WHERE
            member_name = a.member_id
    ),
    a.process_timestamp
FROM
    stage_2_archive a);

    drop table STAGE_2_ARCHIVE;

    alter table "ACCUMS"."STAGE_2_ARCHIVE2" rename to STAGE_2_ARCHIVE;