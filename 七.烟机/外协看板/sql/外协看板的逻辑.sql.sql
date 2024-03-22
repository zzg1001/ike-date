
select 
   a.eindt
  ,a.factory
  ,a.total_od_cnt                      --总订单行
  ,a.finish_od_cnt                     --按时完成订单行数
  ,a.overdue_f_od_num                  --逾期完成订单行数
  ,a.nf_od_num_over30                  --未完成未逾期>30天的订单行数
  ,a.nf_od_num_in30                    --未完成未逾期<30天的订单行数
  ,a.nf_overdue_od_num                 --未完成已未逾期
  ,b.peitao_cnt                        -- 配套
  ,a.finish_od_cnt /a.total_od_cnt     --订单交货及时率
  ,a.j_finish_od_num/a.j_h_od_num      -- 紧急订单交货及时率
  ,1-(a.finish_od_cnt /a.total_od_cnt) -- 订单完成率
  ,z/m                                 -- 配套率
  ,an/an_num                           -- 订单交货及时完成订单及时率
  ,j_an/j_an_num                       -- 紧急订单交货及时完成订单及时率
  ,1-not_qualified_cnt/total_od_num    -- 合格率
from (
    select
	  left(EINDT,6) eindt
      ,factory
	  ,count(1)                                                                                             total_od_cnt              --总订单行
	  ,count(case when finish_or_not = '完成'   and completion_date<=EINDT          then 1 else null end )  finish_od_cnt             --按时完成订单行数
	  ,count(case when finish_or_not = '完成'   and   overdue_or_not = '逾期'       and  BUDAT<='${end_date}' and completion_date<=EINDT  then 1 else null end )   overdue_f_od_num  --逾期完成订单行数
	  ,count(case when finish_or_not = '未完成' and delivery_days_30 = '大于30'     then 1 else null end )   nf_od_num_over30         --未完成未逾期>30天的订单行数
	  ,count(case when finish_or_not = '未完成' and delivery_days_30 = '小于等于30' then 1 else null end )   nf_od_num_in30           --未完成未逾期<30天的订单行数
	  ,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期'         then 1 else null end )   nf_overdue_od_num        --未完成已未逾期
	  ,count(case when adpri= 'J' and overdue_or_not='按时' and finish_or_not = '完成')                      j_finish_od_num          -- 紧急按时完成订单行数   
      ,count(case when adpri= 'J'then 1 else null end )                                                      j_h_od_num               -- 紧急订单行数  	
	  ,sum(case when (ADPRI !='J' or ADPRI is null) and  finish_or_not ='完成' and overdue_or_not ='按时'  then 1 else 0 end ) an     -- 订单交货及时完成订单数                                                
      ,sum(case when (ADPRI !='J' or ADPRI is null) then 1 else 0 end )                                      an_num                   -- 订单交货及订单数  
	  ,sum(case when (ADPRI ='J' or ADPRI is null) and  finish_or_not ='完成' and overdue_or_not ='按时'   then 1 else 0 end ) j_an   -- 紧急订单交货及时完成订单数                                                
      ,sum(case when (ADPRI ='J' or ADPRI is null) then 1 else 0 end )                                       j_an_num                 -- 紧急订单交货及订单数 
	  ,sum(1)                                                                                                total_od_num              --总订单行
	  ,sum(case when finish_or_not = '完成'   and completion_date<=EINDT then 1 else 0 end )                 finish_od_num             --按时完成订单行数
	  ,sum(case when ADPRI ='J' and is_qualified ='不合格' then 1 else 0 end)                                not_qualified_cnt             --合格数         
 from Outsourcing_Dashboard.dbo.sap_base_field_wide a
 where (LOEKZ <> 'L' or LOEKZ is null) 
  and BUKRS='2000' and FRGKE='S'
  group by 
      factory
	  ,left(EINDT,6) 
	  ) a
 left join (
		   select 
			   target_vender factory
			  ,left(ERDAT,6) ERDAT
		      ,count(1) peitao_cnt -- 配套
			  ,sum(case when target_vender<>'' and target_vender<>'自加工' then 1 else 0 end)  m 
			  ,sum(case when order_num is not null or r24_vender is not null then 1 else 0 end) z
		 from Outsourcing_Dashboard.dbo.match_rate_r24
		 group by target_vender
		         ,left(ERDAT,6)
           ) b 
   on  a.EINDT= b.ERDAT
   and a.factory = b.factory
   
   
   
   
   
   
   
