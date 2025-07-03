truncate table report0624.dbo.r24_consolidate_table_all

   select  a.order_num
	      ,a.order_item_num
	      ,b.node_status
     into #node_status_info
	 from [ods_srm].[dbo].[srm_poc_order_item] as a,
	      [ods_srm].[dbo].[srm_poc_order_item_extra] as b
    where a.id = b.order_item_id 
	  and b.node_status is not null
    group by a.order_num
            ,a.order_item_num
            ,b.node_status;


-------------------------------------------------------

	 select
			a.DELNR2  as supply_no
		   ,a.DELPS2  as supply_line
		   ,a.DELNR1  as require_no                 -- 预留号                
		   ,a.DELPS1  as require_line               -- 预留号行号      
	   into #supply_no_5
	   from ODS_HANA.dbo.mrp_ww  a
	where  a.DELKZ2  like '5%';
		

-------------------------------------------------------

  select  A.ORDER_NUM  
		 ,B.ORDER_ITEM_NUM
	     ,SUM(B.STOCK_QTY) STOCK_QTY_SM
	into #supply_stock
	from ODS_SRM.dbo.srm_poc_order_hd A
	join ODS_SRM.dbo.srm_poc_order_item B 
	on A.ID = B.ORDER_ID
   where A.DELETE_FLAG = 0
	 and B.DELETE_FLAG = 0
	 and A.REF_PURCHASER_CD = '2000'
	 and B.STOCK_QTY > 0
   group by A.ORDER_NUM  
		   ,B.ORDER_ITEM_NUM;

-------------------------------------------------------	

		  
   SELECT DISTINCT
					a.MATNR AS MATNR, -- 物料编号
					a.DELNR1 AS rsnum, -- 预留号
					a.DELPS1 AS rspos, -- 预留号行号
					CAST(a.MNG012 AS FLOAT) AS MNG01, -- 将 MNG012 转换为数值类型
					a.DELNR2 AS DELNR, -- 计划协议号
					a.DELPS2 AS DELPS, -- 计划协议明细行号
					a.DELET2 AS DELET,
					a.DAT01 AS EINDT -- 计划协议交货行交货时间
			   into #DistinctData
			   FROM ODS_HANA.dbo.mrp_ww a
		  left join ( 
					  select 
							COALESCE(SUBSTRING(A.POSID,1,1), 'NA')+ '-' + COALESCE(RTRIM(LTRIM(SUBSTRING(A.POSID,2,50))), 'NA') as POSKI 
						   ,PSPNR
						from ODS_HANA.dbo.PRPS A
	                ) b
		         on a.PSPNR = b.PSPNR
			  where (
					DELKZ1 IN ('VC', 'VJ')OR (DELKZ1 = 'AR' AND b.POSKI = 'Z-2000_XSCB004')
					)
			   and a.DELNR2 LIKE '55%';
			   
  
					SELECT
						d.MATNR,
						d.rsnum,
						d.rspos,
						d.MNG01,
						d.DELNR,
						d.DELPS,
						d.DELET,
						d.EINDT,
						(
						   SELECT SUM(d2.MNG01)
							 FROM #DistinctData d2
							WHERE d2.DELNR = d.DELNR
							  AND d2.DELPS = d.DELPS
							  AND d2.EINDT <= d.EINDT
						) AS Cumulative_MNG01
					 into #CumulativeData
					from #DistinctData d;
				
					
			 select a.MATNR
					,a.rsnum
					,a.rspos
					,a.MNG01
					,a.DELNR
					,a.DELPS
					,a.DELET
					,a.EINDT
					,case when b.STOCK_QTY_SM >= Cumulative_MNG01 then MNG01 else 0 end STOCK_QTY
			   into #delnr_55
			  from #CumulativeData a
		 left join #supply_stock b
				on b.ORDER_NUM      = a.DELNR 
		       and b.ORDER_ITEM_NUM = a.DELPS;
	  
		
		  
-------------------------------------------------------

		  select distinct 
				 ebeln
				,ebelp
				,etenr
				,fixkz
		   into #sap_lp  -- #h
		   from [report0624].[dbo].[sap_lp];

-------------------------------------------------------

 SELECT 
		 order_num              -- 订单号			
		,order_line_num         -- 行号			
		,plan_item_num          -- 如果是协议订单，就是计划需求行号			
		,current_node_code
		,current_node_name      -- 节点code和名称	
		,n45_current_node_status
		,update_date_time
		,update_date_time as n45_update_date_time -- 当前节点时间 采购
 into #logistics__status
 from (
		 SELECT			
				order_num              -- 订单号			
				,order_line_num        -- 行号			
				,plan_item_num         -- 如果是协议订单，就是计划需求行号			
				,current_node_code
				,current_node_name      -- 节点code和名称					
				,case when current_node_status=3 THEN '结束'			
					  when current_node_status=2 THEN '异常'			
					  when current_node_status=1 THEN '开始'			
					  else 'X' end	n45_current_node_status		
                ,CONVERT(VARCHAR(19), CAST(update_date_time AS DATETIME), 120) update_date_time				  
				,row_number()over(PARTITION by order_num ,order_line_num ,plan_item_num order by update_date_time desc  ) rn
		  FROM  ODS_LPS.dbo.t_logistical_task_pur_migo		
		 WHERE task_status!=3 		
	)a
where rn = 1;

