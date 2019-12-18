create or replace PACKAGE accum_engine AS
    PROCEDURE move_rx_stage_1_to_stage_2 (
        iclaim_id NUMBER
    );

PROCEDURE delete_rx_stage_1 (
        iclaim_id NUMBER
    );

PROCEDURE create_member_accumulation (
        imember_id VARCHAR2
    );

END accum_engine;