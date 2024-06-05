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
    


    cursor.execute('''IF OBJECT_ID('Outsourcing_Dashboard.dbo.sap_base_field_histry_wide','U')  IS NOT NULL
                drop table Outsourcing_Dashboard.dbo.sap_base_field_histry_wide;''')
    print(f"删除表：sap_base_field_histry_wide")

    exc1('2015-09-01')

    start_date = datetime.date(2015, 10, 1)
    end_date = datetime.date(2024, 5, 1)

    result = get_all_months(start_date, end_date)

    for date_sql in result:
        date_sql = date_sql+"-01"
        exc(date_sql)

    end_time = time.time()  # 记录结束时间
    execution_time = end_time - start_time
    print(f"执行结束：{execution_time}秒")


    # 提交事务
    conn.commit()
    # 关闭连接
    cursor.close()
    conn.close()

