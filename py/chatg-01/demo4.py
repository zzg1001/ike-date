import pandas as pd
import pymysql

# MySQL 数据库连接信息
db_user = 'weizhengbo'
db_password = 'Password.1'
db_host = '139.224.197.121'  # 或者是你的数据库服务器地址
db_port = 63306  # 默认端口
db_name = 'language_pack'

# 创建数据库连接
connection = pymysql.connect(host=db_host,
                             user=db_user,
                             password=db_password,
                             db=db_name,
                             port= db_port,
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)

try:
    # SQL 查询语句
    query = """
    SELECT * FROM automl_table_91;
    """

    # 读取数据到 DataFrame
    df = pd.read_sql_query(query, connection)
    print(df)
    # print(df.values)

    # 显示 DataFrame
    print(df.head())
    df.to_csv('/Users/zhangzuogong/Desktop/test.csv')

finally:
    # 关闭数据库连接
    connection.close()