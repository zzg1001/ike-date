
-----------------年度采购总金额-------------------
SELECT SUM(contract_amount) as contract_amount
  FROM LeanProduction_Dashboard.dbo.purchase_dashboard_base_contract_info
  where sponsor_dept_code = '59TKR0X9'
and contract_year = year(GETDATE())

-------------采购计划完成率-------------------------------------
SELECT aaa.计划编号,bbb.dept_name 部门,aaa.金额,aaa.执行类型 FROM 
(
(SELECT a.purchase_plan_code 计划编号,a.exec_dept_code 部门,ISNULL(b.zxje, 0)/10000 金额,'执行' 执行类型 FROM
((SELECT purchase_plan_code,exec_dept_code,SUM(contract_amount) jhje FROM ads_purchase_contract_info
WHERE 1=1
${if(or(len(jbksrq)=0,len(jbjsrq)=0),"","AND exec_start_date_time>='"+date(year(jbksrq),1,1)+"' AND exec_end_date_time<='"+date(year(jbksrq),12,31)+"'")}
GROUP BY purchase_plan_code,exec_dept_code) a
LEFT JOIN
(SELECT purchase_plan_code,sponsor_dept_code,SUM(contract_amount) zxje FROM ads_company_contract_info
WHERE 1=1
${if(len(jbspzt)=0,"AND contract_state_desc IN ('审批通过','审批中')","AND contract_state_desc='审批通过'")}
${if(or(len(jbksrq)=0,len(jbjsrq)=0),"","AND create_date_time BETWEEN '"+jbksrq+"' AND '"+jbjsrq+"' AND contract_year='"+year(jbksrq)+"'")}
GROUP BY purchase_plan_code,sponsor_dept_code) b
ON a.purchase_plan_code=b.purchase_plan_code AND a.exec_dept_code=b.sponsor_dept_code)
)

UNION

(SELECT a.purchase_plan_code 计划编号,a.exec_dept_code 部门,(a.jhje-ISNULL(b.zxje, 0))/10000 金额,'未执行' 执行类型 FROM
((SELECT purchase_plan_code,exec_dept_code,SUM(contract_amount) jhje FROM ads_purchase_contract_info
WHERE 1=1
${if(or(len(jbksrq)=0,len(jbjsrq)=0),"","AND exec_start_date_time>='"+date(year(jbksrq),1,1)+"' AND exec_end_date_time<='"+date(year(jbksrq),12,31)+"'")}
GROUP BY purchase_plan_code,exec_dept_code) a
LEFT JOIN
(SELECT purchase_plan_code,sponsor_dept_code,SUM(contract_amount) zxje FROM ads_company_contract_info
WHERE 1=1
${if(len(jbspzt)=0,"AND contract_state_desc IN ('审批通过','审批中')","AND contract_state_desc='审批通过'")}
${if(or(len(jbksrq)=0,len(jbjsrq)=0),"","AND create_date_time BETWEEN '"+jbksrq+"' AND '"+jbjsrq+"' AND contract_year='"+year(jbksrq)+"'")}
GROUP BY purchase_plan_code,sponsor_dept_code) b
ON a.purchase_plan_code=b.purchase_plan_code AND a.exec_dept_code=b.sponsor_dept_code))
) aaa
LEFT JOIN 
ads_purchase_dept_mapping bbb
ON aaa.部门=bbb.dept_code
WHERE bbb.dept_name IS NOT NULL

----

