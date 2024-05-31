					select sum(bbb.in_time_cp_dlv)      as an_finish_od      -- 按时完成
						  ,sum(bbb.overdue_cp_dlv)      as overdue_finish_od -- 逾期完成
						  ,sum(bbb.overdue_icp_dlv)     as overdue_nf_od     -- 逾期未完成
						  ,sum(case when bbb.non_overdue_icp_dlv = 1 and bbb.dlv_date is null and bbb.schedule_finish_date > getdate() and abs(datediff(day, schedule_finish_date, getdate())) <= ccc.D2 then 1 else 0 end) as under_overdue_od                                -- 临近逾期
						  ,sum(bbb.non_overdue_icp_dlv) - sum(case when bbb.non_overdue_icp_dlv = 1 and bbb.dlv_date is null  and bbb.schedule_finish_date > getdate() and abs(datediff(day, schedule_finish_date, getdate())) <= ccc.D2 then 1 else 0 end)  as noverdue_nf_od -- 未逾期未完成
					      ,sum(emergent) as emergent_num --紧急订单
					
					from (
								 select prod_order_no
								       ,max(match) as match
								       ,max(emergent) as emergent
								 from (
										  select 
										         prod_order_no
										        ,0 as match
												,0 as emergent
										   from LeanProduction_Dashboard.dbo.machining_dashboard_base_production_order
										  where schedule_finish_date >= CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'
											and schedule_finish_date <= CONVERT(DATE, GETDATE())
										  group by prod_order_no
										  
										  union
										  
										  (
											  select order_no
											        ,1 as match
											        ,0 as emergent
											  from (select order_no,
														   cast(cast(year as varchar) + '-' + cast(month as varchar) + '-1' as date) as date
													from LeanProduction_Dashboard.dbo.machining_dashboard_apd_monthly_match_order
													group by year, month, order_no) as a
											  where date >= CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'
												and date <= CONVERT(DATE, GETDATE())
										    )
											
										  union
										  (
											  select order_no
											        ,0 as match
											        ,1 as emergent
											  from (select order_no,
														   cast(cast(year as varchar) + '-' + cast(month as varchar) + '-1' as date) as date
													from LeanProduction_Dashboard.dbo.machining_dashboard_apd_monthly_emergency_order
													group by year, month, order_no) as a
											  where date >= CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'
												and date <= CONVERT(DATE, GETDATE()) 
										  )
									  ) as aa
								 group by prod_order_no
							 ) as aaa
         left join(
						select *
						 from LeanProduction_Dashboard.dbo.machining_dashboard_ads_order_distribution1
						where schedule_finish_date >= CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'
						  and schedule_finish_date <= CONVERT(DATE, GETDATE()) 
                 ) as bbb
                  on aaa.prod_order_no = bbb.prod_order_no
         left join LeanProduction_Dashboard.dbo.machining_dashboard_apd_parameters as ccc
                   on 1 = 1;
				   
				   
	-----------------------------------------------------------------------------------------------			   
				   
				   
select 
       on_time_order_completion_rate, -- 订单按时完成率
       efficient_order_completion_rate,-- 高效完成率
       overdue_order_completion_rate,  -- 逾期订单完成率
       month
from LeanProduction_Dashboard.dbo.machining_dashboard_ads_order_completion_status
where year=year(getdate())
order by month
				   



			
			                           