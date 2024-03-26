import pyodbc

# 连接到SQL Server数据库
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=172.16.31.42,1433;DATABASE=ODS_SRM;UID=DW_YK;PWD=DW_YK')

# 创建游标对象
cursor = conn.cursor()

# 执行SQL查询
sql_query = "SELECT * FROM YourTableName;"  # 将 YourTableName 替换为实际的表名
cursor.execute(sql_query)

# 获取查询结果
results = cursor.fetchall()

# 打印查询结果
for row in results:
    print(row)

# 关闭连接
cursor.close()
conn.close()