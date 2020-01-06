DECLARE
    vmember_number   NUMBER;
    vcounter         NUMBER;
    vlow_range       NUMBER;
    vhigh_range      NUMBER;
BEGIN
    vmember_number := NULL;
    vcounter := 1;

--delete from members;
    WHILE vcounter != 100 LOOP
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
    vcounter := 1;
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

    WHILE vcounter != 100 LOOP
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