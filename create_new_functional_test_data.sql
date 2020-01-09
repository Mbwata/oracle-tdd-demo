delete from test_med_claims;
delete from test_members;
delete from test_rx_claims;
delete from TEST_ACCUMULATION_RESULTS;

insert into test_med_claims (select claim_id * -1, claim_date ,claim_amount ,member_id * -1 from stage_1_med_claims);
insert into test_rx_claims (select claim_id * -1, claim_date ,claim_amount ,member_id * -1  from stage_1_rx_claims);
insert into test_members (select member_id * -1,member_name, DEDUCTIBLE_THRESHOLD from members);


--insert into TEST_ACCUMULATION_RESULTS (select member_id * -1,rx_total, med_total, met_DEDUCTIBLE from member_ACCUMULATION);

commit;