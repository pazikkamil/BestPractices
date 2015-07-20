load data
CHARACTERSET UTF16
infile 'PATH_TO_INFILE/PGM_VALUE.txt'
badfile 'PATH_TO_SQLLDR_LOG/PGM_VALUE.bad'
discardfile 'PATH_TO_SQLLDR_LOG/PGM_VALUE.discard'
APPEND
into table pink.temp_comment_adhoc
fields terminated by "\t" optionally enclosed by '"'
TRAILING NULLCOLS
(
rettsnr,
event,
kilde,
kommentar char(4000) "SUBSTR(:kommentar,1,4000)",
status CONSTANT 'loaded',
status_id CONSTANT "5",
pgm CONSTANT 'PGM_VALUE',
time_loaded EXPRESSION "current_timestamp(4)"
)
