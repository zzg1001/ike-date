SELECT SUM(contract_amount) as contract_amount
  FROM [LeanProduction_Dashboard].[dbo].[purchase_dashboard_base_contract_info]
  where sponsor_dept_code = '59TKR0X9'
and contract_year between '${year_begin}' and '${year_end}'