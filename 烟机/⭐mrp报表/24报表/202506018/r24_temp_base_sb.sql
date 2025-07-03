
truncate table Report0624.dbo.r24_temp_base_sb;


-----------------------未下达订单：全量订单&订单的物料信息----------------------
select 
	  require_no           -- 预留号                
	 ,require_line         -- 预留号行号  
	 ,assemble_order_no    -- 装配订单号
	 ,req_material_code    -- 物料编码
	 ,require_quantity     -- 缺口数量
	 ,parent_material_code -- 父项物料编码
	 ,replace(ltrim(replace(a.req_material_code, '0', ' ')), ' ', '0') as material_code --物料编码
	 ,wbs_code
	 ,delivery_date
into #require_main
from (
	  select  DELNR1 as require_no                    
			 ,DELPS1 as require_line        
			 ,DEL121 as assemble_order_no  
			 ,MATNR  as req_material_code  
			 ,MNG011 as require_quantity   
	         ,BAUGR1 as parent_material_code
			 ,PSPNR  as wbs_code
			 ,DAT001 as delivery_date
		from ODS_HANA.dbo.mrp_ww
		   where DELKZ1='SB'
			 and MNG011 > 0
	   group by DELNR1               
			  ,DELPS1   
			  ,DEL121 
			  ,MATNR  
			  ,MNG011
			  ,BAUGR1
			  ,PSPNR
			  ,DAT001

	 )a;
-----------------------售达方-----------------------

             SELECT 
					a.order_no
					,a.KUNNR
					,b.NAME1
			into #order_name
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
----------------------------------------------
      
	  select
			 a.assemble_order_no
			,a.plant_code
			,a.order_type_code
			,a.order_type_desc
			,a.wbs_code
			,a.wbs_desc
			,a.material_code
			,a.material_desc
			,a.order_quantity
			,a.schedule_date
			,a.release_date
			,a.delivery_date
			,a.delivery_quantity
			,a.zp_ltxt
			,b.wbs_category_code
			,b.wbs_category_desc
	 into #wbs_info
	 from Report0624.dbo.r24_assemble_order_detail a
left join YJ_DIM.dbo.dim_wbs b
	 on a.wbs_code = b.wbs_code
    and b.last_version = 1;
      
----------------------------------------------

 select DELNR1 as require_no         -- 预留号                
	   ,DELPS1 as require_line       -- 预留号行号  
	   ,MNG012 as supply_quantity
 into #supply_wb
 from ODS_HANA.dbo.mrp_ww a
where DELKZ1='SB' 
  and DELKZ2 = 'WB'
  and MNG012 > 0;

----------------------计划订单------------------------

	select DELNR1   as require_no         -- 预留号                
		  ,DELPS1   as require_line       -- 预留号行号  
		  ,MNG012   as supply_quantity
		  ,DELNR2   as supply_no
		  ,b.purchase_order_no
		  ,b.purchase_order_line
		  -- ,b.schedule_date
		  ,a.DAT002 as schedule_date      -- 交货期
		  --  ,b.purchase_order_no + '/' + b.purchase_order_line as purchase_order_NoLine
		  ,a.DELNR2 as purchase_order_NoLine
		  ,a.DELPS2 as purchase_order_NoLine_h
		  ,b.current_point
		  ,b.vendor_desc
		  ,b.order_priority
		  ,case when current_point = 'gr'       then '收货'
                when current_point = 'NA'       then '待下达'
                when current_point = 'painting' then '油漆'
                when current_point = 'migo'     then '入库'
                when current_point = 'qx'       then '质检'
		        when current_point = 'srm'      then '在途'
            end as purchase_order_current_point   --当前指针
	 into #supply_be  -- #c
	 from ODS_HANA.dbo.mrp_ww a
left join Report0624.dbo.r24_purchase_order_detail as b
       on a.DELNR2 = b.purchase_order_no
      and a.DELPS2 = '0' + b.purchase_order_line
    where a.DELKZ1 ='SB' 
      and a.DELKZ2 = 'BE' --计划订单
      and a.MNG012 > 0;

