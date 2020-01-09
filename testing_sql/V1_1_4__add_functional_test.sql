Insert into ACCUMS.TESTS (TEST_ID,TEST_NAME,PROC_NAME,INPUTS,SETUP,VALIDATION,TEARDOWN,EXCEPTIONS) values (12,'FUNCTIONAL TEST','accum_engine.run_engine',null,'begin
insert into stage_1_rx_claims (select * from test_rx_claims);

insert into stage_1_med_claims (select * from test_med_claims);

insert into members (select * from test_members);

end;','declare
vTEST number:= NULL;

begin

SELECT member_id
into vTEST
FROM
    test_accumulation_results
WHERE
    ( member_id,
      rx_total,
      med_total,
      met_deductable ) NOT IN (
        SELECT
            member_id,
            rx_total,
            med_total,
            met_deductable
        FROM
            member_accumulation
	where member_id < 0
    );


raise_application_error( -20002, ''ERRORS IN ACCUM'' );
exception when NO_DATA_FOUND then
null;
end;','rollback',null);