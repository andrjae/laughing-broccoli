CREATE OR REPLACE PACKAGE APPS.XXD_SOAP_DAX AS
/******************************************************************************
   NAME:       XXD_SOAP_DAX
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29.08.2018      Andres       1. Created this package.
******************************************************************************/

  procedure print_clob( p_clob in clob );
  PROCEDURE generate_soap_dax(p_ebs_transaction_no IN VARCHAR2, p_clob OUT CLOB);
  PROCEDURE get_answer(p_ebs_transaction_no VARCHAR2, p_trans_type VARCHAR2, p_answer_id NUMBER, p_clob CLOB);
END XXD_SOAP_DAX;
/