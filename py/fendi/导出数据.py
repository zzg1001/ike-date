import pandas as pd
from sqlalchemy import create_engine

# 数据库连接配置
server = '139.196.89.86'
database = 'fendi'
username = 'fendi'
password = 'Password.1'
driver = 'ODBC Driver 17 for SQL Server'

# 创建数据库连接引擎
connection_string = f'mssql+pyodbc://{username}:{password}@{server}/{database}?driver={driver.replace(" ", "+")}'
engine = create_engine(connection_string)

# 执行SQL查询
query = '''
   
          select 
           b.LAST_NAME+','+b.FIRST_NAME  as 'Employee'
          ,b.EMP_ID                      as 'Employee ID'
          ,a.REPORT_ID                   as 'Report ID'
          ,a.name                        as 'Report Name'
          ,''                            as 'Report Type'
          ,a.REPORT_TYPE                 as 'Report Type Code'
          ,d.REQUEST_ID                  as 'Request ID'
          ,e.ACCOUNT_CODE                as 'Account Code'
          ,f.name                        as 'Expense Type'
          ,g.LI_SHORT_CODE               as 'Custom 5 - Name'
          ,a.START_DATE                  as 'Start Date'
          ,a.END_DATE                    as 'End Date'
          ,''                            as 'Sent for Payment Date'
          ,ay.TRANSACTION_DATE           as 'Transaction Date'
          ,ay.IS_PERSONAL                 as 'Personal'
          ,ay.VENDOR_DESCRIPTION         as 'Vendor'
          ,a.CTRY_SUB_CODE               as 'Entry City/Location'
          ,p.NAME                        as 'Payment Type'
          ,a.CA_RETURNS_AMOUNT           as 'Entry Expense Amount (reimbursement currency)'
          ,ay.APPROVED_AMOUNT            as 'Entry Approved Amount'
          ,ay.ATTENDEE_COUNT             as 'Number of Attendees'
          ,a.FIRST_SUBMIT_DATE           as 'First Submitted Date'
          ,h.NAME                        as 'Approval Status'
          ,ar.PURPOSE                    as 'Purpose'
          ,i.name                        as 'Payment Status'
          ,j.ALPHA_CODE                  as 'Reimbursement Currency'
          ,k.VALUE                       as 'Cost Center'
          ,a.ORG_UNIT_4                  as 'Cost Center - Code'
          ,m.LEDGER_CODE                 as 'Ledger Code'
          ,n.LI_SHORT_CODE               as 'Employee Org Unit 4 - Code'
          ,o.LI_SHORT_CODE               as 'Employee Org Unit 3 - Code'
          from fendi.dbo.ct_report a 
     left join fendi.dbo.ct_report_entry ay
          on a.RPT_KEY = ay.RPT_KEY
     left join fendi.dbo.ct_employee b
            on b.EMP_KEY = b.EMP_KEY
     left join fendi.dbo.ct_report_ar_map c  
            on a.RPT_KEY = c.RPT_KEY
          join fendi.dbo.ct_authorization_request d
            on c.AR_KEY = d.AR_KEY
     left join ct_acct_node_exp_type_map e 
            on ay.EXP_KEY = e.EXP_KEY 
           and e.ACCT_CODE_TYPE = 1
     left join fendi.dbo.ct_expense_type_lang f
            on f.exp_key = ay.exp_key
     left join ct_account_node an
       on e.NODE_KEY = an.NODE_KEY 
     left join ct_list_item_map g 
            on g.LI_KEY = a.CUSTOM5 
     left join ct_payment_type_lang p
            on ay.PAT_KEY = p.PAT_KEY 
     left join ct_status_lang h 
            on a.APS_KEY = h.STAT_KEY 
     left join fendi.dbo.ct_report_ar_map ap  
          on a.RPT_KEY = ap.RPT_KEY
     left join  fendi.dbo.ct_authorization_request ar 
            on ap.AR_KEY = ar.AR_KEY
     left join ct_status_lang i 
            on a.APS_KEY = i.STAT_KEY 
     left join ct_currency j 
            on j.CRN_KEY = ay.CRN_KEY 
     left join fendi.dbo.ct_list_item_lang k
          on a.ORG_UNIT_4 = k.LI_KEY
     left join ct_ledger m 
       on m.LEDGER_KEY = an.LEDGER_KEY
     left join ct_list_item_map n 
            on a.ORG_UNIT_4 = n.LI_KEY 
     left join ct_list_item_map o 
            on a.ORG_UNIT_3 = o.LI_KEY 


'''  # 替换为你的表名
df = pd.read_sql(query, engine)

# 将数据写入Excel文件
output_file = '/Users/zhangzuogong/Desktop/output.xlsx'
df.to_excel(output_file, index=False)

print(f"数据已成功写入 {output_file}")
