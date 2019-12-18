Insert into TESTS (TEST_ID,TEST_NAME,PROC_NAME,INPUTS,SETUP,VALIDATION,TEARDOWN,EXCEPTIONS) values (1,'COPY RX RECORD FROM STAGE 1 TO STAGE 2 TABLE','accum_engine.move_rx_stage_1_to_stage_2','-1000','Insert into ACCUMS.STAGE_1_RX_CLAIMS (CLAIM_ID,CLAIM_DATE,CLAIM_AMOUNT,MEMBER_ID) values (-1000,sysdate,1045.18,''MEMBER 000'')','declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from stage_2
where claim_id = -1000;
end;','rollback',null);
