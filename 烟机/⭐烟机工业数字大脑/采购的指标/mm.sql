truncate table Purchase_Office_Dashboard.dbo.ads_company_contract_info
insert into Purchase_Office_Dashboard.dbo.ads_company_contract_info
select A.contract_code,
       batch_code,
       order_no_list,
       contract_type_desc,
       create_date_time,
       approved_date_time,
       contract_year,
       delivery_date_time,
       create_user_name,
	   sponsor_dept_code,
       sponsor_dept_desc,
       A.vendor_code,
       left(A.vendor_desc,2) + '**********',
       contract_state_desc,
       left(target_desc,2) + '**********',
       B.contract_amount,
       B.purchase_plan_code,
       B.actual_purchase_type_desc,
       isnull(C.statstic_caliber,'非行业单一来源供方') as statstic_caliber
from Purchase_Office_Dashboard.dbo.base_contract_info A
         left join Purchase_Office_Dashboard.dbo.base_contract_purchase_plan_relation B 
         on A.contract_id = B.contract_id
         left join Purchase_Office_Dashboard.dbo.apd_vendor_statstic_caliber C 
         on A.vendor_code = C.vendor_code




truncate table Purchase_Office_Dashboard.dbo.base_purchase_plan_info
insert into Purchase_Office_Dashboard.dbo.base_purchase_plan_info
select id                        as purchase_plan_id,
       pur_plan_item_code        as purchase_plan_code,
       pur_plan_item_name        as purchase_plan_desc,
       plan_year                 as purchase_plan_year,
       organizing_dept_code      as org_dept_code,
       organizing_dept_name      as org_dept_desc,
       exec_dept_code,
       exec_dept_name            as exec_dept_desc,
       pur_category_code         as purchase_category_code,
       pur_category_name         as purchase_category_desc,
       contract_code             as contract_code_list,
       contract_quantity,
       year_contract_amt         as contract_amount,
	   approve_status		     as approve_status_code,
       case approve_status
           when 0 then '草稿'
           when 1 then '审批中'
           when 2 then '初审通过'
		   when 3 then '审批通过'
           when 4 then '已废弃' end as approve_status_desc,
       pur_mode                  as purchase_mode_code,
       case pur_mode
           when 0 then '公开招标'
           when 1 then '单一来源'
           when 2 then '竞争性谈判'
           when 3 then '询价'
           when 4 then '邀请招标'
           when 5 then '竞争性磋商'
           when 6 then '询比' end  as purchase_mode_desc,
       curing_pur_mode           as curing_purchase_mode_code,
       case curing_pur_mode
           when 0 then '公开招标'
           when 1 then '单一来源'
           when 2 then '竞争性谈判'
           when 3 then '询价'
           when 4 then '邀请招标'
           when 5 then '竞争性磋商'
           when 6 then '询比' end  as curing_purchase_mode_desc,
       exec_time_from            as exec_start_date_time,
       exec_time_to              as exec_end_date_time,
       cumulative_amt            as cumulative_amount,
       year_financial_budget_amt as budget_amount,
	   process_apply_date,
       process_release_date
from ODS_SRM.dbo.srm_purch_plan_item
where is_deleted = 0 and is_modified = 0 and exec_dept_code in (select dept_code from Purchase_Office_Dashboard.dbo.ads_purchase_dept_mapping)



--

truncate table Purchase_Office_Dashboard.dbo.base_contract_info
insert into Purchase_Office_Dashboard.dbo.base_contract_info
		select A.id                                          as contract_id
		       ,contract_code_perfix + contract_serial_number as contract_code
		       ,contract_year
		       ,target_description                            as target_desc
		       ,contract_amount
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
		       ,approved_date                                 as approved_date_time
		       ,c.contract_amount                             as plan_contract_amount -- 合同计划金额
       from ODS_SRM.dbo.ct_contract A
  left join ODS_SRM.dbo.ct_contract_type B 
         on A.contract_type_id = B.id
        and B.is_deleted = 0
       join ODS_SRM.dbo.ct_contract_purchase_plan c 
         on c.contract_id = a.id
        and c.is_deleted = 0
       join ODS_SRM.dbo.srm_purch_plan_item d
         on c.plan_code = d.pur_plan_item_code
        and d.is_deleted = 0
where purchaser_cd = '2000'
  and A.is_deleted = 0
 




  truncate table Purchase_Office_Dashboard.dbo.base_contract_purchase_plan_relation
insert into Purchase_Office_Dashboard.dbo.base_contract_purchase_plan_relation
select A.id                                          as ct_contract_purchase_plan_id,
       plan_id                                       as purchase_plan_id,
       plan_code                                     as purchase_plan_code,
       pur_plan_item_name                            as purchase_plan_name,
       plan_purchase_type                            as plan_purchase_type_code,
       case plan_purchase_type
           when 0 then '公开招标'
           when 1 then '单一来源'
           when 2 then '竞争性谈判'
           when 3 then '询价'
           when 4 then '邀请招标'
           when 5 then '竞争性磋商'
           when 6 then '询比' end                      as plan_purchase_type_desc,
       actual_purchase_type                          as actual_purchase_type_code,
       case actual_purchase_type
           when 0 then '公开招标'
           when 1 then '单一来源'
           when 2 then '竞争性谈判'
           when 3 then '询价'
           when 4 then '邀请招标'
           when 5 then '竞争性磋商'
           when 6 then '询比' end                      as actual_purchase_type_desc,
       contract_id,
       contract_code_perfix + contract_serial_number as contract_code,
       A.contract_amount
from ODS_SRM.dbo.ct_contract_purchase_plan A
         inner join ODS_SRM.dbo.ct_contract B on A.contract_id = B.id
where A.is_deleted = 0
  and B.is_deleted = 0
  and B.purchaser_cd = '2000'















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
               ,approved_date                                 as approved_date_time
               ,c.contract_amount                             as plan_contract_amount -- 合同计划金额
               ,g.supplier_level
               ,g.SUPPLIER_ID
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
  left join (select distinct purchase_category_num
                   ,plan_department 
              from ODS_SRM.dbo.purchase_plan_department_category_mapping
              ) e
         on e.purchase_category_num = d.pur_category_code 
        and e.plan_department =  d.organizing_dept_name
  left join ODS_SRM.dbo.srm_md_suppliercode f 
         on a.vendor = f.compcode_cd 
        and f.REF_SYS = 'SAP02'
  left join (
                      select SUPPLIER_ID
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
             ) g
         on f.SRM_COMP_ID = g.SUPPLIER_ID
      where a.purchaser_cd = '2000'
        and A.is_deleted = 0;
  