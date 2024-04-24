select 
      MATNR  as part_code
      ,MAKTX as part_name 
 from ODS_HANA.dbo.MAKT
 
 
 select 
      MEINS as '计划单位'
     ,MATNR as part_code -- 物料代码
 from ODS_HANA.dbo.MARA
 
 
 select 
     EKGRP as '采购组'        -- 采购组
     ,MAABC as '采购重要度分类'
     ,PLIFZ as '计划周期（天）'
     ,MATNR as part_code -- 物料代码
 from ODS_HANA.dbo.MARC
 
 
  select 
      EKNAM as '采购组描述'
      EKGRP as '采购组'
 from ODS_HANA.dbo.T024