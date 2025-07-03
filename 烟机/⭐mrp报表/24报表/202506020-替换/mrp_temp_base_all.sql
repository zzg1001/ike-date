truncate table Report_Mrp.dbo.mrp_temp_base;


--------------老逻辑没用--------------------------------
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_temp_base_all_wb;
INSERT INTO Report_Mrp.dbo.tmp_mrp_temp_base_all_wb

 select DELNR1 as require_no         -- 预留号                
	   ,DELPS1 as require_line       -- 预留号行号  
	   ,MNG012 as supply_quantity
 from ODS_HANA.dbo.mrp_ww a
where DELKZ2 = 'WB'
  and MNG012 > 0;

--------------老逻辑没用--------------------------------
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_temp_base_all_qm;
INSERT INTO Report_Mrp.dbo.tmp_mrp_temp_base_all_qm
	select a.DELNR1    as require_no         -- 预留号                
		  ,a.DELPS1    as require_line       -- 预留号行号  
		  ,a.MNG012    as supply_quantity
		  ,a.DELNR2    as supply_no
		  ,b.purchase_order_no
		  ,b.vendor_desc
		  ,b.purchase_order_line
		  ,b.insp_status
	  from ODS_HANA.dbo.mrp_ww a
 left join Report0624.dbo.r24_insp_lot_detail b
		on a.DELNR2 = b.insp_no
	 where a.DELKZ2 = 'QM'
	   and a.MNG012 >  0;

--------------老逻辑没用--------------------------------

TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_temp_base_all_pb_pa;
INSERT INTO Report_Mrp.dbo.tmp_mrp_temp_base_all_pb_pa
select  a.DELNR1      as require_no         -- 预留号                
	   ,a.DELPS1      as require_line       -- 预留号行号  
	   ,sum(a.MNG012) as supply_quantity    -- 匹配数量
  from ODS_HANA.dbo.mrp_ww a
 where a.DELKZ2 in ('PB', 'PA')
   and a.MNG012 > 0
 group by a.DELNR1
         ,a.DELPS1;

-----------------------生产报表-----------------------

     insert into Report_Mrp.dbo.mrp_temp_base
          select
                  a.require_no                                                       as require_no                       -- 预留号
                 ,a.require_line                                                     as require_line                     -- 预留号行号
                 ,a.POSKI                                                            as wbs_code                         -- 替换 n.wbs_code WBS
                 ,a.wbs_desc                                                         as wbs_desc                         -- WBS描述  
                 ,a.wbs_category_code                                                as wbs_category_code
                 ,a.wbs_category_desc                                                as wbs_category_desc
                 ,a.order_type_code                                                  as order_type_code
                 ,a.purchase_group_code                                              as purchase_group_code
                 ,a.purchase_group_desc                                              as purchase_group_desc
                 ,a.purchase_group_code_desc                                         as purchase_group_code_desc
                 ,a.material_code                                                    as material_code                    -- 物料编码
                 ,a.material_desc                                                    as material_desc                    -- 物料名称
                 ,a.figure_no                                                        as figure_no                        -- 图号
                 ,a.purchase_type_code                                               as purchase_type_code               -- 类型
                 ,a.is_manuf                                                         as is_manuf                         -- 自制
                 ,a.is_purchase                                                      as is_purchase                      -- 外协
                 ,a.is_other                                                         as is_other                         -- 其他
                 ,a.require_quantity                                                 as require_quantity                 -- 需求数量
                 ,a.delivery_quantity                                                as delivery_quantity                -- 已发数量
                 ,a.assemble_order_no                                                as assemble_order_code              -- 装配订单号   -- 替换 h.assemble_order_no 
                 ,a.parent_material_code                                             as parent_material_code             -- 父项物料编码 -- 替换 n.material_code 
                 ,a.zp_ltxt                                                          as zp_ltxt                          -- 订单长文本
                 ,a.sort_string                                                      as sort_string                      -- 排序字符串
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
                 ,e.inquiry_status                                                   as inquiry_status                   -- 询价状态
				 ,b.supply_quantity                                                  as stock_supply_quantity            --库存匹配数-- WB_quantity
                 ,case when a.require_quantity = b.supply_quantity then 1 else 0 end as stock_supply_flag                --stock_supply
                 ,g.supply_quantity                                                  as other_supply_quantity            --其他匹配数-- PA，PB_quantity
                 ,i.total_qty                                                        as stock_quantity                   --库存数
	             ,getdate()                                                          as update_date
	             ,c.order_priority 	                                                 as purchase_order_order_priority     -- 订单优先级
	             ,i.total_qty                                                        as total_qty                         -- sap库存
				 ,i.inv_quantity                                                     as inv_quantity_1005                 -- 1005库存
	             ,CASE WHEN a.rep_type='ALL' THEN i.qty_1099 else i.qty end          as qty                               -- 199/1050库存
				 ,p.project_qty                                                      as project_qty                       -- 项目库存
				 ,a.zd_code                                                          as zd_code
                 ,c.SUPPLIER_DATE                                                    as commit_purchase_order_deliery_date -- 替换 SUPPLIER_DATE 承诺交货期 
                 ,c.order_sync_date                                                  as order_sync_date                    --采购订单：订单同步时间
                 ,c.receive_status                                                   as receive_status                     --采购订单：收货状态
                 ,c.insp_status                                                      as insp_status                        --采购订单：质检状态
                 ,c.receive_status                                                   as insp_receive_status                -- 检验批：收货状态
                 ,c.insp_status                                                      as insp_insp_status                   -- 检验批：质检状态
			     ,c.n45_current_node_status                                          as n45_current_node_status            -- 物流状态
				 ,c.n45_update_date_time                                             as n45_update_date_time               -- 当前节点时间
				 ,a.rep_type
				 ,case when a.POSKI ='Z-2000_XSCB004' then '上海中臣烟草机械配件有限责任公司' else  a.NAME1 end NAME1      -- 售达方
			     ,GETDATE()  etl_time
			 from Report_Mrp.dbo.mrp_requirement_order_detail a
        left join Report_Mrp.dbo.mrp_purchase_order_noLine_h_detail c          
               on a.require_no          = c.require_no
              and a.require_line        = c.require_line
        left join Report_Mrp.dbo.mrp_production_order_supply_no_detail d         
               on a.require_no          = d.require_no
              and a.require_line        = d.require_line
        left join Report_Mrp.dbo.mrp_purchase_request_order_noLine_h_detail e        
               on a.require_no          = e.require_no
              and a.require_line        = e.require_line
		left join  Report_Mrp.dbo.tmp_mrp_temp_base_all_wb b          
               on a.require_no          = b.require_no
              and a.require_line        = b.require_line
        left join Report_Mrp.dbo.tmp_mrp_temp_base_all_qm f       
               on a.require_no          = f.require_no
              and a.require_line        = f.require_line
        left join Report_Mrp.dbo.tmp_mrp_temp_base_all_pb_pa g
               on a.require_no          = g.require_no
              and a.require_line        = g.require_line
        left join Report0624.dbo.r24_stock_detail  stock
               on a.req_material_code   = stock.material_code
		left join Report_Mrp.dbo.mrp_stock i 
			   on i.material_code = a.req_material_code
		left join (  
		            select 
						  MATNR as material_code 
						 ,sum(PRLAB) project_qty
					 from ODS_HANA.dbo.MSPR 
					WHERE WERKS = '2000' 
					GROUP by MATNR
				   ) p
		       on a.req_material_code   = p.material_code

select 1;