WITH a as (
select  factory 
,category
,finish_or_not
,overdue_or_not
,1 num
,CONVERT(date, EINDT, 112) AS converted_date
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S' 
and (ADPRI !='J' or ADPRI is null)


)
select 
	 factory 
	,category
	,count(*)over() total_num
	,count(*)over(PARTITION by category) num_category
	,sum(sn) sn 
	,sum(an) an 
	,cast(sum(an) as float)/cast(sum(sn) as float) rate
	,ROW_NUMBER ()over(order by cast(sum(an) as float)/cast(sum(sn) as float) desc)  rk_total
	,ROW_NUMBER ()over(PARTITION by category order by cast(sum(an) as float)/cast(sum(sn) as float) desc)  rk_category
from (
		select 
				factory 
				,category
				,sum(num) sn 
				,case when finish_or_not ='完成' and overdue_or_not ='按时' then sum(num) else 0 end an
		from a 
		group by 
		 factory 
		,category
		,finish_or_not
		,overdue_or_not
) m 
group by 
     factory 
	 ,category
order by 
    rk_total
	
	
	
	
	WITH a as (
select  factory ,category,finish_or_not,overdue_or_not,
1 num,CONVERT(date, EINDT, 112) AS converted_date
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S' and ADPRI ='J'
${if(len(batch_num)==0,"","and IDNLF='" + batch_num + "'")}
--${if(len(factory_m)==0,"","and factory in ('" + factory_m + "')")}
and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
--and EINDT >='20221001' AND EINDT <='20231231'

)
select factory ,category,count(*)over() total_num,count(*)over(PARTITION by category) num_category,
sum(sn) sn ,sum(an) an ,cast(sum(an) as float)/cast(sum(sn) as float) rate,
ROW_NUMBER ()over(order by cast(sum(an) as float)/cast(sum(sn) as float) desc)  rk_total,
ROW_NUMBER ()over(PARTITION by category order by cast(sum(an) as float)/cast(sum(sn) as float) desc)  rk_category
from (
select factory ,category,sum(num) sn ,case when finish_or_not ='完成' and overdue_or_not ='按时' then sum(num) else 0 end an
from a 
group  by factory ,category,finish_or_not,overdue_or_not
) m 
group by factory ,category
order by rk_total



WITH a as (
select  factory ,category,finish_or_not,overdue_or_not,is_qualified,
1 num,CONVERT(date, EINDT, 112) AS converted_date
from Outsourcing_Dashboard.dbo.sap_base_field_wide
where  (LOEKZ <>'L' or LOEKZ is null)
and BUKRS='2000' and FRGKE='S' 
${if(len(batch_num)==0,"","and IDNLF='" + batch_num + "'")}
--${if(len(factory_m)==0,"","and factory in ('" + factory_m + "')")}
and EINDT >='${start_date}' AND EINDT <='${end_date}'  --日期区间
--and EINDT >='20221001' AND EINDT <='20231231'

)
select factory ,category,count(*)over() total_num,
count(*)over(PARTITION by category) num_category,
sum(sn) sn ,sum(an) an ,cast(sum(an) as float)/cast(sum(sn) as float) rate,
ROW_NUMBER ()over(order by cast(sum(an) as float)/cast(sum(sn) as float) desc)  rk,
ROW_NUMBER ()over(PARTITION by category order by cast(sum(an) as float)/cast(sum(sn) as float) desc)  rk_category
from (
select factory ,category,case when finish_or_not ='完成' and overdue_or_not ='按时' then sum(num) else 0 end sn,
case when is_qualified ='不合格' then sum(num) end an
from a 
group  by factory ,category,finish_or_not,overdue_or_not,is_qualified
) m 
group by factory ,category
HAVING sum(an) is not null
order by rate desc