SELECT a.amount,a.status FROM 
(
    (
        SELECT ISNULL(b.zxje, 0)/10000 amount,'执行' status  FROM
        (
            (
                SELECT purchase_plan_code,exec_dept_code,SUM(contract_amount) jhje 
                  FROM Purchase_Office_Dashboard.dbo.ads_purchase_contract_info
                 WHERE 1=1
                                   and CONVERT(date,exec_end_date_time) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                          and CONVERT(date,exec_end_date_time) <='2024-12-31'               
                      GROUP BY purchase_plan_code,exec_dept_code
            ) a
            LEFT JOIN
            (
                SELECT purchase_plan_code,sponsor_dept_code,SUM(contract_amount) zxje 
                FROM Purchase_Office_Dashboard.dbo.ads_company_contract_info
                 WHERE 1=1
                 AND contract_state_desc IN ('审批通过','审批中')
                 AND CONVERT(date,create_date_time) 
               BETWEEN CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01' 
                 AND CONVERT(DATE, GETDATE())   
                 AND contract_year=year(CONVERT(DATE, GETDATE()) )
              GROUP BY purchase_plan_code,sponsor_dept_code
            ) b
            ON a.purchase_plan_code=b.purchase_plan_code AND a.exec_dept_code=b.sponsor_dept_code
        )
    )
    UNION
    (
    SELECT (a.jhje-ISNULL(b.zxje, 0))/10000 amount,'未执行' status FROM
        (
          (
             SELECT purchase_plan_code,exec_dept_code,SUM(contract_amount) jhje 
             FROM Purchase_Office_Dashboard.dbo.ads_purchase_contract_info
            WHERE 1=1
              and CONVERT(date,exec_end_date_time) >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
                  and CONVERT(date,exec_end_date_time) <=CONVERT(DATE, GETDATE()) 
            GROUP BY purchase_plan_code,exec_dept_code
          ) a
          LEFT JOIN
          (
            SELECT purchase_plan_code,sponsor_dept_code,SUM(contract_amount) zxje 
             FROM Purchase_Office_Dashboard.dbo.ads_company_contract_info
            WHERE 1=1
            ${if(len(jbspzt)=0,"AND contract_state_desc IN ('审批通过','审批中')","AND contract_state_desc='审批通过'")}
            ${if(or(len(jbksrq)=0,len(jbjsrq)=0),"","AND create_date_time BETWEEN '"+jbksrq+"' AND '"+jbjsrq+"' AND contract_year='"+year(jbksrq)+"'")}
            GROUP BY purchase_plan_code,sponsor_dept_code
          ) b
          ON a.purchase_plan_code=b.purchase_plan_code AND a.exec_dept_code=b.sponsor_dept_code
        )
    
    )
) a
-----------------准入供应商数量----------------------------------------
 select count(distinct supplier_id) preparation_cont
  from ODS_SRM.dbo.srm_mgt_access
 where created_ts >=CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'  
   and created_ts<=CONVERT(DATE, GETDATE()) 

------------------供应商合同签订金额-----部门采购金额TOPS------------------

  

 TRUNCATE table ODS_HANA.dbo.digital_brain_purchase_department_amount_index;
insert INTO  ODS_HANA.dbo.digital_brain_purchase_department_amount_index
   select 
           SUM(contract_amount)/10000 contract_amount
          ,sponsor_dept_desc
          ,contract_year  year_b 
          ,CONVERT(VARCHAR(7), CONVERT(DATE,approved_date_time ) , 120) moth_year
          ,GETDATE() etl_time
      from Purchase_Office_Dashboard.dbo.ads_company_contract_info a
     where contract_state_desc = '审批通过' 
       AND CONVERT(DATE,approved_date_time )
     BETWEEN CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'   
       AND CONVERT(DATE, GETDATE())  
      AND contract_year=YEAR( GETDATE())
    GROUP BY sponsor_dept_desc
             ,contract_year
             ,CONVERT(VARCHAR(7), CONVERT(DATE,approved_date_time ) , 120)  
   
    union 
     select 
           SUM(contract_amount)/10000 contract_amount
           ,sponsor_dept_desc
          ,contract_year  year_b 
          ,CONVERT(VARCHAR(7), CONVERT(DATE,approved_date_time ) , 120)  moth_year
           ,GETDATE() etl_time
      from Purchase_Office_Dashboard.dbo.ads_company_contract_info 
     where contract_state_desc = '审批通过' 
       AND YEAR(approved_date_time )=YEAR( GETDATE())-1
      AND contract_year=YEAR( GETDATE())-1
    GROUP BY sponsor_dept_desc
             ,contract_year
             ,CONVERT(VARCHAR(7), CONVERT(DATE,approved_date_time ) , 120) 


---------------------------------------分级供应商金额占比------------------------------------------
    
                             select sum(contract_amount)
                                   ,c.supplier_level
                               from ODS_SRM.dbo.ct_contract a
                               join ODS_SRM.dbo.srm_md_suppliercode b 
                                 on a.vendor = b.compcode_cd 
                                and b.REF_SYS = 'SAP02'
                               join (
                                    select SUPPLIER_ID
                                          ,CASE
                            WHEN CHARINDEX('(', supplier_level) > 0
                            THEN SUBSTRING(supplier_level, 1, CHARINDEX('(', supplier_level) - 1)
                            ELSE supplier_level
                        END AS supplier_level
                                          
                                           from ODS_SRM.dbo.srm_mgt_access 
                                          where supplier_level is not null 
                                            and supplier_type like '%外%'
                                       GROUP by SUPPLIER_ID
                                          ,CASE
                            WHEN CHARINDEX('(', supplier_level) > 0
                            THEN SUBSTRING(supplier_level, 1, CHARINDEX('(', supplier_level) - 1)
                            ELSE supplier_level
                        END 
                                    )  c 
                                 on b.SRM_COMP_ID = c.SUPPLIER_ID
                              where CONVERT(DATE,create_date_time ) >= CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'   
                                AND CONVERT(DATE,create_date_time ) <=CONVERT(DATE, GETDATE()) 
                              group by c.supplier_level                               


