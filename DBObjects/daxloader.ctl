LOAD DATA
INFILE 'daxloader.txt' APPEND
  INTO TABLE xxd_dax_clob
  FIELDS TERMINATED BY ','
  (ebs_transaction_no	CHAR(10),
   answer_id		CHAR(10),
   fname		FILLER CHAR(80),
   answer		LOBFILE(fname) TERMINATED BY EOF
  )
