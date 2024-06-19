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

--1采购申请--------------------------------------------- 

-- CREATE NONCLUSTERED INDEX CDPOS_index
-- ON ODS_HANA.dbo.CDPOS  (OBJECTID,tabname,VALUE_NEW,CHANGENR)


-- CREATE NONCLUSTERED INDEX CDHDR_index
-- ON ODS_HANA.dbo.CDHDR  (OBJECTID,CHANGENR,UDATE)
		 
  
	      
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
       ,count(case when a.min_udate = CONVERT(DATE, GETDATE()) and day_cnt = 0 then 1 else null end ) d -- 日新增数量
       ,count(case when a.min_udate = CONVERT(DATE, GETDATE()) and day_cnt > 0 then 1 else null end ) c -- 日消耗数量
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
  select * from  ODS_SRM.dbo.srm_inq_inquiry_hd 
   where STATUS_CD_ID not in ('INQ_HD_STATUS_REVIEWED','INQ_HD_STATUS_CLOSED','INQ_HD_STATUS_DRAFT')
    and delete_flag =0

		 
--3订单执行（计划员）=================================--------------------------------------------- 



  drop table  ODS_HANA.dbo.digital_brain_outbuy_step_delivery;
--
--
--TRUNCATE table ODS_HANA.dbo.digital_brain_outbuy_step_delivery;
--
--INSERT INTO ODS_HANA.dbo.digital_brain_outbuy_step_delivery
select 
-- 订单执行（计划员）
count(action)  --当前数量
,sum(DATEDIFF(day,CREATE_TS,max_updated))/count(action)  -- 本月平均周期
,count(case when DATEDIFF(day,CREATE_TS,max_updated) = 0 then 1 else null end) -- 日新增数量
,count(case when DATEDIFF(day,CREATE_TS,max_updated) > 0 then 1 else null end) -- 日消耗数量

-- 订单执行（计划员）
,sum(delivery_cnt) --当前数量
,sum(day_cnt)/sum(num_cnt) -- 本月平均周期


,count(delivery_t) 
,count(quality)
,count(md_cnt)
from ODS_HANA.dbo.digital_brain_outbuy_step_delivery


TRUNCATE table ODS_HANA.dbo.digital_brain_outbuy_step_delivery;
--
INSERT INTO ODS_HANA.dbo.digital_brain_outbuy_step_delivery

