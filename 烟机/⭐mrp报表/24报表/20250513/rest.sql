
           SELECT 
					a.order_no
					,a.KUNNR
					,b.NAME1
			from ( 
				  SELECT  
						VBELN  as order_no
						,KUNNR as KUNNR
					from ODS_HANA.dbo.VBAK
					union all 
					
					SELECT  
						VBELN  as order_no
						,KUNAG as KUNNR
					from ODS_HANA.dbo.LIKP
			      ) a
         left join (
                  select KUNNR
                        ,NAME1 
                    from ODS_HANA.dbo.KNA1
                    ) b 
                on a.KUNNR = b.KUNNR
          
		
		
		
		SELECT 
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
				,MNG01
				,a.DELNR
				,a.DELPS
				,a.DELET
			    ,a.ebeln
				,a.ebelp
				,a.etenr
				,a.fixkz
			    ,a.NAME1
				,a.current_node_name        -- 物流节点
				,a.update_date_time         -- 当前节点时间
			    ,b.EINDT
			    ,n.order_num
			    ,n.order_line_num
			    ,n.plan_item_num
			    ,n.current_node_code
			    ,n.current_node_status
			    ,n.task_status
			    ,n.task_num
			    ,n.tenant
			    ,a.n45_current_node_status  -- 物流状态
			    ,a.n45_update_date_time     -- 当前节点时间
			    ,n45.current_node_name as n45_current_node_name
		   into #result_index
		   FROM Report0624.dbo.r24_consolidate_table a
	  LEFT JOIN [ODS_HANA].[dbo].[EKET] b
			 on a.EBELN = b.EBELN
			and a.EBELP = b.EBELP
			and a.DELET = b.ETENR
	  LEFT JOIN ODS_LPS.dbo.lps_node n
			 on a.ebeln = n.order_num
			and a.EBELP = n.order_line_num
			and n.plan_item_num = 1
	  LEFT JOIN ODS_LPS.dbo.lps_node n45
	         on a.purchase_order_no = n45.order_num
	        and a.purchase_order_line= n45.order_line_num;
			
			
			
			