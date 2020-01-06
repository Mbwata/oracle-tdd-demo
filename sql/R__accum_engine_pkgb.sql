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
        INSERT INTO stage_2
            ( SELECT
                stage_2_id_seq.NEXTVAL,
                claim_id,
                'MED',
                claim_date,
                claim_amount,
                member_id
            FROM
                stage_1_med_claims
            WHERE
                claim_id = iclaim_id
            );

    END move_med_stage_1_to_stage_2;

    PROCEDURE delete_rx_stage_1 (
        iclaim_id NUMBER
    ) IS
    BEGIN
        DELETE FROM stage_1_rx_claims
        WHERE
            claim_id = iclaim_id;

    END delete_rx_stage_1;

    PROCEDURE delete_med_stage_1 (
        iclaim_id NUMBER
    ) IS
    BEGIN
        DELETE FROM stage_1_med_claims
        WHERE
            claim_id = iclaim_id;

    END delete_med_stage_1;

    PROCEDURE create_member_accumulation (
        imember_id number
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
        imember_id      number
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

    PROCEDURE accumulate_med_claims (
        iclaim_amount   NUMBER,
        imember_id      number
    ) IS
        vexisting_amount NUMBER;
    BEGIN
        SELECT
            med_total
        INTO vexisting_amount
        FROM
            member_accumulation
        WHERE
            member_id = imember_id;

        UPDATE member_accumulation
        SET
            med_total = ( vexisting_amount + iclaim_amount )
        WHERE
            member_id = imember_id;

    END accumulate_med_claims;

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
        imember_id number
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

        vrx_claim_id               NUMBER;
        vmed_claim_id              NUMBER;
        vstage2_claim_id              NUMBER;
        vmember_record_id          VARCHAR2(20);
        vstage2_claim_amount       NUMBER;
        vstage2_member_record_id   VARCHAR2(20);
        vstage2_claim_type         VARCHAR2(20);
        CURSOR find_stage_1_rx_claims IS
        SELECT
            claim_id
        FROM
            stage_1_rx_claims;

        CURSOR find_stage_1_med_claims IS
        SELECT
            claim_id
        FROM
            stage_1_med_claims;

        CURSOR find_stage_2_members IS
        SELECT DISTINCT
            member_id
        FROM
            stage_2;

        CURSOR find_stage_2_claim_amounts IS
        SELECT DISTINCT
            a.member_id,
            a.claim_type,
            (
                SELECT
                    SUM(claim_amount)
                FROM
                    stage_2
                WHERE
                    member_id = a.member_id
                    and claim_type = a.claim_type
            )
        FROM
            stage_2 a;

        CURSOR find_stage_2_claims IS
        SELECT
            stage_2_id
        FROM
            stage_2;

    BEGIN
    
    --Move stage 1 RX claims to stage 2 and delete the stage 1 records
        OPEN find_stage_1_rx_claims;
        LOOP
            FETCH find_stage_1_rx_claims INTO vrx_claim_id;
            EXIT WHEN find_stage_1_rx_claims%notfound;
            move_rx_stage_1_to_stage_2(vrx_claim_id);
            delete_rx_stage_1(vrx_claim_id);
        END LOOP;

        CLOSE find_stage_1_rx_claims;
        
    --Move stage 1 MED claims to stage 2 and delete the stage 1 records    
        OPEN find_stage_1_med_claims;
        LOOP
            FETCH find_stage_1_med_claims INTO vmed_claim_id;
            EXIT WHEN find_stage_1_med_claims%notfound;
            move_med_stage_1_to_stage_2(vmed_claim_id);
            delete_med_stage_1(vmed_claim_id);
        END LOOP;

        CLOSE find_stage_1_med_claims;
        
    --Check claims to see if new member accumulation records need to be created  
        OPEN find_stage_2_members;
        LOOP
            FETCH find_stage_2_members INTO vmember_record_id;
            EXIT WHEN find_stage_2_members%notfound;
            create_member_accumulation(vmember_record_id);
        END LOOP;

        CLOSE find_stage_2_members;
        OPEN find_stage_2_claim_amounts;
        LOOP
            FETCH find_stage_2_claim_amounts INTO
                vstage2_member_record_id,
                vstage2_claim_type,
                vstage2_claim_amount;
            EXIT WHEN find_stage_2_claim_amounts%notfound;
            IF vstage2_claim_type = 'RX' THEN
                accumulate_rx_claims(vstage2_claim_amount, vstage2_member_record_id);
            ELSE
                IF vstage2_claim_type = 'MED' THEN
                    accumulate_med_claims(vstage2_claim_amount, vstage2_member_record_id);
                END IF;
            END IF;

        END LOOP;

        CLOSE find_stage_2_claim_amounts;
        OPEN find_stage_2_members;
        LOOP
            FETCH find_stage_2_members INTO vmember_record_id;
            EXIT WHEN find_stage_2_members%notfound;
            check_deductable(vmember_record_id);
        END LOOP;

        CLOSE find_stage_2_members;
        
                OPEN find_stage_2_claims;
        LOOP
            FETCH find_stage_2_claims INTO vstage2_claim_id;
            EXIT WHEN find_stage_2_claims%notfound;
            archive_stage_2_record(vstage2_claim_id);
            delete_stage_2_record(vstage2_claim_id);
        END LOOP;

        CLOSE find_stage_2_claims;
        
        
    END run_engine;

END accum_engine;