select 
             b.ORDER_ITEM_NUM  action
            ,c.delivery_cnt    delivery_cnt
            ,d.delivery_t      delivery_t
            ,e.order_item_num  quality 
            ,f.md_cnt           md_cnt
            
            ,CONVERT(DATE, a.CREATED_TS)  CREATE_TS    -- 订单行首次审批通过时间
            ,CONVERT(DATE, c.max_updated) max_updated -- 订单行创建装运单时间（最晚）

            
            ,num_cnt     -- 订单配送（供应商）
            ,day_cnt

            ,insp_cnt      -- 6.质检
            ,quantity
            
            ,md_max_date   -- 7.开票
            ,md_create_date
            
            ,GETDATE() etl_time
        -- into  ODS_HANA.dbo.digital_brain_outbuy_step_delivery
       from ODS_SRM.dbo.srm_poc_order_hd a
       join ODS_SRM.dbo.srm_poc_order_item b
         on a.ID = b.ORDER_ID 
        and b.DELETE_FLAG = 0
      left join (  


                   SELECT b.order_item_id 
                         ,b.order_item_num
                         ,b.order_num
                         ,count(case when a.DN_STATUS = 'SENT_AUDITED' then b.order_item_id else null end) delivery_cnt
                         ,MAX(case when a.DN_STATUS = 'SENT_AUDITED' then a.updated_ts else null end)       max_updated
                        ,count(case when current_status = '点收节点/结束指令' then a.updated_ts else null end) num_cnt
                        ,count(DATEDIFF(day,
					                         case when current_status = '点收节点/结束指令' then a.created_ts else null end
					                        ,case when current_status = '点收节点/结束指令' then b.created_ts else null end      
                                         )
                               ) day_cnt 
                        ,count( case when 
                        	       DATEDIFF(day,
					                         case when current_status = '点收节点/结束指令' then a.created_ts else null end
					                        ,case when current_status = '点收节点/结束指令' then b.created_ts else null end      
                                            ) = 0 then 1 else null end
                               ) day_cnt_curr 
                        ,count( case when 
                        	       DATEDIFF(day,
					                         case when current_status = '点收节点/结束指令' then a.created_ts else null end
					                        ,case when current_status = '点收节点/结束指令' then b.created_ts else null end      
                                            ) > 0 then 1 else null end
                               ) day_cnt_ne 
				     FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
				     join ODS_SRM.dbo.srm_poc_delivery_note_item b
				       ON a.id = b.dn_hd_id
				    WHERE  CONVERT(DATE, a.updated_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	                  and CONVERT(DATE, a.updated_ts)<=CONVERT(DATE, GETDATE())
	                 group by b.order_item_id 
	                     ,b.order_item_num
                         ,b.order_num
	             
	              )c
          on b.id = c.order_item_id
	  left join ( 
	            	  SELECT b.order_item_id  delivery_t
				      FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
				      join ODS_SRM.dbo.srm_poc_delivery_note_item b
				        ON a.id = b.dn_hd_id
				   WHERE  a.DN_STATUS = 'SENT_AUDITED'
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
	                group by b.order_item_id 
		        )d
         on b.id = d.delivery_t
    left join ( 
	            	  SELECT b.order_item_id  delivery_t
				      FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
				      join ODS_SRM.dbo.srm_poc_delivery_note_item b
				        ON a.id = b.dn_hd_id
				   WHERE  a.DN_STATUS = 'SENT_AUDITED'
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
	                group by b.order_item_id 
		        )dd
         on b.id = dd.delivery_t
    left join (   
                  select 
			             order_num 
			             ,order_item_num
			             ,DATEDIFF(day,ud_date_time ,create_date_time)  insp_cnt
			             ,quantity
			       from  (
				          select  order_num 
				                 ,order_item_num
			    	         from ODS_SRM.dbo.insp_lot 
			    	        where ud_flag=0
			    	        group by order_num 
			    	              ,order_item_num
		    	         )a
		    	         
			         union 
			              select 
			                 distinct 
			                   a.order_num 
			                  ,order_item_num
			                  ,0 insp_cnt
			                  ,0 quantity
		    	          from ODS_SRM.dbo.srm_poc_order_hd a
				          join ODS_SRM.dbo.srm_poc_order_item b
				            on a.ID = b.ORDER_ID 
				           and b.DELETE_FLAG = 0
				         where a.DELETE_FLAG = 0
				           and b.EXAMINATION_FLAG =0
					       and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
						   and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE()) 	
    	     )e 
           on e.order_item_num = c.ORDER_ITEM_NUM  
          and e.order_num = c.ORDER_NUM  

    -- 7.开票
    left join (                        
		    	
	           SELECT order_item_id
		                ,count(CASE when  b.INVOICE_QTY<> b.QTY then order_item_id else null end) md_ne_cnt
		               ,max( CASE when  b.INVOICE_QTY= b.QTY then b.created_ts else null end) as md_max_date
		               ,max(CASE when  b.INVOICE_QTY=b.QTY then a.created_ts else null end) as md_create_date
		               ,count(CASE when  b.INVOICE_QTY=b.QTY then a.created_ts else null end) md_eq_cnt
		          from ODS_SRM.dbo.srm_poc_md_hd a
		     left join ODS_SRM.dbo.srm_poc_md_item b 
		            on a.id = b.MD_HD_ID 
		         where  CONVERT(DATE, a.created_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
		           and CONVERT(DATE, a.created_ts)<=CONVERT(DATE, GETDATE()) 
		           group by order_item_id
               )f 
           on f.order_item_id = b.id 
       where a.DELETE_FLAG = 0
         and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	     and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE()) 	 
	     
	---------------     
	      select * from ODS_SRM.dbo.srm_poc_md_invoice_hd
           where CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	        and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE()) 
	     
