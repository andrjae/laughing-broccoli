LOAD DATA
INFILE 'daxloader_r.txt' APPEND
  INTO TABLE xxd_dax_req_clob
  FIELDS TERMINATED BY ','
  (ebs_transaction_no	CHAR(10),
   answer_id            CHAR(10),
   fname		FILLER CHAR(80),
   req			LOBFILE(fname) TERMINATED BY EOF
  )
