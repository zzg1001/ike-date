-- 使用说明：最小粒度到生产订单->supply_no

TRUNCATE TABLE Report_Mrp.dbo.mrp_production_order_supply_no_detail;

INSERT INTO Report_Mrp.dbo.mrp_production_order_supply_no_detail
   select   a.DELNR1    as require_no         -- 预留号                
		   ,a.DELPS1    as require_line       -- 预留号行号  
		   ,a.DELNR2    as supply_no          -- 生产订单号
		   ,a.DAT002    as schedule_date      -- 生产交货期
		   ,a.MNG012    as supply_quantity    -- 生产订单匹配数
		   ,a.DELKZ1    as rep_type           -- AR类型，SB类似，销售类型 ZPPT002.DELKZ1='VC' OR 'VJ'OR (ZPPT002.DELKZ1='AR' AND ZPPT002.PSPNR = 'Z-2000_XSCB004')
		   ,b.current_process_no
		   ,b.current_process_desc
		   ,b.current_key_dept_desc           -- 管理部门
		   ,b.current_process_no + '/' + b.current_process_desc + '/' + b.current_key_dept_desc as prod_order_current_point --当前节点
	       ,GETDATE() etl_time                -- 调度时间
	 from  ODS_HANA.dbo.mrp_ww a
left join  Report0624.dbo.r24_prod_order_detail as b
	   on  a.DELNR2 = prod_order_no
    where  a.DELKZ2 = 'FE';                   -- 生产订单
	
	
	


-- 使用说明：最小粒度采购订单行
----------------------------------------------------------------
-----------------------采购订单---------------------------------
----------------------------------------------------------------
TRUNCATE TABLE Report_Mrp.dbo.mrp_purchase_order_noLine_h_detail;

------------采购同步日期
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_status;
INSERT INTO Report_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_status   
 select  A.ORDER_NUM  as order_code
		,ORDER_ITEM_NUM as order_item
		,B.UPDATED_TS as order_sync_date -- 采购同步日期
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
	from ODS_SRM.dbo.srm_poc_order_hd A
	join ODS_SRM.dbo.srm_poc_order_item B on A.ID = B.ORDER_ID
	join ODS_SRM.dbo.srm_poc_order_item_extra C on B.ID = C.ORDER_ITEM_ID
   where A.DELETE_FLAG = 0
	 and B.DELETE_FLAG = 0
	 and A.REF_PURCHASER_CD = '2000';

----采购提交日期
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_commit;
INSERT INTO Report_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_commit  
	 select SUPPLIER_DATE
	       ,ORDER_NUM
	       ,ORDER_ITEM_NUM as ORDER_ITEM_NUM
      from ODS_SRM.dbo.srm_poc_order_item
     where SUPPLIER_DATE is not null;
 
 
 ---采购物料状态
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_node;
INSERT INTO Report_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_node  
  SELECT 
		 order_num              -- 订单号			
		,order_line_num         -- 行号			
		,plan_item_num          -- 如果是协议订单，就是计划需求行号			
		,current_node_code
		,current_node_name      -- 节点code和名称	
		,n45_current_node_status
		,update_date_time
		,update_date_time as n45_update_date_time -- 当前节点时间 采购
 into #logistics__status
 from (
		 SELECT			
				order_num              -- 订单号			
				,order_line_num        -- 行号			
				,plan_item_num         -- 如果是协议订单，就是计划需求行号			
				,current_node_code
				,current_node_name      -- 节点code和名称					
				,case when current_node_status=3 THEN '结束'			
					  when current_node_status=2 THEN '异常'			
					  when current_node_status=1 THEN '开始'			
					  else 'X' end	n45_current_node_status		
                ,CONVERT(VARCHAR(19), CAST(update_date_time AS DATETIME), 120) update_date_time				  
				,row_number()over(PARTITION by order_num ,order_line_num ,plan_item_num order by update_date_time desc  ) rn
		  FROM  ODS_LPS.dbo.t_logistical_task_pur_migo		
		 WHERE task_status!=3 		
	)a
where rn = 1;




