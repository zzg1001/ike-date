truncate table report0624.dbo.r24_consolidate_table

select a.order_num, a.order_item_num, b.node_status
into #d
from [ods_srm].[dbo].[srm_poc_order_item] as a,
[ods_srm].[dbo].[srm_poc_order_item_extra] as b
where a.id = b.order_item_id and b.node_status is not null
group by a.order_num, a.order_item_num, b.node_status


select * 
into #new1
from [report0624].[dbo].[r24_1050_1051]
where [r24_1050_1051].midlgort = 1050


select rmd.supply_no, rmd.supply_line, rmd.require_no, rmd.require_line
into #md
from [report0624].dbo.r24_mrp_detail rmd
where rmd.supply_no like '5%'


select distinct *
into #ww
from [ods_hana].[dbo].[md04_2000]  
where delnr like '55%'


select distinct ebeln, ebelp, etenr, fixkz
into #sl
from [report0624].[dbo].[sap_lp];

insert into report0624.dbo.r24_consolidate_table
select
    a.*,
    b.note,
    cast(insp_purc_order_no as varchar) + '/' + cast(insp_purc_order_line as varchar) as 对应采购订单_行号,
    c.inquiry_status,
    d.node_status,
    new1.qty,
    md.supply_no as 计划协议号,
    md.supply_line as 计划行号,
    ww.*,
    sl.*,
    lfa1.SORTL as NAME1
from report0624.dbo.r24_temp_base as a
left join report0624.dbo.r24_temp_note as b
    on a.require_line = b.require_line
    and a.require_no = b.require_no
left join report0624.dbo.r24_inquiry_status as c
    on a.material_code = c.material_code
left join #d as d
    on a.purchase_order_no = d.order_num and a.purchase_order_line = d.order_item_num
left join #new1 as new1 
    on new1.rsnum = a.require_no
    and new1.rspos = a.require_line
left join #md as md
    on a.require_no = md.require_no
    and a.require_line = md.require_line
left join #ww as ww
    on a.require_no = ww.rsnum
    and stuff(ltrim(ww.rspos), 1, 2, '') = a.require_line
left join #sl as sl 
    on sl.ebeln = ww.delnr
    and sl.ebelp = stuff(ltrim(ww.delps), 1, 1, '')
    and sl.etenr = ww.delet
left join ods_hana.dbo.ekko
    on ekko.ebeln = sl.ebeln
left join ods_hana.dbo.lfa1
    on ekko.lifnr = lfa1.lifnr;
	
	
	
	
	
	
	
	
	
	
	
truncate table Report0624.dbo.r24_temp_base

select require_no
       , require_line
       , assemble_order_no
       , req_material_code
       , require_quantity
into #a
  from Report0624.dbo.r24_mrp_detail
  where require_quantity > 0
  group by require_no
         , require_line
         , assemble_order_no
         , req_material_code
         , require_quantity

----------------------------------------------

select a.*, wbs.wbs_category_code, wbs.wbs_category_desc
into #bb
from Report0624.dbo.r24_assemble_order_detail as a
           left join YJ_DIM.dbo.dim_wbs as wbs
                     on a.wbs_code = wbs.wbs_code
where wbs.last_version = 1
----------------------------------------------

select require_no
     , require_line
     , supply_quantity
into #b
from Report0624.dbo.r24_mrp_detail
where supply_code = 'WB'
  and require_quantity > 0

----------------------------------------------


select require_no
     , require_line
     , supply_quantity
     , supply_no
     , cb.purchase_order_no
	  , cb.purchase_order_line
     , cb.schedule_date
     , cb.purchase_order_no + '/' + cb.purchase_order_line as purchase_order_NoLine
     , cb.current_point
     , cb.vendor_desc
	 , cb.order_priority
into #c
from Report0624.dbo.r24_mrp_detail as ca
         left join
     Report0624.dbo.r24_purchase_order_detail as cb
     on ca.supply_no = cb.purchase_order_no
         and ca.supply_line = '0' + cb.purchase_order_line
