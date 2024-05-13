import pyodbc
import time
import datetime
from datetime import date

# 连接到SQL Server数据库
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=172.16.31.42,1433;DATABASE=ODS_SRM;UID=DW_YK;PWD=DW_YK')
# 创建游标对象
cursor = conn.cursor()



def exc1(date_sql):
    
    curr =  str(date_sql[:7])
    # date1 = date.fromisoformat(date_sql)
    # result = date1 - relativedelta(months=12) 
    laft = int(date_sql[:4])-1
    result = str(laft)+"-01"
    print(f"0执行{result}====={curr}")
    sql_query = f'''
                select 
                *
                into Outsourcing_Dashboard.dbo.sap_base_field_histry_wide
                from (
                    SELECT
                    '{curr}' year_month 
                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
                     ,0 is_curr_year
                     ,0 is_contain
                    ,*
                    ,GETDATE() etl_time
                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
                where (LOEKZ <> 'L' or LOEKZ is null) 
                and BUKRS='2000' and FRGKE='S' 
            and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2)) = '{curr}'

            union all

            SELECT 
                    '{curr}' year_month
                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
                    ,case when SUBSTRING(EINDT, 1, 4)=CONVERT(varchar(4), GETDATE(), 120)  then 0 else 1 end is_curr_year
                    ,1 is_contain
                    ,*
                    ,GETDATE() etl_time
                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
                where (LOEKZ <> 'L' or LOEKZ is null) 
                and BUKRS='2000' and FRGKE='S' 
                and finish_or_not = '未完成' and overdue_or_not = '逾期'
                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) )<'{curr}'
                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2)) >= '{result}'
                ) a
                '''
        # 将 YourTableName 替换为实际的表名
    cursor.execute(sql_query)

def exc(date_sql):
      
      curr =  date_sql[:7]
      laft = int(date_sql[:4])-1
      result = str(laft)+"-01"
 

      print(f"0执行{curr}====={result}")
      sql_query = f'''
            insert into Outsourcing_Dashboard.dbo.sap_base_field_histry_wide
                select 
                *
                from (
                    SELECT
                    '{curr}' year_month 
                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
                     ,0 is_curr_year
                     ,0 is_contain
                    ,*
                    ,GETDATE() etl_time
                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
                where (LOEKZ <> 'L' or LOEKZ is null) 
                and BUKRS='2000' and FRGKE='S' 
            and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) )='{curr}'

            union all

            SELECT 
                    '{curr}'  year_month
                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
                     ,case when SUBSTRING(EINDT, 1, 4)=CONVERT(varchar(4), GETDATE(), 120)  then 0 else 1 end is_curr_year
                     ,1 is_contain
                    ,*
                    ,GETDATE() etl_time
                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
                where (LOEKZ <> 'L' or LOEKZ is null) 
                and BUKRS='2000' and FRGKE='S' 
                and finish_or_not = '未完成' and overdue_or_not = '逾期'
                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) )<'{curr}'
                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2))>='{result}'
                ) a
                '''
        # 将 YourTableName 替换为实际的表名
      cursor.execute(sql_query)
     
def get_all_months(start_date, end_date):
    months = []
    current_date = start_date
    while current_date <= end_date:
        months.append(current_date.strftime("%Y-%m"))
        if current_date.month == 12:
            current_date = current_date.replace(year=current_date.year + 1, month=1)
        else:
            current_date = current_date.replace(month=current_date.month + 1)
    return months

# 读取查询结果并打印
# rows = cursor.fetchall()
# for row in rows:
#     print(row)
if __name__ == "__main__":

    start_time = time.time()  # 记录开始时间