INSERT INTO Report_Mrp.dbo.mrp_purchase_order_noLine_h_detail   
    select DELNR1   as require_no         -- 预留号                
		  ,DELPS1   as require_line       -- 预留号行号  
		  ,MNG012   as supply_quantity    -- 采购订单匹配数
		  ,DELNR2   as supply_no
		  ,b.purchase_order_no
		  ,b.purchase_order_line
		  ,a.DAT002 as schedule_date           -- 采购交货期
		  ,a.DELNR2 as purchase_order_NoLine   -- 采购订单号
		  ,a.DELPS2 as purchase_order_NoLine_h -- 采购订单行
		  ,b.current_point
		  ,b.vendor_desc
		  ,b.order_priority                    -- 订单优先级 
		  ,case when current_point = 'gr'       then '收货'
                when current_point = 'NA'       then '待下达'
                when current_point = 'painting' then '油漆'
                when current_point = 'migo'     then '入库'
                when current_point = 'qx'       then '质检'
		        when current_point = 'srm'      then '在途'
            end as purchase_order_current_point            -- 当前指针
          ,a.DELKZ1   as rep_type                          -- AR类型，SB类似，销售类型 ZPPT002.DELKZ1='VC' OR 'VJ'OR (ZPPT002.DELKZ1='AR' AND ZPPT002.PSPNR = 'Z-2000_XSCB004')
		  ,SUPPLIER_DATE                                   -- 承诺交货期
		  ,d.order_sync_date                               -- 采购订单：订单同步时间
		  ,d.receive_status                                -- 采购订单：收货状态
		  ,d.insp_status                                   -- 检验批：  质检状态
		  ,x.current_node_name as n45_current_node_status  -- 物流状态
		  ,x.update_date_time  as n45_update_date_time     -- 当前节点时间
		  ,GETDATE() etl_time                              -- 调度时间
	 from ODS_HANA.dbo.mrp_ww a
left join Report0624.dbo.r24_purchase_order_detail as b
       on a.DELNR2 = b.purchase_order_no
      and a.DELPS2 = '0' + b.purchase_order_line
left join Report_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_commit c
	  on b.purchase_order_no   = c.ORDER_NUM 
	 and b.purchase_order_Line = c.ORDER_ITEM_NUM
left join eport_Mrp.dbo.tmp_mrp_purchase_order_noLine_h_detail_status  d
	   on b.purchase_order_no   = d.order_code 
	  and b.purchase_order_Line = d.order_item
left join #logistics__status x 
	   on a.DELNR2    =  x.order_num
	  and CAST(CAST(a.DELPS2  AS INT) AS NVARCHAR)   = CAST(CAST(x.order_line_num AS INT) AS NVARCHAR)  
	  and x.order_num like '45%' -- 采购订单
   where a.DELKZ2 = 'BE' -- 采购订单
     and a.MNG012 > 0;


----------------------------------------------------------------
-----------------------采购申请---------------------------------
----------------------------------------------------------------

TRUNCATE TABLE Report_Mrp.dbo.mrp_purchase_request_order_noLine_h_detail;

INSERT INTO Report_Mrp.dbo.mrp_purchase_request_order_noLine_h_detail
	select a.DELNR1    as require_no         -- 预留号                
		  ,a.DELPS1    as require_line       -- 预留号行号  
		  ,a.MNG012    as supply_quantity    -- 匹配数量
		  ,a.DELNR2    as supply_no          -- 采购申请号
		  ,a.DAT002    as supply_date
		  ,c.inquiry_status                  -- 询价状态
		  ,a.DELKZ1    as rep_type           -- AR类型，SB类似，销售类型 ZPPT002.DELKZ1='VC' OR 'VJ'OR (ZPPT002.DELKZ1='AR' AND ZPPT002.PSPNR = 'Z-2000_XSCB004')
		  ,GETDATE() etl_time 
	 from ODS_HANA.dbo.mrp_ww a
 left join report0624.dbo.r24_inquiry_status c
	    on replace(ltrim(replace(a.MATNR, '0', ' ')), ' ', '0') = c.material_code
     where a.DELKZ2 = 'BA' -- 采购申请号
      and a.MNG012 > 0;
	  


----------------------------------------------------------------
-----------------------计划协议---------------------------------
----------------------------------------------------------------

TRUNCATE TABLE Report_Mrp.dbo.mrp_plan_protocol_order_detail;	  
---供货商库存  

TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_stock;
INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_stock  
  select  A.ORDER_NUM  
		 ,B.ORDER_ITEM_NUM
	     ,SUM(B.STOCK_QTY) STOCK_QTY_SM --供货商库存
	from ODS_SRM.dbo.srm_poc_order_hd A
	join ODS_SRM.dbo.srm_poc_order_item B 
	on A.ID = B.ORDER_ID
   where A.DELETE_FLAG = 0
	 and B.DELETE_FLAG = 0
	 and A.REF_PURCHASER_CD = '2000'
	 and B.STOCK_QTY > 0
   group by A.ORDER_NUM  
		   ,B.ORDER_ITEM_NUM;  
