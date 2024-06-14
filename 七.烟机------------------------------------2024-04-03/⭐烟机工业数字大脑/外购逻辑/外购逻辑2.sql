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
		 
  
 SELECT 
	 EBELN
	 ,EBELP
	 ,min_udate
	 ,GETDATE() etl_time
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
				  and a.EKGRP in ('201','211','214','215','204','205')
				  and a.EBELN is null
	     )a
	     where min_udate >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	       and min_udate<=CONVERT(DATE, GETDATE()) 
			 
--2寻源--------------------------------------------- 
  select * from  ODS_SRM.dbo.srm_inq_inquiry_hd 
   where STATUS_CD_ID not in ('INQ_HD_STATUS_REVIEWED','INQ_HD_STATUS_CLOSED','INQ_HD_STATUS_DRAFT')
    and delete_flag =0

		 
--3订单执行（计划员）--------------------------------------------- 

     select 
             a.ORDER_NUM
            ,b.ORDER_ITEM_NUM  
            ,CONVERT(DATE, a.CREATED_TS) CREATED_TS
            ,GETDATE() etl_time
       from ODS_SRM.dbo.srm_poc_order_hd a
       join ODS_SRM.dbo.srm_poc_order_item b
         on a.ID = b.ORDER_ID 
       join ODS_SRM.dbo.srm_poc_delivery_note_item c 
         on b.id = c.order_item_id
      where a.DELETE_FLAG = 0
        and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	    and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE()) 	 
         -- and c.order_item_id is null  
    

--4订单配送（供应商）--------------------------------------------- 	
            SELECT b.order_num
                  ,b.order_item_num
                  ,CONVERT(DATE, a.CREATED_TS) CREATED_TS
              from ODS_SRM.dbo.srm_poc_delivery_note_hd a
	          join ODS_SRM.dbo.srm_poc_delivery_note_item b 
		        on a.id = b.dn_hd_id 
		     where a.DELETE_FLAG=0 
		       and a.DN_STATUS='SENT_AUDITED'
			   and CONVERT(DATE, a.CREATED_TS) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
	           and CONVERT(DATE, a.CREATED_TS)<=CONVERT(DATE, GETDATE()) 	
		      -- and b.current_status is null 


--5物流周转（仓库）----------------------------------------------- 	

	    
SELECT a.updated_ts 
      ,b.ORDER_NUM
      ,b.ORDER_ITEM_NUM  
 FROM ODS_SRM.dbo.srm_poc_delivery_note_hd a
 JOIN (select dn_hd_id
              ,ORDER_NUM
              ,ORDER_ITEM_NUM  
         from ODS_SRM.dbo.srm_poc_delivery_note_item
     group by dn_hd_id
              ,ORDER_NUM
              ,ORDER_ITEM_NUM ) b
   ON a.id = b.dn_hd_id
WHERE a.DELETE_FLAG = 0
  AND a.DN_STATUS = 'SENT_AUDITED'
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
--6质检----------------------------------------------------------- 

select count(1) from  ODS_SRM.dbo.insp_lot where ud_flag=0

--7.开票----------------------------------------------------------- 

   SELECT CONVERT(DATE, a.created_ts ) created_ts 
              ,b.MD_HD_NUM
              ,b.MD_ITEM_NUM
          from ODS_SRM.dbo.srm_poc_md_hd a
     left join ODS_SRM.dbo.srm_poc_md_item b 
            on a.id = b.MD_HD_ID 
            where b.INVOICE_QTY<> b.QTY 
             and CONVERT(DATE, a.created_ts) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
             and CONVERT(DATE, a.created_ts)<=CONVERT(DATE, GETDATE()) 