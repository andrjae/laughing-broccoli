select min(t.sent_date) over (partition by reference_number) sent_min, 
sum(case when type='RECEIPT' then -invoice_amount else invoice_amount end) over (partition by reference_number) sum, t.* 
from xxemt.xxd_ar_trx_dax t
order by case when sent_date - sent_min < 10/24/60 then sent_min else sent_date end desc, reference_number, sent_date desc, journal_name

select * from xxemt.xxd_ar_trx_dax
where sent_date is null
and creation_date < sysdate -5/24/60

select * from xxd_ar_trx_dax_out_v

select * from (
select count(*) over (partition by ebs_transaction_no, trans_type) c, a.* from xxd_dax_answer a
) where c>1
order by 1 desc, 3, 5 desc



select max(sent_date), count(*), EBS_TRANSACTION_NO, TRANS_TYPE, CONFIRMED, L_CONF, INFO, L_INFO, WARNING, ERR, FAULT from (
select ebs_transaction_no, trans_type, sent_date, confirmed, l_conf, info, l_info, warning, err, fault from (
select a.*, 
min(info) KEEP (DENSE_RANK LAST ORDER BY sent_date)  over (partition by ebs_transaction_no, trans_type) l_info,
min(confirmed) KEEP (DENSE_RANK LAST ORDER BY sent_date)  over (partition by ebs_transaction_no, trans_type) l_conf
from xxd_dax_answer a
)
where nvl(info,'X') != 'Töölehele sisestatud kannete arv: 1'
or nvl(l_info,'X') != 'Töölehele sisestatud kannete arv: 1'
)
group by EBS_TRANSACTION_NO, TRANS_TYPE, CONFIRMED, L_CONF, INFO, L_INFO, WARNING, ERR, FAULT
order by 1 desc

select * from xxd_soap_dax_v

select * from xxd_dax_clob

select * from xxd_dax_req_clob

select * from xxd_dax_customer_miss


