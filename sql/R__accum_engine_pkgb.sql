CREATE OR REPLACE PACKAGE BODY accum_engine AS

    PROCEDURE move_rx_stage_1_to_stage_2 (
        iclaim_id NUMBER
    ) IS
    BEGIN
        INSERT INTO stage_2
            ( SELECT
                stage_2_id_seq.NEXTVAL,
                claim_id,
                'RX',
                claim_date,
                claim_amount,
                member_id
            FROM
                stage_1_rx_claims
            WHERE
                claim_id = iclaim_id
            );

    END move_rx_stage_1_to_stage_2;

    PROCEDURE move_med_stage_1_to_stage_2 (
        iclaim_id NUMBER
    ) IS
    BEGIN
        NULL;
    END move_med_stage_1_to_stage_2;

    PROCEDURE delete_rx_stage_1 (
        iclaim_id NUMBER
    ) IS
    BEGIN
        DELETE FROM stage_1_rx_claims
        WHERE
            claim_id = iclaim_id;

    END delete_rx_stage_1;

    PROCEDURE create_member_accumulation (
        imember_id VARCHAR2
    ) IS
    BEGIN
        INSERT INTO member_accumulation
            ( SELECT
                imember_id,
                0,
                0,
                'N',
                NULL
            FROM
                dual
            WHERE
                NOT EXISTS (
                    SELECT
                        'X'
                    FROM
                        member_accumulation
                    WHERE
                        member_id = imember_id
                )
            );

    END create_member_accumulation;

    PROCEDURE accumulate_rx_claims (
        iclaim_amount   NUMBER,
        imember_id      VARCHAR2
    ) IS
        vexisting_amount NUMBER;
    BEGIN
        SELECT
            rx_total
        INTO vexisting_amount
        FROM
            member_accumulation
        WHERE
            member_id = imember_id;

        UPDATE member_accumulation
        SET
            rx_total = ( vexisting_amount + iclaim_amount )
        WHERE
            member_id = imember_id;

    END accumulate_rx_claims;

    PROCEDURE archive_stage_2_record (
        istage_2_id NUMBER
    ) IS
    BEGIN
        -- Never do insert statements this way. Super bad practice kids.
        INSERT INTO stage_2_archive
            ( SELECT
                stage_2_id,
                claim_id,
                claim_type,
                claim_date,
                claim_amount,
                member_id,
                systimestamp
            FROM
                stage_2
            WHERE
                stage_2_id = istage_2_id
            );

    END archive_stage_2_record;

    PROCEDURE delete_stage_2_record (
        istage_2_id NUMBER
    ) IS
    BEGIN
        DELETE FROM stage_2
        WHERE
            stage_2_id = istage_2_id;

    END delete_stage_2_record;

    PROCEDURE check_deductable (
        imember_id VARCHAR2
    ) IS
    BEGIN
        UPDATE member_accumulation
        SET
            met_deductable = 'Y',
            met_deductable_date = SYSDATE
        WHERE
            member_id = imember_id
            AND met_deductable = 'N'
            AND ( rx_total + med_total ) >= (
                SELECT
                    deductible_threshold
                FROM
                    members
                WHERE
                    member_id = imember_id
            );

    END check_deductable;

    PROCEDURE run_engine IS

        vrx_claim_id        NUMBER;
        vmember_record_id   VARCHAR2(20);
        vrx_claim_amount        NUMBER;
        vrx_member_record_id   VARCHAR2(20);
        CURSOR find_stage_1_rx_claims IS
        SELECT
            claim_id
        FROM
            stage_1_rx_claims;

        CURSOR find_stage_2_members IS
        SELECT DISTINCT
            member_id
        FROM
            stage_2;
        
        CURSOR find_stage_2_rx_amounts IS
        select distinct a.member_id,(select sum(claim_amount)
from stage_2
where claim_type = 'RX'
and member_id = a.member_id)
from stage_2 a;  

    BEGIN
        OPEN find_stage_1_rx_claims;
        LOOP
            FETCH find_stage_1_rx_claims INTO vrx_claim_id;
            EXIT WHEN find_stage_1_rx_claims%notfound;
            move_rx_stage_1_to_stage_2(vrx_claim_id);
            delete_rx_stage_1(vrx_claim_id);
            --dbms_output.put_line();
        END LOOP;

        CLOSE find_stage_1_rx_claims;
        
         OPEN find_stage_2_members;
        LOOP
            FETCH find_stage_2_members INTO vmember_record_id;
            EXIT WHEN find_stage_2_members%notfound;
            create_member_accumulation(vmember_record_id);
        END LOOP;

        CLOSE find_stage_2_members;     
        
                 OPEN find_stage_2_rx_amounts;
        LOOP
            FETCH find_stage_2_rx_amounts INTO vrx_member_record_id,vrx_claim_amount;
            EXIT WHEN find_stage_2_rx_amounts%notfound;
            accumulate_rx_claims(vrx_claim_amount,vrx_member_record_id);
        END LOOP;

        CLOSE find_stage_2_rx_amounts;  
        
                 OPEN find_stage_2_members;
        LOOP
            FETCH find_stage_2_members INTO vmember_record_id;
            EXIT WHEN find_stage_2_members%notfound;
            check_deductable(vmember_record_id);
        END LOOP;

        CLOSE find_stage_2_members;     
        
        
    END run_engine;

END accum_engine;