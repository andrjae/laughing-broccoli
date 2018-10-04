CREATE OR REPLACE PACKAGE BODY APPS.XXD_SOAP_DAX AS
/******************************************************************************
   NAME:       XXD_SOAP_DAX
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        29.08.2018      Andres       1. Created this package body.
******************************************************************************/

 procedure print_clob( p_clob in clob ) is
      v_offset number default 1;
      v_chunk_size number := 255;
      v_real_chunk number;
      v_real_chunk1 number;
      v_real_chunk2 number;
      v_out varchar2(255);
  begin
      loop
          exit when v_offset > dbms_lob.getlength(p_clob);
          v_real_chunk2 := dbms_lob.instr(p_clob, CHR(10), v_offset, 1)-v_offset;
          v_real_chunk2 := case when v_real_chunk2 < 0 then 999999 else v_real_chunk2 end;
          v_real_chunk := least(v_chunk_size, v_real_chunk2);
--          dbms_output.put_line( v_real_chunk2 || ' ' || v_real_chunk || ' ' || v_offset  );
          if v_real_chunk > 0 then
            v_out := trim( trailing chr(13) from dbms_lob.substr( p_clob, v_real_chunk, v_offset ));
            dbms_output.put_line( v_out );
          end if;  
          v_offset := v_offset +  least(v_real_chunk+1, v_chunk_size);

      end loop;
  end print_clob;
  
 
  
  PROCEDURE generate_soap_dax(p_ebs_transaction_no IN VARCHAR2, p_clob OUT CLOB) IS
    l_clob CLOB;
    l_rate VARCHAR2 (100);
    l_attachment CLOB;
    CURSOR c_ar_trx_dax IS
    select *
    from xxemt.xxd_ar_trx_dax
    where ebs_transaction_no = p_ebs_transaction_no;
    l_ar_trx_dax c_ar_trx_dax%ROWTYPE;
  BEGIN
        open c_ar_trx_dax;
        FETCH c_ar_trx_dax INTO l_ar_trx_dax;
        l_rate := case when l_ar_trx_dax.rate is null then null else '
                       <sof1:CurrencyRate>' || trim(to_char(l_ar_trx_dax.rate, '999999999999.99')) || '</sof1:CurrencyRate>' end;
        l_attachment := case when l_ar_trx_dax.invoice_pdf_b64 is null 
        then null else '
               <sof1:Attacment class="entity">
                  <sof1:InvoicePdf>
' || l_ar_trx_dax.invoice_pdf_b64 || '</sof1:InvoicePdf>
               </sof1:Attacment>' end;
        p_clob :=  
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:dat="http://schemas.microsoft.com/dynamics/2010/01/datacontracts" xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays" 
xmlns:sof="http://softwerk.ee/elion/SofEbsSalesInvoiceService" xmlns:sof1="http://schemas.microsoft.com/dynamics/2008/01/documents/SofEbsSalesInvoice" xmlns:shar="http://schemas.microsoft.com/dynamics/2008/01/sharedtypes">
   <soapenv:Header>
      <dat:CallContext>
             </dat:CallContext>
   </soapenv:Header>
   <soapenv:Body>
      <sof:SofEbsSalesInvoiceServiceCreateRequest>
         <sof1:SofEbsSalesInvoice>
            <sof1:EbsSalesInvoice class="entity">
               <sof1:Brand>' || initcap(l_ar_trx_dax.brand) || '</sof1:Brand>' ||
               l_rate || '
               <sof1:CustomerId>' || l_ar_trx_dax.customer_id || '</sof1:CustomerId>
               <sof1:CustomerName>' || htf.escape_sc(l_ar_trx_dax.customer_name) || '</sof1:CustomerName>
               <sof1:DebitAndCreditInvoiceRelations>' || l_ar_trx_dax.debit_invoice || '</sof1:DebitAndCreditInvoiceRelations>
               <sof1:DueDate>' || to_char(l_ar_trx_dax.due_date, 'YYYY-MM-DD') || '</sof1:DueDate>
               <sof1:EBSFuture>' || l_ar_trx_dax.financial_dimentsion || '</sof1:EBSFuture>
               <sof1:EBSInvoiceType>' || l_ar_trx_dax.ebs_inv_type || '</sof1:EBSInvoiceType>
               <sof1:EBStransactionNo>' || l_ar_trx_dax.ebs_transaction_no || '</sof1:EBStransactionNo>
               <sof1:GLDate>' || to_char(l_ar_trx_dax.gl_date, 'YYYY-MM-DD') || '</sof1:GLDate>
               <sof1:HideFromAccountQuery>' || l_ar_trx_dax.show || '</sof1:HideFromAccountQuery>
               <sof1:InvoiceAmount>' || trim(to_char(l_ar_trx_dax.invoice_amount, '999999999999.99')) || '</sof1:InvoiceAmount>
               <sof1:InvoiceCurrency>' || l_ar_trx_dax.currency || '</sof1:InvoiceCurrency>
               <sof1:InvoiceDate>' || to_char(l_ar_trx_dax.invoice_date, 'YYYY-MM-DD') || '</sof1:InvoiceDate>
               <sof1:InvoiceNo>' || l_ar_trx_dax.invoice_no || '</sof1:InvoiceNo>
               <sof1:InvoiceRefNo>' || l_ar_trx_dax.reference_number || '</sof1:InvoiceRefNo>
               <sof1:JournalName>' || l_ar_trx_dax.journal_name || '</sof1:JournalName>
               <sof1:OffsetGLAccount>' || l_ar_trx_dax.gl_account || '</sof1:OffsetGLAccount>' ||
               l_attachment || '
            </sof1:EbsSalesInvoice>
         </sof1:SofEbsSalesInvoice>
      </sof:SofEbsSalesInvoiceServiceCreateRequest>
   </soapenv:Body>
