INITIAL_STAT_KEY
A_ACCO: 已记录/已记账
A_PEND: 待处理/待批准
A_NOTF: 待通知
A_PECO: 已邮寄/待回收
A_PVAL: 已验证
P_PROC: 处理中
P_PAID: 已支付


ROLE_CODE
TRAVELER: 可能指出差旅人员或者差旅申请人。
MANAGER: 可能指出部门经理或批准人员。
REQ_TRAVELER: 可能指出差旅申请人。
REQ_MANAGER: 可能指出差旅申请的批准人员。
BDGT_APPROVER: 可能指出预算审批人员。
INT_TRVL: 可能指出内部差旅人员。
BUDGET_OWNER: 可能指出预算负责人。


select 
        b.PROCESS_KEY
        ,c.STEP_KEY
        ,b.name
        ,c.SEQUENCE_ORDER
        ,c.INITIAL_STAT_KEY
        ,c.ROLE_CODE
        ,c.AUTH_APPROVER_LEVEL
        ,c.ALLOW_STEP_EXIT_WITH_EXCEPTION
        ,d.name step_name
from fendi.dbo.ct_workflow_process a
left join ct_workflow_process_lang b 
      on a.PROCESS_KEY = b.PROCESS_KEY 
       and a.IS_DELETED ='N'
 left join fendi.dbo.ct_workflow_step c 
        on a.PROCESS_KEY = c.PROCESS_KEY
       and c.IS_DELETED='N'
 left join fendi.dbo.ct_workflow_step_lang d 
        on d.STEP_KEY  = c.STEP_KEy
     where a.PROCESS_KEY ='2043'
     ORDER by c.SEQUENCE_order  




    select EMAIL_ADDRESS from  fendi.dbo.ct_employee ce where EMP_KEY='2467'                
                select CURRENT_WORKFLOW from fendi.dbo.ct_report a where REPORT_ID='4C50CF93460E46589154'
                select * from fendi.dbo.ct_workflow_step_instance WHERE  STEP_INSTANCE_KEY ='44618'  
                select * from fendi.dbo.ct_workflow_step where STEP_KEY='2234'
                select * from fendi.dbo.ct_workflow_process_instance cwpi  WHERE  PROCESS_KEY ='2043'
                select ce.FIRST_NAME+ce.MIDDLE_NAME +ce.LAST_NAME  from  fendi.dbo.ct_employee ce where EMP_KEY='2337'  
                
                
                    select * from  fendi.dbo.ct_employee ce where EMP_KEY='1'                

                
                 select a.REPORT_ID 
                        ,c.PROCESS_KEY
                        ,f.STEP_KEY
                        ,e.NAME
                        
                 from fendi.dbo.ct_report a 
                 join fendi.dbo.ct_workflow_step_instance b 
                   on a.CURRENT_WORKFLOW = b.STEP_INSTANCE_KEY
                 join fendi.dbo.ct_workflow_step c 
                   on b.STEP_KEY = c.STEP_KEY    
                 join fendi.dbo.ct_workflow_process d 
                   on d.PROCESS_KEY = c.PROCESS_KEY
                  and d.IS_DELETED = 'N'      
                 join fendi.dbo.ct_workflow_process_lang e 
                   on e.PROCESS_KEY = c.PROCESS_KEY
                 join fendi.dbo.ct_workflow_step f 
                   on f.PROCESS_KEY =d.PROCESS_KEY
               
                   
                 where   REPORT_ID='4C50CF93460E46589154'
                 
                 
                 select * from fendi.dbo.ct_workflow_step_instance WHERE STEP_KEY='2232'                 
                 select * from fendi.dbo.ct_workflow_process_instance WHERE PROCESS_KEY='2043'
                 
                 select * from fendi.dbo.ct_workflow_step cwsi  
                 
                 
                 
                 select * from ct_workflow_step_instance WHERE STEP_INSTANCE_KEY ='119262'                
                 
                 
                         
                 select a.CURRENT_WORKFLOW
                 from fendi.dbo.ct_report a 
                 join fendi.dbo.ct_workflow_step_instance b 
                   on a.CURRENT_WORKFLOW = b.STEP_INSTANCE_KEY
                 join fendi.dbo.ct_workflow_step c 
                   on b.STEP_KEY = c.STEP_KEY    
                 join fendi.dbo.ct_workflow_process d 
                   on d.PROCESS_KEY = c.PROCESS_KEY
                  and d.IS_DELETED = 'N'      
                 where   REPORT_ID='4C50CF93460E46589154'
                 
                 
                 select * from fendi.dbo.ct_workflow_step
                 
                                                   select * from fendi.dbo.ct_workflow_step cws  where  PROCESS_KEY ='2043'
                                                   select * from fendi.dbo.ct_workflow_step_instance cwsi          where  PROCESS_KEY ='2043'

                 
                                  select * from fendi.dbo.ct_workflow_process where  PROCESS_KEY ='2043'
                                  
 select *from fendi.dbo.ct_workflow_process_instance cwpi  where PROCESS_KEY ='2043'


                 
                 select count(distinct CURRENT_WORKFLOW) from fendi.dbo.ct_report
                 
                                                                    select * from fendi.dbo.ct_workflow_process_instance cwpi  where  PROCESS_KEY ='2043'

                      select  CURRENT_WORKFLOW
                 from fendi.dbo.ct_report a 
                 where   REPORT_ID='4C50CF93460E46589154'
                 
                 
                 select * from fendi.dbo.ct_workflow_step_instance where PROCESS_INSTANCE_KEY ='1'
                  select * from fendi.dbo.ct_workflow_process_instance cwpi where PROCESS_INSTANCE_KEY ='1'

