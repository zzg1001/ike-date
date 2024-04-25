import os
import pyodbc

# SQL Server连接信息
server = '139.196.89.86'
database = 'fendi'
username = 'fendi'
password = 'Password.1'

# 文件夹路径
folder_path = 'C:\\Users\\22492\\Desktop\\sss'

# # 建立SQL Server连接
# conn_str = f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};UID={username};PWD={password}'
# conn = pyodbc.connect(conn_str)
# cursor = conn.cursor()

conn = pyodbc.connect('DRIVER={SQL Server};SERVER=172.16.31.42,1433;DATABASE=ODS_SRM;UID=DW_YK;PWD=DW_YK')
# 创建游标对象
cursor = conn.cursor()

# 获取文件夹中的.dat文件列表
file_list = [file for file in os.listdir(folder_path) if file.endswith('.dat')]

# 逐个处理.dat文件
for file_name in file_list:
    # 提取表名
    table_name = os.path.splitext(file_name)[0]

    # 打开.dat文件，读取数据并插入到SQL Server表中
    with open(os.path.join(folder_path, file_name), 'r') as file:
        for line in file:
            # 去除换行符，并按“|”分割数据
            data = line.strip().split('|')

            # 构建SQL插入语句
            columns = ', '.join(data)
            values = ', '.join(['?' for _ in data])
            insert_query = f"INSERT INTO {table_name} ({columns}) VALUES ({values})"

            # 执行SQL插入语句
            cursor.execute(insert_query, data)
    
    # 提交事务
    conn.commit()

# 关闭连接
cursor.close()
conn.close()