----计划协议：已下达
			TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_DistinctData_ar;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_DistinctData_ar 
             SELECT DISTINCT
					a.MATNR AS MATNR,  -- 物料编号
					a.DELNR1 AS rsnum, -- 预留号
					a.DELPS1 AS rspos, -- 预留号行号
					CAST(a.MNG012 AS FLOAT) AS MNG01, -- 将 MNG012 转换为数值类型
					a.DELNR2 AS DELNR, -- 计划协议号
					a.DELPS2 AS DELPS, -- 计划协议明细行号
					a.DELET2 AS DELET,
					a.DAT01 AS EINDT -- 计划协议交货行交货时间
			   FROM ODS_HANA.dbo.mrp_ww a
	      left join ( 
					  select 
							COALESCE(SUBSTRING(A.POSID,1,1), 'NA')+ '-' + COALESCE(RTRIM(LTRIM(SUBSTRING(A.POSID,2,50))), 'NA') as POSKI 
						   ,PSPNR
						from ODS_HANA.dbo.PRPS A
			       ) b
		         on a.PSPNR = b.PSPNR
			WHERE a.DELKZ1 = 'AR'
			    AND (b.POSKI <>'Z-2000_XSCB004' or b.POSKI is null)
			    AND a.DELNR2 LIKE '55%';
			   
            TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_ar;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_ar 
					SELECT
						d.MATNR,
						d.rsnum,
						d.rspos,
						d.MNG01,
						d.DELNR,
						d.DELPS,
						d.DELET,
						d.EINDT,
						(
						   SELECT SUM(d2.MNG01)
							 FROM Report_Mrp.dbo.tmp_mrp_plan_DistinctData_ar d2
							WHERE d2.DELNR = d.DELNR
							  AND d2.DELPS = d.DELPS
							  AND d2.EINDT <= d.EINDT
						) AS Cumulative_MNG01
					from Report_Mrp.dbo.tmp_mrp_plan_DistinctData_ar d;
				
			TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_55_ar;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_55_ar		
			 select a.MATNR
					,a.rsnum
					,a.rspos
					,a.MNG01
					,a.DELNR
					,a.DELPS
					,a.DELET
					,a.EINDT
					,case when b.STOCK_QTY_SM >= Cumulative_MNG01 then MNG01 else 0 end STOCK_QTY
			  from Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_ar  a
		 left join Report_Mrp.dbo.tmp_mrp_plan_stock b
				on b.ORDER_NUM      = a.DELNR 
		       and b.ORDER_ITEM_NUM = a.DELPS;
----- 计划协议：未下达
	        TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_DistinctData_sb;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_DistinctData_sb 
             SELECT DISTINCT
					a.MATNR AS MATNR,  -- 物料编号
					a.DELNR1 AS rsnum, -- 预留号
					a.DELPS1 AS rspos, -- 预留号行号
					CAST(a.MNG012 AS FLOAT) AS MNG01, -- 将 MNG012 转换为数值类型
					a.DELNR2 AS DELNR, -- 计划协议号
					a.DELPS2 AS DELPS, -- 计划协议明细行号
					a.DELET2 AS DELET,
					a.DAT01 AS EINDT -- 计划协议交货行交货时间
			   FROM ODS_HANA.dbo.mrp_ww a
			  WHERE a.DELKZ1 = 'SB'
			    AND a.DELNR2 LIKE '55%';
			   
            TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_sb;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_sb 
					SELECT
						d.MATNR,
						d.rsnum,
						d.rspos,
						d.MNG01,
						d.DELNR,
						d.DELPS,
						d.DELET,
						d.EINDT,
						(
						   SELECT SUM(d2.MNG01)
							 FROM Report_Mrp.dbo.tmp_mrp_plan_DistinctData_sb d2
							WHERE d2.DELNR = d.DELNR
							  AND d2.DELPS = d.DELPS
							  AND d2.EINDT <= d.EINDT
						) AS Cumulative_MNG01
					from Report_Mrp.dbo.tmp_mrp_plan_DistinctData_sb d;
				
			TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_55_sb;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_55_sb		
			 select a.MATNR
					,a.rsnum
					,a.rspos
					,a.MNG01
					,a.DELNR
					,a.DELPS
					,a.DELET
					,a.EINDT
					,case when b.STOCK_QTY_SM >= Cumulative_MNG01 then MNG01 else 0 end STOCK_QTY
			  from Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_sb  a
		 left join Report_Mrp.dbo.tmp_mrp_plan_stock b
				on b.ORDER_NUM      = a.DELNR 
		       and b.ORDER_ITEM_NUM = a.DELPS;
