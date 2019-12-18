--------------------------------------------------------
--  DDL for Table TESTS
--------------------------------------------------------

  CREATE TABLE "TESTS" 
   (	"TEST_ID" NUMBER, 
	"TEST_NAME" VARCHAR2(500 BYTE), 
	"PROC_NAME" VARCHAR2(500 BYTE), 
	"INPUTS" VARCHAR2(500 BYTE), 
	"SETUP" VARCHAR2(500 BYTE), 
	"VALIDATION" VARCHAR2(500 BYTE), 
	"TEARDOWN" VARCHAR2(500 BYTE), 
	"EXCEPTIONS" VARCHAR2(500 BYTE)
   ) ;
--------------------------------------------------------
--  DDL for Index TESTS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "TESTS_PK" ON "TESTS" ("TEST_ID") 
  ;
--------------------------------------------------------
--  Constraints for Table TESTS
--------------------------------------------------------

  ALTER TABLE "TESTS" MODIFY ("TEST_ID" NOT NULL ENABLE);
  ALTER TABLE "TESTS" ADD CONSTRAINT "TESTS_PK" PRIMARY KEY ("TEST_ID")
  USING INDEX  ENABLE;
