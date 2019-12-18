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
        NULL;
    END;

END accum_engine;