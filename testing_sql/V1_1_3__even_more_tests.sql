INSERT INTO accums.tests (
    test_id,
    test_name,
    proc_name,
    inputs,
    setup,
    validation,
    teardown,
    exceptions
) VALUES (
    10,
    'COPY MED RECORD FROM STAGE 1 TO STAGE 2 TABLE',
    'accum_engine.move_med_stage_1_to_stage_2',
    '-1000',
    'Insert into ACCUMS.STAGE_1_MED_CLAIMS (CLAIM_ID,CLAIM_DATE,CLAIM_AMOUNT,MEMBER_ID) values (-1000,sysdate,1045.18,-1)',
    'declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from stage_2
where claim_id = -1000;
end;',
    'rollback',
    NULL
);

INSERT INTO accums.tests (
    test_id,
    test_name,
    proc_name,
    inputs,
    setup,
    validation,
    teardown,
    exceptions
) VALUES (
    11,
    'ACCUMULATE MED CLAIMS',
    'accum_engine.accumulate_med_claims',
    '100,-1',
    'insert into member_accumulation (member_id,med_total) values (-1,100)',
    'declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from member_accumulation
where med_total = 200
and member_id = -1;
end;'
    ,
    'rollback',
    NULL
);

UPDATE tests
SET
    setup = 'Insert into ACCUMS.STAGE_1_RX_CLAIMS (CLAIM_ID,CLAIM_DATE,CLAIM_AMOUNT,MEMBER_ID) values (-1000,sysdate,1045.18,-1)'
WHERE
    test_id = 1;

UPDATE tests
SET
    setup = 'Insert into ACCUMS.STAGE_1_RX_CLAIMS (CLAIM_ID,CLAIM_DATE,CLAIM_AMOUNT,MEMBER_ID) values (-1000,sysdate,1045.18,-1)'
WHERE
    test_id = 2;

UPDATE tests
SET
    setup = 'INSERT INTO accums.stage_2 (
        stage_2_id,
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
        -1
    )'
    ,
    inputs = '-1',
    validation = 'DECLARE
    vtest NUMBER := NULL;
BEGIN
    SELECT
        COUNT(member_id)
    INTO vtest
    FROM
        member_accumulation
    WHERE
        member_id = -1;

    IF vtest > 1 THEN
        raise_application_error(-20002, ''MORE THAN ONE RECORD FOR MEMBER'' );
    ELSE
        IF vtest < 1 THEN
            raise_application_error(-20002, ''NO RECORD FOR MEMBER'');
        END IF;
    END IF;

END;'
WHERE
    test_id = 3;

UPDATE tests
SET
    setup = 'begin INSERT INTO accums.stage_2 (
        stage_2_id,
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
        -1
    );
    insert into member_accumulation (member_id) values (-1);
end;'
    ,
    inputs = '-1',
    validation = 'DECLARE
    vtest NUMBER := NULL;
BEGIN
    SELECT
        COUNT(member_id)
    INTO vtest
    FROM
        member_accumulation
    WHERE
        member_id = -1;

    IF vtest > 1 THEN
        raise_application_error(-20002, ''MORE THAN ONE RECORD FOR MEMBER'' );
    ELSE
        IF vtest < 1 THEN
            raise_application_error(-20002, ''NO RECORD FOR MEMBER'');
        END IF;
    END IF;

END;'
WHERE
    test_id = 4;

DELETE FROM tests
WHERE
    test_id = 5;

INSERT INTO ACCUMS.tests (
    test_id,
    test_name,
    proc_name,
    inputs,
    setup,
    validation,
    teardown,
    exceptions
) VALUES (
    5,
    'ACCUMULATE RX CLAIMS',
    'accum_engine.accumulate_rx_claims',
    '100,-1',
    'insert into member_accumulation (member_id,rx_total) values (-1,100)',
    'declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from member_accumulation
where rx_total = 200
and member_id = -1;
end;'
    ,
    'rollback',
    NULL
);

DELETE FROM tests
WHERE
    test_id IN (
        6,
        7
    );

INSERT INTO accums.tests (
    test_id,
    test_name,
    proc_name,
    inputs,
    setup,
    validation,
    teardown,
    exceptions
) VALUES (
    6,
    'ARCHIVE STAGE 2 RECORD',
    'accum_engine.archive_stage_2_record',
    '-1001',
    '    INSERT INTO accums.stage_2 (
        stage_2_id,
        claim_id,
        claim_type,
        claim_date,
        claim_amount,
        member_id
    ) VALUES (
        -1001,
        - 1000,
        ''RX'',
        SYSDATE,
        1000.99,
        -1
    )'
    ,
    'declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from stage_2_archive
where stage_2_id = -1001;
end;',
    'rollback',
    NULL
);

INSERT INTO accums.tests (
    test_id,
    test_name,
    proc_name,
    inputs,
    setup,
    validation,
    teardown,
    exceptions
) VALUES (
    7,
    'DELETE STAGE 2 RECORD',
    'accum_engine.delete_stage_2_record',
    '-1001',
    '    INSERT INTO accums.stage_2 (
        stage_2_id,
        claim_id,
        claim_type,
        claim_date,
        claim_amount,
        member_id
    ) VALUES (
        -1001,
        - 1000,
        ''RX'',
        SYSDATE,
        1000.99,
        -1
    )'
    ,
    'declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from stage_2
where stage_2_id = -1001;
raise_application_error( -20002, ''RECORD NOT DELETED'' );
exception when NO_DATA_FOUND then
null;
end;'
    ,
    'rollback',
    NULL
);

DELETE FROM tests
WHERE
    test_id IN (
        8,
        9
    );

INSERT INTO accums.tests (
    test_id,
    test_name,
    proc_name,
    inputs,
    setup,
    validation,
    teardown,
    exceptions
) VALUES (
    8,
    'CHECK FOR MET DEDUCTIBLE - YES',
    'accum_engine.check_deductable',
    '-1',
    'begin
insert into member_accumulation (member_id,rx_total,med_total,met_deductable) values (-1,100,100,''N'');
insert into members (member_id, deductible_threshold) values (-1,200);
end;'
    ,
    'declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from member_accumulation
where member_id = -1
and met_deductable = ''Y'';
end;
'
    ,
    'rollback',
    NULL
);

INSERT INTO accums.tests (
    test_id,
    test_name,
    proc_name,
    inputs,
    setup,
    validation,
    teardown,
    exceptions
) VALUES (
    9,
    'CHECK FOR MET DEDUCTIBLE - NO',
    'accum_engine.check_deductable',
    '-1',
    'begin
insert into member_accumulation (member_id,rx_total,med_total,met_deductable) values (-1,100,99,''N'');
insert into members (member_id, deductible_threshold) values (-1,200);
end;'
    ,
    'declare
vTEST VARCHAR2(20):= NULL;

begin
select ''X''
into vTEST
from member_accumulation
where member_id = -1
and met_deductable = ''N'';
end;
'
    ,
    'rollback',
    NULL
);