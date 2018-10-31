CREATE OR REPLACE FORCE VIEW APPS.XXD_SOAP_DAX_V
(
    CUSTOMER_ID,
    INVOICE_NO,
    INVOICE_DATE,
    GL_DATE,
    EBS_TRANSACTION_NO,
    STATUS,
    TYPE,
    PDF,
    ZCLOB
)
AS
    SELECT customer_id,
           invoice_no,
           invoice_date,
           gl_date,
           ebs_transaction_no,
           status,
           TYPE,
           NVL2 (invoice_pdf, 1, 0)
               pdf,
           CASE TYPE
               WHEN 'INVOICE'
               THEN
                   XMLSERIALIZE (
                       CONTENT XMLELEMENT (
                                   "soapenv:Envelope",
                                   XMLATTRIBUTES (
                                       'http://schemas.xmlsoap.org/soap/envelope/'
                                           AS "xmlns:soapenv",
                                       'http://schemas.microsoft.com/dynamics/2010/01/datacontracts'
                                           AS "xmlns:dat",
                                       'http://schemas.microsoft.com/2003/10/Serialization/Arrays'
                                           AS "xmlns:arr",
                                       'http://softwerk.ee/elion/SofEbsSalesInvoiceService'
                                           AS "xmlns:sof",
                                       'http://schemas.microsoft.com/dynamics/2008/01/documents/SofEbsSalesInvoice'
                                           AS "xmlns:sof1",
                                       'http://schemas.microsoft.com/dynamics/2008/01/sharedtypes'
                                           AS "xmlns_shar"),
                                   XMLELEMENT (
                                       "soapenv:Header",
                                       XMLELEMENT ("dat:CallContext")),
                                   XMLELEMENT (
                                       "soapenv:Body",
                                       XMLELEMENT (
                                           "sof:SofEbsSalesInvoiceServiceCreateRequest",
                                           XMLELEMENT (
                                               "sof1:SofEbsSalesInvoice",
                                               XMLELEMENT (
                                                   "sof1:EbsSalesInvoice",
                                                   XMLATTRIBUTES (
                                                       'entity' AS "class"),
                                                   XMLELEMENT (
                                                       NAME "sof1:Brand",
                                                       INITCAP (q1.brand)),
                                                   NVL2 (
                                                       q1.rate,
                                                       XMLELEMENT (
                                                           NAME "sof1:CurrencyRate",
                                                           q1.rate),
                                                       NULL),
                                                   XMLELEMENT (
                                                       NAME "sof1:CustomerId",
                                                       q1.customer_id),
                                                   XMLELEMENT (
                                                       NAME "sof1:CustomerName",
                                                       HTF.escape_sc (
                                                           q1.customer_name)),
                                                   XMLELEMENT (
                                                       NAME "sof1:DebitAndCreditInvoiceRelations",
                                                       q1.debit_invoice),
                                                   XMLELEMENT (
                                                       NAME "sof1:DueDate",
                                                       TO_CHAR (q1.due_date,
                                                                'YYYY-MM-DD')),
                                                   --XMLELEMENT(NAME "sof1:EBSFuture" ,q1.financial_dimentsion),
                                                   XMLELEMENT (
                                                       NAME "sof1:EBSFuture",
                                                       NULL),
                                                   XMLELEMENT (
                                                       NAME "sof1:EBSInvoiceType",
                                                       q1.ebs_inv_type),
                                                   XMLELEMENT (
                                                       NAME "sof1:EBStransactionNo",
                                                       q1.ebs_transaction_no),
                                                   XMLELEMENT (
                                                       NAME "sof1:GLDate",
                                                       TO_CHAR (
                                                           CASE
                                                               WHEN q1.MESSAGE LIKE
                                                                        '%rahandusperiood pole avatud%'
                                                               THEN
                                                                   TRUNC (
                                                                       SYSDATE,
                                                                       'MM')
                                                               ELSE
                                                                   q1.gl_date
                                                           END,
                                                           'YYYY-MM-DD')),
                                                   XMLELEMENT (
                                                       NAME "sof1:HideFromAccountQuery",
                                                       q1.show),
                                                   XMLELEMENT (
                                                       NAME "sof1:InvoiceAmount",
                                                       TRIM (
                                                           TO_CHAR (
                                                               q1.invoice_amount,
                                                               '999999999990.99'))),
                                                   XMLELEMENT (
                                                       NAME "sof1:InvoiceCurrency",
                                                       q1.currency),
                                                   XMLELEMENT (
                                                       NAME "sof1:InvoiceDate",
                                                       TO_CHAR (
                                                           q1.invoice_date,
                                                           'YYYY-MM-DD')),
                                                   XMLELEMENT (
                                                       NAME "sof1:InvoiceNo",
                                                       q1.invoice_no),
                                                   XMLELEMENT (
                                                       NAME "sof1:InvoiceRefNo",
                                                       q1.reference_number),
                                                   XMLELEMENT (
                                                       NAME "sof1:JournalName",
                                                       q1.journal_name),
                                                   XMLELEMENT (
                                                       NAME "sof1:OffsetGLAccount",
                                                       q1.gl_account),
                                                   NVL2 (
                                                       q1.invoice_pdf_b64,
                                                       XMLELEMENT (
                                                           NAME "sof1:Attacment",
                                                           XMLATTRIBUTES (
                                                               'entity'
                                                                   AS "class"),
                                                           XMLELEMENT (
                                                               NAME "sof1:InvoicePdf",
                                                               q1.invoice_pdf_b64)),
                                                       NULL)))))) AS CLOB
                       INDENT SIZE = 0)
               WHEN 'RECEIPT'
               THEN
                   XMLSERIALIZE (
                       CONTENT XMLELEMENT (
                                   "soapenv:Envelope",
                                   XMLATTRIBUTES (
                                       'http://schemas.xmlsoap.org/soap/envelope/'
                                           AS "xmlns:soapenv",
                                       'http://schemas.microsoft.com/dynamics/2010/01/datacontracts'
                                           AS "xmlns:dat",
                                       'http://schemas.microsoft.com/2003/10/Serialization/Arrays'
                                           AS "xmlns:arr",
                                       'http://softwerk.ee/elion/SofBankAPIPaymentService'
                                           AS "xmlns:sof",
                                       'http://schemas.microsoft.com/dynamics/2008/01/documents/SofBankAPIPayment'
                                           AS "xmlns:sof1",
                                       'http://schemas.microsoft.com/dynamics/2008/01/sharedtypes'
                                           AS "xmlns_shar"),
                                   XMLELEMENT ("soapenv:Header"),
                                   XMLELEMENT (
                                       "soapenv:Body",
                                       XMLELEMENT (
                                           "sof:SofBankAPIPaymentServiceCreateRequest",
                                           XMLELEMENT (
                                               "sof1:SofBankAPIPayment",
                                               XMLELEMENT (
                                                   "sof1:SofBankAPIPayment",
                                                   XMLATTRIBUTES (
                                                       NOENTITYESCAPING
                                                       'entity' AS "class",
                                                       '' AS "action"),
                                                   XMLELEMENT (
                                                       NAME "sof1:Amount",
                                                       TRIM (
                                                           TO_CHAR (
                                                               q1.invoice_amount,
                                                               '999999999990.99'))),
                                                   --XMLELEMENT(NAME "sof1:BindingId", initcap(q1.brand)),
                                                   XMLELEMENT (
                                                       NAME "sof1:BookingDate",
                                                       TO_CHAR (
                                                           CASE
                                                               WHEN q1.MESSAGE LIKE
                                                                        '%rahandusperiood pole avatud%'
                                                               THEN
                                                                   TRUNC (
                                                                       SYSDATE,
                                                                       'MM')
                                                               ELSE
                                                                   q1.gl_date
                                                           END,
                                                           'YYYY-MM-DD')),
                                                   XMLELEMENT (
                                                       NAME "sof1:Brand",
                                                       INITCAP (q1.brand)),
                                                   XMLELEMENT (
                                                       NAME "sof1:Currency",
                                                       q1.currency),
                                                   XMLELEMENT (
                                                       NAME "sof1:CustomerId",
                                                       q1.customer_id),
                                                   XMLELEMENT (
                                                       NAME "sof1:Description",
                                                       COALESCE (
                                                           q1.description,
                                                           q1.receipt_nr)),
                                                   XMLELEMENT (
                                                       NAME "sof1:DocNumber",
                                                       q1.receipt_nr),
                                                   CASE
                                                       WHEN q1.invoice_amount <
                                                            0
                                                       THEN
                                                           XMLELEMENT (
                                                               NAME "sof1:IdentificationRef",
                                                               q1.debit_invoice)
                                                   END,
                                                   XMLELEMENT (
                                                       NAME "sof1:JournalName",
                                                       NVL (q1.journal_name,
                                                            'LEBS')),
                                                   --XMLELEMENT(NAME "sof1:PaymentMethod" ,q1.ebs_transaction_no),
                                                   --XMLELEMENT(NAME "sof1:ReceiverAccount" ,to_char(q1.gl_date, 'YYYY-MM-DD')),
                                                   --XMLELEMENT(NAME "sof1:ReceiverName" ,q1.show),
                                                   XMLELEMENT (
                                                       NAME "sof1:RefNumber",
                                                       q1.reference_number),
                                                   XMLELEMENT (
                                                       NAME "sof1:RefType",
                                                       COALESCE (q1.reftype,
                                                                 q1.TYPE)),
                                                   XMLELEMENT (
                                                       NAME "sof1:SenderAccount",
                                                       q1.iban),
                                                   XMLELEMENT (
                                                       NAME "sof1:SenderName",
                                                       q1.customer_name),
                                                   --XMLELEMENT(NAME "sof1:SplitingId" ,q1.reference_number),
                                                   XMLELEMENT (
                                                       NAME "sof1:TargetAccount",
                                                       q1.gl_account),
                                                   XMLELEMENT (
                                                       NAME "sof1:TransactionIdentification",
                                                       q1.ebs_transaction_no), --NOT SURE
                                                   --XMLELEMENT(NAME "sof1:TransactionTimeStamp" ,q1.gl_account),
                                                   XMLELEMENT (
                                                       NAME "sof1:ValueDate",
                                                       TO_CHAR (
                                                           CASE
                                                               WHEN q1.MESSAGE LIKE
                                                                        '%rahandusperiood pole avatud%'
                                                               THEN
                                                                   TRUNC (
                                                                       SYSDATE,
                                                                       'MM')
                                                               ELSE
                                                                   q1.gl_date
                                                           END,
                                                           'YYYY-MM-DD')) --NOT SURE what date?
                                                                         ))))) AS CLOB
                       INDENT SIZE = 0)
               ELSE
                   NULL
           END
               zclob
      FROM xxemt.xxd_ar_trx_dax q1
     WHERE old = 'N';