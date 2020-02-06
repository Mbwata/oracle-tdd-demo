SET SERVEROUTPUT ON
begin
dbms_output.put_line(systimestamp);
accum_engine.run_engine();
commit;
dbms_output.put_line(systimestamp);
end;