where ca.supply_code = 'BE'
  and require_quantity > 0


----------------------------------------------

select a.require_no
     , a.require_line
     , a.supply_no
     , b.schedule_date
     , a.supply_quantity
	 , b.current_process_no
     , b.current_process_desc
     , b.current_key_dept_desc
into #d
from Report0624.dbo.r24_mrp_detail as a
         left join Report0624.dbo.r24_prod_order_detail as b
                   on a.supply_no = prod_order_no
where a.supply_code = 'FE'



----------------------------------------------

select require_no
     , require_line
     , supply_quantity
     , supply_no
     , supply_date
into #e
from Report0624.dbo.r24_mrp_detail
where supply_code = 'BA'
  and require_quantity > 0


----------------------------------------------

select a.require_no
     , a.require_line
     , a.supply_quantity
     , a.supply_no
     , b.purchase_order_no
     , b.vendor_desc
    , b.purchase_order_line
  , b.insp_status
into #f
from Report0624.dbo.r24_mrp_detail as a
         left join Report0624.dbo.r24_insp_lot_detail as b
                   on a.supply_no = b.insp_no
where a.supply_code = 'QM'
  and require_quantity > 0


----------------------------------------------


select require_no
     , require_line
     , sum(supply_quantity) as supply_quantity
into #g
from Report0624.dbo.r24_mrp_detail
where supply_code in ('PB', 'PA')
  and require_quantity > 0
group by require_no, require_line

----------------------------------------------


select *
into #require
from Report0624.dbo.r24_assemble_require_detail
where require_quantity > 0

----------------------------------------------


SELECT MATNR as material_code, SUM(CLABS) as inv_quantity
INTO #inv_1005
FROM ODS_HANA.dbo.MCHB
WHERE WERKS = '2000' AND LGORT = '1005' --AND MATNR = '1BBE40104300'
  GROUP BY MATNR


----------------------------------------------
SELECT OBJEK as material_code,ATWRT as zd_code
INTO #zd_material
FROM ODS_HANA.dbo.AUSP
WHERE KLART = '001' AND ATINN = '0000000009'

-----------------------------------------------------------
select SUPPLIER_DATE, ORDER_NUM, right('00000' + ltrim(ORDER_ITEM_NUM), 5) as ORDER_ITEM_NUM
into #commit_supple_date
from ODS_SRM.dbo.srm_poc_order_item
where SUPPLIER_DATE is not null
-----------------------------------------------------------
select A.ORDER_NUM  as order_code,
	   right('00000' + ltrim(ORDER_ITEM_NUM), 5) as order_item,
       A.CREATED_TS as order_sync_date,
       case C.STATUS
           when 'NOT_PRICE_APPRAISAL' then '待审价'
           when 'PENDING_DELIVERY' then '待交货'
           when 'PENDING_GR' then '待收货'
           when 'PARTIAL_GR' then '部分收货'
           when 'GR_COMPLETED' then '已收货'
           when 'PR_CANCELLED' then '购方取消'
           end      as receive_status,
       case C.QC_STATUS
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
           end      as insp_status
into #order_status
from ODS_SRM.dbo.srm_poc_order_hd A
         inner join ODS_SRM.dbo.srm_poc_order_item B on A.ID = B.ORDER_ID
         inner join ODS_SRM.dbo.srm_poc_order_item_extra C on B.ID = C.ORDER_ITEM_ID
where A.DELETE_FLAG = 0
  and B.DELETE_FLAG = 0
  and A.REF_PURCHASER_CD = '2000';
