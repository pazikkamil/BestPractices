

alter SESSION set NLS_DATE_FORMAT = 'DD-MM-YYYY HH24:MI:SS' ;

SET echo off
SET feedback off
SET term off
SET pagesize 0
SET linesize 12
SET newpage 0
SET VERIFY OFF
SET space 0
col FWF format 12
spool "xxx.txt"

select DISTINCT TRIM(UPPER(da.value_char)) from DOCUMENT_ATTRIBUTE da
where da.attribute_id = 51505
and REGEXP_LIKE(UPPER(da.value_char), '^[[:digit:]]+$')
and LENGTH(TRIM(UPPER(da.value_char))) < 8;

spool off
exit;
