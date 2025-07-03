SELECT
      a.assemble_order_no  as assemble_order_no_sap
     ,b.assemble_order_no 
from
	(
	
		  select distinct        
			 DEL121 as assemble_order_no  
		from ODS_HANA.dbo.mrp_ww
		   where DELKZ1='SB'
			 and MNG011 > 0
	

 )a
left join (

			select
		distinct assemble_order_code as assemble_order_no
	from
		report0624.dbo.r24_consolidate_table_sb 

		) b
		on a.assemble_order_no = b.assemble_order_no
where  b.assemble_order_no is null;


-- 1生产订单号	  
SELECT			    
	 a.assemble_order_no   assemble_order_no
	,b.assemble_order_no   assemble_order_no_sap

from(
				select
						 distinct          
						          DEL121 assemble_order_no
							 from ODS_HANA.dbo.mrp_ww  a
						   where DELKZ1='SB'
			                 and MNG011 > 0
	                         and  a.DELKZ2 = 'FE'
			
		 )a
left join (
			select
		      distinct   assemble_order_code assemble_order_no
				from report0624.dbo.r24_temp_base_sb
                where prod_order_no is not null 
                
					) b
		
			on a.assemble_order_no = b.assemble_order_no
        where  b.assemble_order_no is null;
				
				
				
-- 2采购订单号	  
SELECT			    
	 a.assemble_order_no   assemble_order_no
	,b.assemble_order_no   assemble_order_no_sap

from(
				select
						 distinct          
						          DEL121 assemble_order_no
							 from ODS_HANA.dbo.mrp_ww  a
						   where DELKZ1='SB'
			                 and MNG011 > 0
	                         and  a.DELKZ2 = 'FE'
			
		 )a
left join (
			select
		      distinct   assemble_order_code assemble_order_no
				from report0624.dbo.r24_consolidate_table_sb
                where prod_order_no is not null 
                
					) b
		
			on a.assemble_order_no = b.assemble_order_no
        where  b.assemble_order_no is null;

	    
-- 3采购申请号	  
SELECT			    
	 a.assemble_order_no   assemble_order_no
	,b.assemble_order_no   assemble_order_no_sap

from(
				select
						 distinct          
						          DEL121 assemble_order_no
							 from ODS_HANA.dbo.mrp_ww  a
						   where DELKZ1='SB'
			                 and MNG011 > 0
	                         and a.DELKZ2 = 'BA'
			
		 )a
left join (
			select
		      distinct   assemble_order_code assemble_order_no
				from report0624.dbo.r24_consolidate_table_sb
               where purchase_request_no is not null 
                
					) b
		
			on a.assemble_order_no = b.assemble_order_no
        where  b.assemble_order_no is null;


-- 4计划协议号
SELECT			    
	 a.assemble_order_no   assemble_order_no
	,b.assemble_order_no   assemble_order_no_sap

from(
				select
						 distinct          
						          DEL121 assemble_order_no
							 from ODS_HANA.dbo.mrp_ww  a
						   where DELKZ1='SB'
			                 and MNG011 > 0
	                         AND a.DELNR2 LIKE '55%'
			
		 )a
left join (
			select
		      distinct   assemble_order_code assemble_order_no
				from report0624.dbo.r24_consolidate_table_sb
               where DELNR is not null 
                
					) b
		
			on a.assemble_order_no = b.assemble_order_no
        where  b.assemble_order_no is null;



-------- 库存：1005库存，1050库存 ，供应商库存总数

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
			    from report0624.dbo.r24_consolidate_table_sb 
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
	 
-----项目库存对比

	SELECT
		 a. material_code
		,a.project_qty 
		,b.project_qty  project_qty_sap
	from (
			select
				  distinct 
						 material_code
						,project_qty
			from report0624.dbo.r24_consolidate_table_sb 
		 )a
	join (  

			  select 
				  MATNR as material_code 
				 ,sum(PRLAB) project_qty
			 from ODS_HANA.dbo.MSPR 
			WHERE WERKS = '2000' 
			GROUP by MATNR
		 ) b 
	  on a.material_code = b.material_code 
   where (a.project_qty <> b.project_qty)	 