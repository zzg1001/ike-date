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