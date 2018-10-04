CREATE OR REPLACE VIEW xxd_soap_dax_v AS 
select customer_id, invoice_no, invoice_date, gl_date, ebs_transaction_no,  status, type, nvl2(invoice_pdf, 1, 0) pdf,
case type when 'INVOICE' then 
XMLSERIALIZE(CONTENT
XMLELEMENT("soapenv:Envelope", XMLATTRIBUTES(
'http://schemas.xmlsoap.org/soap/envelope/' AS "xmlns:soapenv",
'http://schemas.microsoft.com/dynamics/2010/01/datacontracts' AS "xmlns:dat",
'http://schemas.microsoft.com/2003/10/Serialization/Arrays' AS "xmlns:arr",
'http://softwerk.ee/elion/SofEbsSalesInvoiceService' AS "xmlns:sof",
'http://schemas.microsoft.com/dynamics/2008/01/documents/SofEbsSalesInvoice' AS "xmlns:sof1",
'http://schemas.microsoft.com/dynamics/2008/01/sharedtypes' AS "xmlns_shar" 
),
XMLELEMENT("soapenv:Header", XMLELEMENT("dat:CallContext")), 
XMLELEMENT("soapenv:Body", 
XMLELEMENT("sof:SofEbsSalesInvoiceServiceCreateRequest",
XMLELEMENT("sof1:SofEbsSalesInvoice",
XMLELEMENT("sof1:EbsSalesInvoice", XMLATTRIBUTES('entity' As "class"),
XMLELEMENT(NAME "sof1:Brand", initcap(q1.brand)),
nvl2(q1.rate, XMLELEMENT(NAME "sof1:CurrencyRate", q1.rate), null),
XMLELEMENT(NAME "sof1:CustomerId", q1.customer_id),
XMLELEMENT(NAME "sof1:CustomerName", htf.escape_sc(q1.customer_name)),
XMLELEMENT(NAME "sof1:DebitAndCreditInvoiceRelations" , q1.debit_invoice),
XMLELEMENT(NAME "sof1:DueDate", to_char(q1.due_date, 'YYYY-MM-DD')),
--XMLELEMENT(NAME "sof1:EBSFuture" ,q1.financial_dimentsion),
XMLELEMENT(NAME "sof1:EBSFuture" ,null),
XMLELEMENT(NAME "sof1:EBSInvoiceType" ,q1.ebs_inv_type),
XMLELEMENT(NAME "sof1:EBStransactionNo" ,q1.ebs_transaction_no),
XMLELEMENT(NAME "sof1:GLDate" ,to_char(q1.gl_date, 'YYYY-MM-DD')),
XMLELEMENT(NAME "sof1:HideFromAccountQuery" ,q1.show),
XMLELEMENT(NAME "sof1:InvoiceAmount" ,trim(to_char(q1.invoice_amount, '999999999999.99'))),
XMLELEMENT(NAME "sof1:InvoiceCurrency" ,q1.currency),
XMLELEMENT(NAME "sof1:InvoiceDate" ,to_char(q1.invoice_date, 'YYYY-MM-DD')),
XMLELEMENT(NAME "sof1:InvoiceNo" ,q1.invoice_no),
XMLELEMENT(NAME "sof1:InvoiceRefNo" ,q1.reference_number),
XMLELEMENT(NAME "sof1:JournalName" ,q1.journal_name),
XMLELEMENT(NAME "sof1:OffsetGLAccount" ,q1.gl_account),
nvl2(q1.invoice_pdf_b64, XMLELEMENT(NAME "sof1:Attacment", XMLATTRIBUTES('entity' As "class"), XMLELEMENT(NAME "sof1:InvoicePdf", q1.invoice_pdf_b64)), null)
))))) AS CLOB INDENT SIZE=0
) when 'RECEIPT' then
XMLSERIALIZE(CONTENT
XMLELEMENT("soapenv:Envelope", XMLATTRIBUTES(
'http://schemas.xmlsoap.org/soap/envelope/' AS "xmlns:soapenv",
'http://schemas.microsoft.com/dynamics/2010/01/datacontracts' AS "xmlns:dat",
'http://schemas.microsoft.com/2003/10/Serialization/Arrays' AS "xmlns:arr",
'http://softwerk.ee/elion/SofBankAPIPaymentService' AS "xmlns:sof",
'http://schemas.microsoft.com/dynamics/2008/01/documents/SofBankAPIPayment' AS "xmlns:sof1",
'http://schemas.microsoft.com/dynamics/2008/01/sharedtypes' AS "xmlns_shar" 
),
XMLELEMENT("soapenv:Header"), 
XMLELEMENT("soapenv:Body", 
XMLELEMENT("sof:SofBankAPIPaymentServiceCreateRequest",
XMLELEMENT("sof1:SofBankAPIPayment",
XMLELEMENT("sof1:SofBankAPIPayment", XMLATTRIBUTES(noentityescaping 'entity' As "class", '' As "action"),
XMLELEMENT(NAME "sof1:Amount", trim(to_char(q1.invoice_amount, '999999999999.99'))),
--XMLELEMENT(NAME "sof1:BindingId", initcap(q1.brand)),
XMLELEMENT(NAME "sof1:BookingDate", to_char(q1.gl_date, 'YYYY-MM-DD')),
XMLELEMENT(NAME "sof1:Brand", initcap(q1.brand)),
XMLELEMENT(NAME "sof1:Currency", q1.currency),
XMLELEMENT(NAME "sof1:CustomerId", q1.customer_id),
XMLELEMENT(NAME "sof1:Description" , q1.description),
XMLELEMENT(NAME "sof1:DocNumber", q1.receipt_nr),
--XMLELEMENT(NAME "sof1:IdentificationRef" ,q1.financial_dimentsion),
--XMLELEMENT(NAME "sof1:JournalName" ,q1.ebs_inv_type),
--XMLELEMENT(NAME "sof1:PaymentMethod" ,q1.ebs_transaction_no),
--XMLELEMENT(NAME "sof1:ReceiverAccount" ,to_char(q1.gl_date, 'YYYY-MM-DD')),
--XMLELEMENT(NAME "sof1:ReceiverName" ,q1.show),
XMLELEMENT(NAME "sof1:RefNumber" ,q1.reference_number),
XMLELEMENT(NAME "sof1:RefType" ,q1.type),
XMLELEMENT(NAME "sof1:SenderAccount" ,q1.iban),
XMLELEMENT(NAME "sof1:SenderName" ,q1.customer_name),
--XMLELEMENT(NAME "sof1:SplitingId" ,q1.reference_number),
XMLELEMENT(NAME "sof1:TargetAccount" ,q1.gl_account)
--XMLELEMENT(NAME "sof1:TransactionIdentification" ,q1.gl_account),
--XMLELEMENT(NAME "sof1:TransactionTimeStamp" ,q1.gl_account),
--XMLELEMENT(NAME "sof1:ValueDate" ,to_char(q1.invoice_date, 'YYYY-MM-DD'))
))))) AS CLOB INDENT SIZE=0
) 
else null end 
zclob
from xxemt.xxd_ar_trx_dax q1
where old = 'N'