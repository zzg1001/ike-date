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
		    	,count(case when finish_or_not = '完成' and overdue_or_not ='按时' then 1 else null end )                              as an_finish_cnt      -- 按时完成订单行数
				,count(case when finish_or_not = '未完成' and overdue_or_not = '逾期' then 1 else null end )                           as nf_overdue_od_cnt  -- 未完成已未逾期
				,count(case when finish_or_not = '完成' and overdue_or_not ='按时' and ADPRI = 'J' then 1 else null end )              as an_j_finish_cnt    -- 按时完成紧急订单行数
				,count(case when ADPRI = 'J' then 1 else null end )                                                                   as j_cnt              -- 紧急订单行数 
				
			from base_buy_tamp
			group by EINDT_MONTH
		 ) a
		 ORDER BY EINDT_MONTH

--1采购申请--------------------------------------------- 

	      
TRUNCATE  table ODS_HANA.dbo.digital_brain_outbuy_step_req;

insert into ODS_HANA.dbo.digital_brain_outbuy_step_req
	 SELECT 
	 EBELN
	 ,EBELP
	 ,min_udate
	 ,GETDATE() etl_time
	--into ODS_HANA.dbo.digital_brain_outbuy_step_req
	 from(
		 select a.EBELN
		         ,a.EBELP 
		         ,CONVERT(VARCHAR(10), CONVERT(datetime, min_udate, 112), 120)min_udate
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
				  where a.FRGKZ='S' 
				-- and a.EKGRP = '203'
				  and a.EKGRP in ('201','211','214','215','204','205','203')
	     )a
	     where min_udate >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	       and min_udate<=CONVERT(DATE, GETDATE()) 


     select
        count(1)  -- 当前数量
       ,sum(day_cnt)/count(case when EBELN is not null then 1 else 0 end) -- 本月平均周期（
       ,count(case when a.min_udate = CONVERT(DATE, GETDATE()) then 1 else null end ) d -- 日新增数量
       ,count(case when a.min_udate = CONVERT(DATE, GETDATE()) and day_cnt = 0 then 1 else null end ) c -- 日消耗数量
      from(

	          select a.min_udate
	               , b.CREATED_TS
	               ,DATEDIFF(day, a.min_udate,b.CREATED_TS ) day_cnt
	           from ODS_HANA.dbo.digital_brain_outbuy_step_req a
	      left join ODS_SRM.dbo.srm_poc_order_hd b 
	             on a.EBELN =b.ORDER_NUM 
	            and b.DELETE_FLAG = 0
	         
	       ) a


	            

			 
--2寻源--------------------------------------------- 
select 
         case when  STATUS_CD_ID not in ('INQ_HD_STATUS_REVIEWED','INQ_HD_STATUS_CLOSED','INQ_HD_STATUS_DRAFT') then INQUIRY_MODE else null end 
        ,case when  STATUS_CD_ID ='INQ_HD_STATUS_PUBLISHED' then DATEDIFF(day,CONVERT(DATE, a.start_date),CONVERT(DATE, a.end_date)) else null end day_cnt
        ,case when  STATUS_CD_ID ='INQ_HD_STATUS_PUBLISHED' then CONVERT(DATE, a.end_date) else null end end_date
        ,case when  STATUS_CD_ID ='INQ_HD_STATUS_PUBLISHED' then CONVERT(DATE, a.start_date) else null end start_date
        from ODS_SRM.dbo.srm_inq_inquiry_hd a
  where delete_flag =0
    and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
    and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE())


		 
--3订单执行（计划员）=================================--------------------------------------------- 


      
with tamp_1 as (
              select 
                    b.id
                    ,DATEDIFF(day, a.CREATED_TS,c.max_updated) day_cnt
                    ,CONVERT(DATE, a.CREATED_TS) create_date    -- 订单行首次审批通过时间
                    ,CONVERT(DATE, c.max_updated) max_updated -- 订单行创建装运单时间（最晚）
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
                )
-- 订单执行（计划员）
select count(1) -- 当前数量
      ,sum(day_cnt)/count(1) -- 本月平均周期（月度？）
      ,count(case when create_date = CONVERT(DATE, GETDATE()) then 1 else null end ) d -- 日新增数量
      ,count(case when create_date = CONVERT(DATE, GETDATE()) and day_cnt = 0 then 1 else null end ) d -- 日消耗数量
  from tamp_1

-----------------------------------

-- 订单配送（供应商）
with tamp_2 as (

                 

                   select  case when a.DN_STATUS = 'SENT_AUDITED'   then order_item_id else null       end delivery_req
                          ,case when current_status = '点收节点/结束指令' then a.CREATED_TS  else null   end create_date
                          ,case when current_status = '点收节点/结束指令' then DATEDIFF(day,a.CREATED_TS,b.updated_ts)  else null   end day_cnt
                     FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
                     join ODS_SRM.dbo.srm_poc_delivery_note_item b
                       ON a.id = b.dn_hd_id
                    WHERE a.delete_flag = 0
                      and b.delete_flag = 0
                      and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                      and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE())

                )
     select count(DISTINCT  delivery_req)
            ,sum( case when CONVERT(VARCHAR(7),create_date, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end )/count(case when CONVERT(VARCHAR(7),create_date, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),120) then day_cnt else null end )
            ,count(DISTINCT case when create_date = CONVERT(DATE, GETDATE()) then delivery_req else null end )   -- 日新增数量
            ,count(DISTINCT case when create_date = CONVERT(DATE, GETDATE()) and day_cnt=0 then 1 else null end ) -- 日消耗数量
       from tamp_2



