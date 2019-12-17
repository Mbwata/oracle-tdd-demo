CREATE OR REPLACE PACKAGE auto_tests AS
    PROCEDURE run_tests (
        itest_id NUMBER
    );

END auto_tests;