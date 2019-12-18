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
    
    
        PROCEDURE delete_rx_stage_1(
        iclaim_id NUMBER
    )is
    begin

    delete from stage_1_rx_claims where claim_id = iclaim_id;

    end delete_rx_stage_1;

END accum_engine;