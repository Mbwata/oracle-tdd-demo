CREATE OR REPLACE PACKAGE accum_engine AS
    PROCEDURE move_rx_stage_1_to_stage_2 (
        iclaim_id NUMBER
    );

    PROCEDURE move_med_stage_1_to_stage_2 (
        iclaim_id NUMBER
    );

    PROCEDURE delete_rx_stage_1 (
        iclaim_id NUMBER
    );

    PROCEDURE create_member_accumulation (
        imember_id VARCHAR2
    );

    PROCEDURE accumulate_rx_claims (
        iclaim_amount   NUMBER,
        imember_id      VARCHAR2
    );

    PROCEDURE archive_stage_2_record (
        istage_2_id NUMBER
    );

    PROCEDURE delete_stage_2_record (
        istage_2_id NUMBER
    );

    PROCEDURE check_deductable (
        imember_id VARCHAR2
    );

    PROCEDURE run_engine;

END accum_engine;