-----------------------------------------------------------
-- select A.ORDER_NUM  as order_code,
-- 	   right('00000' + ltrim(ORDER_ITEM_NUM), 5) as order_item,
--        A.CREATED_TS as order_sync_date,
--        case C.STATUS
--            when 'NOT_PRICE_APPRAISAL' then '待审价'
--            when 'PENDING_DELIVERY' then '待交货'
--            when 'PENDING_GR' then '待收货'
--            when 'PARTIAL_GR' then '部分收货'
--            when 'GR_COMPLETED' then '已收货'
--            when 'PR_CANCELLED' then '购方取消'
--            end      as insp_receive_status,
--        case C.QC_STATUS
--            when 'PARTIAL_PAINTING' then '部分油漆'
--            when 'PO_OUT' then '外检完成'
--            when 'PAINTING' then '油漆'
--            when 'IN_QC' then '在检'
--            when 'PARTIAL_INBOUND' then '部分入库'
--            when 'INBOUND' then '入库'
--            when 'NO_INSP' then '免检'
--            when 'NOT_QC' then '待质检'
--            when 'PARTIAL_QC' then '部分在检'
--            when 'PARTIAL_QC_DONE' then '部分质检完成'
--            when 'ALL_QC' then '质检完成'
--            end      as insp_insp_status
-- into #insp_order_status
-- from ODS_SRM.dbo.srm_poc_order_hd A
--          inner join ODS_SRM.dbo.srm_poc_order_item B on A.ID = B.ORDER_ID
--          inner join ODS_SRM.dbo.srm_poc_order_item_extra C on B.ID = C.ORDER_ITEM_ID
-- where A.DELETE_FLAG = 0
--   and B.DELETE_FLAG = 0
--   and A.REF_PURCHASER_CD = '2000';
-----------------------------------------------------------

insert into Report0624.dbo.r24_temp_base
select
-- 	top 500
    a.require_no
     , a.require_line
     , bb.wbs_code
     , bb.wbs_desc
     , bb.wbs_category_code
     , bb.wbs_category_desc
     , bb.order_type_code
     , require.purchase_group_code
     , require.purchase_group_desc
     , require.purchase_group_code + '/' + require.purchase_group_desc  as purchase_group_code_desc
     , replace(ltrim(replace(a.req_material_code, '0', ' ')), ' ', '0') as material_code--物料编码
     , mm.material_desc                                                 as material_desc--物料名称
     , mm.figure_no                                                     as figure_no--图号
     , mm.purchase_type_code
     , case
        when purchase_type_code='E'
            then 1
            else 0
            end as is_manuf--自制
     , case
        when purchase_type_code='F'
            then 1
            else 0
            end as is_purchase--外协
     , case
        when (purchase_type_code!='F') AND (purchase_type_code!='E')
            then 1
            else 0
            end as is_other--其他



     , a.require_quantity                                               as require_quantity--需求数量
     , require.delivery_quantity 										as delivery_quantity--已发数量
--     ,0 as 缺口数
     , bb.assemble_order_no                                             as assemble_order_code--装配订单号
     , bb.material_code                                                 as parent_material_code--父项物料编码
     , bb.zp_ltxt                                                       as zp_ltxt--订单长文本
     , require.sort_string                                              as sort_string--排序字符串
     , bb.schedule_date                                                 as delivery_date--订单交货期
---------------------------------------------------------------
     , d.supply_quantity                                                as prod_order_supply_quantity-- 生产订单匹配数-- FE_quantity
     , d.supply_no                                                      as prod_order_no--生产订单号
     , d.schedule_date                                                  as prod_order_delivery_date--生产交货期
	 , d.current_process_no + '/' + d.current_process_desc + '/' + d.current_key_dept_desc                                          as prod_order_current_point--当前节点
     , d.current_key_dept_desc                                          as prod_order_current_key_dept_desc --管理部门
---------------------------------------------------------------
     , c.supply_quantity                                                as purchase_order_supply_quantity-- 采购订单匹配数-- BE_quantity
	 , c.supply_no 														as purchase_order_no--采购订单号
	 , c.purchase_order_line 											as purchase_order_line--采购订单行号
     , c.purchase_order_NoLine                                          as purchase_order_no_line--采购订单行
     , c.schedule_date                                                  as purchase_order_deliery_date--采购交货期
     , case
           when
               current_point = 'gr'
               then
               '收货'
           when
               current_point = 'NA'
               then '待下达'
           when
               current_point = 'painting'
               then '油漆'
           when
               current_point = 'migo'
               then '入库'
           when current_point = 'qx'
               then '质检'
		   when
               current_point = 'srm'
               then '在途'
    end
                                                                        as purchase_order_current_point --当前指针
     , c.vendor_desc                                                    as purchase_order_vendor_desc--供应商
