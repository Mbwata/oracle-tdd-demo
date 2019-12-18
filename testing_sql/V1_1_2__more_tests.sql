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

Insert into ACCUMS.TESTS (TEST_ID,TEST_NAME,PROC_NAME,INPUTS,SETUP,VALIDATION,TEARDOWN,EXCEPTIONS) values (3,'CREATE NEW MEMBER ACCUM RECORD IF ONE DOESN''T EXIST','accum_engine.create_member_accumulation','''MEMBER 000''','    INSERT INTO accums.stage_2 (
        stage_1_id,
        claim_id,
        claim_type,
        claim_date,
        claim_amount,
        member_id
    ) VALUES (
        stage_2_id_seq.NEXTVAL,
        - 1000,
        ''RX'',
        SYSDATE,
        1000.99,
        ''MEMEBER 000''
    )','DECLARE
    vtest NUMBER := NULL;
BEGIN
    SELECT
        COUNT(member_id)
    INTO vtest
    FROM
        member_accumulation
    WHERE
        member_id = ''MEMBER 000'';

    IF vtest > 1 THEN
        raise_application_error(-20002, ''MORE THAN ONE RECORD FOR MEMBER'' );
    ELSE
        IF vtest < 1 THEN
            raise_application_error(-20002, ''NO RECORD FOR MEMBER'');
        END IF;
    END IF;

END;','rollback',null);