select *from fendi.dbo.ct_workflow_process_instance cwpi  where PROCESS_KEY ='2043'
                 
                        select a.PROCESS_INSTANCE_KEY 
                              ,b.PROCESS_INSTANCE_KEY
                              ,b.STEP_INSTANCE_KEY
                          from  fendi.dbo.ct_workflow_process_instance a 
                          join fendi.dbo.ct_workflow_step_instance b 
                            on a.PROCESS_INSTANCE_KEY = b.PROCESS_INSTANCE_KEY
                            where a.PROCESS_INSTANCE_KEY='44618'
                         
                 select count(1) from fendi.dbo.ct_workflow_step_instance 
                 
                        select a from fendi.dbo.ct_report a 
                                 join fendi.dbo.ct_workflow_step_instance b 
                                   on a.CURRENT_WORKFLOW = b.STEP_INSTANCE_KEY 
                                 join fendi.dbo.ct_workflow_process_instance c 
                                   on c.PROCESS_INSTANCE_KEY = b.PROCESS_INSTANCE_KEY
                                 where  REPORT_ID='411A17A56D674552B45B'
                                 
                                 
                                 
                                     select * from fendi.dbo.ct_workflow_step_instance where PROCESS_INSTANCE_KEY ='1'
                  select * from fendi.dbo.ct_workflow_process_instance cwpi where PROCESS_INSTANCE_KEY ='1'
                                 
                                          select a.REPORT_ID
                                                ,a.APS_KEY
                                                ,isnull(ce.FIRST_NAME,'')+isnull(ce.MIDDLE_NAME,'')+isnull(ce.LAST_NAME,'') emp_name
                                                ,d.name step_name
                                                ,isnull(se.FIRST_NAME,'')+isnull(se.MIDDLE_NAME,'')+isnull(se.LAST_NAME,'')  Approval_name
                                                ,se.EMAIL_ADDRESS
                                            from fendi.dbo.ct_report a 
                                            join fendi.dbo.ct_employee ce
                                              on a.EMP_KEY = ce.EMP_KEY
                                            join dbo.ct_workflow_process_instance b
                                              on a.CURRENT_WORKFLOW = b.PROCESS_INSTANCE_KEY
                                            join fendi.dbo.ct_workflow_step_instance c 
                                              on c.PROCESS_INSTANCE_KEY = b.PROCESS_INSTANCE_KEY 
                                             and c.IS_DELETED = 'N'
                                       left join fendi.dbo.ct_employee se
                                              on se.EMP_KEY = c.EMP_KEY
                                            join fendi.dbo.ct_workflow_step_lang d 
                                              on c.STEP_KEY = d.STEP_KEY
                                           where  REPORT_ID='411A17A56D674552B45B'
                                           order by c.SEQUENCE_ORDER
                                           


                                                select     a.REPORT_ID '报告ID'
            ,a.name  '报告名称'
            ,a.rpt_key '报告key'
        --  ,a.APS_KEY
            ,i.name '审批状态'
            ,ce.EMP_ID  '员工 ID'
            ,isnull(ce.LAST_NAME,'') +','+isnull(ce.FIRST_NAME,'')+isnull(ce.MIDDLE_NAME,'') '员工姓名'
        --  ,b.PROCESS_INSTANCE_KEY
        --  ,b.PROCESS_KEY
        --  ,c.STEP_INSTANCE_KEY
        -- ,c.STEP_KEY 
          
            ,e.value country
            ,j.NAME Currency
            ,f.value Company 
            ,g.value Department
        from fendi.dbo.ct_report a 
        join fendi.dbo.ct_employee ce
          on a.EMP_KEY = ce.EMP_KEY
        join dbo.ct_workflow_process_instance b
          on a.CURRENT_WORKFLOW = b.PROCESS_INSTANCE_KEY
        join fendi.dbo.ct_workflow_step_instance c 
          on c.PROCESS_INSTANCE_KEY = b.PROCESS_INSTANCE_KEY 
         and c.IS_DELETED = 'N'
   left join fendi.dbo.ct_employee se
          on se.EMP_KEY = c.EMP_KEY
        join fendi.dbo.ct_workflow_step_lang d 
          on c.STEP_KEY = d.STEP_KEY
   l
                                           
