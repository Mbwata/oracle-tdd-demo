declare
vcounter number;

begin

vcounter := 1;

WHILE vcounter != 5000
LOOP
insert into STAGE_1_RX_CLAIMS (CLAIM_ID,CLAIM_DATE,CLAIM_AMOUNT,MEMBER_ID) values (claim_id_seq.nextval,sysdate - DBMS_RANDOM.value(1, 200),round(DBMS_RANDOM.value(01, 5000),2),'MEMBER '||round(DBMS_RANDOM.value(1, 200),0));

insert into STAGE_1_MED_CLAIMS (CLAIM_ID,CLAIM_DATE,CLAIM_AMOUNT,MEMBER_ID) values (claim_id_seq.nextval,sysdate - DBMS_RANDOM.value(1, 200),round(DBMS_RANDOM.value(01, 5000),2),'MEMBER '||round(DBMS_RANDOM.value(1, 200),0));

vcounter := vcounter +1;
END LOOP;

commit;


end;