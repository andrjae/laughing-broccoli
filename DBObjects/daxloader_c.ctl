LOAD DATA
INFILE 'o2.txt' APPEND
  INTO TABLE xxd_dax_customer_temp
  FIELDS TERMINATED BY ','
  (ebs_customer_id	CHAR(10),
   customer_id		CHAR(10)
  )
