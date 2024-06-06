TRUNCATE  table digital_brain_outbuy_dashboard_index;

with base_buy_tamp as
                (
				select ADPRI
				      ,finish_or_not
					  ,CONVERT(date, completion_date, 112) completion_date
					  ,CONVERT(date, EINDT, 112) EINDT
					  ,delivery_days_30
					  ,overdue_or_not,BUDAT
				from Outsourcing_Dashboard.dbo.sap_base_buy_field_wide
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
				from Outsourcing_Dashboard.dbo.sap_base_buy_field_wide
				where  (LOEKZ <>'L' or LOEKZ is null)
				and BUKRS='2000' and FRGKE='S'
				and CONVERT(date, EINDT, 112) < CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
				and CONVERT(date, EINDT, 112) >=  CAST(YEAR(GETDATE())-1 AS VARCHAR(4)) + '-01-01'  
				and overdue_or_not = '逾期' and finish_or_not = '未完成'
               )
			   
        INSERT INTO  digital_brain_outbuy_dashboard_index
         select 
				 count(1)                                                                                                             as total_od_cnt                 -- 总订单数
				,count(case when finish_or_not = '完成'   and completion_date<=EINDT  then 1 else null end )                          as an_finish_od_cnt             -- 按时完成订单行数
				,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT<=CONVERT(DATE, GETDATE()) then 1 else null end ) as overdue_f_od_cnt  -- 逾期完成订单行数
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end )                          as nf_overdue_od_cnt            -- 未完成逾期
				,count(case when ADPRI = 'J'  then 1 else null end )                                                                  as emergency_od_cnt             -- 紧急订单数量
				,count(case when finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then 1 else null end )             as an_j_finish_cnt              -- 按时完成紧急订单行数
				,count(case when finish_or_not = '完成' and overdue_or_not ='逾期' and ADPRI = 'J' then 1 else null end )             as overdue_j_finish_cnt         -- 按时完成紧急订单行数
				,count(case when finish_or_not <> '完成' then 1 else null end )                                                       as total_nf_od_cnt              -- 现有订单总行数  
                ,GETDATE() etl_time
			--	into digital_brain_outbuy_dashboard_index
			from base_buy_tamp

	------------------------------------------------------- 
	  
	  TRUNCATE  table digital_brain_outbuy_dashboard_index_month;
	  with base_buy_tamp as
                (
					select ADPRI
						,finish_or_not
						,completion_date
						,CONVERT(VARCHAR(7),CONVERT(date, EINDT, 112), 120) EINDT_MONTH
						,DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, CONVERT(VARCHAR(10),CONVERT(date, EINDT, 112), 120) ) + 1, 0)) AS LastDayOfMonth
						,delivery_days_30
						,overdue_or_not,BUDAT
					from Outsourcing_Dashboard.dbo.sap_base_buy_field_wide
					where  (LOEKZ <>'L' or LOEKZ is null)
					and BUKRS='2000' and FRGKE='S'
					and CONVERT(date, EINDT, 112) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
					and CONVERT(date, EINDT, 112) <=CONVERT(DATE, GETDATE())  

               )
			   
  	INSERT INTO  digital_brain_outbuy_dashboard_index_month	 
		select 
		    EINDT_MONTH
           ,od_cont           -- 当月新增订单
           ,overdue_f_od_cnt  -- 逾期完成订单行数	 
           ,an_finish_cnt     -- 当月按时订单	
           ,an_j_finish_cnt	  -- 当月按时完成紧急订单	
           ,j_cnt		      -- 当月紧急订单
		   ,GETDATE() etl_time
	     -- into digital_brain_outbuy_dashboard_index_month
     from(		   
         select  EINDT_MONTH
		        ,count(1) as od_cont
				,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT<=LastDayOfMonth then 1 else null end ) as overdue_f_od_cnt  -- 逾期完成订单行数
		    	,count(case when finish_or_not = '完成' and overdue_or_not ='按时' then 1 else null end )                             as an_finish_cnt      -- 按时完成订单行数
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end )                          as nf_overdue_od_cnt  -- 未完成已未逾期
				,count(case when finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then 1 else null end )             as an_j_finish_cnt    -- 按时完成紧急订单行数
				,count(case when ADPRI = 'J' then 1 else null end )                                                                   as j_cnt              -- 紧急订单行数 
				
			from base_buy_tamp
			group by EINDT_MONTH
		 ) a
		 ORDER BY EINDT_MONTH

--采购申请--------------------------------------------- 
		 
select a.* ,min_udate
        from ODS_HANA.dbo.EBAN a
   left join (
			   select a.OBJECTID
			         ,min(b.UDATE) min_udate
			    from ODS_HANA.dbo.CDPOS a
			         join ODS_HANA.dbo.CDHDR b 
			           on a.OBJECTID = b.OBJECTID
			          and a.tabname='EBAN' 
			          and a.fname='FRGKZ'
			          and a.VALUE_NEW='s'
			          and b.CHANGENR=a.CHANGENR
			     group by  a.OBJECTID
			 )b
		  on a.BANFN = b.OBJECTID
			 
--寻源--------------------------------------------- 
