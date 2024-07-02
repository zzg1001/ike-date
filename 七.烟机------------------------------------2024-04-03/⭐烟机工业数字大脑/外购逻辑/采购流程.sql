TRUNCATE  table Digital_Brain_Quality.dbo.digital_brain_outbuy_dashboard_index;

with base_buy_tamp as
                (
				select ADPRI
				      ,finish_or_not
					  ,CONVERT(date, completion_date, 112) completion_date
					  ,CONVERT(date, EINDT, 112) EINDT
					  ,delivery_days_30
					  ,overdue_or_not
					  ,BUDAT
					  ,purchase_flag
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
					   ,purchase_flag
				from Outsourcing_Dashboard.dbo.sap_base_buy_field_wide
				where  (LOEKZ <>'L' or LOEKZ is null)
				and BUKRS='2000' and FRGKE='S'
				and CONVERT(date, EINDT, 112) < CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
				and CONVERT(date, EINDT, 112) >=  CAST(YEAR(GETDATE())-1 AS VARCHAR(4)) + '-01-01'  
				and overdue_or_not = '逾期' and finish_or_not = '未完成'
               )
			   
        INSERT INTO  Digital_Brain_Quality.dbo.digital_brain_outbuy_dashboard_index
         select 
				 count(1)                                                                                                             as total_od_cnt                 -- 总订单数
				,count(case when finish_or_not = '完成'   and completion_date<=EINDT  then 1 else null end )                          as an_finish_od_cnt             -- 按时完成订单行数
				,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT<=CONVERT(DATE, GETDATE()) then 1 else null end ) as overdue_f_od_cnt  -- 逾期完成订单行数
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end )                          as nf_overdue_od_cnt            -- 未完成逾期
				,count(case when ADPRI = 'J'  then 1 else null end )                                                                  as emergency_od_cnt             -- 紧急订单数量
				,count(case when finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then 1 else null end )             as an_j_finish_cnt              -- 按时完成紧急订单行数
				,count(case when finish_or_not = '完成' and overdue_or_not ='逾期' and ADPRI = 'J' then 1 else null end )             as overdue_j_finish_cnt         -- 按时完成紧急订单行数
				,count(case when finish_or_not <> '完成' then 1 else null end )                                                       as total_nf_od_cnt              -- 现有订单总行数  
                ,purchase_flag
			    ,GETDATE() etl_time
			--	into  Digital_Brain_Quality.dbo.digital_brain_outbuy_dashboard_index
			from base_buy_tamp
		   group by purchase_flag

	------------------------------------------------------- 
	  

TRUNCATE  table Digital_Brain_Quality.dbo.digital_brain_outbuy_dashboard_index_month;
	  with base_buy_tamp as
                (
					select ADPRI
						,finish_or_not
						,completion_date
						,CONVERT(VARCHAR(7),CONVERT(date, EINDT, 112), 120) EINDT_MONTH
						,DATEADD(DAY, -1, DATEADD(MONTH, DATEDIFF(MONTH, 0, CONVERT(VARCHAR(10),CONVERT(date, EINDT, 112), 120) ) + 1, 0)) AS LastDayOfMonth
						,delivery_days_30
						,overdue_or_not
						,BUDAT
						,purchase_flag
             ,NAME1  factory_name
						 ,is_qualified
					from Outsourcing_Dashboard.dbo.sap_base_buy_field_wide
					where  (LOEKZ <>'L' or LOEKZ is null)
					and BUKRS='2000' and FRGKE='S'
					and CONVERT(date, EINDT, 112) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
					and CONVERT(date, EINDT, 112) <=CONVERT(DATE, GETDATE())  

               )
			   
 	INSERT INTO  Digital_Brain_Quality.dbo.digital_brain_outbuy_dashboard_index_month	 
		select 
		    EINDT_MONTH
           ,od_cont           -- 当月新增订单
           ,overdue_f_od_cnt  -- 逾期完成订单行数	 
           ,an_finish_cnt     -- 当月按时订单	
           ,an_j_finish_cnt	  -- 当月按时完成紧急订单	
           ,j_cnt		      -- 当月紧急订单
		      ,purchase_flag
           ,factory_name
           ,qualified_cnt
		      ,GETDATE() etl_time
	    -- into Digital_Brain_Quality.dbo.digital_brain_outbuy_dashboard_index_month
     from(		   
         select  EINDT_MONTH
		        ,count(1) as od_cont
				,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT<=LastDayOfMonth then 1 else null end ) as overdue_f_od_cnt  -- 逾期完成订单行数
		    	,count(case when finish_or_not = '完成' and overdue_or_not ='按时' then 1 else null end )                              as an_finish_cnt      -- 按时完成订单行数
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end )                           as nf_overdue_od_cnt  -- 未完成已未逾期
				,count(case when finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then 1 else null end )              as an_j_finish_cnt    -- 按时完成紧急订单行数
				,count(case when ADPRI = 'J' then 1 else null end )                                                                  as j_cnt              -- 紧急订单行数 
		    	,count(case when is_qualified ='合格' then 1 else null end )                                                          as qualified_cnt      -- 按时完成订单行数
				,purchase_flag
				,factory_name
			from base_buy_tamp
			group by EINDT_MONTH
			        ,purchase_flag
              ,factory_name 
		 ) a
		 ORDER BY EINDT_MONTH

