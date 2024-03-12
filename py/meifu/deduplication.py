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

start_time = time.time()  # 记录开始时间

cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_5 ;")
print(f"删除表:meifu_analysis_platform_main_2023_5")
# 创建表格
cursor.execute('''create table  meifu_analysis_platform_main_2023_4 as 
              select distinct * from meifu_analysis_platform_main_2023_3 ;''')


end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"创建表格执行时间：{execution_time}秒")

# 提交更改并关闭连接
conn.commit()
conn.close()