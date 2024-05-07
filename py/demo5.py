import pyodbc

# 数据库连接配置
server = '139.196.89.86'  # 数据库地址
database = 'fendi'  # 数据库名
username = 'fendi'  # 用户名
password = 'Password.1'  # 密码
driver = '{ODBC Driver 17 for SQL Server}'

# 关键词
keyword = 'your_keyword_here'

# 建立数据库连接
conn = pyodbc.connect(f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password}")

# 获取数据库中的所有表
cursor = conn.cursor()
cursor.tables()
tables = cursor.fetchall()

# 存储匹配结果的列表
matched_tables = []

# 在每个表中搜索关键词
for table in tables:
    table_name = table.table_name
    
    # 排除系统表和视图
    if table.table_type == "TABLE":
        print(f"正在搜索表：{table_name}")
        
        # 获取表的字段信息
        cursor.columns(table=table_name)
        columns = cursor.fetchall()
        
        # 在字段中搜索关键词
        for column in columns:
            column_name = column.column_name
            print(f"正在搜索字段：{column_name}")
            
            # 使用模糊查询进行匹配
            query = f"SELECT * FROM {table_name} WHERE {column_name} LIKE '%{keyword}%'"
            cursor.execute(query)
            
            if cursor.fetchone():
                matched_tables.append(table_name)
                print(f"在表 {table_name} 中找到匹配字段：{column_name}")
                break
        else:
            print(f"在表 {table_name} 中没有找到匹配字段")
        
        print("---")

# 打印匹配结果
if matched_tables:
    print(f"包含关键词 '{keyword}' 的表：")
    for table_name in matched_tables:
        print(table_name)
else:
    print(f"没有找到包含关键词 '{keyword}' 的表。")

# 关闭数据库连接
conn.close()