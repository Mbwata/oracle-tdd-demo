declare
vmember_number number;

begin

vmember_number := 1;

WHILE vmember_number != 201
LOOP
insert into members (MEMBER_ID,DEDUCTIBLE_THRESHOLD) values ('MEMBER '||vmember_number, round(DBMS_RANDOM.value(2, 15),0) * 1000);

vmember_number := vmember_number +1;
END LOOP;

commit;


end;