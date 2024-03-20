import pandas as pd
from sqlalchemy import create_engine



print(f"开始")
# 读取 CSV 文件
data = pd.read_excel('/Users/zhangzuogong/Desktop/setmmm.xlsx')

# 连接到 MySQL 数据库
engine = create_engine('mysql+mysqlconnector://weizhengbo:Password.1@139.224.197.121:63306/ods_海量2023')

# 将数据写入数据库（自动创建表）
data.to_sql('tmp_shuijun_and_qingan', con=engine, if_exists='replace', index=False, chunksize=5000)
print(f"结束")