--1采购申请------------------------------------------------------------------------------------------------------------------------------------------------------ 


	      

TRUNCATE  table Digital_Brain_Quality.dbo.digital_brain_outbuy_step_req;

insert into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_req

	 SELECT 
	 case when a.EBELN is  null then min_udate else null end min_udate
	 ,DATEDIFF(day,min_udate,BEDAT) day_cnt
	 ,BEDAT
	 ,case when a.EBELN is not null then a.EBELN else null end EBELN
	 ,GETDATE() etl_time
	-- into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_req
	 from(
		 select 
		          b.min_udate
		          ,a.EBELN 
				 ,CONVERT(VARCHAR(10), CONVERT(datetime, d.BEDAT, 112), 120) BEDAT
		        from ODS_HANA.dbo.EBAN a
		    join (
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
				 left join ( select distinct BANFN,BNFPO,EBELN from ODS_HANA.dbo.EKPO) c 
				   on a.BANFN = c.BANFN 
				  and a.BNFPO = c.BNFPO 
				 left join ODS_HANA.dbo.EKKO d 
				   on d.EBELN = c.EBELN
				  where a.FRGKZ='S' 
				-- and a.EKGRP = '203'
				  and a.EKGRP in ('201','211','214','215','204','205','203')
	     )a
	     where min_udate >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	       and min_udate<=CONVERT(DATE, GETDATE()) 


     select
        count(min_udate)  -- 当前数量
	   ,sum( case when CONVERT(VARCHAR(7),BEDAT, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end )/count(case when CONVERT(VARCHAR(7),BEDAT, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),120) then EBELN else null end )
       ,count(case when a.min_udate = CONVERT(DATE, GETDATE()-1) then 1 else null end ) -- 日新增数量
       ,count(case when a.BEDAT = CONVERT(DATE, GETDATE()-1) and day_cnt = 0 then 1 else null end )  -- 日消耗数量
      from  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_req a


--2寻源--------------------------------------------- 

TRUNCATE  table Digital_Brain_Quality.dbo.digital_brain_outbuy_step_src;

   insert into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_src

  select 
         case when  STATUS_CD_ID not in ('INQ_HD_STATUS_REVIEWED','INQ_HD_STATUS_CLOSED','INQ_HD_STATUS_DRAFT') then INQUIRY_MODE else null end INQUIRY_MODE
        ,case when  STATUS_CD_ID ='INQ_HD_STATUS_PUBLISHED' then DATEDIFF(day,CONVERT(DATE, a.start_date),CONVERT(DATE, a.end_date)) else null end day_cnt
        ,case when  STATUS_CD_ID ='INQ_HD_STATUS_PUBLISHED' then CONVERT(DATE, a.end_date) else null end end_date
        ,CONVERT(DATE, a.start_date) start_date
        ,GETDATE() etl_time
        into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_src
        from ODS_SRM.dbo.srm_inq_inquiry_hd a
  where delete_flag =0
    and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
    and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE())

    
    
      select count(INQUIRY_MODE)
         ,sum( case when CONVERT(VARCHAR(7),end_date,  120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end )/count(case when CONVERT(VARCHAR(7),end_date,  120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),120) then day_cnt else null end )
         ,count(case when start_date = CONVERT(DATE, GETDATE()-1) then 1 else null end ) -- 日新增数量
         ,count(case when end_date = CONVERT(DATE, GETDATE()-1) then 1 else null end )   -- 日消耗数量
    from Digital_Brain_Quality.dbo.digital_brain_outbuy_step_src
    