-----------------------------------


-- 物流周转（仓库）

                   SELECT 
                           b.order_item_id 
                          ,a.dn_hd_num
                          ,b.line_num
                      FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
                      join ODS_SRM.dbo.srm_poc_delivery_note_item b
                        ON a.id = b.dn_hd_id
                    WHERE  a.delete_flag = 0
                      and b.delete_flag =0
                      and a.DN_STATUS = 'SENT_AUDITED'
                      and CONVERT(DATE, a.updated_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                      and CONVERT(DATE, a.updated_ts)<=CONVERT(DATE, GETDATE()) 
                      AND EXISTS (
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

                



with tamp_3 as (

                 
                    SELECT 
                           b.order_item_id 
                          ,a.dn_hd_num
                          ,b.line_num
                      FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
                      join ODS_SRM.dbo.srm_poc_delivery_note_item b
                        ON a.id = b.dn_hd_id
                    WHERE  a.delete_flag = 0
                      and b.delete_flag =0
                      and a.DN_STATUS = 'SENT_AUDITED'
                      and CONVERT(DATE, a.updated_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                      and CONVERT(DATE, a.updated_ts)<=CONVERT(DATE, GETDATE()) 

                )
               ,tamp_3_1 as (
      
                            select
                              notice_num
                               ,notice_line_num 
                               ,DATEDIFF(day,chech_time,migo_time) day_cnt  
                               ,chech_time 
                               ,migo_time                            
                            from(
                                select notice_num 
                                      ,notice_line_num 
                                      ,max(case when node_code = 'CHECK' then a.close_time else null end) chech_time
                                      ,max(case when node_code = 'MIGO'  then a.close_time else null end) migo_time
                                 from ODS_LPS.dbo.ods_logistics_pur_info a
                                where node_code in ('CHECK','MIGO')
                                group by notice_num 
                                        ,notice_line_num 

                                  )
                    
                      )

               

          select count( order_item_id)
                ,sum(case when CONVERT(VARCHAR(7),chech_time, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end)/count(case when CONVERT(VARCHAR(7),chech_time, 120) = CONVERT(VARCHAR(7),CONVERT(DATE, GETDATE()),  120) then day_cnt else null end)
                ,count(case when CONVERT(DATE, chech_time) = CONVERT(DATE, GETDATE()) then 1 else null end ) -- 日新增数量
                ,count(case when CONVERT(DATE, migo_time) = CONVERT(DATE, GETDATE()) and DATEDIFF(day,chech_time,migo_time)=0 then 1 else null end )  -- 日消耗数量
    
            from tamp_3 a 
       left join tamp_3_1 b 
              on a.dn_hd_num = b.notice_num 
             and a.line_num = b.notice_line_num




-----------------------------------

-- 质检
with tamp_4 as (

                  select 
                         order_num 
                         ,order_item_num
                         ,DATEDIFF(day,create_date_time,ud_date_time )  day_cnt
                         ,create_date_time
                         ,quantity
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
                              ,0 quantity
                              ,a.CREATED_TS create_date_time
                          from ODS_SRM.dbo.srm_poc_order_hd a
                          join ODS_SRM.dbo.srm_poc_order_item b
                            on a.ID = b.ORDER_ID 
                           and b.DELETE_FLAG = 0
                         where a.DELETE_FLAG = 0
                           and b.EXAMINATION_FLAG =0
                           and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                           and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE())

                )
     select   count( order_item_num)
             ,sum(day_cnt)/sum(quantity)
             ,count(case when CONVERT(DATE,create_date_time) = CONVERT(DATE, GETDATE()) then 1 else null end )  -- 日新增数量
             ,count(case when CONVERT(DATE,create_date_time) = CONVERT(DATE, GETDATE()) and day_cnt =0 then 1 else null end )  -- 日消耗数量
       from tamp_4
       



-----------------------------------

-- 开票
with tamp_5 as (

                SELECT 
                        CASE when  b.INVOICE_QTY<> b.QTY then order_item_id else null end as md_ne
                       ,CASE when  b.INVOICE_QTY= b.QTY then b.created_ts else null   end as md_max_date
                       ,CASE when  b.INVOICE_QTY=b.QTY then a.created_ts else null    end as md_create_date
                       ,CASE when  b.INVOICE_QTY=b.QTY then b.created_ts  else null   end as md_eq_cnt
                  from ODS_SRM.dbo.srm_poc_md_hd a
             left join ODS_SRM.dbo.srm_poc_md_item b 
                    on a.id = b.MD_HD_ID 
                 where  CONVERT(DATE, a.created_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                   and CONVERT(DATE, a.created_ts)<=CONVERT(DATE, GETDATE()) 
                )
                         

     select   count( md_ne)
             ,sum(DATEDIFF(day,md_create_date,md_max_date))/count(md_eq_cnt)
             ,count(case when CONVERT(DATE,md_create_date) = CONVERT(DATE, GETDATE()) then 1 else null end )  -- 日新增数量
             ,count(case when CONVERT(DATE,md_create_date) = CONVERT(DATE, GETDATE()) and DATEDIFF(day,md_max_date,md_max_date) =0 then 1 else null end )  -- 日消耗数量
       from tamp_5
