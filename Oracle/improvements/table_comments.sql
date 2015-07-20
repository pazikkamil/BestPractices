create table TEMP_COMMENT_ADHOC
(
RETTSNR varchar2(20) ,
EVENT varchar2(20),
KILDE varchar2(20),
KOMMENTAR varchar2(4000),
STATUS_ID varchar2(1) DEFAULT '5',
PGM VARCHAR(20),
TIME_LOADED TIMESTAMP
);
COMMENT ON TABLE PINK.TEMP_COMMENT_ADHOC IS 'The table holds data used to load comments and events.';
COMMENT ON COLUMN PINK.TEMP_COMMENT_ADHOC.RETTSNR IS 'StdName: rettsnr number of debtor.';
COMMENT ON COLUMN PINK.TEMP_COMMENT_ADHOC.EVENT IS 'StdName: EVENT. Name of event type id.';
COMMENT ON COLUMN PINK.TEMP_COMMENT_ADHOC.KOMMENTAR IS 'StdName: KOMMENTAR. Comment for cases of debtor.';
COMMENT ON COLUMN PINK.TEMP_COMMENT_ADHOC.STATUS_ID IS 'StdName: STATUS_ID. Technical field which help us processing rows (at the begining 5, if processed ok then 0).';
COMMENT ON COLUMN PINK.TEMP_COMMENT_ADHOC.TIME_LOADED IS 'StdName: TIME_LOADED. Field with timestamp of loading file by sqlldr.';
