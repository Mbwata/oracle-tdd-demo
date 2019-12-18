select distinct 'DROP TABLE '||owner||'.'||object_name||';'
from dba_objects
where owner = 'ACCUMS'
and object_type = 'TABLE'
--and object_type in ('TABLE','PACKAGE','PACKAGE BODY')
and object_name != 'flyway_schema_history'
union
select distinct 'DROP PACKAGE '||owner||'.'||object_name||';'
from dba_objects
where owner = 'ACCUMS'
and object_type = 'PACKAGE'
union
select distinct 'DROP SEQUENCE '||owner||'.'||object_name||';'
from dba_objects
where owner = 'ACCUMS'
and object_type = 'SEQUENCE'
union
select 'delete from ACCUMS.'||'"'||'flyway_schema_history'||'"'||'; COMMIT;' from dual;