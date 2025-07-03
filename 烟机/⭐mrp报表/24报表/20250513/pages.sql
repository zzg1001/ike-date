SELECT 
			top 100
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
				,a.note
				,a.对应采购订单_行号
				,a.inquiry_status
				,a.node_status
				,a.qty
				,a.计划协议号
				,a.计划行号
				,a.MATNR
				,a.RSNUM
				,a.RSPOS
				,a.MNG01
				,a.DELNR
				,a.DELPS
				,a.DELET
				,a.EINDT
				,a.ebeln
				,a.ebelp
				,a.etenr
				,a.fixkz
				,a.NAME1
				,a.current_node_name
				,a.update_date_time
				,a.n45_current_node_status
				,a.n45_update_date_time
				,n.order_num
				,n.order_line_num
				,n.plan_item_num
				,n.current_node_code
				,n.current_node_name
				,n.current_node_status
				,n.update_date_time
				,n.task_status
				,n.task_num
				,n.tenant
				,a.n45_update_date_time
				,a.n45_current_node_status
				,n45.current_node_name as n45_current_node_name
		FROM  report0624.dbo.r24_consolidate_table_ar a
   LEFT JOIN ODS_LPS.dbo.lps_node n
          on a.ebeln = n.order_num
         and a.EBELP = n.order_line_num
         and n.plan_item_num = 1
   LEFT JOIN ODS_LPS.dbo.lps_node n45
          on a.purchase_order_no = n45.order_num
         and a.purchase_order_line= n45.order_line_num
where
stock_supply_flag = '${stock_supply_tag}'

${if(len(需求日期_起始)==0,'',"and a.delivery_date>=  '"+$需求日期_起始+"'")}
${if(len(需求日期_结束)==0,'',"and a.delivery_date<=  '"+$需求日期_结束+"'")}
${if(len(zp类型)==0,'',"and a.order_type_code=  '"+$zp类型+"'")}
${if(len(wbs分类)==0,'',"and a.wbs_category_desc=  '"+$wbs分类+"'")}
--${if(len(采购组)==0,'',"and purchase_group_code_desc=  '"+$采购组+"'")}
${if(len(采购组)==0,'',"and a.purchase_group_code_desc in ('"+$采购组+"')")}
----------
${if(len(采购组编码)==0,'',"and a.purchase_group_code in ('"+$采购组编码+"')")}
----------
${if(len(父项物料编码)==0,'',"and a.parent_material_code like  '%"+$父项物料编码+"%'")}
${if(len(子项物料编码)==0,'',"and a.material_code like  '%"+$子项物料编码+"%'")}
${if(len(wbs)==0,'',"and a.wbs_code = '"+$wbs+"'")}

${if(len(wbs_模糊)==0,'',"and a.wbs_code like  '%"+$wbs_模糊+"%'")}

${if(len(排序字符串)==0,'',"and a.sort_string like  '%"+$排序字符串+"%'")}
${if(len(装配订单号)==0,'',"and a.assemble_order_code like  '%"+$装配订单号+"%'")}
${if(len(自制tag)==0,'',"and a.is_manuf =  "+$自制tag+"")}
${if(len(外协tag)==0,'',"and a.is_purchase =  "+$外协tag+"")}
${if(len(其他tag)==0,'',"and a.is_other =  "+$其他tag+"")}
${if(len(未发订单tag)==0,'',"and purchase_request_no is not null")}
order by a.wbs_code, a.material_code