------计划协议:销售
	  TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_DistinctData_all;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_DistinctData_all 
             SELECT DISTINCT
					a.MATNR AS MATNR,  -- 物料编号
					a.DELNR1 AS rsnum, -- 预留号
					a.DELPS1 AS rspos, -- 预留号行号
					CAST(a.MNG012 AS FLOAT) AS MNG01, -- 将 MNG012 转换为数值类型
					a.DELNR2 AS DELNR, -- 计划协议号
					a.DELPS2 AS DELPS, -- 计划协议明细行号
					a.DELET2 AS DELET,
					a.DAT01 AS EINDT -- 计划协议交货行交货时间
			   FROM ODS_HANA.dbo.mrp_ww a
		 left join ( 
					  select 
							COALESCE(SUBSTRING(A.POSID,1,1), 'NA')+ '-' + COALESCE(RTRIM(LTRIM(SUBSTRING(A.POSID,2,50))), 'NA') as POSKI 
						   ,PSPNR
						from ODS_HANA.dbo.PRPS A
	                ) b
		         on a.PSPNR = b.PSPNR
			  where (
					DELKZ1 IN ('VC', 'VJ')OR (DELKZ1 = 'AR' AND b.POSKI = 'Z-2000_XSCB004')
					)
			   and a.DELNR2 LIKE '55%'; -- 计划协议
			   
			   
            TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_all;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_all 
					SELECT
						d.MATNR,
						d.rsnum,
						d.rspos,
						d.MNG01,
						d.DELNR,
						d.DELPS,
						d.DELET,
						d.EINDT,
						(
						   SELECT SUM(d2.MNG01)
							 FROM Report_Mrp.dbo.tmp_mrp_plan_DistinctData_all d2
							WHERE d2.DELNR = d.DELNR
							  AND d2.DELPS = d.DELPS
							  AND d2.EINDT <= d.EINDT
						) AS Cumulative_MNG01
					from Report_Mrp.dbo.tmp_mrp_plan_DistinctData_all d;
				
			TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_55_all;
			INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_55_all		
			 select a.MATNR
					,a.rsnum
					,a.rspos
					,a.MNG01
					,a.DELNR
					,a.DELPS
					,a.DELET
					,a.EINDT
					,case when b.STOCK_QTY_SM >= Cumulative_MNG01 then MNG01 else 0 end STOCK_QTY
			  from Report_Mrp.dbo.tmp_mrp_plan_CumulativeData_all  a
		 left join Report_Mrp.dbo.tmp_mrp_plan_stock b
				on b.ORDER_NUM      = a.DELNR 
		       and b.ORDER_ITEM_NUM = a.DELPS;
			   
  --------计划协议 节点和状态
        TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_node_status;
		INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_node_status	
		 SELECT 
				 order_num              -- 订单号			
				,order_line_num         -- 行号			
				,plan_item_num          -- 如果是协议订单，就是计划需求行号			
				,current_node_code
				,current_node_name      -- 节点code和名称	
				,n45_current_node_status
				,update_date_time
				,update_date_time as n45_update_date_time -- 当前节点时间 采购
		 from (
				 SELECT			
						order_num              -- 订单号			
						,order_line_num        -- 行号			
						,plan_item_num         -- 如果是协议订单，就是计划需求行号			
						,current_node_code
						,current_node_name      -- 节点code和名称					
						,case when current_node_status=3 THEN '结束'			
							  when current_node_status=2 THEN '异常'			
							  when current_node_status=1 THEN '开始'			
							  else 'X' end	n45_current_node_status		
						,CONVERT(VARCHAR(19), CAST(update_date_time AS DATETIME), 120) update_date_time				  
						,row_number()over(PARTITION by order_num ,order_line_num ,plan_item_num order by update_date_time desc  ) rn
				  FROM  ODS_LPS.dbo.t_logistical_task_pur_migo		
				 WHERE task_status!=3 		
			)a
		where rn = 1;
		
  -----计划协同步时间
		TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_syn_date;
		INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_syn_date	
			  SELECT
					  ORDER_NUM
					 ,ORDER_ITEM_NUM
					 ,DELIVERY_ITEM_NUM
					 ,max(UPDATED_TS) CREATED_TS --计划协同步时间
				FROM ODS_SRM.dbo.srm_poc_delivery_plan 
			   where DELETE_FLAG =0
				 and AUDIT_FLAG = 1
			   group by ORDER_NUM
					,ORDER_ITEM_NUM
					,DELIVERY_ITEM_NUM;
					
