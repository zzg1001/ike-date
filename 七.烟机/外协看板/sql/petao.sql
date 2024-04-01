
with tmp_base as(
	select 
	factory
	,EBELN
	,category
	,RIGHT(REPLICATE('0', 5) + EBELP , 5) EBELP 
	,left(EINDT,4)+'-'+SUBSTRING(EINDT,5,2)EINDT
	from Outsourcing_Dashboard.dbo.sap_base_field_wide
	where  (LOEKZ <>'L' or LOEKZ is null)
	and BUKRS='2000' and FRGKE='S'
	group by  
	factory
	,EBELN
	,category
	,RIGHT(REPLICATE('0', 5) + EBELP , 5)
	,left(EINDT,4)+'-'+SUBSTRING(EINDT,5,2)
),
tmp_base_1 as(

	select 
	     a.factory
		  ,a.category
		  ,CONVERT(varchar(7), b.delivery_date, 120) as year_month
			,count(*) pt_cnt
	from Outsourcing_Dashboard.dbo.r24_temp_base b
	join tmp_base a 
	on a.EBELN = b.purchase_order_no 
	and b.purchase_order_line  = a.EBELP
	and a.factory = b.factory
	and  CONVERT(varchar(7), b.delivery_date, 120) = a.EINDT
	where receive_status is not null
	and purchase_group_code = '203'
	group by 
	 a.factory
	,a.category
	,CONVERT(varchar(7), b.delivery_date, 120)
)

select * from tmp_base_1