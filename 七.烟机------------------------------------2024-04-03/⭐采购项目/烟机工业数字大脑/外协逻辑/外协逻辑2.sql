with base_tamp as
                (
				select ADPRI
				      ,finish_or_not
					  ,CONVERT(date, completion_date, 112) completion_date
					  ,CONVERT(date, EINDT, 112) EINDT
					  ,delivery_days_30
					  ,overdue_or_not,BUDAT
				from Outsourcing_Dashboard.dbo.sap_base_field_wide
				where  (LOEKZ <>'L' or LOEKZ is null)
				and BUKRS='2000' and FRGKE='S'
				and CONVERT(date, EINDT, 112) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
				and CONVERT(date, EINDT, 112) <=CONVERT(DATE, GETDATE()) 

				union all 

				select ADPRI
				       ,finish_or_not
					   ,CONVERT(date, completion_date, 112) completion_date
					   ,CONVERT(date, EINDT, 112) EINDT
					   ,delivery_days_30
					   ,overdue_or_not
					   ,BUDAT
				from Outsourcing_Dashboard.dbo.sap_base_field_wide
				where  (LOEKZ <>'L' or LOEKZ is null)
				and BUKRS='2000' and FRGKE='S'
				and CONVERT(date, EINDT, 112) < CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
				and CONVERT(date, EINDT, 112) >=  CAST(YEAR(GETDATE())-1 AS VARCHAR(4)) + '-01-01'  
				and overdue_or_not = '逾期' and finish_or_not = '未完成'
               )
			   
select 
				 count(1)  as total_od_cnt --总订单数
				,count(case when finish_or_not = '完成'   and completion_date<=EINDT  then 1 else null end )  as finish_od_cnt                            -- 按时完成订单行数
				,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT<='${end_date}' then 1 else null end ) as overdue_f_od_cnt -- 逾期完成订单行数
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end ) as nf_overdue_od_cnt         --未完成已未逾期
				,count(case when ADPRI = 'J'  then 1 else null end ) as emergency_od_cnt  --紧急订单数量

			from base_tamp
	 

	------------------------------------------------------- 
	  
	  
	  with base_tamp as
                (
					select ADPRI
						,finish_or_not
						,completion_date
						,CONVERT(VARCHAR(7),CONVERT(date, EINDT, 112), 120) EINDT_MONTH
						,delivery_days_30
						,overdue_or_not,BUDAT
					from Outsourcing_Dashboard.dbo.sap_base_field_wide
					where  (LOEKZ <>'L' or LOEKZ is null)
					and BUKRS='2000' and FRGKE='S'
					and CONVERT(date, EINDT, 112) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
					and CONVERT(date, EINDT, 112) <=CONVERT(DATE, GETDATE())  

               )
			   
			 
		select 
		    EINDT_MONTH
           ,od_cont           -- 当月新增订单
           ,overdue_f_od_cnt  -- 逾期完成订单行数	 
           ,an_finish_cnt     -- 当月按时订单	
           ,an_j_finish_cnt	  -- 当月按时完成紧急订单	
           ,j_cnt		      -- 当月紧急订单
     from(		   
         select  EINDT_MONTH
		        ,count(1) as od_cont
				,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT<='${end_date}' then 1 else null end ) as overdue_f_od_cnt -- 逾期完成订单行数
		    	,count(case when finish_or_not = '完成' and overdue_or_not ='按时' then 1 else null end ) as an_finish_cnt
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end ) as nf_overdue_od_cnt         --未完成已未逾期
				,count(case when finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then 1 else null end ) as an_j_finish_cnt
				,count(case when ADPRI = 'J' then 1 else null end ) as j_cnt
			from base_tamp
			group by EINDT_MONTH
		 ) a
		 ORDER BY EINDT_MONTH