--	 , c.order_priority 												as purchase_order_order_priority-- 订单优先级
---------------------------------------------------------------
     , f.supply_quantity                                                as insp_supply_quantity--检验批匹配数-- QM_quantity
     , f.supply_no                                                      as insp_no--检验批号
     , f.purchase_order_no                                              as insp_purc_order_no--	对应采购订单
	 , f.purchase_order_line											as insp_purc_order_line--对应采供订单行
     , f.vendor_desc                                                    as insp_vendor_desc--加工方
	 , f.insp_status													as insp_current_point--检验当前节点
---------------------------------------------------------------
     , e.supply_quantity                                                as purchase_request_supply_quantity--采购申请匹配数-- BA_quantity
     , e.supply_no                                                      as purchase_request_no--采购申请号
     , e.supply_date                                                    as purchase_request_delievery_date--采购申请交货期
---------------------------------------------------------------
     , b.supply_quantity                                                as stock_supply_quantity--库存匹配数-- WB_quantity
     , case
           when
               a.require_quantity = b.supply_quantity
               then 1
           else
               0
    end
                                                                        as stock_supply_flag--stock_supply
     , g.supply_quantity                                                as other_supply_quantity--其他匹配数-- PA，PB_quantity
     , stock.stock_quantity                                             as stock_quantity--库存数
	 , getdate() as update_date
	 , c.order_priority 												as purchase_order_order_priority-- 订单优先级
	 , inv_1005.inv_quantity
	 , zd_material.zd_code
     , commit_date.SUPPLIER_DATE
     , order_status.order_sync_date                 --采购订单：订单同步时间
     , order_status.receive_status                  --采购订单：收货状态
     , order_status.insp_status                     --采购订单：质检状态
     , insp_order_status.receive_status  as insp_receive_status        --检验批：收货状态
     , insp_order_status.insp_status as insp_insp_status           --检验批：质检状态


----------------------------------------------------------------------------------------------------------------------------------------------------------
from
----------------------------------------------------------------------------------------------------------------------------------------------------------


    #a as a
         inner join
            #bb as bb
                on a.assemble_order_no = bb.assemble_order_no

         left join
            Report0624.dbo.material_info as mm
                on a.req_material_code = mm.material_code
         left join
            #b as b
                on a.require_no = b.require_no
                and a.require_line = b.require_line

         left join
            #c as c
                on a.require_no = c.require_no
                and a.require_line = c.require_line
         left join
            #d as d
                on a.require_no = d.require_no
                and a.require_line = d.require_line
         left join
            #e as e
                on a.require_no = e.require_no
                and a.require_line = e.require_line
         left join
            #f as f
                on a.require_no = f.require_no
                and a.require_line = f.require_line
         left join
            #g as g
                on a.require_no = g.require_no
                and a.require_line = g.require_line
         left join
            #require as require
                on a.require_line = require.require_line
                and a.require_no = require.require_no
         left join
            Report0624.dbo.r24_stock_detail as stock
                on a.req_material_code = stock.material_code
		 left join
			 #inv_1005 inv_1005
			 ON a.req_material_code = inv_1005.material_code
		left join
			 #zd_material zd_material
			 ON a.req_material_code = zd_material.material_code
        left join
             #commit_supple_date commit_date
             on c.purchase_order_no = commit_date.ORDER_NUM and c.purchase_order_Line = commit_date.ORDER_ITEM_NUM
        left join
             #order_status as order_status
             on c.purchase_order_no = order_status.order_code and c.purchase_order_Line = order_status.order_item
        left join
             #order_status as insp_order_status
             on f.purchase_order_no = insp_order_status.order_code and f.purchase_order_Line = insp_order_status.order_item


select 1;
