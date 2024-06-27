      
TRUNCATE table Purchase_Dashboard.dbo.base_outsourced_risk_price ;
INSERT INTO Purchase_Dashboard.dbo.base_outsourced_risk_price 

select 
a.part_code
,a.part_name
,m.ltext makt
,plant
,purchase_group_code
,purchase_group_desc
,purchase_importance_type
,purchase_cycle
,material_desc
,plant_code
,stock_quantity
,sap_unit
,sap_price
,b.windchill_part_name
,model_specifications
,source
,unit_code
,alien_code
,order_no
,manufacturer
,standard_no
,supplier
,status_indication
,item_classification_code
,description
,Windchill_sample
,supplier_cd
,supplier_name
,examine_price
,valid_end_date
,actual_purchase_name
,inquiry_cd
from (
				     select 
				     
							CASE 
								        WHEN PATINDEX('%[^0]%', a.MATNR  ) > 0 
								        THEN SUBSTRING(a.MATNR  , PATINDEX('%[^0]%', a.MATNR  ), LEN(a.MATNR  ))
								        ELSE  a.MATNR
						  END AS part_code
				           ,a.MAKTX    as part_name -- 物料计划名称
				           ,''         as makt      -- 物料计划描述（长文本）
				           ,'2000'     as plant      -- makt
				           ,c.EKGRP    as purchase_group_code      -- 采购组
				           ,d.EKNAM    as purchase_group_desc      --'采购组描述'
				            ,c.MAABC   as purchase_importance_type --'采购重要度分类'
				            ,c.PLIFZ   as purchase_cycle           --'计划周期（天）'
							,material_desc  as material_desc
							,plant_code     as plant_code
							,stock_quantity as stock_quantity
				           ,b.sap_unit      as sap_unit                 --'计划单位'
				           ,bb.sap_price    as sap_price
				      from ODS_HANA.dbo.MAKT a
				 left join (select DISTINCT
								   MEINS as sap_unit
								  ,MATNR as part_code -- 物料代码
						     from ODS_HANA.dbo.MARA
				           ) b
				        on a.MATNR = b.part_code
				  left join (
				      select 
						    CASE  WHEN MATNR LIKE '%.%' THEN REPLACE(MATNR, '\.[0-9]+$', '' ) ELSE MATNR end part_code
						    ,lplpr  sap_price
						    from ODS_HANA.dbo.MBEW where bwkey =2000
				         ) bb 
				        on a.MATNR = bb.part_code
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
           )a 


left join (

	           select   CASE
						    WHEN part_code LIKE '%sh' OR part_code LIKE '%SH' 
						    THEN SUBSTRING(part_code, 1, LEN(part_code) - 2)
						    ELSE part_code
						  END AS part_code
						,windchill_part_name   -- '物料技术名称'           
						,model_specifications  --'物料技术型号（规格）' 
						,unit_code             --'技术单位'              
						,alien_code            --'外来代码'        
						,order_no              --'订货号'           
						,manufacturer          --'技术要求品牌(制造商)'          
						,standard_no           --'标准号'           
						,supplier              -- '供应商' 
						,source                -- '来源'   
						,status_indication     -- '状态标识'      
						,item_classification_code  -- '项目分类'
						,description           -- 'description'
				             ,'' Windchill_sample  --  '样本（即时要求低的从数据中台抽）'

	               from (
							select 
									CASE 
													WHEN PATINDEX('%[^0]%', part_code  ) > 0 
													THEN SUBSTRING(part_code  , PATINDEX('%[^0]%', part_code  ), LEN(part_code ))
													ELSE  part_code
									END AS part_code
									,part_name windchill_part_name  -- '物料技术名称'           
									,model_specifications  --'物料技术型号（规格）' 
									,unit_code             --'技术单位'              
									,alien_code            --'外来代码'        
									,order_no              --'订货号'           
									,manufacturer          --'技术要求品牌(制造商)'          
									,standard_no           --'标准号'           
									,supplier              -- '供应商' 
									,source                -- '来源'   
									,status_indication     -- '状态标识'      
									,item_classification_code  -- '项目分类'
									,description           -- 'description'
									,'' Windchill_sample  --  '样本（即时要求低的从数据中台抽）'		
							from DWD_WINDCHILL.dbo.dws_pdm_part_info where is_new = 1
							)a
                        ) b
       on a.part_code = b.part_code
left join  [ODS_HANA].[dbo].[LTXT_purchase] m 
       on a.part_code = m.matnr
left join (

			
			                 select 
			                         CASE 
								        WHEN PATINDEX('%[^0]%', item_cd  ) > 0 
								        THEN SUBSTRING(item_cd  , PATINDEX('%[^0]%', item_cd  ), LEN(item_cd ))
								        ELSE  item_cd
						             END AS part_code    
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
      ) c
      on  a.part_code = c.part_code