# 执行SQL查询
    


    cursor.execute('''IF OBJECT_ID('Outsourcing_Dashboard.dbo.sap_base_field_merge_wide ','U')  IS NOT NULL
                drop table Outsourcing_Dashboard.dbo.sap_base_field_merge_wide;''')
    print(f"删除表：Outsourcing_Dashboard.dbo.sap_base_field_merge_wide")

    sql1 ='''    select 
                       *
                       into Outsourcing_Dashboard.dbo.sap_base_field_merge_wide
                    from Outsourcing_Dashboard.dbo.sap_base_field_histry_wide
           '''
    cursor.execute(sql1)

    sql2 ='''      insert into Outsourcing_Dashboard.dbo.sap_base_field_merge_wide  
		     select 
                *
                from (
	                    SELECT
	                      CONVERT(varchar(7), GETDATE(), 120) year_month
	                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
	                    ,0 is_curr_year
                        ,0 is_contain
	                    ,*
	                    ,GETDATE() etl_time
	                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
	                where (LOEKZ <> 'L' or LOEKZ is null) 
	                and BUKRS='2000' and FRGKE='S' 
	            and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) )=CONVERT(varchar(7), GETDATE(), 120)
	
	            union all
	
	            SELECT 
	                    CONVERT(varchar(7), GETDATE(), 120) year_month
	                    ,(SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) + '-' + SUBSTRING(EINDT, 7, 2)) eindt_date
	                    ,case when SUBSTRING(EINDT, 1, 4)=CONVERT(varchar(4), GETDATE(), 120)  then 0 else 1 end is_curr_year
                        ,1 is_contain
	                    ,*
	                    ,GETDATE() etl_time
	                from Outsourcing_Dashboard.dbo.sap_base_field_wide a
	                where (LOEKZ <> 'L' or LOEKZ is null) 
	                and BUKRS='2000' and FRGKE='S' 
	                and finish_or_not = '未完成' and overdue_or_not = '逾期'
	                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2) )< CONVERT(varchar(7), GETDATE(), 120)
	                and (SUBSTRING(EINDT, 1, 4) + '-' + SUBSTRING(EINDT, 5, 2))>= CONVERT(varchar(7),DATEADD(year, DATEDIFF(year, 0, GETDATE()) - 1, 0), 120)

                ) a;
           '''
    cursor.execute(sql2)


   
    cursor.execute('''IF OBJECT_ID('Outsourcing_Dashboard.dbo.sap_base_field_merge_wide_index_1 ','U')  IS NOT NULL
                drop table Outsourcing_Dashboard.dbo.sap_base_field_merge_wide_index_1;''')
    print(f"删除表：Outsourcing_Dashboard.dbo.sap_base_field_merge_wide_index_1")

    sql3 ='''    select
                        year_month
                        ,factory
                        ,category
                        ,count(1)                                                                                              total_od_cnt              -- 总订单行
                        ,count(case when ADPRI !='J' or ADPRI is null  then 1 else null end )                                  regular_od_num            -- 常规订单数量
                        ,count(case when adpri= 'J'then 1 else null end )                                                      j_h_od_num                -- 紧急订单行数  
                        ,count(case when adpri= 'J' and finish_or_not = '完成' and overdue_or_not = '按时' then 1 else null end )  an_j_h_od_num             --  按时紧急订单行数  
                        ,count(case when finish_or_not = '完成'   and completion_date<=EINDT then 1 else null end )              finish_od_cnt              -- 按时完成订单行数
                        ,count(case when finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT< DATEADD(month, 1, year_month+'-01')  then 1 else null end )  overdue_f_od_num          -- 按时完成订单行数
                        ,count(case when is_qualified ='不合格' then 1 else null end)                                              not_qualified_cnt          -- 合格数         
                        ,count(case when finish_or_not ='完成' and overdue_or_not ='按时'  then 1 else null end)                   an_qualified_finish
                        
                        ,count(case when is_contain = 0 then 1 else null end)                                                          total_od_cnt1              -- 总订单行
                        ,count(case when is_contain = 0 and (ADPRI !='J' or ADPRI is null ) then 1 else null end )                     regular_od_num1            -- 常规订单数量
                        ,count(case when is_contain = 0 and adpri= 'J'then 1 else null end )                                           j_h_od_num1                -- 紧急订单行数  
                        ,count(case when is_contain = 0 and adpri= 'J' and finish_or_not = '完成' and overdue_or_not = '按时' then 1 else null end )      an_j_h_od_num1             --  按时紧急订单行数  
                        ,count(case when is_contain = 0 and finish_or_not = '完成'   and completion_date<=EINDT then 1 else null end ) finish_od_cnt1             -- 按时完成订单行数
                        ,count(case when is_contain = 0 and finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT< DATEADD(month, 1, year_month+'-01')  then 1 else null end )  overdue_f_od_num1          -- 按时完成订单行数
                        ,count(case when is_contain = 0 and is_qualified ='不合格' then 1 else null end)                 not_qualified_cnt1
                        ,count(case when is_contain = 0 and  finish_or_not ='完成' and overdue_or_not ='按时'  then 1 else null end)       an_qualified_finish1
                        
                        ,count(case when is_curr_year = 1 then 1 else null end)                                                          total_od_cnt2              -- 总订单行
                        ,count(case when is_curr_year = 1 and ( ADPRI !='J' or ADPRI is null)  then 1 else null end )                       regular_od_num2            -- 常规订单数量
                        ,count(case when is_curr_year = 1 and adpri= 'J'then 1 else null end )                                           j_h_od_num2                -- 紧急订单行数  
                        ,count(case when is_curr_year = 1 and adpri= 'J' and finish_or_not = '完成' and overdue_or_not = '按时' then 1 else null end )      an_j_h_od_num2            --  按时紧急订单行数  
                        ,count(case when is_curr_year = 1 and finish_or_not = '完成'   and completion_date<=EINDT then 1 else null end ) finish_od_cnt2             -- 按时完成订单行数
                        ,count(case when  is_curr_year = 1 and  finish_or_not = '完成'   and overdue_or_not = '逾期' and BUDAT< DATEADD(month, 1, year_month+'-01')  then 1 else null end )  overdue_f_od_num2          -- 按时完成订单行数
                        ,count(case when  is_curr_year = 1  and is_qualified ='不合格' then 1 else null end)                   not_qualified_cnt2
                        ,count(case when  is_curr_year = 1  and  finish_or_not ='完成' and overdue_or_not ='按时'  then 1 else null end)  an_qualified_finish2
                        into Outsourcing_Dashboard.dbo.sap_base_field_merge_wide_index_1
                        from Outsourcing_Dashboard.dbo.sap_base_field_merge_wide a
                    group by 
                        factory
                        ,category
                        ,year_month
                        ORDER  by year_month desc 
            '''
    cursor.execute(sql3)



      
    cursor.execute('''IF OBJECT_ID('Outsourcing_Dashboard.dbo.sap_base_field_merge_peitao ','U')  IS NOT NULL
                drop table Outsourcing_Dashboard.dbo.sap_base_field_merge_peitao;''')
    print(f"删除表：Outsourcing_Dashboard.dbo.sap_base_field_merge_peitao")

    sql4 ='''    SET ANSI_WARNINGS OFF;
                SET ARITHABORT OFF;
                SET ARITHIGNORE ON;
                    
                select 
                                a.factory
                                ,CONVERT(varchar(7), delivery_date, 120) year_month
                                ,count(*) every_cnt
                                ,count(case when is_curr_year = 0 then 1 else null end ) add_every_cnt
                                ,count(case when is_curr_year = 1 then 1 else null end ) pr_cnt
                            into Outsourcing_Dashboard.dbo.sap_base_field_merge_peitao	
                        from Outsourcing_Dashboard.dbo.r24_temp_base  a 
                        join (
                                select 
                                        factory
                                        ,EBELN
                                        ,category
                                        ,RIGHT(REPLICATE('0', 5) + EBELP , 5) EBELP 
                                        ,left(EINDT,4)+'-'+SUBSTRING(EINDT,5,2)EINDT
                                        ,is_curr_year
                                        ,is_contain
                                from Outsourcing_Dashboard.dbo.sap_base_field_merge_wide
                                group by  
                                        factory
                                        ,EBELN
                                        ,category
                                        ,is_curr_year
                                        ,is_contain
                                        ,RIGHT(REPLICATE('0', 5) + EBELP , 5)
                                        ,left(EINDT,4)+'-'+SUBSTRING(EINDT,5,2)
                                ) b 
                            on a.factory = b.factory
                            and b.EBELN = a.purchase_order_no
                            and b.EBELP = a.purchase_order_line
                            and b.EINDT = CONVERT(varchar(7), delivery_date, 120)	 
                    where  receive_status is not null
                    and purchase_group_code = '203'
                    group by a.factory
                    ,CONVERT(varchar(7), delivery_date, 120)
            '''
    cursor.execute(sql4)





    # 提交事务
    conn.commit()
    # 关闭连接
    cursor.close()
    conn.close()

