

select 
		part_code              -- '物料代码'            
		,part_name             -- '物料技术名称'           
		,model_specifications  --'物料技术型号（规格）' 
		,unit_code             --'技术单位'              
		,alien_code            --'外来代码'        
		,order_no              --'订货号'           
		,manufacturer          --'技术要求品牌(制造商)'          
		,standard_no           --'标准号'           
		,supplier              -- '供应商'          
		,item_classification_code  -- '项目分类'
		,description           -- 'description'
        ,'' Windchill_samlple  --  '样本（即时要求低的从数据中台抽）'		
from DWD_WINDCHILL.dbo.dws_pdm_part_info a 



     select 
            a.MATNR    as part_code -- 物料code
           ,a.MAKTX    as part_name -- 物料计划名称
           ,''         as makt      -- 物料计划描述（长文本）
           ,'2000'     as makt      -- makt
           ,c.EKGRP    as purchase_group_code      -- 采购组
           ,d.EKNAM    as purchase_group_desc      --'采购组描述'
            ,c.MAABC   as purchase_importance_tpye --'采购重要度分类'
            ,c.PLIFZ   as purchase_cycle           --'计划周期（天）'
			,material_desc  as material_desc
			,plant_code     as plant_code
			,stock_quantity as stock_quantity
           ,b.sap_unit as sap_unit                 --'计划单位'
           ,''         as sap_price
      from ODS_HANA.dbo.MAKT a
 left join (select DISTINCT
				   MEINS as sap_unit
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
			  SELECT material_code
					,material_desc
					,plant_code
					,stock_quantity
  FROM Report0624.dbo.r24_stock_detail
  where plant_code = 2000

             ) e
           on a.MATNR = e.material_code
		    where c.EKGRP in ('201','211','214','215','204','205')





 select 
                         a.item_cd
						,a.supplier_cd     -- '采购供应商代码'
						,a.supplier_name   -- '采购供应商'
						,a.examine_price    -- '采购单价'
						,a.valid_end_date  -- '价格有效期'
						,b.actual_purchase_name -- '采购方式（招标、单一来源等）'
                        ,b.inquiry_cd          -- '招标文件编号

			from (
					select 
					    item_cd
						,supplier_cd     -- '采购供应商代码'
						,supplier_name   -- '采购供应商'
						,examine_price    -- '采购单价'
						,valid_end_date  -- '价格有效期'
						,form_num
					from (
							  select 
									item_cd
									,supplier_cd     -- '采购供应商代码'
									,supplier_name   -- '采购供应商'
									,examine_price    -- '采购单价'
									,valid_end_date  -- '价格有效期'
									,form_num
							        ,ROW_NUMBER()over(PARTITION by item_cd ORDER by examine_price ) rn 
							from ODS_SRM.dbo.srm_price_item a
							where DELETEd=0 
							and PUrchaser_cd=2000 
						    and  len(item_cd)>1
					) a where rn = 1
			) a 
left join ODS_SRM.dbo.srm_inq_supplier_confirm_head_field b 
      on a.form_num  = b.CONFIRM_NUM 
      and b.DELETED = 0