---------------------------------采购品类合同金额占比------------------------------------------


                         select c.pur_type_name
                                ,sum(contract_amount)  contract_amount
                                ,d.category_type_name
                           from ODS_SRM.dbo.ct_contract_purchase_plan a
                           join ODS_SRM.dbo.srm_purch_plan_item b 
                             on a.plan_code = b.pur_plan_item_code
                            and a.is_deleted = 0
                           join ODS_SRM.dbo.srm_purch_catalog c 
                             on b.pur_category_id = c.id
                           join ODS_SRM.dbo.purchase_plan_department_category_mapping d 
                             on d.purchase_category_num = b.pur_category_code 
                            and d.plan_department =  b.organizing_dept_name
                          where CONVERT(DATE,a.create_date_time ) >= CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '-01-01'   
                            AND CONVERT(DATE,a.create_date_time ) <=CONVERT(DATE, GETDATE()) 
                          GROUP by c.pur_type_name
                                  ,d.category_type_name 










TRUNCATE table Outsourcing_Dashboard.dbo.digital_brain_purchase_plan_amount;

INSERT  into  Outsourcing_Dashboard.dbo.digital_brain_purchase_plan_amount
       
select A.id                                          as contract_id
               ,contract_code_perfix + contract_serial_number as contract_code
           ,a.contract_year
           ,a.contract_amount                             as contract_amount
           ,sponsor_dept_code
           ,sponsor_dept_name                             as sponsor_dept_desc
           ,vendor                                        as vendor_code
           ,vendor_name                                   as vendor_desc
           ,B.type_name                                   as contract_type_desc
           ,contract_state                                as contract_state_code
           ,case contract_state
               when 0 then '草稿'
               when 1 then '审批中'
               when 2 then '审批通过'
               when 3 then '已废弃' end                     as contract_state_desc
           ,chargs                                        as batch_code
           ,order_nums                                    as order_no_list
           ,A.create_user_name                            as create_user_code
           
           ,A.create_user_cn_name                         as create_user_name
           ,A.create_date_time
           ,delivery_date                                 as delivery_date_time
           ,CONVERT(DATE, approved_date)                  as approved_date_time
           ,c.contract_amount                             as plan_contract_amount -- 合同计划金额
           ,g.supplier_level
           ,g.SUPPLIER_ID
           ,g.supplier_created_date
           ,e.category_type pur_type_name
           ,e.category_type_name
           ,GETDATE() etl_time
       -- into  Outsourcing_Dashboard.dbo.digital_brain_purchase_plan_amount
       from ODS_SRM.dbo.ct_contract A
  left join ODS_SRM.dbo.ct_contract_type B 
         on A.contract_type_id = B.id
        and B.is_deleted = 0
       join ODS_SRM.dbo.ct_contract_purchase_plan c 
         on c.contract_id = a.id
        and c.is_deleted = 0
       join ODS_SRM.dbo.srm_purch_plan_item d
         on c.plan_code = d.pur_plan_item_code
        and d.is_modified = 0
        and d.is_deleted = 0
  left join ODS_SRM.dbo.srm_purch_catalog m 
         on d.pur_category_id = m.id
  left join (select distinct purchase_category_num
                   ,category_type_name 
                   ,plan_department 
                   ,category_type
              from ODS_SRM.dbo.purchase_plan_department_category_mapping
              ) e
         on e.purchase_category_num = d.pur_category_code 
        and e.plan_department =  d.organizing_dept_name
  left join ODS_SRM.dbo.srm_md_suppliercode f 
         on a.vendor = f.compcode_cd 
        and f.REF_SYS = 'SAP02'
  left join (
                      select SUPPLIER_ID
                            ,CONVERT(DATE, created_ts) supplier_created_date
                            ,CASE
                                 WHEN CHARINDEX('(', supplier_level) > 0
                                 THEN SUBSTRING(supplier_level, 1, CHARINDEX('(', supplier_level) - 1)
                             ELSE supplier_level
                             END AS supplier_level      
                       from ODS_SRM.dbo.srm_mgt_access a
                      where supplier_level is not null 
                        and purchaser_id = 'BUYER0000000001'
                        and supplier_type like '%外%'
                      GROUP by SUPPLIER_ID
                             ,CASE
                                   WHEN CHARINDEX('(', supplier_level) > 0
                                   THEN SUBSTRING(supplier_level, 1, CHARINDEX('(', supplier_level) - 1)
                              ELSE supplier_level END
                             ,CONVERT(DATE, created_ts)
             ) g
         on f.SRM_COMP_ID = g.SUPPLIER_ID
      where a.purchaser_cd = '2000'
        and A.is_deleted = 0
        --  AND contract_year=YEAR( GETDATE())
         






