with a as(
select  ADPRI
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S'
${if(len(batch_num)==0,"","and IDNLF in ('" + batch_num + "')")}
${if(len(factory_m)==0,"","and factory in ('" + factory_m + "')")}
and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
--and EINDT >='20231001' AND EINDT <='20231031'
union all 
select ADPRI
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S'

--and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
and EINDT<'${start_date}' and EINDT>= (year('${start_date}')-1)*10000+101
and overdue_or_not = '逾期' and finish_or_not = '未完成'
)
select (
select count(*) od_num from a
) as total_od_num,
(
select count(*) od_num from a where  (ADPRI !='J' or ADPRI is null) --常规订单数量
) as regular_od_num,
(
select count(*) od_num from a where  ADPRI = 'J' --紧急订单数量
) as emergency_od_num


-----------------------------------------
total_od_num -- 总订单数
emergency_od_num --紧急订单
-----------------------------------------




--采购订单总行数=交货期内的订单行 + 交货期前未完成的订单行
with a as(
select  finish_or_not,completion_date,EINDT,delivery_days_30,overdue_or_not,BUDAT
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S'
${if(len(batch_num)==0,"","and IDNLF in ('" + batch_num + "')")}
${if(len(factory_m)==0,"","and factory in ('" + factory_m + "')")}
and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
--and EINDT >='20231001' AND EINDT <='20231031'
union all 
select  finish_or_not,completion_date,EINDT,delivery_days_30,overdue_or_not,BUDAT
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S'
${if(len(batch_num)==0,"","and IDNLF in ('" + batch_num + "')")}
${if(len(factory_m)==0,"","and factory in ('" + factory_m + "')")}
--and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
and EINDT<'${start_date}' and EINDT>= (year('${start_date}')-1)*10000+101
and overdue_or_not = '逾期' and finish_or_not = '未完成'
)
----交货期前的订单行
select (
select m.od_num     --总订单行
from (select count(*) od_num from a) m
) as total_od_num,
(
select count(*)   --按时完成订单行数
from a 
where  finish_or_not = '完成' and completion_date<=EINDT 
) as finish_od_num,
(
select count(*)   --逾期完成订单行数
from a 
where  finish_or_not = '完成' and   overdue_or_not = '逾期' and BUDAT<='${end_date}' 
) as overdue_f_od_num,
(
select count(*)   --未完成未逾期>30天的订单行数
from a 
where  finish_or_not = '未完成' and delivery_days_30 = '大于30'
) as nf_od_num_over30,
(
select count(*)   --未完成未逾期<=30天的订单行数
from a 
where  finish_or_not = '未完成' and delivery_days_30 = '小于等于30'
) as nf_od_num_in30,
(select count(*)   --未完成已未逾期
from a 
where  finish_or_not = '未完成' and overdue_or_not = '逾期'
) as nf_overdue_od_num



-----------------------------------------
 finish_od_num+overdue_f_od_num+nf_od_num_over30+nf_od_num_in30+nf_overdue_od_num     --总完成数 
 -----------------------------------------
 
 
 ----------------------------------------
 -- 总完成数 / 总订单数= 完成率
 --  按时完成订单行数 / 总订单数=及时率
 -- 逾期完成订单行数+未完成未逾期 / 总订单数=逾期率
 ----------------------------------------
 
 
 with m as (
select finish_or_not,overdue_or_not,ADPRI,
1 num,CONVERT(date, EINDT, 112) AS converted_date,left(EINDT,6) cate
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S'
${if(len(batch_num)==0,"","and IDNLF='" + batch_num + "'")}
${if(len(factory_m)==0,"","and factory in ('" + factory_m + "')")}
and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
--and EINDT >='20221001' AND EINDT <='20231231'
),
n as(
select cate,
case when finish_or_not = '完成' and overdue_or_not ='按时' then sum(num) end a,
sum(num) b,
case when finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then sum(num) end jw,
case when ADPRI = 'J' then sum(num) end j
from m 
group by cate,finish_or_not,overdue_or_not,ADPRI
),
--------------------------------配套率计算-----------------------
a as (
select  wbs_code,ERDAT,target_vender,order_num,r24_vender,
1 num,CONVERT(date, ERDAT, 112) AS converted_date,left(ERDAT,6) cate
from Outsourcing_Dashboard.dbo.match_rate_r24
where  --1=1
${if(len(batch_num)!=0,"1<0",if(len(wbs_code_1)==0 ,"1=1","wbs_code in ('" + wbs_code_1 + "')"))}
${if(len(factory_m)==0,"","and target_vender in ('" + factory_m + "')")}
AND ERDAT <=GETDATE() 
),
am as (
select wbs_code,left(ERDAT,6) cate,
case when target_vender<>'' and target_vender<>'自加工' then 1 else 0 end m ,  --分母
case when order_num is not null or r24_vender is not null then 1 else 0 end z ,  --分子
num
from a 
---group by wbs_code ,ERDAT,K-2000_K2002ZJ01KY --得到分母
),
p as (
select am.cate, isnull(sum(z),0) z ,Isnull(sum(m),0) m
from am
group by cate
)

---------------------------------------------------------------------
select n.cate,
CAST(sum(a) AS decimal(10,2))/CAST(sum(b) AS decimal(10,2)) w_rate,
CAST(sum(jw) AS decimal(10,2))/CAST(sum(j) AS decimal(10,2)) j_rate
,case when sum(m)= 0 then 0 else 1- CAST(sum(p.z) AS decimal(10,2))/CAST(sum(p.m) AS decimal(10,2)) end p_rate
from n left join p on n.cate = p.cate
group by n.cate
order by n.cate
 
