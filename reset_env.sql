delete from stage_2_archive;
delete from member_accumulation;
delete from members;

--delete from test_med_claims;
--delete from test_members;
--delete from test_rx_claims;

DROP SEQUENCE ACCUMS.CLAIM_ID_SEQ;
DROP SEQUENCE ACCUMS.MEMBER_SEQ;
DROP SEQUENCE ACCUMS.STAGE_2_ID_SEQ;

create sequence member_seq;
create sequence stage_2_id_seq;
create sequence CLAIM_ID_SEQ;

commit;