select 
		part_code     '物料代码'            
		,part_name    '物料技术名称'           
		,model_specifications   '物料技术型号（规格）' 
		,unit_code    '技术单位'              
		,alien_code   '外来代码'        
		,order_no     '订货号'           
		,manufacturer '技术要求品牌(制造商)'          
		,standard_no  '标准号'           
		,supplier     '供应商'          
		,item_classification_code  '项目分类'
		,description  'description'
        ,''           '样本（即时要求低的从数据中台抽）'		
from DWD_WINDCHILL.dbo.dws_pdm_part_info a 



select 
supplier_cd      '采购供应商代码'
,supplier_name   '采购供应商'
,examine_price   '采购单价'
,valid_end_date  '价格有效期'
,form_num
from ODS_SRM.dbo.srm_price_item

select 
actual_purchase_name '采购方式（招标、单一来源等）'
,inquiry_cd          '招标文件编号'
from ODS_SRM.dbo.srm_inq_supplier_confirm_head_field





select 
            a.MATNR   as part_code -- 物料code
           ,a.MAKTX   as part_name -- 物料计划名称
           ,''        as makt      -- 物料计划描述（长文本）
           ,'2000'    as plant     -- plant
           ,c.EKGRP   as '采购组'   -- 采购组
           ,b.计划单位  as '计划单位'
           ,d.EKNAM   as '采购组描述'
           ,c.MAABC   as '采购重要度分类'
           ,c.PLIFZ   as '计划周期（天）'
      from ODS_HANA.dbo.MAKT a
 left join (select DISTINCT
				   MEINS as '计划单位'
				  ,MATNR as part_code -- 物料代码
		     from ODS_HANA.dbo.MARA
           ) b
        on a.MATNR = b.part_code
 left join ODS_HANA.dbo.MARC c 
        on a.MATNR = c.MATNR
       and c.WERKS=2000
 left join ODS_HANA.dbo.T024 d 
        on c.EKGRP = d.EKGRP
 left join (
			    SELECT 
                             distinct 
			          a.material_code,
			          a.stock_quantity,
			        --  a.stock_supply_quantity,
			          a.inv_quantity_1005
			       --   new.qty 
			     FROM Report0624.dbo.r24_temp_base AS a
			LEFT JOIN Report0624.dbo.r24_temp_note AS b
			       ON a.require_line = b.require_line
			      AND a.require_no = b.require_no
			LEFT JOIN Report0624.dbo.r24_inquiry_status AS c
			       ON a.material_code = c.material_code
			LEFT JOIN (
						    SELECT a.ORDER_NUM, a.ORDER_ITEM_NUM, b.NODE_STATUS
						     FROM ODS_SRM.dbo.srm_poc_order_item AS a
						     JOIN ODS_SRM.dbo.srm_poc_order_item_extra AS b
						       ON a.ID = b.ORDER_ITEM_ID 
						    WHERE b.NODE_STATUS IS NOT NULL
						 GROUP BY a.ORDER_NUM, a.ORDER_ITEM_NUM, b.NODE_STATUS
			          ) AS d
			       ON a.purchase_order_no = d.ORDER_NUM 
			      AND a.purchase_order_line = d.ORDER_ITEM_NUM
			LEFT JOIN (
					    SELECT * 
					    FROM Report0624.dbo.r24_1050_1051 
					    WHERE r24_1050_1051.midlgort = 1050
			          ) AS new
			       ON new.rsnum = a.require_no
			      AND new.rspos = a.require_line
             ) e
           on a.MATNR = e.material_code
