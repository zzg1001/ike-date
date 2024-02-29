import pymysql
import time

# 连接到数据库
conn = pymysql.connect(
    host='139.224.197.121',
    port=63306,
    user='weizhengbo',
    password='Password.1',
    database='ods_海量2023'
)
cursor = conn.cursor()

# 删除表格
cursor.execute("create table meifu_analysis_platform_main_2023_1 as select * from meifu_analysis_platform_main_2023;")
print(f'执行解释')