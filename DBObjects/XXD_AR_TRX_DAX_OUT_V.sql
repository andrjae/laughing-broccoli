/* Formatted on 24.10.2018 9:22:31 (QP5 v5.318) */
CREATE OR REPLACE FORCE VIEW APPS.XXD_AR_TRX_DAX_OUT_V
(
    CUSTOMER_ID,
    EBS_CUSTOMER_ID,
    CUSTOMER_NAME,
    INVOICE_NO,
    EBS_INV_TYPE,
    INVOICE_AMOUNT,
    CURRENCY,
    RATE,
    INVOICE_DATE,
    GL_DATE,
    DUE_DATE,
    JOURNAL_NAME,
    EBS_TRANSACTION_NO,
    GL_ACCOUNT,
    REFERENCE_NUMBER,
    INVOICE_PDF,
    INVOICE_PDF_B64,
    PDF_FILENAME,
    DEBIT_INVOICE,
    FINANCIAL_DIMENTSION,
    BRAND,
    SHOW,
    CREATION_DATE,
    STATUS,
    MESSAGE,
    OLD,
    CLOSED_FAKE_RECEIPT,
    APPLIED_CUSTOMER_TRX_ID,
    ARCHIVE_ID,
    DESCRIPTION,
    IBAN,
    PAYMENT_SCHEDULE_ID,
    RECEIPT_NR,
    TYPE,
    SENT_DATE,
    DAX_JOURNAL_NR,
    TERM_NAME,
    ACCOUNT_NUMBER,
    REFTYPE,
    EBS_CUSTOMER_ID_ORIG
)
AS
    SELECT "CUSTOMER_ID",
           "EBS_CUSTOMER_ID",
           "CUSTOMER_NAME",
           "INVOICE_NO",
           "EBS_INV_TYPE",
           "INVOICE_AMOUNT",
           "CURRENCY",
           "RATE",
           "INVOICE_DATE",
           "GL_DATE",
           "DUE_DATE",
           "JOURNAL_NAME",
           "EBS_TRANSACTION_NO",
           "GL_ACCOUNT",
           "REFERENCE_NUMBER",
           "INVOICE_PDF",
           "INVOICE_PDF_B64",
           "PDF_FILENAME",
           "DEBIT_INVOICE",
           "FINANCIAL_DIMENTSION",
           "BRAND",
           "SHOW",
           "CREATION_DATE",
           "STATUS",
           "MESSAGE",
           "OLD",
           "CLOSED_FAKE_RECEIPT",
           "APPLIED_CUSTOMER_TRX_ID",
           "ARCHIVE_ID",
           "DESCRIPTION",
           "IBAN",
           "PAYMENT_SCHEDULE_ID",
           "RECEIPT_NR",
           "TYPE",
           "SENT_DATE",
           "DAX_JOURNAL_NR",
           "TERM_NAME",
           "ACCOUNT_NUMBER",
           "REFTYPE",
           "EBS_CUSTOMER_ID_ORIG"
      FROM xxemt.xxd_ar_trx_dax x
     WHERE     gl_date >= DATE '2018-10-01'
           --  AND reference_number IN ('771537723561')
           AND old = 'N'
           AND status in ('N', 'E') 
           AND (message like '%rahandusperiood pole avatud%' OR status = 'N') 
           AND customer_id IS NOT NULL
           AND (   (    TYPE = 'RECEIPT'
                    AND receipt_nr IS NOT NULL
                    AND x.reference_number IN
                            (SELECT reference_number
                               FROM xxemt.xxd_ar_trx_dax t1
                              WHERE     (status = 'P' OR old = 'O')
                                    AND x.ebs_transaction_no !=
                                        t1.ebs_transaction_no))
                OR (TYPE = 'INVOICE' AND invoice_pdf_b64 IS NOT NULL));