----------------------------------------------

   select  a.DELNR1    as require_no         -- 预留号                
		  ,a.DELPS1    as require_line       -- 预留号行号  
		  ,a.DELNR2    as supply_no
	   -- ,b.schedule_date
		  ,a.DAT002    as schedule_date
		  ,a.MNG012    as supply_quantity
		  ,b.current_process_no
		  ,b.current_process_desc
		  ,b.current_key_dept_desc
		  ,b.current_process_no + '/' + b.current_process_desc + '/' + b.current_key_dept_desc as prod_order_current_point --当前节点
	into #supply_fe  -- #d
	from ODS_HANA.dbo.mrp_ww a
left join Report0624.dbo.r24_prod_order_detail as b
	  on a.DELNR2 = prod_order_no
   where a.DELKZ1 = 'SB' 
	 and a.DELKZ2 = 'FE';

----------------------------------------------

select a.DELNR1    as require_no         -- 预留号                
	  ,a.DELPS1    as require_line       -- 预留号行号  
	  ,a.MNG012    as supply_quantity
	  ,a.DELNR2    as supply_no
	  ,a.DAT002    as supply_date
 into #supply_ba  -- #e
 from ODS_HANA.dbo.mrp_ww a
where a.DELKZ1 = 'SB'
  and a.DELKZ2 = 'BA'
  and a.MNG012 > 0;

----------------------------------------------

	select a.DELNR1    as require_no         -- 预留号                
		  ,a.DELPS1    as require_line       -- 预留号行号  
		  ,a.MNG012    as supply_quantity
		  ,a.DELNR2    as supply_no
		  ,b.purchase_order_no
		  ,b.vendor_desc
		  ,b.purchase_order_line
		  ,b.insp_status
	  into #supply_qm  -- #f
	  from ODS_HANA.dbo.mrp_ww a
 left join Report0624.dbo.r24_insp_lot_detail b
		on a.DELNR2 = b.insp_no
	 where a.DELKZ1 = 'SB' 
	   and a.DELKZ2 = 'QM'
	   and a.MNG012 >  0;

----------------------------------------------

select  a.DELNR1      as require_no         -- 预留号                
	   ,a.DELPS1      as require_line       -- 预留号行号  
	   ,sum(a.MNG012) as supply_quantity    -- 匹配数量
  into #supply_quantity_sum
  from ODS_HANA.dbo.mrp_ww a
 where a.DELKZ1 = 'SB'  
   and a.DELKZ2 in ('PB', 'PA')
   and a.MNG012 > 0
 group by a.DELNR1
         ,a.DELPS1;

----------------------------------------------

   select  a.require_no
		  ,a.require_line
		  ,a.plant_code
		  ,a.assemble_order_no
		  ,a.req_material_code
		  ,a.req_material_desc
		  ,a.unit
		  ,a.purchase_group_code
		  ,a.purchase_group_desc
		  ,a.require_date
		  ,a.require_quantity
		  ,a.delivery_quantity
		  ,a.is_delivery
		  ,a.sort_string
		  ,a.purchase_group_code + '/' + a.purchase_group_desc as purchase_group_code_desc
	into #require
	from Report0624.dbo.r24_assemble_require_detail a
   where a.require_quantity > 0;

----------------------------------------------


  select 
          material_code
		,sum(inv_quantity) inv_quantity
		,sum(qty)   qty
		,sum(total) total_qty
		 INTO #inv_qty
	from( 
		 SELECT MATNR as material_code
			   ,SUM(case when LGORT = '1005' then CLABS else 0 end ) as inv_quantity
			   ,SUM(case when LGORT = '1050' then CLABS else 0 end ) as qty
			   ,sum(CLABS) total
		   FROM ODS_HANA.dbo.MCHB
		  WHERE WERKS = '2000' 
		  GROUP BY MATNR
		  
		union all 
		
		 select 
			   MATNR as material_code
			  ,sum(case when LGORT = '1005' then SLABS else 0 end) as inv_quantity
			  ,sum(case when LGORT = '1050' then SLABS else 0 end) as qty
			  ,sum(SLABS) total
		  from ODS_HANA.dbo.MKOL a
		  WHERE  WERKS = '2000' 
		  GROUP BY MATNR
		 ) a
   GROUP by material_code;
