import pandas as pd
import pymysql

# 读取数据的连接配置
read_config = {
    'host': '139.224.197.121',
    'port': 63306,
    'user': 'weizhengbo',
    'password': 'Password.1',
    'database': 'ods_海量2023'
}

# 写入数据的连接配置
write_config = {
    'host': '172.16.10.152',
    'port': 3306,
    'user': 'root',
    'password': 'root123456',
    'database': 'test'
}

# 建立读取数据的MySQL连接
read_conn = pymysql.connect(
    host=read_config['host'],
    port=read_config['port'],
    user=read_config['user'],
    password=read_config['password'],
    database=read_config['database']
)

# 从MySQL读取数据
query = "SELECT * FROM meifu_analysis_platform_main_2023_3"
df = pd.read_sql(query, con=read_conn)

# 打印读取的数据
print(df)

# 建立写入数据的MySQL连接
write_conn = pymysql.connect(
    host=write_config['host'],
    port=write_config['port'],
    user=write_config['user'],
    password=write_config['password'],
    database=write_config['database']
)

# 写入数据到MySQL
table_name = 'meifu_analysis_platform_main_2023_3'
df.to_sql(name=table_name, con=write_conn, if_exists='replace', index=False)

# 关闭连接
read_conn.close()
write_conn.close()