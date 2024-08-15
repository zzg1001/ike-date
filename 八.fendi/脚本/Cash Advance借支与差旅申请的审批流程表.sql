
	
	
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
             ,c.LAST_MODIFIED '审批时间'
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
       order by a.REQUEST_ID
                ,c.SEQUENCE_ORDER;
								
								
	