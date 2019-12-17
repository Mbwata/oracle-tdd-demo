CREATE OR REPLACE PACKAGE BODY auto_tests AS

    gtest_run NUMBER := NULL;

    PROCEDURE log_test_results (
        itest_name       test_history.test_name%TYPE,
        iproc_tested     test_history.proc_tested%TYPE,
        iinputs          test_history.inputs%TYPE,
        iresult          test_history.result%TYPE,
        ierror_message   test_history.error_message%TYPE
    ) IS
    BEGIN
        IF gtest_run IS NULL THEN
            gtest_run := test_run_id_seq.nextval;
            dbms_output.put_line('**** Test Run #'
                                 || gtest_run
                                 || ' '
                                 || systimestamp
                                 || ' ****');

        END IF;

        INSERT INTO footie.test_history (
            test_run_id,
            test_date,
            test_name,
            proc_tested,
            inputs,
            result,ERROR_MESSAGE
        ) VALUES (
            gtest_run,
            systimestamp,
            itest_name,
            iproc_tested,
            iinputs,
            iresult,
            ierror_message
        );

        dbms_output.put_line(iresult
                             || ' - '
                             || itest_name);
        COMMIT;
    END log_test_results;

    PROCEDURE execute_test (
        itest_id NUMBER
    ) IS

        vproc             tests.proc_name%TYPE;
        vinputs           tests.inputs%TYPE;
        vvalidation       tests.validation%TYPE;
        vteardown         tests.teardown%TYPE;
        vtest_exception   tests.exceptions%TYPE;
        vsetup            tests.setup%TYPE;
        vtest_name        tests.test_name%TYPE;
        vproc_call        VARCHAR2(4000);
    BEGIN
        SELECT
            proc_name,
            inputs,
            setup,
            validation,
            teardown,
            exceptions,
            test_name
        INTO
            vproc,
            vinputs,
            vsetup,
            vvalidation,
            vteardown,
            vtest_exception,
            vtest_name
        FROM
            tests
        WHERE
            test_id = itest_id;

        vproc_call := 'BEGIN '
                      || vproc
                      || '('
                      || vinputs
                      || ')'
                      || '; '
                      || vtest_exception
                      || ' END;';

        --dbms_output.put_line(vproc_call);

        EXECUTE IMMEDIATE vproc_call;

       --dbms_output.put_line(vVALIDATION);
        EXECUTE IMMEDIATE vvalidation;
        --dbms_output.put_line('PASS');
        EXECUTE IMMEDIATE vteardown;
        log_test_results(vtest_name, vproc, vinputs, 'PASS', NULL);
    EXCEPTION
        WHEN OTHERS THEN
            EXECUTE IMMEDIATE vteardown;
            IF sqlcode = -20001 THEN
                log_test_results(vtest_name, vproc, vinputs, 'PASS', NULL);
            ELSE
                log_test_results(vtest_name, vproc, vinputs, 'FAIL', sqlerrm);
            END IF;

    END execute_test;

    PROCEDURE run_tests (
        itest_id NUMBER
    ) IS

        TYPE r_cursor IS REF CURSOR;
        test_cursor   r_cursor;
        vsql          VARCHAR2(200);
        vtest_id      tests.test_id%TYPE;
    BEGIN
        IF itest_id IS NULL THEN
            vsql := 'select test_id from tests';
        ELSE
            vsql := 'select test_id from tests where test_id = ' || itest_id;
        END IF;

        OPEN test_cursor FOR vsql;

        LOOP
            FETCH test_cursor INTO vtest_id;
            EXIT WHEN test_cursor%notfound;
            execute_test(vtest_id);
        END LOOP;

        gtest_run := NULL;
    END run_tests;

END auto_tests;