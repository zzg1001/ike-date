import sql_test_new
import pandas as pd
import numpy as np
from sqlalchemy import text
from snownlp import SnowNLP #pip install snownlp

host='139.224.197.121'
username='weizhengbo'
password='Password.1'
database='ods_海量2023'
port = 63306

sql = text('select * from ods_海量2023.meifu_analysis_platform_main_2023_4 limit 10000')

a = sql_test_new.dbconnect(host, username, password, database, port)
df = a.read_select_sql(sql=sql)

# df['flag'] = list(map(lambda x, y, z: y if z == 1 else x, df['content'], df['commentContent'], df['is_comment']))
# df['sentiment_analysis'] = list(map(lambda x, y, z: SnowNLP(y).sentiments if z == 1 and pd.notna(y) else(SnowNLP(x).sentiments if pd.notna(x) else np.nan), df['content'], df['commentContent'], df['is_comment']))
def sentiment_analysis(x, y, z):
    try:
        if pd.notna(y) and z == 1:
            return SnowNLP(y).sentiments
        elif pd.notna(x):
            return SnowNLP(x).sentiments
        else:
            return np.nan
    except:
        print(x,y,z)
        return np.nan

# 应用 sentiment_analysis 函数到 DataFrame 中的列
df['sentiment_analysis'] = df.apply(lambda row: sentiment_analysis(row['content'], row['commentContent'], row['is_comment']), axis=1)


df['sentiment_flag'] = list(map(lambda x: 0 if x <= 0.01 else(1 if x >= 0.8 else 2), df['sentiment_analysis']))

# df1 = df.values.tolist()
# for i in df1:
#     print(i)
#     # print(str(i['comment_content']),str(i['setiment_analysis']),str(i['sentiment_flag']))

a = sql_test_new.dbconnect(host, username, password, database, port)
a.insert_database(table_name='meifu_analysis_platform_main_2023_5_water', data=df, if_exists='truncate')