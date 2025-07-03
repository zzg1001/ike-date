SELECT 
    a.*,
    a.ebeln,
	EKET.EINDT
	,n.*
	,n45.update_date_time as n45_update_date_time
	,n45.current_node_status as n45_current_node_status
	,n45.current_node_name as n45_current_node_name
FROM 
    Report0624.dbo.r24_consolidate_table a

	
LEFT JOIN [ODS_HANA].[dbo].[EKET]
on a.EBELN = eket.EBELN
and a.EBELP = eket.EBELP
and a.DELET = EKET.ETENR


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