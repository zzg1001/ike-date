with base_tamp as
                (
				select 0 flg ,ADPRI, finish_or_not,completion_date,EINDT,delivery_days_30,overdue_or_not,BUDAT
				from Outsourcing_Dashboard.dbo.sap_base_field_wide
				where  (LOEKZ <>'L' or LOEKZ is null)
				and BUKRS='2000' and FRGKE='S'
				and EINDT >=year('${start_date}')*10000+101 AND EINDT <='${end_date}'  --日期区间

				union all 

				select 1 flg, ADPRI, finish_or_not,completion_date,EINDT,delivery_days_30,overdue_or_not,BUDAT
				from Outsourcing_Dashboard.dbo.sap_base_field_wide
				where  (LOEKZ <>'L' or LOEKZ is null)
				and BUKRS='2000' and FRGKE='S'
				and EINDT<'${start_date}' and EINDT>= (year('${start_date}')-1)*10000+101
				and overdue_or_not = '逾期' and finish_or_not = '未完成'
               )
			   
select
     total_od_cnt              --总订单数
	,(finish_od_cnt+overdue_f_od_cnt)  as total_finish_od_cnt -- 总完成数
    ,finish_od_cnt             -- 完成及时数
	,emergency_od_cnt           -- 紧急订单数量
	,CAST(finish_od_cnt+overdue_f_od_cnt AS decimal(10,2))/CAST(total_od_cnt AS decimal(10,2))  as total_finish_od_rate -- 总完成数率
	,CAST(finish_od_cnt AS decimal(10,2))/CAST(total_od_cnt AS decimal(10,2))  as total_finish_od_rate  -- 及时率
    ,CAST(overdue_f_od_cnt+nf_od_num_in30 AS decimal(10,2))/CAST(total_od_cnt AS decimal(10,2)) as overdue_rate  -- 逾期率
	,CAST(an_finish_cnt AS decimal(10,2))/CAST(finish_cnt AS decimal(10,2))  -- 订单交货及时率
	,CAST(an_j_finish_cnt AS decimal(10,2))/CAST(j_cnt AS decimal(10,2))    -- 紧急订单交货及时率
 
from (
         select 
				 count(1)  as total_od_cnt --总订单数
				,count(case when finish_or_not = '完成'   and completion_date<=EINDT  then 1 else null end )  as finish_od_cnt                            -- 按时完成订单行数
				,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT<='${end_date}' then 1 else null end ) as overdue_f_od_cnt -- 逾期完成订单行数
				,count(case when finish_or_not = '未完成' and delivery_days_30 = '大于30'     then 1 else null end ) as nf_od_num_over30  --未完成未逾期>30天的订单行数
				,count(case when finish_or_not = '未完成' and delivery_days_30 = '小于等于30' then 1 else null end ) as nf_od_num_in30    --未完成未逾期<=30天的订单行数
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end ) as nf_overdue_od_cnt         --未完成未逾期<=30天的订单行数
				,count(case when ADPRI = 'J'  then 1 else null end ) as emergency_od_cnt  --紧急订单数量
		    	,count(case when flg=0 and finish_or_not = '完成' and overdue_or_not ='按时' then 1 else null end ) as an_finish_cnt
                ,count(case when flg=0 then 1 else null end ) as finish_cnt
				,count(case when flg=0 and finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then 1 else null end ) as an_j_finish_cnt
				,count(case when flg=0 and ADPRI = 'J' then 1 else null end ) as j_cnt

			from base_tamp
      )a