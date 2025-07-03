truncate table Report_Mrp.dbo.mrp_consolidate_table 


------------------老逻辑-------------------------------------
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_consolidate_table_all_node_status;
INSERT INTO Report_Mrp.dbo.tmp_mrp_consolidate_table_all_node_status
   select  a.order_num
	      ,a.order_item_num
	      ,b.node_status
	 from [ods_srm].[dbo].[srm_poc_order_item] as a,
	      [ods_srm].[dbo].[srm_poc_order_item_extra] as b
    where a.id = b.order_item_id 
	  and b.node_status is not null
    group by a.order_num
            ,a.order_item_num
            ,b.node_status;
--------------------老逻辑-----------------------------------
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_consolidate_table_all_5;
INSERT INTO Report_Mrp.dbo.tmp_mrp_consolidate_table_all_5
	 select
			a.DELNR2  as supply_no
		   ,a.DELPS2  as supply_line
		   ,a.DELNR1  as require_no                 -- 预留号                
		   ,a.DELPS1  as require_line               -- 预留号行号      
	   from ODS_HANA.dbo.mrp_ww  a
	where  a.DELKZ2  like '5%';
		

-------------------------------------------------------


 insert into Report_Mrp.dbo.mrp_consolidate_table         
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
			    ,a.inquiry_status 
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
			    ,g.ebeln
				,g.ebelp
				,g.etenr
				,g.fixkz
			    ,g.SORTL as NAME1
				,g.current_node_name         -- 物流节点
				,g.update_date_time          -- 当前节点时间
				,a.n45_current_node_status  -- 物流状态
				,a.n45_update_date_time     -- 当前节点时间
				,g.CREATED_TS               -- 计划协议交货行同步时间
				,a.NAME1 AS FD_NAME
				,a.rep_type
				,GETDATE()  etl_time
		   from Report_Mrp.dbo.mrp_temp_base a
	  left join report0624.dbo.r24_temp_note b
			 on a.require_line = b.require_line
			and a.require_no   = b.require_no
	  left join Report_Mrp.dbo.tmp_mrp_consolidate_table_all_node_status d
			 on a.purchase_order_no   = d.order_num 
			and a.purchase_order_line = d.order_item_num
	  left join Report_Mrp.dbo.tmp_mrp_consolidate_table_all_5 f
             on a.require_no   = f.require_no
			and a.require_line = f.require_line
	  left join Report_Mrp.dbo.mrp_plan_protocol_order_detail g
			 on a.require_no   = g.rsnum
			and a.require_line = g.rspos
			and g.rep_type = a.rep_type; 


			