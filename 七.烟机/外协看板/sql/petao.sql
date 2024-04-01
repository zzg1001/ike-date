-with a as(
select  ADPRI
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S'
${if(len(batch_num)==0,"","and IDNLF in ('" + batch_num + "')")}
${if(len(factory_m)==0,"","and factory in ('" + factory_m + "')")}
and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
--and EINDT >='20231001' AND EINDT <='20231031'

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
   



    select
	  left(EINDT,6) eindt
      ,factory
	  ,category
	  ,count(1)                                                                                              total_od_cnt              --总订单行
	  ,count(case when ADPRI !='J' or ADPRI is null  then 1 else null end )                                  regular_od_num            --常规订单数量
	  ,count(case when adpri= 'J'then 1 else null end )                                                      j_h_od_num               -- 紧急订单行数  
	  
	  
	  ,count(case when finish_or_not = '完成'   and completion_date<=EINDT then 1 else null end )            finish_od_cnt             --按时完成订单行数
	  ,count(case when adpri= 'J' and overdue_or_not='按时' and finish_or_not = '完成')                      j_finish_od_num          -- 紧急按时完成订单行数   
	  ,sum(case when (ADPRI !='J' or ADPRI is null) and  finish_or_not ='完成' and overdue_or_not ='按时'  then 1 else 0 end ) an     -- 订单交货及时完成订单数                                                
      ,sum(case when (ADPRI !='J' or ADPRI is null) then 1 else 0 end )                                      an_num                   -- 订单交货及订单数  
	  ,sum(case when (ADPRI ='J' or ADPRI is null) and  finish_or_not ='完成' and overdue_or_not ='按时'   then 1 else 0 end ) j_an   -- 紧急订单交货及时完成订单数                                                
      ,sum(case when (ADPRI ='J' or ADPRI is null) then 1 else 0 end )                                       j_an_num                 -- 紧急订单交货及订单数 
	  ,sum(1)                                                                                                total_od_num              --总订单行
	  ,sum(case when finish_or_not = '完成'   and completion_date<=EINDT then 1 else 0 end )                 finish_od_num             --按时完成订单行数
	  ,sum(case when ADPRI ='J' and is_qualified ='不合格' then 1 else 0 end)                                not_qualified_cnt         --合格数         
 from Outsourcing_Dashboard.dbo.sap_base_field_wide a
 where (LOEKZ <> 'L' or LOEKZ is null) 
  and BUKRS='2000' and FRGKE='S'
  group by 
      factory
	  ,left(EINDT,6) 
