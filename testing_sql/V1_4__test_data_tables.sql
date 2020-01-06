CREATE TABLE "TEST_MEMBERS" 
   (	"MEMBER_ID" NUMBER, 
	"MEMBER_NAME" VARCHAR2(20 BYTE), 
	"DEDUCTIBLE_THRESHOLD" NUMBER
   );

   CREATE TABLE "TEST_RX_CLAIMS" 
   (	"CLAIM_ID" NUMBER, 
	"CLAIM_DATE" DATE, 
	"CLAIM_AMOUNT" NUMBER, 
	"MEMBER_ID" NUMBER
   );

      CREATE TABLE "TEST_MED_CLAIMS" 
   (	"CLAIM_ID" NUMBER, 
	"CLAIM_DATE" DATE, 
	"CLAIM_AMOUNT" NUMBER, 
	"MEMBER_ID" NUMBER
   );