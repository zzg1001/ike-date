import pymysql
import time

# 连接到数据库
conn = pymysql.connect(
    host='139.224.197.121',
    port=63306,
    user='weizhengbo',
    password='Password.1',
    database='dws_meifu_all'
)
cursor = conn.cursor()


start_time = time.time()  # 记录开始时间
print("开始读取数据")

cursor.execute(str(ss))
end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"插入数据执行时间：{execution_time}秒")

# 提交更改并关闭连接
conn.commit()
conn.close()