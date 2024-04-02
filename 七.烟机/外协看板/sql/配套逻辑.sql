SET ANSI_WARNINGS OFF;
SET ARITHABORT OFF;
SET ARITHIGNORE ON;
select 
	a.factory
	,a.category
	,a.eindt
,sum(total_od_cnt) total_od_cnt
,sum(every_cnt) peitao_cnt
,cast(sum(every_cnt) as decimal(10,2)) /cast(sum(total_od_cnt) as decimal(10,2))  peitao_rate
from (
		 select 
		        factory
				,EBELN
				,category
				,RIGHT(REPLICATE('0', 5) + EBELP , 5) EBELP 
				,left(EINDT,4)+'-'+SUBSTRING(EINDT,5,2)EINDT
				,count(*) total_od_cnt
		   from Outsourcing_Dashboard.dbo.sap_base_field_merge_wide
		  where  (LOEKZ <>'L' or LOEKZ is null)
		      and BUKRS='2000' and FRGKE='S'
		group by  
				factory
				,EBELN
				,category
				,RIGHT(REPLICATE('0', 5) + EBELP , 5)
				,left(EINDT,4)+'-'+SUBSTRING(EINDT,5,2)
	 ) a

left join(
		select 
		        factory
				,purchase_order_no 
				,purchase_order_line
				,CONVERT(varchar(7), delivery_date, 120) delivery_date
				,count(*) every_cnt
		 from Outsourcing_Dashboard.dbo.r24_temp_base  
		 where  receive_status is not null
		   and purchase_group_code = '203'
		   group by 
		        factory
				,purchase_order_no 
				,purchase_order_line
				,CONVERT(varchar(7), delivery_date, 120) 

      )b 
      on a.factory = b.factory
     and a.EBELN = b.purchase_order_no
     and a.EBELP = b.purchase_order_line
     and a.EINDT = b.delivery_date
     group by 
             a.factory
		        ,a.category
		        ,a.EINDT
						