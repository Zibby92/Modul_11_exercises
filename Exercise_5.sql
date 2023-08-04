CREATE OR REPLACE PACKAGE error_pkg IS
        err_constraint EXCEPTION;
        PRAGMA EXCEPTION_INIT (err_constraint,-00001);
        ms_err_constraint VARCHAR2(1000);
END error_pkg;
/
CREATE OR REPLACE PACKAGE BODY error_pkg IS
BEGIN
    -- "q' - easy way to insert into variable a lot of text with many signs used in programs
    -- I know that putting logig into EXCEPTION part is not good practice but in this case it
    -- made code much cleaner than normal
    ms_err_constraint :=  
    q'[
    BEGIN
    DBMS_OUTPUT.PUT_LINE('format_error_stack');
    DBMS_OUTPUT.PUT_LINE(dbms_utility.format_error_stack);
    DBMS_OUTPUT.PUT_LINE('format_error_backtrace');
    DBMS_OUTPUT.PUT_LINE(dbms_utility.format_error_backtrace);
    DBMS_OUTPUT.PUT_LINE
    ('naruszenie ograniczenia, w tym miejscu nie mo¿na wstawiæ informacji do kolumny');
    END;]';
END;
/
DECLARE 
    v_new_country_id countries.country_id%TYPE := 'ML';
    v_country_name countries.country_name%TYPE := 'Malta';
    
    err_constraint EXCEPTION;
    PRAGMA EXCEPTION_INIT (err_constraint,-00001);
BEGIN
    INSERT INTO countries (country_id, country_name) VALUES (v_new_country_id, v_country_name);
EXCEPTION
    WHEN error_pkg.err_constraint THEN 
    EXECUTE IMMEDIATE error_pkg.ms_err_constraint;
    END;
/


