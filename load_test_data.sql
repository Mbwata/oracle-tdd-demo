insert into stage_1_rx_claims (select * from test_rx_claims);

insert into stage_1_med_claims (select * from test_med_claims);

insert into members (select * from test_members);

commit;


--delete from stage_2_archive where claim_id < 0;
--delete from member_accumulation where claim_id < 0;
--delete from members where member_id < 0;
commit;