</soapenv:Envelope>' ;
        CLOSE c_ar_trx_dax;
--        print_clob(l_clob);
  END;
  
  
  PROCEDURE get_answer(p_ebs_transaction_no VARCHAR2, p_trans_type VARCHAR2, p_answer_id NUMBER, p_clob CLOB) IS
  l_msg VARCHAR2(200 CHAR);
  l_info VARCHAR2(4000);
  l_warning VARCHAR2(4000);
  l_error VARCHAR2(4000);
  l_msgtype VARCHAR2(200);
  l_fld VARCHAR2(200);
  l_val VARCHAR2(200);
  l_no_val VARCHAR(1);
  l_faultstring VARCHAR2(4000);
  l_faultcode VARCHAR2(200);
  l_x1 XMLTYPE;
  l_x2 XMLTYPE;
  BEGIN
    --insert into xx_aj_clob select p_ebs_transaction_no, p_clob from dual;
    --commit;

    If p_clob = 'XML too long' then
        begin
            select t.head, t.body
            into l_x1, l_x2
            from (select XMLType(answer) d from xxd_dax_clob where answer_id = p_answer_id) x1, 
                  XMLTable(XMLNamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "s"),
                        '/s:Envelope' PASSING x1.d
                        COLUMNS head XMLTYPE PATH 's:Header',
                                body XMLTYPE PATH 's:Body'
                        ) t;
        exception
           when others then
              null;  
        end;                 

    else    
        begin
            select t.head, t.body
            into l_x1, l_x2
            from XMLTable(XMLNamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "s"),
                        '/s:Envelope' PASSING XMLType(p_clob)
                        COLUMNS head XMLTYPE PATH 's:Header',
                                body XMLTYPE PATH 's:Body'
                        ) t;
        exception
           when others then
              null;  
        end;
        
     End If;                    
     
    if l_x1 is null and l_x2 is null then
         update xxemt.xxd_ar_trx_dax
         set sent_date = sysdate, status = 'E', message = 'No valid XML' 
         where ebs_transaction_no = p_ebs_transaction_no
         and type = p_trans_type;
         update XXD_DAX_ANSWER
         set confirmed = 'N'
         where id = p_answer_id;
         merge into XXD_DAX_CLOB d
         USING (select p_answer_id answer_id from DUAL) s
         ON (d.answer_id = s.answer_id)
         WHEN NOT MATCHED THEN
           INSERT (answer_id, ebs_transaction_no, answer)
           VALUES (p_answer_id, p_ebs_transaction_no, p_clob)
         ;
        commit;
        return;
    end if;  


    begin 
      if l_x1 is not null then
        begin
          FOR cur_rec IN (
            select trim(leading chr(9) from t2.msg) msg 
            from (select l_x1 head from dual) x2, XMLTable(XMLNamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "s", 'http://www.w3.org/2001/XMLSchema-instance' as "i", 'Infolog' as "xx",
                                            'http://schemas.datacontract.org/2004/07/Microsoft.Dynamics.AX.Framework.Services' as "yy"),
                        '/s:Header/xx:Infolog/yy:InfologMessage[yy:InfologMessageType="Info"]' PASSING x2.head
                        COLUMNS msg VARCHAR2(200) PATH 'yy:Message'
                        ) t2)
          LOOP
            l_info := l_info || case when l_info is not null then ' ' else '' end || cur_rec.msg;
          END LOOP;         
          --  l_msgtype := 'Info';            
        exception
           when others then
              null;            
        end;            
        begin
          FOR cur_rec IN (
            select trim(leading chr(9) from t2.msg) msg 
            from (select l_x1 head from dual) x2, XMLTable(XMLNamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "s", 'http://www.w3.org/2001/XMLSchema-instance' as "i", 'Infolog' as "xx",
                                            'http://schemas.datacontract.org/2004/07/Microsoft.Dynamics.AX.Framework.Services' as "yy"),
                        '/s:Header/xx:Infolog/yy:InfologMessage[yy:InfologMessageType="Warning"]' PASSING x2.head
                        COLUMNS msg VARCHAR2(200) PATH 'yy:Message'
                        ) t2)
          LOOP
            l_warning := l_warning || case when l_warning is not null then ' ' else '' end || cur_rec.msg;
          END LOOP;         
          --  l_msgtype := 'Warning';            
        exception
           when others then
              null;            
        end;            
        begin
          FOR cur_rec IN (
            select trim(leading chr(9) from t2.msg) msg 
            from (select l_x1 head from dual) x2, XMLTable(XMLNamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "s", 'http://www.w3.org/2001/XMLSchema-instance' as "i", 'Infolog' as "xx",
                                            'http://schemas.datacontract.org/2004/07/Microsoft.Dynamics.AX.Framework.Services' as "yy"),
                        '/s:Header/xx:Infolog/yy:InfologMessage[yy:InfologMessageType="Error"]' PASSING x2.head
                        COLUMNS msg VARCHAR2(200) PATH 'yy:Message'
                        ) t2)
          LOOP
            l_error := l_error || case when l_error is not null then ' ' else '' end || cur_rec.msg;
          END LOOP;         
          --  l_msgtype := 'Error';            
        exception
           when others then
              null;            
        end;            
      end if;
    exception
       when others then
          null;  
    end;                 

    begin 
      if l_x2 is not null then
        select  t3.fld , t3.val
        into l_fld, l_val
        from (select l_x2 body from dual) x2, XMLTable(XMLNamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "s",  
                                        'http://schemas.microsoft.com/dynamics/2006/02/documents/EntityKeyList' as "yy",
                                        'http://schemas.microsoft.com/dynamics/2006/02/documents/EntityKey' as "zz"),
                    '/s:Body/*/yy:EntityKeyList/zz:EntityKey[1]' PASSING x2.body
                    COLUMNS fld VARCHAR2(200) PATH 'zz:KeyData/zz:KeyField/zz:Field',
                            val VARCHAR2(200) PATH 'zz:KeyData/zz:KeyField/zz:Value'
                    ) t3;
         l_no_val := 'N';           
      end if;
    exception
           when no_data_found then
             l_no_val := 'Y';
           when others then
          null;  
    end;                 
    
    begin 
      if l_no_val = 'Y'  then
          select  t3.faultcode , t3.faultstring
          into l_faultcode, l_faultstring
          from (select l_x2 body from dual) x2, XMLTable(XMLNamespaces('http://schemas.xmlsoap.org/soap/envelope/' as "s"),  
                        '/s:Body/s:Fault[1]' PASSING x2.body
                    COLUMNS faultcode VARCHAR2(200) PATH 'faultcode',
                            faultstring VARCHAR2(4000) PATH 'faultstring'
                    ) t3;
          l_msg := coalesce(l_msg, l_faultstring);
          l_msgtype := 'Fault';
     end if;
    exception
           when others then
          null;  
    end;                 

    UPDATE XXD_DAX_ANSWER
    SET    INFO               = l_info,
           WARNING            = l_warning,
           ERR                = l_error,
           FAULT              = l_faultstring,
           FLD                = l_fld,
           VAL                = l_val,
           CONFIRMED          = case when l_warning is null and l_error is null and l_faultstring is null and l_info is not null then 'Y' else 'N' end
    where id = p_answer_id;

    l_msg := substr(UTL_I18N.UNESCAPE_REFERENCE(coalesce(l_warning, l_error, l_faultstring, l_info)), 1, 200);
    
     merge into XXD_DAX_CLOB d
     USING (select p_answer_id answer_id from DUAL 
            --where l_error is not null OR l_faultstring is not null
            ) s
     ON (d.answer_id = s.answer_id)
     WHEN NOT MATCHED THEN
       INSERT (answer_id, ebs_transaction_no, answer)
       VALUES (p_answer_id, p_ebs_transaction_no, p_clob)
     ;

     update xxemt.xxd_ar_trx_dax
     set sent_date = sysdate, status = case when l_warning is null and l_error is null and l_faultstring is null and l_info is not null then 'P' else 'E' end, 
          message = l_msg, 
         dax_journal_nr = case when l_fld = 'JournalNum' OR l_fld = 'Voucher' then l_val end 
     where ebs_transaction_no = p_ebs_transaction_no
     and type = p_trans_type
     and nvl(status, 'N') != 'P';
    commit;
         
--  EXCEPTION
--    WHEN OTHERS THEN
--         update xxemt.xxd_ar_trx_dax
--         set sent_date = sysdate, status = 'E', message = 'Unknown'
--         where ebs_transaction_no = p_ebs_transaction_no;
--    RAISE;     
  END;
  
  

END XXD_SOAP_DAX;
/