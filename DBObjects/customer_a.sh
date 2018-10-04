#!/bin/bash

get_req() {
sqlplus -s apps/apps <<EOF
set echo off
set feed off
set lines 800
set pages 0
set head off
select distinct
cust.cust_account_id || ',' || to_number(regexp_substr(cust.attribute20, '\d+',1,1)) emt_id
from hz_cust_accounts cust, hz_parties p
where cust.status = 'A'
and p.party_id = cust.party_id
and p.party_name !='Elion / Arveldusteenus'
and cust.attribute20  = regexp_substr(cust.attribute20, 'tbcis:\d+',1,1)
and cust.attribute9 is null
and cust.cust_account_id not in (select ebs_customer_id from XXD_DAX_CUSTOMER_MISS)
and cust.CUST_ACCOUNT_ID in (
select customer_id from ar_payment_schedules_all
where gl_date >= date '2016-01-01'
)
and rownum < 4001;
EOF
}

set -e
set -u
USER=SGW-eBS-test
PASSWORD=":mq-NKDA6Gu9y&b'"
AUTHENTICATION=$USER:$PASSWORD
TIMEOUT=500

EBSFILE="./o.txt"
req=$(get_req)
echo "$req"  > $EBSFILE

