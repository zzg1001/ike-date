  select 
            a.MATNR    as part_code -- 物料code
           ,a.MAKTX    as part_name -- 物料计划名称
           ,''         as makt      -- 物料计划描述（长文本）
           ,'2000'     as plant_code -- makt
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
           