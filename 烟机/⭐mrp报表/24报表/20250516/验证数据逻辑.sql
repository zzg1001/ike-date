SELECT
 a.require_no   require_no
,b.require_no   require_no_sap
,a.require_line require_line
,b.require_line require_line_sap
from
	(
		select
		distinct DELNR1 require_no,
		DELPS1 require_line
	from ODS_HANA.dbo.mrp_ww a
	left join #wbs_detail_info y
	on y.PSPNR = a.PSPNR
   where (y.POSKI <>'Z-2000_XSCB004' or y.POSKI is null)
	 and a.DELKZ1 = 'AR' 

 )a
left join (
select
		distinct require_no,
		require_line
	from
		report0624.dbo.r24_consolidate_table_ar

		) b
		on a.require_no = b.require_no
	  and a.require_line = b.require_line
where  b.require_no is null 

-- 1生产订单号	  

    SELECT
				 a.require_no   require_no_sap
				,b.require_no   require_no
				,a.require_line require_line_sap
				,b.require_line require_line
    from(
				select
						 distinct DELNR1 require_no,
											DELPS1 require_line
							 from ODS_HANA.dbo.mrp_ww  a
					left join #wbs_detail_info y
								on y.PSPNR = a.PSPNR	
						 where (y.POSKI <>'Z-2000_XSCB004' or y.POSKI is null)
							and a.DELKZ1 = 'AR' 
							and a.DELKZ2 = 'FE'
			
					 )a
left join (
			select
		distinct require_no,
					   require_line
				from report0624.dbo.r24_consolidate_table_ar
       where prod_order_no is not null 
					) b
					on a.require_no = b.require_no
				and a.require_line = b.require_line
				where  b.require_no is null 
				
				
				
-- 2采购订单号	  
SELECT
 a.require_no   require_no
,b.require_no   require_no_sap
,a.require_line require_line
,b.require_line require_line_sap
from
	(
          select
						 distinct DELNR1 require_no,
							     DELPS1 require_line
							 from ODS_HANA.dbo.mrp_ww  a
					left join #wbs_detail_info y
								on y.PSPNR = a.PSPNR	
						 where (y.POSKI <>'Z-2000_XSCB004' or y.POSKI is null)
						  and	a.DELKZ1 ='AR' 
              and a.DELKZ2 = 'BE'
							and a.MNG012 > 0
	
 )a
left join (
select
		distinct require_no,
		require_line
	from report0624.dbo.r24_consolidate_table_ar
  where purchase_order_no_line is not null 
		) b
		on a.require_no = b.require_no
	  and a.require_line = b.require_line
where  b.require_no is null 


-- 3采购申请号	  
SELECT
 a.require_no   require_no
,b.require_no   require_no_sap
,a.require_line require_line
,b.require_line require_line_sap
from
	(
select
						 distinct DELNR1 require_no,
											DELPS1 require_line
							 from ODS_HANA.dbo.mrp_ww  a
					left join #wbs_detail_info y
								on y.PSPNR = a.PSPNR	
						 where (y.POSKI <>'Z-2000_XSCB004' or y.POSKI is null)
						 and a.DELKZ1 = 'AR'
             and a.DELKZ2 = 'BA'
              and a.MNG012 > 0
	
 )a
left join (
select
		distinct require_no,
		require_line
	from report0624.dbo.r24_consolidate_table_ar
  where purchase_request_no is not null 
		) b
		on a.require_no = b.require_no
	  and a.require_line = b.require_line
where  b.require_no is null 


-- 4采购申请号	  
SELECT
 a.require_no   require_no
,b.require_no   require_no_sap
,a.require_line require_line
,b.require_line require_line_sap
from
	(
select
						 distinct DELNR1 require_no,
											DELPS1 require_line
							 from ODS_HANA.dbo.mrp_ww  a
					left join #wbs_detail_info y
								on y.PSPNR = a.PSPNR	
						 where (y.POSKI <>'Z-2000_XSCB004' or y.POSKI is null)
						 and a.DELKZ1 = 'AR'
             and a.DELKZ2 = 'BA'
              and a.MNG012 > 0
	
 )a
left join (
select
		distinct require_no,
		require_line
	from report0624.dbo.r24_consolidate_table_ar
  where purchase_request_no is not null 
		) b
		on a.require_no = b.require_no
	  and a.require_line = b.require_line
where  b.require_no is null 

-- 5计划协议号
SELECT
 a.require_no   require_no
,b.require_no   require_no_sap
,a.require_line require_line
,b.require_line require_line_sap
from
	(
select
						 distinct DELNR1 require_no,
											DELPS1 require_line
							 from ODS_HANA.dbo.mrp_ww  a
					left join #wbs_detail_info y
								on y.PSPNR = a.PSPNR	
						 where (y.POSKI <>'Z-2000_XSCB004' or y.POSKI is null)
						 and a.DELKZ1 = 'AR'
             AND a.DELNR2 LIKE '55%'
	
 )a
left join (
select
		distinct require_no,
		require_line
	from report0624.dbo.r24_consolidate_table_ar
  where DELNR is not null 
		) b
		on a.require_no = b.require_no
	  and a.require_line = b.require_line
where  b.require_no is null 



-------- 库存

	SELECT
	a. material_code
	,a.inv_quantity 
	,b.inv_quantity  inv_quantity_sap
	,a.qty          
	,b.qty          qty_sap
	,a.total_qty    
	,b.total_qty    total_qty_sap
	from 
	(
				select
				      distinct 
							 material_code
							,inv_quantity_1005 as  inv_quantity
							,qty               as  qty
							,stock_quantity    as  total_qty
			    from report0624.dbo.r24_consolidate_table_ar
 )a
join 
(  
  select 
          material_code
		,sum(inv_quantity) inv_quantity-- 1005库存
		,sum(qty)          qty           -- 1050库存
		,sum(total)        total_qty     --  库存数
		-- INTO #inv_qty
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
   GROUP by material_code
	 ) b 
	 on a.material_code = b.material_code 
	 where (a.inv_quantity <> b.inv_quantity)
	 or( a.inv_quantity <> b.inv_quantity)
	 or( a.qty <> b.qty)
	 or (a.total_qty <> b.total_qty)
	 