------1-------------------------------------

     select     a.REPORT_ID 
            ,a.name  
            ,a.rpt_key 
          ,a.APS_KEY
            ,i.name 
            ,ce.EMP_ID  
         ,b.PROCESS_INSTANCE_KEY
         ,b.PROCESS_KEY
         ,c.STEP_INSTANCE_KEY
        ,c.STEP_KEY 
        
        from fendi.dbo.ct_report a 
        join fendi.dbo.ct_employee ce
          on a.EMP_KEY = ce.EMP_KEY
        join dbo.ct_workflow_process_instance b
          on a.CURRENT_WORKFLOW = b.PROCESS_INSTANCE_KEY
        join fendi.dbo.ct_workflow_step_instance c 
          on c.PROCESS_INSTANCE_KEY = b.PROCESS_INSTANCE_KEY 
         and c.IS_DELETED = 'N'
   left join fendi.dbo.ct_employee se
          on se.EMP_KEY = c.EMP_KEY

         on m.stat_key = c.FINAL_STAT_KEY
      where  REPORT_ID='80F856D1FA4E40C69AA6'
       order by a.REPORT_ID
                ,c.SEQUENCE_ORDER;

---------------------------------------------------------
    select     a.REPORT_ID '报告ID'
            ,a.name  '报告名称'
            ,a.rpt_key '报告key'
        --  ,a.APS_KEY
            ,i.name '审批状态'
            ,ce.EMP_ID  '员工 ID'
            ,isnull(ce.LAST_NAME,'') +','+isnull(ce.FIRST_NAME,'')+isnull(ce.MIDDLE_NAME,'') '员工姓名'
        --  ,b.PROCESS_INSTANCE_KEY
        --  ,b.PROCESS_KEY
        --  ,c.STEP_INSTANCE_KEY
        -- ,c.STEP_KEY 
          
            ,e.value country
            ,j.NAME Currency
            ,f.value Company 
            ,g.value Department
            ,h.value  'Cost Center'
            ,l.name   '策略'
            ,a.CUSTOM17 'Vendor ID'
          -- ,c.FINAL_STAT_KEY
            ,isnull(se.LAST_NAME,'')+','+isnull(se.FIRST_NAME,'')+isnull(se.MIDDLE_NAME,'') '审批人'
            ,isnull(se.EMAIL_ADDRESS,'system')  '审批人邮件'
            ,d.name '审批流程'
            ,m.name  '审批流程状态'
            ,c.LAST_MODIFIED '审批时间'
         --   ,a.COMPANY_TO_CREDIT_CARDS_AMOUNT
            ,a.COMPANY_TO_EMPLOYEE_AMOUNT '公司到员工的金额'
            ,a.CREATION_DATE '报告创建时间'
            ,SEQUENCE_ORDER '审批流程的循序'
        from fendi.dbo.ct_report a 
        join fendi.dbo.ct_employee ce
          on a.EMP_KEY = ce.EMP_KEY
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
      left join (select  * 
               ,ROW_NUMBER()over(PARTITION  by pol_key order  by POL_KEY  )rn
               from ct_policy_lang
               ) l
          on l.POL_KEY = a.POL_KEY  
          and l.rn=1
   left join fendi.dbo.ct_status_lang m
         on m.stat_key = c.FINAL_STAT_KEY
       order by a.REPORT_ID
                ,c.SEQUENCE_ORDER;		
               
               
		
		