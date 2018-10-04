DROP TABLE APPS.XXD_DAX_REQ_CLOB CASCADE CONSTRAINTS PURGE;

CREATE TABLE APPS.XXD_DAX_REQ_CLOB
(
  ANSWER_ID           NUMBER,
  EBS_TRANSACTION_NO  VARCHAR2(20 BYTE)         NOT NULL,
  REQ                 CLOB
)
LOB (REQ) STORE AS BASICFILE (
  TABLESPACE  APPS_TS_TX_DATA
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  RETENTION
      STORAGE    (
                  INITIAL          64K
                  NEXT             1M
                  MINEXTENTS       1
                  MAXEXTENTS       UNLIMITED
                  PCTINCREASE      0
                  BUFFER_POOL      DEFAULT
                 ))
TABLESPACE APPS_TS_TX_DATA;


CREATE INDEX APPS.XXD_DAX_REQ_CLOB_I1 ON APPS.XXD_DAX_REQ_CLOB
(ANSWER_ID)
TABLESPACE APPS_TS_TX_DATA;
