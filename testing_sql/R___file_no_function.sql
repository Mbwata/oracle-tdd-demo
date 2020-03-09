CREATE OR REPLACE FUNCTION generate_file_number RETURN VARCHAR2 IS
    vfileno VARCHAR2(20);
BEGIN
    SELECT
        'V'
        || TO_CHAR(SYSDATE, 'J')
        || '_'
        || file_id_seq.NEXTVAL
    INTO vfileno
    FROM
        dual;

    RETURN vfileno;
END;