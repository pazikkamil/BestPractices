DECLARE
v_out_file UTL_FILE.FILE_TYPE;
v_str varchar2(3500):='TEST';
l_code                  PLS_INTEGER := 0;
l_mesg                  VARCHAR2 (32767);
BEGIN
v_out_file := UTL_FILE.FOPEN('TEST2', 'test_util2.txt', 'W', 4000);
v_str := rpad('aaaaaaaaaaa', 3000, '-');
UTL_FILE.PUT_LINE(v_out_file, v_str);
utl_file.fclose_all;
 EXCEPTION
      WHEN OTHERS THEN
         l_code         := SQLCODE;
         l_mesg         := SQLERRM;
         DBMS_OUTPUT.put_line ('other exception code: ' || l_code || CHR (10) || 'Message ' || l_mesg);
END;
/