Insert into ACCUMS.TESTS (TEST_ID,TEST_NAME,PROC_NAME,INPUTS,SETUP,VALIDATION,TEARDOWN,EXCEPTIONS) values (2,'DELETE RX RECORD FROM STAGE 1','accum_engine.delete_rx_stage_1','-1000','Insert into ACCUMS.STAGE_1_RX_CLAIMS (CLAIM_ID,CLAIM_DATE,CLAIM_AMOUNT,MEMBER_ID) values (-1000,sysdate,1045.18,''MEMBER 000'')','declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from stage_1_rx_claims
where claim_id = -1000;
raise_application_error( -20002, ''RECORD NOT DELETED'' );
exception when NO_DATA_FOUND then
null;
end;','rollback',null);
