import mysql.connector
import pandas as pd

# 数据库连接信息
config = {
    'user': 'weizhengbo',
    'password': 'Password.1',
    'host': '139.224.197.121',
    'port': '63306',
}

# 连接到MySQL数据库
conn = mysql.connector.connect(**config)

# 创建一个游标对象
cursor = conn.cursor()

# 获取所有数据库
cursor.execute("SHOW DATABASES")
databases = cursor.fetchall()

# 准备存储数据的字典
db_tables = {}

# 获取每个数据库中的所有表
for db in databases:
    db_name = db[0]
    cursor.execute(f"USE {db_name}")
    cursor.execute("SHOW TABLES")
    tables = cursor.fetchall()
    db_tables[db_name] = [table[0] for table in tables]

# 关闭连接ll
cursor.close()
conn.close()

# 将数据写入Excel文件
with pd.ExcelWriter('databases_and_tables.xlsx') as writer:
    for db_name, tables in db_tables.items():
        df = pd.DataFrame(tables, columns=['Tables'])
        df.to_excel(writer, sheet_name=db_name, index=False)

print("数据已写入 'databases_and_tables.xlsx'")
