
--mrp报表明细的总数据量对比---------------------------------------------------------------------
-- 2944 销售的
SELECT COUNT(1) from Report_Mrp.dbo.mrp_consolidate_table where rep_type ='ALL'
-- 2944
SELECT COUNT(1) FROM report0624.dbo.r24_consolidate_table_all
-- 未下达
-- 37586
SELECT COUNT(1) from Report_Mrp.dbo.mrp_consolidate_table where rep_type ='SB'
-- 37586
SELECT COUNT(1) FROM report0624.dbo.r24_consolidate_table_sb
-- 下达的
-- 1197852
SELECT COUNT(1) from Report_Mrp.dbo.mrp_consolidate_table where rep_type ='AR'

-- 1197852
SELECT COUNT(1) FROM report0624.dbo.r24_consolidate_table_ar


-- mrp报表的总数据量对比---------------------------------------------------------------------
-- 2931
SELECT COUNT(1) from Report_Mrp.dbo.mrp_temp_base where rep_type ='ALL'

-- 2931
SELECT COUNT(1) FROM Report0624.dbo.r24_temp_base_all

-- 37557
SELECT COUNT(1) from Report_Mrp.dbo.mrp_temp_base where rep_type ='SB'

-- 37557
SELECT COUNT(1) FROM Report0624.dbo.r24_temp_base_sb

-- 1197808
SELECT COUNT(1) from Report_Mrp.dbo.mrp_temp_base where rep_type ='AR'

-- 1197808
SELECT COUNT(1) FROM Report0624.dbo.r24_temp_base_ar

-- mrp报表的装配订单号的对比,已下达，销售的，未下达---------------------------------------------------------------------
SELECT
      a.assemble_order_code
     ,b.assemble_order_code  assemble_order_code_x
from
	(
	
		  select distinct        
			 assemble_order_code 
		from Report0624.dbo.r24_temp_base_ar
	

 )a
left join (

		 select    distinct        
			       assemble_order_code 
			 from Report_Mrp.dbo.mrp_temp_base where rep_type ='AR'

		) b
		on a.assemble_order_code = b.assemble_order_code
where  b.assemble_order_code is null;

--------------反过来比较
SELECT
      a.assemble_order_code
     ,b.assemble_order_code  assemble_order_code_x
from
	( select   distinct  assemble_order_code  from Report_Mrp.dbo.mrp_temp_base where rep_type ='AR')a
left join (
			 select distinct   assemble_order_code from Report0624.dbo.r24_temp_base_ar) b
		on a.assemble_order_code = b.assemble_order_code
where  b.assemble_order_code is null;


-- mrp报表的生产订单号的对比,已下达，销售的，未下达---------------------------------------------------------------------
SELECT
      a.prod_order_no
     ,b.prod_order_no  prod_order_no_x
from
	(
		  select distinct        
			 prod_order_no 
		from Report0624.dbo.r24_temp_base_all
 )a
left join (

		 select    distinct        
			       prod_order_no 
			 from Report_Mrp.dbo.mrp_temp_base where rep_type ='ALL'

		) b
		on a.prod_order_no = b.prod_order_no
where  b.prod_order_no is  null;

--------------反过来比较
SELECT
      a.prod_order_no
     ,b.prod_order_no  prod_order_no_x
from
	(
	 select  distinct  prod_order_no  from Report_Mrp.dbo.mrp_temp_base where rep_type ='ALL'
 )a
left join (
			 select distinct  prod_order_no from Report0624.dbo.r24_temp_base_all
		 ) b
		on a.prod_order_no = b.prod_order_no
where  b.prod_order_no is null;

-- mrp报表的采购订单号的对比,已下达，销售的，未下达---------------------------------------------------------------------
SELECT
      a.purchase_request_no
     ,b.purchase_request_no  purchase_request_no_line_x
from
	(
		  select distinct        
			 purchase_request_no 
		from Report0624.dbo.r24_temp_base_all
 )a
left join (

		 select    distinct        
			       purchase_order_no_line 
			 from Report_Mrp.dbo.mrp_temp_base where rep_type ='ALL'
		) b
		on a.purchase_order_no_line = b.purchase_order_no_line
where  b.purchase_order_no_line is  null;

--------------反过来比较
SELECT
      a.purchase_order_no_line
     ,b.purchase_order_no_line  purchase_order_no_line_x
from
	(
		 select    distinct        
			       purchase_order_no_line 
			 from Report_Mrp.dbo.mrp_temp_base where rep_type ='ALL'
 )a
left join (
			 select distinct        
						 purchase_order_no_line 
					from Report0624.dbo.r24_temp_base_all
		) b
		on a.purchase_order_no_line = b.purchase_order_no_line
where  b.purchase_order_no_line is null;

-- mrp报表的采购申请订单号的对比,已下达，销售的，未下达---------------------------------------------------------------------
SELECT
      a.purchase_request_no
     ,b.purchase_request_no  purchase_request_no_x
from
	(
		  select distinct        
			 purchase_request_no 
		from Report0624.dbo.r24_temp_base_all
 )a
left join (

		 select    distinct        
			       purchase_request_no 
			 from Report_Mrp.dbo.mrp_temp_base where rep_type ='ALL'
		) b
		on a.purchase_request_no = b.purchase_request_no
where  b.purchase_request_no is  null;

--------------反过来比较
SELECT
      a.purchase_request_no
     ,b.purchase_request_no  purchase_request_no_x
from
	(
		 select    distinct        
			       purchase_request_no 
			 from Report_Mrp.dbo.mrp_temp_base where rep_type ='ALL'
 )a
left join (
			 select distinct        
						 purchase_request_no 
					from Report0624.dbo.r24_temp_base_all
		) b
		on a.purchase_request_no = b.purchase_request_no
where  b.purchase_request_no is null;
-- mrp报表的计划协议订单号的对比,已下达，销售的，未下达---------------------------------------------------------------------
SELECT
      a.DELNR
     ,b.DELNR  DELNR_x
from
	(
		  select distinct        
			  DELNR ,DELPS 
		from report0624.dbo.r24_consolidate_table_sb
 )a
left join (

		 select    distinct        
			        DELNR ,DELPS
			 from Report_Mrp.dbo.mrp_consolidate_table where rep_type ='SB'
		) b
		on a.DELNR = b.DELNR
		AND a.DELPS = b.DELPS
where  b.DELNR is  null;

--------------反过来比较
SELECT
      a.DELNR
     ,b.DELNR  purchase_request_no_x
from
	(
		 select    distinct        
			       DELNR ,DELPS
			 from Report_Mrp.dbo.mrp_consolidate_table where rep_type ='SB'
 )a
left join (
			 select distinct        
						  DELNR ,DELPS
					from report0624.dbo.r24_consolidate_table_sb 
		) b
		on a.DELNR = b.DELNR
		AND a.DELPS = b.DELPS
where  b.DELNR is null;