-------------------------------------------------------

  SELECT
		  ORDER_NUM
		 ,ORDER_ITEM_NUM
		 ,DELIVERY_ITEM_NUM
		 ,max(UPDATED_TS) CREATED_TS
	into #plan_date
	FROM ODS_SRM.dbo.srm_poc_delivery_plan 
   where DELETE_FLAG =0
     and AUDIT_FLAG = 1
   group by ORDER_NUM
		,ORDER_ITEM_NUM
		,DELIVERY_ITEM_NUM;
		
-------------------------------------------------------



 insert into report0624.dbo.r24_consolidate_table_all
         select
				 a.require_no
				,a.require_line
				,a.wbs_code
				,a.wbs_desc
				,a.wbs_category_code
				,a.wbs_category_desc
				,a.order_type_code
				,a.purchase_group_code
				,a.purchase_group_desc
				,a.purchase_group_code_desc
				,a.material_code
				,a.material_desc
				,a.figure_no
				,a.purchase_type_code
				,a.is_manuf
				,a.is_purchase
				,a.is_other
				,a.require_quantity
				,a.delivery_quantity
				,a.assemble_order_code
				,a.parent_material_code
				,a.zp_ltxt
				,a.sort_string
				,a.delivery_date
				,a.prod_order_supply_quantity
				,a.prod_order_no
				,a.prod_order_delivery_date
				,a.prod_order_current_point
				,a.[prod_order_current_key_dept_desc ]
				,a.purchase_order_supply_quantity
				,a.purchase_order_no
				,a.purchase_order_line
				,a.purchase_order_no_line
				,a.purchase_order_no_line_h
				,a.purchase_order_deliery_date
				,a.purchase_order_current_point
				,a.purchase_order_vendor_desc
				,a.insp_supply_quantity
				,a.insp_no
				,a.insp_purc_order_no
				,a.insp_purc_order_line
				,a.insp_current_point
				,a.insp_vendor_desc
				,a.purchase_request_supply_quantity
				,a.purchase_request_no
				,a.purchase_request_delievery_date
				,a.stock_supply_quantity
				,a.stock_supply_flag
				,a.other_supply_quantity
				,a.stock_quantity
				,a.update_date
				,a.purchase_order_order_priority
				,a.inv_quantity_1005
				,a.zd_code
				,a.commit_purchase_order_deliery_date
				,a.order_sync_date
				,a.receive_status
				,a.insp_status
				,a.insp_receive_status
				,a.insp_insp_status
			    ,b.note
			    ,cast(insp_purc_order_no as varchar) + '/' + cast(insp_purc_order_line as varchar) as 对应采购订单_行号
			    ,c.inquiry_status 
			    ,d.node_status
			    ,a.qty
				,a.project_qty  -- 项目库存
			    ,f.supply_no   as 计划协议号
			    ,f.supply_line as 计划行号
			    ,g.MATNR
				,g.RSNUM
				,g.RSPOS
				,g.MNG01
				,g.DELNR
				,g.DELPS
				,g.DELET
				,g.EINDT
			    ,g.STOCK_QTY
			    ,h.ebeln
				,h.ebelp
				,h.etenr
				,h.fixkz
			    ,k.SORTL as NAME1
				,m.current_node_name         -- 物流节点
				,m.update_date_time          -- 当前节点时间
				,x.current_node_name as n45_current_node_status  -- 物流状态
				,x.update_date_time  as n45_update_date_time     -- 当前节点时间
				,p.CREATED_TS               -- 计划协议交货行同步时间
				,a.NAME1 AS FD_NAME
		   from  Report0624.dbo.r24_temp_base_all a
	  left join report0624.dbo.r24_temp_note b
			 on a.require_line = b.require_line
			and a.require_no   = b.require_no
	  left join report0624.dbo.r24_inquiry_status c
			 on a.material_code = c.material_code
	  left join #node_status_info d
			 on a.purchase_order_no   = d.order_num 
			and a.purchase_order_line = d.order_item_num
	  left join #supply_no_5 f
             on a.require_no   = f.require_no
			and a.require_line = f.require_line
	  left join #delnr_55 g
			 on a.require_no   = g.rsnum
			and a.require_line = g.rspos 
	  left join #logistics__status m
	         on m.order_num      =  g.DELNR
            and m.order_line_num =  SUBSTRING(g.DELPS, 2, LEN(g.DELPS))
	        and m.plan_item_num =CAST(CAST( g.DELET  AS INT) AS VARCHAR(50)) 
	  left join #sap_lp h 
			 on h.ebeln = g.delnr
			and h.ebelp = stuff(ltrim(g.delps), 1, 1, '')
			and h.etenr = g.delet
	  left join ods_hana.dbo.ekko j
			 on j.ebeln = h.ebeln
	  left join ods_hana.dbo.lfa1 k
			 on j.lifnr = k.lifnr
	  left join #plan_date p
	         on p.ORDER_NUM         = g.DELNR
			and p.ORDER_ITEM_NUM    = CAST(CAST(g.DELPS AS INT) AS NVARCHAR)
			and p.DELIVERY_ITEM_NUM  = CAST(CAST(g.DELET AS INT) AS NVARCHAR)
	 left join #logistics__status x
	         on a.purchase_order_no_line    =  x.order_num
            and CAST(CAST(a.purchase_order_no_line_h  AS INT) AS NVARCHAR)   = CAST(CAST(x.order_line_num AS INT) AS NVARCHAR)  
			and x.order_num like '45%'

			