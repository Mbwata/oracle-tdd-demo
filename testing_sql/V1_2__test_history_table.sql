--------------------------------------------------------
--  DDL for Table TEST_HISTORY
--------------------------------------------------------

  CREATE TABLE "TEST_HISTORY" 
   (	"TEST_RUN_ID" NUMBER, 
	"TEST_DATE" TIMESTAMP (6), 
	"TEST_NAME" VARCHAR2(255 BYTE), 
	"PROC_TESTED" VARCHAR2(255 BYTE), 
	"INPUTS" VARCHAR2(255 BYTE), 
	"RESULT" VARCHAR2(20 BYTE), 
	"ERROR_MESSAGE" VARCHAR2(255 BYTE)
   ) ;
--------------------------------------------------------
--  Constraints for Table TEST_HISTORY
--------------------------------------------------------

  ALTER TABLE "TEST_HISTORY" MODIFY ("TEST_RUN_ID" NOT NULL ENABLE);
  ALTER TABLE "TEST_HISTORY" MODIFY ("TEST_DATE" NOT NULL ENABLE);
  ALTER TABLE "TEST_HISTORY" MODIFY ("TEST_NAME" NOT NULL ENABLE);
  ALTER TABLE "TEST_HISTORY" MODIFY ("PROC_TESTED" NOT NULL ENABLE);
  ALTER TABLE "TEST_HISTORY" MODIFY ("RESULT" NOT NULL ENABLE);