----------判断是否审批		
        TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_plan_sap_lp;
		INSERT INTO Report_Mrp.dbo.tmp_mrp_plan_sap_lp
		 select distinct 
				 ebeln
				,ebelp
				,etenr
				,fixkz
		   from [report0624].[dbo].[sap_lp];
		   

		

		INSERT INTO Report_Mrp.dbo.mrp_plan_protocol_order_detail	
			select 
				  a.MATNR
				 ,a.rsnum   -- 预留号
				 ,a.rspos   -- 预留号行号
				 ,a.MNG01   -- fixkz='X':待交货数量,fixkz='未审批'：待审批数量
				 ,a.DELNR   -- 计划协议号
				 ,a.DELPS   -- 计划行号
				 ,a.DELET   -- 计划协议交货行行号
				 ,a.EINDT   -- 计划协议交货行交货时间
				 ,a.STOCK_QTY -- 供应商库存总数
				 ,b.current_node_name -- 物流节点
				 ,b.update_date_time  -- 当前节点时间
				 ,p.CREATED_TS        -- 计划协议交货行同步时间
				 ,h.ebeln
				 ,h.ebelp
				 ,h.etenr
				 ,h.fixkz
				 ,k.SORTL             -- 供应商简称
				 ,a.rep_type
				 ,GETDATE() etl_time  -- 调度时间
			 from (
			       select 	  
						  MATNR
						 ,rsnum   -- 预留号
						 ,rspos   -- 预留号行号
						 ,MNG01   -- fixkz='X':待交货数量,fixkz='未审批'：待审批数量
						 ,DELNR   -- 计划协议号
						 ,DELPS   -- 计划行号
						 ,DELET   -- 计划协议交货行行号
						 ,EINDT   -- 计划协议交货行交货时间
						 ,STOCK_QTY -- 供应商库存总数
						 ,'AR' rep_type
					from Report_Mrp.dbo.tmp_mrp_plan_55_ar 
				   union all 
				   select MATNR
						 ,rsnum   -- 预留号
						 ,rspos   -- 预留号行号
						 ,MNG01   -- fixkz='X':待交货数量,fixkz='未审批'：待审批数量
						 ,DELNR   -- 计划协议号
						 ,DELPS   -- 计划行号
						 ,DELET   -- 计划协议交货行行号
						 ,EINDT   -- 计划协议交货行交货时间
						 ,STOCK_QTY -- 供应商库存总数from #delnr_55_sb
						 ,'SB' rep_type
					from Report_Mrp.dbo.tmp_mrp_plan_55_sb
				   union all 
				   select MATNR
						 ,rsnum   -- 预留号
						 ,rspos   -- 预留号行号
						 ,MNG01   -- fixkz='X':待交货数量,fixkz='未审批'：待审批数量
						 ,DELNR   -- 计划协议号
						 ,DELPS   -- 计划行号
						 ,DELET   -- 计划协议交货行行号
						 ,EINDT   -- 计划协议交货行交货时间
						 ,STOCK_QTY -- 供应商库存总数 from #delnr_55_all
						 ,'ALL' rep_type
					from Report_Mrp.dbo.tmp_mrp_plan_55_all
			      )a 
		left join Report_Mrp.dbo.tmp_mrp_plan_node_status b
			   on b.order_num      =  a.DELNR
			  and b.order_line_num =  SUBSTRING(a.DELPS, 2, LEN(a.DELPS))
			  and b.plan_item_num =CAST(CAST( a.DELET  AS INT) AS VARCHAR(50))
		left join Report_Mrp.dbo.tmp_mrp_plan_syn_date p
	           on p.ORDER_NUM         = a.DELNR
			  and p.ORDER_ITEM_NUM    = CAST(CAST(a.DELPS AS INT) AS NVARCHAR)
			  and p.DELIVERY_ITEM_NUM  = CAST(CAST(a.DELET AS INT) AS NVARCHAR)
        left join Report_Mrp.dbo.tmp_mrp_plan_sap_lp h 
			   on h.ebeln = a.delnr
			  and h.ebelp = stuff(ltrim(a.delps), 1, 1, '')
			  and h.etenr = a.delet
	    left join ods_hana.dbo.ekko j
			   on j.ebeln = h.ebeln
	    left join ods_hana.dbo.lfa1 k
			   on j.lifnr = k.lifnr;


----------------------------------------------------------------
-----------------------需求订单信息-----------------------------
----------------------------------------------------------------
TRUNCATE TABLE Report_Mrp.dbo.mrp_requirement_order_detail;

