import pymysql
import pyodbc

# MySQL连接配置
mysql_config = {
    'host': '172.16.31.88',
    'port': 3306,
    'user': 'stmc_bigdata',
    'password': 'Bigdata-1234',
    'db': 'srm',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

# SQL Server连接配置
sql_server_config = {
    'driver': '{ODBC Driver 17 for SQL Server}',
    'server': '1172.16.31.42,1433',  # 注意这里的端口号是逗号分隔
    'database': 'ODS_SRM',
    'uid': 'dw',
    'pwd': 'dw'
}

# 连接到MySQL
mysql_conn = pymysql.connect(**mysql_config)
mysql_cursor = mysql_conn.cursor()

# 连接到SQL Server
sql_server_conn = pyodbc.connect(**sql_server_config)
sql_server_cursor = sql_server_conn.cursor()

try:
    # 从MySQL中获取数据
    mysql_cursor.execute("SELECT * FROM srm_poc_order_item")
    rows = mysql_cursor.fetchall()

    # 准备SQL Server的插入语句
    columns = ', '.join([f'[{column}]' for column in rows[0].keys()])
    values = ', '.join(['%s'] * len(rows[0]))
    insert_query = f"INSERT INTO srm_poc_order_item_os ({columns}) VALUES ({values})"

    # 批量插入数据到SQL Server
    for row in rows:
        sql_server_cursor.execute(insert_query, tuple(row.values()))

    # 提交事务
    sql_server_conn.commit()

except Exception as e:
    print(f"An error occurred: {e}")
    sql_server_conn.rollback()

finally:
    # 关闭游标和连接
    mysql_cursor.close()
    sql_server_cursor.close()
    mysql_conn.close()
    sql_server_conn.close()