--3订单执行（计划员）=================================--------------------------------------------- 


  TRUNCATE  table  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_ord;

            insert into  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_ord
              select 
                    case when c.order_item_id is null then b.id else null end as order_item_id
                    ,DATEDIFF(day, a.CREATED_TS,c.max_updated) day_cnt
                    ,CONVERT(DATE, a.CREATED_TS) create_date    -- 订单行首次审批通过时间
                    ,CONVERT(DATE, c.max_updated) max_updated -- 订单行创建装运单时间（最晚）
                    ,GETDATE() etl_time
                   -- into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_ord
               from ODS_SRM.dbo.srm_poc_order_hd a
               join ODS_SRM.dbo.srm_poc_order_item b
                 on a.ID = b.ORDER_ID 
               left join (
                select order_item_id
                                  ,MAX(a.updated_ts)  max_updated
                             FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
                             join ODS_SRM.dbo.srm_poc_delivery_note_item b
                               ON a.id = b.dn_hd_id
                            group by order_item_id
                         )c 
                 on b.id = c.order_item_id
                and b.DELETE_FLAG = 0
              where a.DELETE_FLAG = 0
                and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE())  
                



-- 订单执行（计划员）
select count(order_item_id) -- 当前数量
      ,sum(day_cnt)/count(1) -- 本月平均周期（月度？）
      ,count(case when create_date = CONVERT(DATE, GETDATE()-1) then 1 else null end ) d -- 日新增数量
      ,count(case when create_date = CONVERT(DATE, GETDATE()-1) and day_cnt = 0 then 1 else null end ) d -- 日消耗数量
  from  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_ord

-----------------------------------

-- 订单配送（供应商）
            TRUNCATE  table  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_delivery;

                 insert into  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_delivery

                   select  case when a.DN_STATUS = 'SENT_AUDITED' and current_status is null  then order_item_id else null       end delivery_req
                          ,case when current_status = '点收节点/结束指令' then a.CREATED_TS  else null   end create_date
                          ,case when current_status = '点收节点/结束指令' then DATEDIFF(day,a.CREATED_TS,b.updated_ts)  else null   end day_cnt
                         -- into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_delivery
                     FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
                     join ODS_SRM.dbo.srm_poc_delivery_note_item b
                       ON a.id = b.dn_hd_id
                    WHERE a.delete_flag = 0
                      and b.delete_flag = 0
                      and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                      and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE())

                
     select count(DISTINCT  delivery_req)
            ,sum( case when CONVERT(VARCHAR(7),create_date, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end )/count(case when CONVERT(VARCHAR(7),create_date, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),120) then day_cnt else null end )
            ,count(DISTINCT case when create_date = CONVERT(DATE, GETDATE()-1) then delivery_req else null end )   -- 日新增数量
            ,count(DISTINCT case when create_date = CONVERT(DATE, GETDATE()-1) and day_cnt=0 then 1 else null end ) -- 日消耗数量
       from Digital_Brain_Quality.dbo.digital_brain_outbuy_step_delivery



-----------------------------------


