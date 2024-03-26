import pyodbc

# 连接到SQL Server数据库
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=<server_name>;DATABASE=<database_name>;UID=<username>;PWD=<password>')

# 创建游标对象
cursor = conn.cursor()

# 执行SQL逻辑
selected_year = 2024
selected_month = 3

# 选择一个月之前的12个月数据
sql_query = """
    SELECT column1, column2, ...
    FROM table_name
    WHERE DATEPART(YEAR, date_column) = ? - 1
      AND DATEPART(MONTH, date_column) = ?;
"""

# 执行SQL查询
cursor.execute(sql_query, (selected_year, selected_month))

# 获取查询结果
results = cursor.fetchall()

# 打印查询结果
for row in results:
    print(row)

# 关闭连接
cursor.close()
conn.close()