-- 需求订单主表
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_requirement_order_detail_require_main;
INSERT INTO Report_Mrp.dbo.tmp_mrp_requirement_order_detail_require_main
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
	 ,rep_type
	 ,POSKI
from (
	  select 
              distinct 
        	  DELNR1 as require_no                    
			 ,DELPS1 as require_line        
			 ,DEL121 as assemble_order_no  
			 ,MATNR  as req_material_code  
			 ,MNG011 as require_quantity   
	         ,BAUGR1 as parent_material_code
			 ,a.PSPNR  as wbs_code
			 ,DAT001   as delivery_date
			 ,'ALL'   as rep_type
			 ,b.POSKI  as POSKI
		from ODS_HANA.dbo.mrp_ww a
   left join (  
              select -- 把 "Z    2000_1480" 转换成 "Z_2000_1480"
					 COALESCE(SUBSTRING(A.POSID,1,1), 'NA')+ '-' + COALESCE(RTRIM(LTRIM(SUBSTRING(A.POSID,2,50))), 'NA') as POSKI 
				    ,PSPNR
				from ODS_HANA.dbo.PRPS A
	          )b
		  on  a.PSPNR = b.PSPNR
	   where 1=1
	     and (DELKZ1 IN ('VC', 'VJ')OR (DELKZ1 = 'AR' AND b.POSKI = 'Z-2000_XSCB004'))
		 and MNG011 > 0
		 
	  union all 
	  
	    select 
              distinct 
        	  DELNR1 as require_no                    
			 ,DELPS1 as require_line        
			 ,DEL121 as assemble_order_no  
			 ,MATNR  as req_material_code  
			 ,MNG011 as require_quantity   
	         ,BAUGR1 as parent_material_code
			 ,a.PSPNR  as wbs_code
			 ,DAT001   as delivery_date
			 ,'AR'   as rep_type
			 ,b.POSKI  as POSKI
		from ODS_HANA.dbo.mrp_ww a
   left join (  
              select -- 把 "Z    2000_1480" 转换成 "Z_2000_1480"
					 COALESCE(SUBSTRING(A.POSID,1,1), 'NA')+ '-' + COALESCE(RTRIM(LTRIM(SUBSTRING(A.POSID,2,50))), 'NA') as POSKI 
				    ,PSPNR
				from ODS_HANA.dbo.PRPS A
	          )b
		  on  a.PSPNR = b.PSPNR
	   where 1=1
	     and DELKZ1 = 'AR'	
         and  (b.POSKI <>'Z-2000_XSCB004' or b.POSKI is null)		 
		 and MNG011 > 0
		 
	 union all 
	  
	    select 
              distinct 
        	  DELNR1 as require_no                    
			 ,DELPS1 as require_line        
			 ,DEL121 as assemble_order_no  
			 ,MATNR  as req_material_code  
			 ,MNG011 as require_quantity   
	         ,BAUGR1 as parent_material_code
			 ,a.PSPNR  as wbs_code
			 ,DAT001   as delivery_date
			 ,'SB'   as rep_type
			 ,b.POSKI  as POSKI
		from ODS_HANA.dbo.mrp_ww a
   left join (  
              select -- 把 "Z    2000_1480" 转换成 "Z_2000_1480"
					 COALESCE(SUBSTRING(A.POSID,1,1), 'NA')+ '-' + COALESCE(RTRIM(LTRIM(SUBSTRING(A.POSID,2,50))), 'NA') as POSKI 
				    ,PSPNR
				from ODS_HANA.dbo.PRPS A
	          )b
		  on  a.PSPNR = b.PSPNR
	   where 1=1
	     and DELKZ1 = 'SB'			 
		 and MNG011 > 0

	 )a;
	 
--------售达方逻辑
	 
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_requirement_order_detail_order_name;
INSERT INTO Report_Mrp.dbo.tmp_mrp_requirement_order_detail_order_name
	      SELECT 
					a.order_no
					,a.KUNNR
					,b.NAME1
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
                on a.KUNNR = b.KUNNR;
				
				
------图号	
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_requirement_order_detail_zd_material;
INSERT INTO Report_Mrp.dbo.tmp_mrp_requirement_order_detail_zd_material	
		select OBJEK  as material_code
		      ,MAX(case when ATINN = '0000000008' then ATWRT else null end)  as figure_no -- 图号
		      ,MAX(case when ATINN = '0000000009' then ATWRT else null end)  as zd_code
		 FROM ODS_HANA.dbo.AUSP
		WHERE KLART = '001' 
		  and ATINN in ('0000000009','0000000008')
		group by OBJEK ;

