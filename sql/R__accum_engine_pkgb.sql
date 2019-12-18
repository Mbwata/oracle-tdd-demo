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
                    FROM member_accumulation
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

END accum_engine;