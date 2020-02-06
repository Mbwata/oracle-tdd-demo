begin

delete from stage_2_archive;
delete from member_accumulation;
delete from members;

delete from test_med_claims;
delete from test_members;
delete from test_rx_claims;


DROP SEQUENCE ACCUMS.CLAIM_ID_SEQ;
DROP SEQUENCE ACCUMS.MEMBER_SEQ;
DROP SEQUENCE ACCUMS.STAGE_2_ID_SEQ;

create sequence member_seq;
create sequence stage_2_id_seq;
create sequence CLAIM_ID_SEQ;

commit;


DECLARE
    vmember_number   NUMBER;
    vcounter         NUMBER;
    vlow_range       NUMBER;
    vhigh_range      NUMBER;
    vmembers number;
    vclaims number;
BEGIN

--How many members do you want?
vmembers := &no_of_members;

--How many claim do you want?

vclaims := &no_of_claims;

    vmember_number := NULL;
    vcounter := 0;

--delete from members;
    WHILE vcounter != vmembers LOOP
        SELECT
            member_seq.NEXTVAL
        INTO vmember_number
        FROM
            dual;

        INSERT INTO members (
            member_id,
            member_name,
            deductible_threshold
        ) VALUES (
            vmember_number,
            'MEMBER ' || vmember_number, round(dbms_random.value(3, 20), 0) * 1000
        );

        vcounter := vcounter + 1;
    END LOOP;

    COMMIT;
    vcounter := 0;
    SELECT
        MIN(member_id)
    INTO vlow_range
    FROM
        members;

    SELECT
        MAX(member_id)
    INTO vhigh_range
    FROM
        members;

    WHILE vcounter != vclaims LOOP
        INSERT INTO stage_1_rx_claims (
            claim_id,
            claim_date,
            claim_amount,
            member_id
        ) VALUES (
            claim_id_seq.NEXTVAL,
            SYSDATE - dbms_random.value(1, 100),
            round(DBMS_RANDOM.value(01, 400), 2),
            round(dbms_random.value(vlow_range, vhigh_range), 0)
        );

        INSERT INTO stage_1_med_claims (
            claim_id,
            claim_date,
            claim_amount,
            member_id
        ) VALUES (
            claim_id_seq.NEXTVAL,
            SYSDATE - dbms_random.value(1, 100),
            round(dbms_random.value(01, 5000), 2),
            round(dbms_random.value(vlow_range, vhigh_range), 0)
        );

        vcounter := vcounter + 1;
    END LOOP;

    COMMIT;
END;

delete from test_med_claims;
delete from test_members;
delete from test_rx_claims;
delete from TEST_ACCUMULATION_RESULTS;

insert into test_med_claims (select claim_id * -1, claim_date ,claim_amount ,member_id from stage_1_med_claims);
insert into test_rx_claims (select claim_id * -1, claim_date ,claim_amount ,member_id  from stage_1_rx_claims);
insert into test_members (select member_id * -1,member_name, DEDUCTIBLE_THRESHOLD from members);

commit;

insert into stage_1_rx_claims (select * from test_rx_claims);

insert into stage_1_med_claims (select * from test_med_claims);

insert into members (select * from test_members);

commit;


begin
dbms_output.put_line(systimestamp);
accum_engine.run_engine();
commit;
dbms_output.put_line(systimestamp);
end;

end;