#!/bin/bash
get_receipt() {
sqlplus -s apps/apps <<EOF
set echo off
set heading off
set feedback off
select ebs_transaction_no
from xxemt.xxd_ar_trx_dax x
where gl_date >= date '2018-06-01'
and type='RECEIPT'
and old='N'
and status='N'
and customer_id is not null
and receipt_nr is not null
and x.reference_number in (
select reference_number 
from xxemt.xxd_ar_trx_dax t1 
where  (status='P' OR old='O') 
and x.ebs_transaction_no != t1.ebs_transaction_no
)
and rownum=1;
EOF
}

get_req() {
sqlplus -s apps/apps <<EOF2
set echo off
set feed off
set lines 800
set longchunksize 800
set pages 0
set long 100000
set head off
select zclob from xxd_soap_dax_v
where ebs_transaction_no='$receipt'
and type='RECEIPT';
EOF2
}

valid_xml() {
sqlplus -s apps/apps <<EOF5
set feed off
set head off;
set serverout on
declare
l_xml XMLType;
begin
  l_xml := XMLType(q'[${answer}]');
  dbms_output.put_line('1');
exception when others then
  dbms_output.put_line('0');
end;
/
EOF5
}

neg_answer() {
sqlplus -s apps/apps <<EOF6
set head off
set feed off
with q1 as (
select '$ans_id' aid from dual
)
select nvl(a.id, 0) v
from q1 left join  xxd_dax_answer a ON q1.aid=a.id and (a.warning is not null or a.err is not null);
EOF6
}

get_ans_id() {
sqlplus -s apps/apps <<EOF3
set serverout on
set feed off
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
declare
l_answer_id NUMBER;
begin
  update xxemt.xxd_ar_trx_dax
  set status = 'W', sent_date = sysdate
  where ebs_transaction_no = '$receipt'
  and   type = 'RECEIPT';
  insert into XXD_DAX_ANSWER (EBS_TRANSACTION_NO, TRANS_TYPE)
  values ('$receipt', 'RECEIPT')
  returning id into l_answer_id;
  commit;
  dbms_output.put_line(l_answer_id);
end;
/
EOF3
}

set -e
set -u
USER=SGW-eBS-test
PASSWORD=":mq-NKDA6Gu9y&b'"
AUTHENTICATION=$USER:$PASSWORD
TIMEOUT=500
receipt=$(echo $(get_receipt))
until [ -z "$receipt" ]
do

SOAPFILE="./r${receipt}.xml"
echo $SOAPFILE
req=$(get_req)
echo "$req"  > $SOAPFILE
RESPFILE=./a${receipt}.xml
URL=https://soa-test.elion.ee/soap/Enterprise/Dynamics/SofBankAPIPayment/xppservice.svc

ans_id=$(get_ans_id)

curl --user $AUTHENTICATION -s -H "Content-Type: text/xml;charset=UTF-8" -H "SOAPAction: \"http://softwerk.ee/elion/SofBankAPIPaymentService/SofBankAPIPaymentService/create\"" --data @$SOAPFILE $URL --connect-timeout $TIMEOUT --insecure --output "$RESPFILE"

valid=1
if [ $(stat --printf="%s" $RESPFILE) -lt 2400 ]; then
answer=$(cat $RESPFILE)
valid=$(echo $(valid_xml))
else
echo ${receipt},${ans_id},${RESPFILE} > daxloader.txt
sqlldr apps/apps control=daxloader.ctl log=daxloader.log bad=daxloader.bad
answer="XML too long"
fi

if [ $valid -eq 0 ]; then
  echo $answer
  break
fi

sqlplus -s apps/apps <<EOF4
set define off
set feed off
WHENEVER SQLERROR EXIT FAILURE ROLLBACK
begin
  XXD_SOAP_DAX.get_answer('$receipt', 'RECEIPT', ${ans_id}, q'[${answer}]');
end;
/
EOF4

na=$(echo $(neg_answer))
if [ $na -gt 0 ]; then
echo ${receipt},${na},${SOAPFILE} > daxloader_r.txt
sqlldr apps/apps control=daxloader_r.ctl log=daxloader_r.log bad=daxloader_r.bad
fi


receipt=$(echo $(get_receipt))

done