-- 物流周转（仓库）

             
            TRUNCATE  table  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_warehouse;

                 insert into  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_warehouse
                
                        SELECT 
                          case when EXISTS (
                                    SELECT 1
                                      FROM ODS_SRM.dbo.srm_poc_delivery_note_item
                                     WHERE order_num = b.order_num
                                       AND current_status = '点收节点/结束指令'
                                    )
                                AND NOT EXISTS (
                                   SELECT 1
                                     FROM ODS_SRM.dbo.srm_poc_delivery_note_item
                                    WHERE order_num = b.order_num
                                      AND current_status = '收货节点/结束指令'
                                       )
                                       then b.order_item_id  else null end order_item_id
                          ,a.dn_hd_num
                          ,b.line_num
                          ,DATEDIFF(day,c.chech_time,c.migo_time) day_cnt 
                          ,c.chech_time 
                          ,c.migo_time 
                         ,GETDATE() etl_time
                        --  into  Outsourcing_Dashboard.dbo.digital_brain_outbuy_step_warehouse						 
                      FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
                      join ODS_SRM.dbo.srm_poc_delivery_note_item b
                        ON a.id = b.dn_hd_id
                      left join (
                            
                                  select notice_num 
                                        ,notice_line_num 
                                        ,max(case when node_code = 'CHECK' then a.close_time else null end) chech_time
                                        ,max(case when node_code = 'MIGO'  then a.close_time else null end) migo_time
                                   from ODS_LPS.dbo.ods_logistics_pur_info a
                                  where node_code in ('CHECK','MIGO')
                                  group by notice_num 
                                          ,notice_line_num 
                                 )c
                          on a.dn_hd_num = c.notice_num 
                      and b.line_num = c.notice_line_num
                    WHERE a.delete_flag = 0
                      and b.delete_flag =0
                      and a.DN_STATUS = 'SENT_AUDITED'
                      and CONVERT(DATE, a.updated_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                      and CONVERT(DATE, a.updated_ts)<=CONVERT(DATE, GETDATE()) 

                            

               

          select count( distinct order_item_id)
                ,sum(case when CONVERT(VARCHAR(7),chech_time, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end)/count(case when CONVERT(VARCHAR(7),chech_time, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end)
                ,count(distinct case when CONVERT(DATE, chech_time) = CONVERT(DATE, GETDATE()-1) then order_item_id else null end ) -- 日新增数量
                ,count(distinct case when CONVERT(DATE, migo_time) = CONVERT(DATE, GETDATE()-1) and day_cnt =0 then order_item_id else null end )  -- 日消耗数量
            from Digital_Brain_Quality.dbo.digital_brain_outbuy_step_warehouse


-----------------------------------

-- 质检
    TRUNCATE  table Digital_Brain_Quality.dbo.digital_brain_outbuy_step_inspection;

                 insert into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_inspection

                  select 
                         order_num 
                         ,order_item_num
                         ,DATEDIFF(day,create_date_time,ud_date_time )  day_cnt
                         ,create_date_time
                         ,quantity
						 ,GETDATE() etl_time
					--	into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_inspection
                   from  (
                          select  order_num 
                                 ,order_item_num
                                 ,create_date_time
                                 ,ud_date_time 
                                 ,quantity
                             from ODS_SRM.dbo.insp_lot a
                            where ud_flag=0
                             and is_deleted=0 
                            
                         )a
                         
                     union 
                          select 
                               a.order_num 
                              ,order_item_num
                              ,0 day_cnt
                              ,a.CREATED_TS create_date_time
                              ,null ud_date_time
                              ,0 quantity
                          from ODS_SRM.dbo.srm_poc_order_hd a
                          join ODS_SRM.dbo.srm_poc_order_item b
                            on a.ID = b.ORDER_ID 
                           and b.DELETE_FLAG = 0
                         where a.DELETE_FLAG = 0
                           and b.EXAMINATION_FLAG =0
                           and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                           and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE())

                
     select   count( distinct order_item_num)
             ,sum(case when CONVERT(VARCHAR(7),create_date_time, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end)/count(case when CONVERT(VARCHAR(7),create_date_time, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then quantity else null end)
             ,count(distinct case when CONVERT(DATE,create_date_time) = CONVERT(DATE, GETDATE()-1) then order_item_num else null end )  -- 日新增数量
             ,count(distinct case when CONVERT(DATE,create_date_time) = CONVERT(DATE, GETDATE()-1) and day_cnt =0 then order_item_num else null end )  -- 日消耗数量
       from  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_inspection
       


-----------------------------------

-- 开票
  TRUNCATE  table  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_md;

                 insert into Digital_Brain_Quality.dbo.digital_brain_outbuy_step_md

				   
				select 
				md_ne
				,md_max_date
				,md_create_date
				,md_eq_cnt
				, DATEDIFF(day,md_create_date,md_max_date) as day_cnt
				,GETDATE() etl_time
				-- into  Digital_Brain_Quality.dbo.digital_brain_outbuy_step_md
				from(
					SELECT 
							CASE when  b.INVOICE_QTY<> b.QTY then order_item_id else null end as md_ne
						   ,CASE when  b.INVOICE_QTY= b.QTY then b.created_ts else null   end as md_max_date
						   ,CASE when  b.INVOICE_QTY=b.QTY then a.created_ts else null    end as md_create_date
						   ,CASE when  b.INVOICE_QTY=b.QTY and len(b.created_ts )>0 then order_item_id else null   end as md_eq_cnt
					  from ODS_SRM.dbo.srm_poc_md_hd a
				 left join ODS_SRM.dbo.srm_poc_md_item b 
						on a.id = b.MD_HD_ID 
					 where  CONVERT(DATE, a.created_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
					   and CONVERT(DATE, a.created_ts)<=CONVERT(DATE, GETDATE()) 
				   )a
              
                         

     select   count(distinct md_ne)
             ,sum(case when CONVERT(VARCHAR(7),md_max_date, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end)/count(case when CONVERT(VARCHAR(7),md_max_date, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then md_eq_cnt else null end)
             ,count(distinct case when CONVERT(DATE,md_create_date) = CONVERT(DATE, GETDATE()-1) then 1 else null end )  -- 日新增数量
             ,count(distinct case when CONVERT(DATE,md_create_date) = CONVERT(DATE, GETDATE()-1) and day_cnt=0 then 1 else null end )  -- 日消耗数量
       from  Outsourcing_Dashboard.dbo.digital_brain_outbuy_step_md