----------------------------------------------	   
	   
  select 
		  MATNR as material_code 
		 ,sum(PRLAB) project_qty
	 into #project_qty -- #p
	 from ODS_HANA.dbo.MSPR 
	WHERE WERKS = '2000' 
	GROUP by MATNR;


----------------------------------------------

select OBJEK  as material_code
      ,MAX(case when ATINN = '0000000008' then ATWRT else null end)  as figure_no
	  ,MAX(case when ATINN = '0000000009' then ATWRT else null end)  as zd_code
 INTO #zd_material
 FROM ODS_HANA.dbo.AUSP
WHERE KLART = '001' and ATINN in ('0000000009','0000000008')
group by OBJEK 

----------------------------------------------

select SUPPLIER_DATE
	   ,ORDER_NUM
	   ,ORDER_ITEM_NUM as ORDER_ITEM_NUM
  into #commit_supple_date
  from ODS_SRM.dbo.srm_poc_order_item
 where SUPPLIER_DATE is not null;
			 
----------------------------------------------

 select  A.ORDER_NUM  as order_code
		--,right('00000' + ltrim(ORDER_ITEM_NUM), 5) as order_item
		,ORDER_ITEM_NUM as order_item
		,A.UPDATED_TS as order_sync_date
		,case C.STATUS
		   when 'NOT_PRICE_APPRAISAL' then '待审价'
		   when 'PENDING_DELIVERY' then '待交货'
		   when 'PENDING_GR' then '待收货'
		   when 'PARTIAL_GR' then '部分收货'
		   when 'GR_COMPLETED' then '已收货'
		   when 'PR_CANCELLED' then '购方取消'
		   end      as receive_status
		,case C.QC_STATUS
		   when 'PARTIAL_PAINTING' then '部分油漆'
		   when 'PO_OUT' then '外检完成'
		   when 'PAINTING' then '油漆'
		   when 'IN_QC' then '在检'
		   when 'PARTIAL_INBOUND' then '部分入库'
		   when 'INBOUND' then '入库'
		   when 'NO_INSP' then '免检'
		   when 'NOT_QC' then '待质检'
		   when 'PARTIAL_QC' then '部分在检'
		   when 'PARTIAL_QC_DONE' then '部分质检完成'
		   when 'ALL_QC' then '质检完成'
		   end    as insp_status
	into #order_status
	from ODS_SRM.dbo.srm_poc_order_hd A
	join ODS_SRM.dbo.srm_poc_order_item B on A.ID = B.ORDER_ID
	join ODS_SRM.dbo.srm_poc_order_item_extra C on B.ID = C.ORDER_ITEM_ID
   where A.DELETE_FLAG = 0
	 and B.DELETE_FLAG = 0
	 and A.REF_PURCHASER_CD = '2000';
				 
----------------------------------------------			 
				 
 select  a.material_code
		,a.material_desc --物料名称
		,a.purchase_type_code 
		,case when purchase_type_code='E'
			  then 1 else 0 end as is_manuf   --自制
		,case when purchase_type_code='F'
			  then 1 else 0 end as is_purchase--外协
		,case when (purchase_type_code!='F') AND (purchase_type_code!='E')
			  then 1 else 0 end as is_other   --其他
   into #material_main
   from Report0624.dbo.material_info a;
   
----------------------------------------------   
  select 
        COALESCE(SUBSTRING(A.POSID,1,1), 'NA')+ '-' + COALESCE(RTRIM(LTRIM(SUBSTRING(A.POSID,2,50))), 'NA') as POSKI 
       ,PSPNR
	into #wbs_detail_info 
    from ODS_HANA.dbo.PRPS A;
	
				   			   