----------物料名称
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_requirement_order_detail_material_main;
INSERT INTO Report_Mrp.dbo.tmp_mrp_requirement_order_detail_material_main
		 select  a.material_code
				,a.material_desc --物料名称
				,a.purchase_type_code 
				,case when purchase_type_code='E'
					  then 1 else 0 end as is_manuf   --自制
				,case when purchase_type_code='F'
					  then 1 else 0 end as is_purchase--外协
				,case when (purchase_type_code!='F') AND (purchase_type_code!='E')
					  then 1 else 0 end as is_other   --其他
		   from Report0624.dbo.material_info a;
		   
		   
--------需求订单的wbs的逻辑
TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_requirement_order_detail_wbs;
INSERT INTO Report_Mrp.dbo.tmp_mrp_requirement_order_detail_wbs
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
			 from Report0624.dbo.r24_assemble_order_detail a
		left join YJ_DIM.dbo.dim_wbs b
			 on a.wbs_code = b.wbs_code
			and b.last_version = 1;
			
			
 ---- 采购组信息
 TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_requirement_order_detail_group;
INSERT INTO Report_Mrp.dbo.tmp_mrp_requirement_order_detail_group
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
	from (
				SELECT 
					a.RSNUM as require_no,
					a.RSPOS as require_line,
					a.WERKS as plant_code,
					a.AUFNR as assemble_order_no,
					a.MATNR as req_material_code,
					c.MAKTX as req_material_desc,
					d.EKGRP as purchase_group_code,
					e.EKNAM as purchase_group_desc,
					CAST(a.BDTER as date) as require_date,
					a.MEINS as unit,
					a.BDMNG as require_quantity,
					a.ENMNG as delivery_quantity,
					CASE WHEN a.KZEAR IS NULL THEN 0 ELSE 1 END as is_delivery,
					COALESCE(a.SORTF, 'NA') as sort_string
				FROM
					ODS_HANA.dbo.RESB a 
				LEFT OUTER JOIN
					ODS_HANA.dbo.AUFK b ON a.MANDT = b.MANDT AND a.AUFNR = b.AUFNR AND a.WERKS = b.WERKS
				LEFT OUTER JOIN
					ODS_HANA.dbo.MAKT c ON a.MANDT = c.MANDT AND a.MATNR = c.MATNR
				LEFT OUTER JOIN
					ODS_HANA.dbo.MARC d ON a.MANDT = d.MANDT AND a.MATNR = d.MATNR AND a.WERKS = d.WERKS
				LEFT OUTER JOIN
					ODS_HANA.dbo.T024 e ON a.MANDT = e.MANDT AND d.EKGRP = e.EKGRP
				WHERE a.XLOEK IS NULL AND a.DUMPS IS NULL AND a.WERKS = '2000'
				AND b.AUART IN ('ZP10','ZP11','ZP12', 'ZP18', 'ZP19', 'ZP20', 'ZP21', 'ZP13')
		   )a
	 where a.require_quantity > 0;
	 
	 ---- 采购组信息
 TRUNCATE TABLE Report_Mrp.dbo.tmp_mrp_requirement_order_detail_group_s;
INSERT INTO Report_Mrp.dbo.tmp_mrp_requirement_order_detail_group_s
	 SELECT 
           require_no
		  ,require_line
		  ,plant_code
		  ,assemble_order_no
		  ,req_material_code
		  ,req_material_desc
		  ,unit
		  ,purchase_group_code
		  ,purchase_group_desc
		  ,require_date
		  ,require_quantity
		  ,delivery_quantity
		  ,is_delivery
		  ,sort_string
		  ,purchase_group_code_desc
