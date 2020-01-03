begin 

delete from stage_2;
delete from member_accumulation;
commit;
accum_engine.run_engine;
commit;

end;