CREATE OR REPLACE PACKAGE accum_engine AS
    PROCEDURE move_rx_stage_1_to_stage_2 (
        iclaim_id NUMBER
    );

END accum_engine;