SET ANSI_WARNINGS OFF;
SET ARITHABORT OFF;
SET ARITHIGNORE ON;
 with tmp_a as(
		select 
		           year_month
				  ,category
				  ,factory
				  ,total_od_cnt                 -- 总订单行
				  ,regular_od_num               -- 常规订单数量
				  ,j_h_od_num                   -- 紧急订单行数
				  ,finish_delivery_rate         -- 订单交货及时率
				  ,row_number()over(PARTITION by category order by finish_delivery_rate ) finish_delivery_r
				  ,j_finish_delivery_rate       -- 紧急订单交货及时率
				  ,row_number()over(PARTITION by category order by j_finish_delivery_rate )as j_finish_delivery_r
				  ,finish_rate         -- 订单完成率
				  ,row_number()over(PARTITION by category order by finish_rate )as finish_rate_r
				  ,qualified_rate               -- 合格率
				  ,row_number()over(PARTITION by category order by qualified_rate )as qualified_r
				  ,COUNT(*) OVER (PARTITION by category ) AS total_rows
		from (	  
				select 
				   a.year_month
				  ,a.category
				  ,a.factory
				  ,a.total_od_cnt                                                                       -- 总订单行
				  ,a.regular_od_num                                                                     -- 常规订单数量
				  ,a.j_h_od_num                                                                         -- 紧急订单行数
				  ,cast(a.finish_od_cnt as decimal(10,2) )/cast(a.total_od_cnt as decimal(10,2) )        as finish_delivery_rate                         -- 订单交货及时率
				  ,case when a.j_h_od_num <>0 then cast(a.j_h_od_num as decimal(10,2) )/cast(a.finish_od_cnt as decimal(10,2) )  else 0 end  as j_finish_delivery_rate -- 紧急订单交货及时率
				  ,1-( cast(a.finish_od_cnt as decimal(10,2)) / cast(a.total_od_cnt as decimal(10,2) ))  as finish_rate                                  -- 订单完成率
				  ,1-( cast(not_qualified_cnt as decimal(10,2)) / cast(total_od_cnt as decimal(10,2) ))  as qualified_rate                               -- 合格率
				from (
							select
							   year_month
							  ,factory
							  ,category
							  ,count(1)                                                                                              total_od_cnt              -- 总订单行
							  ,count(case when ADPRI !='J' or ADPRI is null  then 1 else null end )                                  regular_od_num            -- 常规订单数量
							  ,count(case when adpri= 'J'then 1 else null end )                                                      j_h_od_num                -- 紧急订单行数  
							  ,count(case when finish_or_not = '完成'   and completion_date<=EINDT then 1 else null end )            finish_od_cnt             -- 按时完成订单行数
							  ,count(case when adpri= 'J' and overdue_or_not='按时' and finish_or_not = '完成'then 1 else null end)   j_finish_od_num           -- 紧急按时完成订单行数   
							  ,sum(case when (ADPRI !='J' or ADPRI is null) then 1 else 0 end )                                      an_num                    -- 订单交货及订单数  
							  ,sum(case when (ADPRI ='J' or ADPRI is null) then 1 else 0 end )                                       j_an_num                  -- 紧急订单交货及订单数 
							  ,sum(case when ADPRI ='J' and is_qualified ='不合格' then 1 else 0 end)                                not_qualified_cnt         -- 合格数         
						 from Outsourcing_Dashboard.dbo.sap_base_field_merge_wide a
						 group by 
							  year_month 
							  ,factory
							  ,category
						   ) a
				  )a
	        )	        
	        ,tmp_b as (
	          select 
	              year_month
				  ,category
				  ,factory
				  ,total_od_cnt                 -- 总订单行
				  ,regular_od_num               -- 常规订单数量
				  ,j_h_od_num                   -- 紧急订单行数
				  ,finish_delivery_rate         -- 订单交货及时率
				  ,CASE
				        WHEN finish_delivery_r <= total_rows / 3 THEN 'A'
				        WHEN finish_delivery_r <= total_rows * 2 / 3 THEN 'B'
				        ELSE  'C'
				    END AS finish_delivery_rn
				  ,j_finish_delivery_rate       -- 紧急订单交货及时率
				    ,CASE
				        WHEN j_finish_delivery_r <= total_rows / 3 THEN 'A'
				        WHEN j_finish_delivery_r <= total_rows * 2 / 3 THEN 'B'
				        ELSE 'C'
				    END AS j_finish_delivery_rn
				  ,finish_rate         -- 订单完成率
				    ,CASE
				        WHEN finish_rate_r <= total_rows / 3 THEN 'A'
				        WHEN finish_rate_r <= total_rows * 2 / 3 THEN 'B'
				        ELSE  'C'
				    END AS finish_rate_rn
				  ,qualified_rate               -- 合格率
				    ,CASE
				        WHEN qualified_r <= total_rows / 3 THEN 'A'
				        WHEN qualified_r <= total_rows * 2 / 3 THEN 'B'
				        ELSE  'C'
				    END AS qualified_rate_rn
				 from tmp_a
	        )
	        SELECT *
			FROM tmp_b
	        