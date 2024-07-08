	
	select * from  fendi.dbo.ct_authorization_request 
	where  REQUEST_ID='3X3F'
	
	select * from ct_exception_lang
	
	select * from ct_workflow_process_instance where inst 72057
	
	select * from ct_report where RPT_KEY='39335'
	select * from ct_authorization_request where  REQUEST_ID='6D4P'
		select * from ct_authorization_request where  AR_KEY='27546'

	ct_exception_lang
	select * from ct_workflow_process_instance where  PROCESS_INSTANCE_KEY='72057'
	select * from ct_ar_exception
	      
	select * from ct_report_entry where rpe_key='39335'
	
	select * from ct_atn_ar_entry_map
	select * from ct_cash_advance_entry where AR_KEY
	
	select * from ct_atn_ar_entry_map
	select * from ct_ar_proposal
	
	select * from ct_report_ar_map where AR_KEY='27546'
	
	select * from ct_ar_exception where AR_KEY='27546'
	select * from ct_exception where XCT_KEY='2253'
	select * from ct_cash_advance_entry
	select * from ct_workflow_step_instance
	select * from ct_ar_exception_atn_amt where AR_KEY='27546'

	
	
	     select   
			 a.AR_KEY
			,a.REQUEST_ID
			,i.name '审批状态'
			,isnull(ce.LAST_NAME,'') +','+isnull(ce.FIRST_NAME,'')+isnull(ce.MIDDLE_NAME,'') '员工姓名'
			,ce.EMAIL_ADDRESS  '电子邮件地址'
		     ,e.value country
            ,f.value Company 
            ,g.value Department
            ,h.value  'Cost Center'
			,l.name   '申请策略'
			,a.START_DATE '开始日期'
			,a.END_DATE '结束日期'
			,isnull(se.LAST_NAME,'')+','+isnull(se.FIRST_NAME,'')+isnull(se.MIDDLE_NAME,'') '审批人'
            ,isnull(se.EMAIL_ADDRESS,'system')  '审批人邮件'
            ,d.name '审批流程'
            ,m.name  '审批流程状态'
            ,a.PURPOSE '目的'
            ,a.TOTAL_POSTED_AMOUNT as '金额'
            ,a.AR_TYPE_CODE '申请类型'
            ,c.SEQUENCE_ORDER
        from fendi.dbo.ct_authorization_request a 
        join fendi.dbo.ct_employee ce
          on a.EMP_KEY = ce.EMP_KEY
	 left join fendi.dbo.ct_report_ar_map ap 
				  on a.AR_KEY = ap.AR_KEY
	 left join ct_report ar 
	        on ap.rpt_key = ar.rpt_key
        join dbo.ct_workflow_process_instance b
          on a.CURRENT_WORKFLOW = b.PROCESS_INSTANCE_KEY
        join fendi.dbo.ct_workflow_step_instance c 
          on c.PROCESS_INSTANCE_KEY = b.PROCESS_INSTANCE_KEY 
         and c.IS_DELETED = 'N'
   left join fendi.dbo.ct_employee se
          on se.EMP_KEY = c.EMP_KEY
        join fendi.dbo.ct_workflow_step_lang d 
          on c.STEP_KEY = d.STEP_KEY
   left join ct_list_item_lang e 
          on ce.ORG_UNIT_1 = e.LI_KEY
   left join ct_list_item_lang f 
          on ce.ORG_UNIT_2 = f.LI_KEY
   left join ct_list_item_lang g 
          on ce.ORG_UNIT_3 = g.LI_KEY
   left join ct_list_item_lang h
          on ce.ORG_UNIT_4 = h.LI_KEY
   left join fendi.dbo.ct_status_lang i
          on i.stat_key = a.APS_KEY
   left join ct_currency_lang j
          on j.CRN_KEY = a.CRN_KEY
      left join  ct_policy_lang l
          on l.POL_KEY = a.POL_KEY  
   left join fendi.dbo.ct_status_lang m
         on m.stat_key = c.FINAL_STAT_KEY
      where 1=1
			and a.IS_DELETED='N'
		    and REQUEST_ID='33AT'
       order by a.REQUEST_ID
                ,c.SEQUENCE_ORDER;
								
								
								
		--------------------------------------------------------------------------------						
								
								
	 select 
       b.name                as '策略'
       ,''                   as '预支现金名称'  -- CT_CASH_ADVANCE
       ,c.LAST_NAME+','+FIRST_NAME as '员工'
       ,c.EMP_ID             as '员工ID'
       ,ad.Description       as 'Description 描述'
       ,a.START_DATE         as '开始时间'
       ,a.END_DATE           as '结束时间'
       ,ar.PURPOSE           as '目的'
       ,e.name               as '币种'
       ,a.CA_UTILIZED_AMOUNT as '金额'
       ,f.COMMENT_PARAMS     as '预支现金备注'
       ,a.PROCESSING_PAYMENT_DATE as '发放日期'
       ,ad.EXCHANGE_RATE     as '汇率'
   from fendi.dbo.ct_report a 
            join fendi.dbo.ct_report_entry ad 
              on a.RPT_KEY = ad.RPT_KEY 
            join fendi.dbo.ct_cash_advance_entry ca 
              on ad.RPE_KEY = ca.RPE_KEY
       left join fendi.dbo.ct_expense_type_lang exp_type
          on exp_type.exp_key = ad.exp_key
       left join fendi.dbo.ct_policy_lang b
             on a.POL_KEY = b.POL_KEY 
      left join fendi.dbo.ct_employee c 
             on c.EMP_KEY = a.EMP_KEY 
      left join  fendi.dbo.ct_currency_lang e
          on a.CRN_KEY = e.CRN_KEY        
      left join fendi.dbo.ct_report_ar_map ap  
          on a.RPT_KEY = ap.RPT_KEY
      left join  fendi.dbo.ct_authorization_request ar 
             on ap.AR_KEY = ar.AR_KEY
      left join ct_expense_comment f 
             on f.RPE_KEY = ad.RPE_KEY
      where  a.REPORT_ID='5D7CE2B13DAC45A9A4A0'
			
			
			select * from fendi.dbo.ct_report_ar_map where AR_KEY='27546'
				select RPT_KEY,* from ct_report where RPT_KEY='38809'
				
				select * from fendi.dbo.ct_report_entry where RPT_KEY='39335'
				
				
								select RPT_KEY,* from ct_report where RPT_KEY='39335'


								select * from ct_workflow_process_instance where PROCESS_INSTANCE_KEY ='72057'
								
								select * from ct_authorization_request where AR_KEY ='27546'
								
								