from(  
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
			  ,a.purchase_group_code_desc
		      ,ROW_NUMBER()OVER(PARTITION BY req_material_code order by a.require_date  ) rn 
		from Report_Mrp.dbo.tmp_mrp_requirement_order_detail_group a
   ) a
   where rn = 1;

	 
		

		        INSERT INTO Report_Mrp.dbo.mrp_requirement_order_detail	
				select 
					  a.require_no           -- 预留号                
					 ,a.require_line         -- 预留号行号  
					 ,a.assemble_order_no    -- 装配订单号
					 ,a.req_material_code    -- 物料编码
					 ,a.require_quantity     -- 缺口数量
					 ,a.parent_material_code -- 父项物料编码
					 ,a.material_code        -- 物料编码
					 ,a.wbs_code             -- wbs_code 已经弃用 用下面的 POSKI
					 ,a.delivery_date        -- 需求日期
					 ,POSKI                  -- wbs_code
					 ,zd.zd_code             -- 铸锻件
					 ,zd.figure_no           -- 图号   
					 ,a.rep_type             -- sb ar ..报表类型
					 ,z.NAME1                -- 售达方
					 ,m.material_desc        -- 物料名称
					 ,m.purchase_type_code   -- 类型
					 ,m.is_manuf             -- 自制
					 ,m.is_purchase          -- 外协
					 ,m.is_other             -- 其他
					 ,n.wbs_desc                                                         
                     ,case when rep_type = 'AR' then n.wbs_category_code else  x.wbs_category_code end  wbs_category_code                                            
                     ,case when rep_type = 'AR' then n.wbs_category_desc else  x.wbs_category_desc end  wbs_category_desc                                            
                     ,n.order_type_code  
                     ,n.zp_ltxt			         -- 订单长文本	
				     ,case when rep_type in ('SB','ALL') THEN  s.purchase_group_code	  else  h.purchase_group_code	   end purchase_group_code	
					 ,case when rep_type in ('SB','ALL') THEN  s.purchase_group_desc      else h.purchase_group_desc       end purchase_group_desc	
					 ,case when rep_type in ('SB','ALL') THEN  s.purchase_group_code_desc else h.purchase_group_code_desc  end purchase_group_code_desc -- 采购组	
					 ,case when rep_type in ('SB','ALL') THEN  s.delivery_quantity        else h.delivery_quantity         end	delivery_quantity      -- 已发数量
					 ,case when rep_type in ('SB','ALL') THEN  s.sort_string              else h.sort_string               end delivery_quantity            -- 排序字符串
					 ,GETDATE() etl_time         -- 调度时间
				from Report_Mrp.dbo.tmp_mrp_requirement_order_detail_require_main a
		   left join Report_Mrp.dbo.tmp_mrp_requirement_order_detail_order_name z
		          on z.order_no = a.assemble_order_no
		   left join Report_Mrp.dbo.tmp_mrp_requirement_order_detail_zd_material zd
			      on a.req_material_code   = zd.material_code
		   left join Report_Mrp.dbo.tmp_mrp_requirement_order_detail_material_main m
		         on a.req_material_code   = m.material_code
		   left join YJ_DIM.dbo.dim_wbs x
		          on a.POSKI = x.wbs_code
		   left join Report_Mrp.dbo.tmp_mrp_requirement_order_detail_wbs n
                  on a.assemble_order_no   = n.assemble_order_no
		   left join Report_Mrp.dbo.tmp_mrp_requirement_order_detail_group h 
		          on a.require_no  = h.require_no 
                 and RIGHT(a.require_line , LEN(a.require_line ) - 2) = h.require_line
		   left join Report_Mrp.dbo.tmp_mrp_requirement_order_detail_group_s s 
		          on a.req_material_code  = s.req_material_code  
				 
				 
				 
				  
----------------------------------------------------------------
-----------------------库存-------------------------------------
----------------------------------------------------------------
   TRUNCATE TABLE Report_Mrp.dbo.mrp_stock;
   INSERT INTO Report_Mrp.dbo.mrp_stock	 
select 
         material_code
		,sum(inv_quantity) inv_quantity
		,sum(qty)          qty
		,sum(qty_1099)     qty_1099
		,sum(total)         total_qty
	    ,GETDATE() etl_time     -- 调度时间
	from( 
		 SELECT MATNR as material_code
			   ,SUM(case when LGORT = '1005' then CLABS else 0 end ) as inv_quantity
			   ,SUM(case when LGORT = '1050' then CLABS else 0 end ) as qty
			   ,SUM(case when LGORT = '1099' then CLABS else 0 end ) as qty_1099
			   ,sum(CLABS) total
		   FROM ODS_HANA.dbo.MCHB
		  WHERE WERKS = '2000' 
		  GROUP BY MATNR
		  
		union all 
		
		 select 
			   MATNR as material_code
			  ,sum(case when LGORT = '1005' then SLABS else 0 end) as inv_quantity
			  ,sum(case when LGORT = '1050' then SLABS else 0 end) as qty
			  ,SUM(case when LGORT = '1099' then SLABS else 0 end ) as qty_1099
			  ,sum(SLABS) total
		  from ODS_HANA.dbo.MKOL a
		  WHERE  WERKS = '2000' 
		  GROUP BY MATNR
		 ) a
   GROUP by material_code;