----------------------------------------------
         insert into Report0624.dbo.r24_temp_base_sb
          select
                  a.require_no                                                       as require_no                       -- 预留号
                 ,a.require_line                                                     as require_line                     -- 预留号行号
                 ,y.POSKI                                                            as wbs_code                         -- 替换 n.wbs_code WBS
                 ,n.wbs_desc                                                         as wbs_desc                         -- WBS描述  
                 ,n.wbs_category_code                                                as wbs_category_code
                 ,n.wbs_category_desc                                                as wbs_category_desc
                 ,n.order_type_code                                                  as order_type_code
                 ,h.purchase_group_code                                              as purchase_group_code
                 ,h.purchase_group_desc                                              as purchase_group_desc
                 ,h.purchase_group_code_desc                                         as purchase_group_code_desc
                 ,a.material_code                                                    as material_code                    -- 物料编码
                 ,m.material_desc                                                    as material_desc                    -- 物料名称
                 ,zd_material.figure_no                                              as figure_no                        -- 图号
                 ,m.purchase_type_code                                               as purchase_type_code               -- 类型
                 ,m.is_manuf                                                         as is_manuf                         -- 自制
                 ,m.is_purchase                                                      as is_purchase                      -- 外协
                 ,m.is_other                                                         as is_other                         -- 其他
                 ,a.require_quantity                                                 as require_quantity                 -- 需求数量
                 ,h.delivery_quantity                                                as delivery_quantity                -- 已发数量
                 ,a.assemble_order_no                                                as assemble_order_code              -- 装配订单号   -- 替换 h.assemble_order_no 
                 ,a.parent_material_code                                             as parent_material_code             -- 父项物料编码 -- 替换 n.material_code 
                 ,n.zp_ltxt                                                          as zp_ltxt                          -- 订单长文本
                 ,h.sort_string                                                      as sort_string                      -- 排序字符串
                 ,a.delivery_date                                                    as delivery_date                    -- 订单交货期    -- 替换 n.schedule_date 
                 ,d.supply_quantity                                                  as prod_order_supply_quantity       -- 生产订单匹配数-- FE_quantity
                 ,d.supply_no                                                        as prod_order_no                    -- 生产订单号    -- 替换 DELNR2
                 ,d.schedule_date                                                    as prod_order_delivery_date         -- 生产交货期
	             ,d.prod_order_current_point                                         as prod_order_current_point         -- 当前节点
                 ,d.current_key_dept_desc                                            as prod_order_current_key_dept_desc -- 管理部门
                 ,c.supply_quantity                                                  as purchase_order_supply_quantity   -- 采购订单匹配数-- BE_quantity
	             ,c.supply_no 														 as purchase_order_no                -- 采购订单号
	             ,c.purchase_order_line 											 as purchase_order_line              -- 采购订单行号
                 ,c.purchase_order_NoLine                                            as purchase_order_no_line           -- 采购订单号    -- 替换 DELNR2
				 ,c.purchase_order_NoLine_h                                          as purchase_order_no_line_h         -- 采购订单行    -- 新 替换 DELPS2
                 ,c.schedule_date                                                    as purchase_order_deliery_date      -- 采购交货期
                 ,c.purchase_order_current_point                                     as purchase_order_current_point     -- 当前指针
                 ,c.vendor_desc                                                      as purchase_order_vendor_desc       -- 供应商
                 ,f.supply_quantity                                                  as insp_supply_quantity             -- 检验批匹配数-- QM_quantity
                 ,f.supply_no                                                        as insp_no                          -- 检验批号
                 ,f.purchase_order_no                                                as insp_purc_order_no               -- 对应采购订单
	             ,f.purchase_order_line											     as insp_purc_order_line             --对应采供订单行
                 ,f.vendor_desc                                                      as insp_vendor_desc                 --加工方
	             ,f.insp_status													     as insp_current_point               --检验当前节点
                 ,e.supply_quantity                                                  as purchase_request_supply_quantity --采购申请匹配数-- BA_quantity
                 ,e.supply_no                                                        as purchase_request_no              --采购申请号
                 ,e.supply_date                                                      as purchase_request_delievery_date  --采购申请交货期
                 ,b.supply_quantity                                                  as stock_supply_quantity            --库存匹配数-- WB_quantity
                 ,case when a.require_quantity = b.supply_quantity then 1 else 0 end as stock_supply_flag                --stock_supply
                 ,g.supply_quantity                                                  as other_supply_quantity            --其他匹配数-- PA，PB_quantity
                 ,i.total_qty                                                        as stock_quantity                   --库存数
	             ,getdate()                                                          as update_date
	             ,c.order_priority 	                                                 as purchase_order_order_priority     -- 订单优先级
	             ,i.total_qty                                                        as total_qty                         -- sap库存
				 ,i.inv_quantity                                                     as inv_quantity_1005                 -- 1005库存
	             ,i.qty                                                              as qty                               -- 1050库存
				 ,p.project_qty                                                      as project_qty                       -- 项目库存
				 ,zd_material.zd_code                                                as zd_code
                 ,commit_date.SUPPLIER_DATE                                          as commit_purchase_order_deliery_date -- 替换 SUPPLIER_DATE 承诺交货期 
                 ,order_status.order_sync_date                                       as order_sync_date                    --采购订单：订单同步时间
                 ,order_status.receive_status                                        as receive_status                     --采购订单：收货状态
                 ,order_status.insp_status                                           as insp_status                        --采购订单：质检状态
                 ,insp_order_status.receive_status                                   as insp_receive_status                -- 检验批：收货状态
                 ,insp_order_status.insp_status                                      as insp_insp_status                   -- 检验批：质检状态
			     ,case when y.POSKI ='Z-2000_XSCB004' then '上海中臣烟草机械配件有限责任公司' else  z.NAME1 end NAME1   -- 售达方
			     ,GETDATE()  etl_time
			 from #require_main  a
        left join #wbs_info      n
               on a.assemble_order_no   = n.assemble_order_no
        left join #material_main m
               on a.req_material_code   = m.material_code
        left join #supply_wb     b          
               on a.require_no          = b.require_no
              and a.require_line        = b.require_line
        left join #supply_be     c          
               on a.require_no          = c.require_no
              and a.require_line        = c.require_line
        left join #supply_fe     d         
               on a.require_no          = d.require_no
              and a.require_line        = d.require_line
        left join #supply_ba     e        
               on a.require_no          = e.require_no
              and a.require_line        = e.require_line
        left join #supply_qm     f       
               on a.require_no          = f.require_no
              and a.require_line        = f.require_line
        left join #supply_quantity_sum g
               on a.require_no          = g.require_no
              and a.require_line        = g.require_line
        left join #require       h          
               on a.require_no  = h.require_no 
              and RIGHT(a.require_line , LEN(a.require_line ) - 2) = h.require_line
        left join Report0624.dbo.r24_stock_detail  stock
               on a.req_material_code   = stock.material_code
		left join #inv_qty i 
			   on  i.material_code = a.req_material_code
		left join #project_qty p
		       on a.req_material_code   = p.material_code
		left join #zd_material zd_material
			   on a.req_material_code   = zd_material.material_code
        left join #commit_supple_date commit_date
               on c.purchase_order_no   = commit_date.ORDER_NUM 
			  and c.purchase_order_Line = commit_date.ORDER_ITEM_NUM
        left join #order_status  order_status
               on c.purchase_order_no   = order_status.order_code 
			  and c.purchase_order_Line = order_status.order_item
        left join #order_status  insp_order_status
               on f.purchase_order_no   = insp_order_status.order_code 
			  and f.purchase_order_Line = insp_order_status.order_item
		left join #order_name z
		       on z.order_no = a.assemble_order_no
		left join #wbs_detail_info y
               on y.PSPNR = a.wbs_code;


select 1;


              
