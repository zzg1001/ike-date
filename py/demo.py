import os
import pyodbc

# SQL Server数据库连接配置
server = '139.196.89.86'  # 数据库地址
database = 'fendi'  # 数据库名
username = 'fendi'  # 用户名
password = 'Password.1'  # 密码
driver = '{ODBC Driver 18 for SQL Server}'  # 驱动程序名称

# 建立数据库连接
conn = pyodbc.connect(f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};TrustServerCertificate=yes;")
cursor = conn.cursor()

# 数据文件所在目录
data_directory = '/Users/zhangzuogong/Desktop/sss'

# 获取文件列表
file_list = [f for f in os.listdir(data_directory) if f.endswith('.dat')]

# 记录表的插入统计
total_tables = len(file_list)
tables_inserted = 0
tables_failed = 0

# 执行数据导入
for file_name in file_list:
    table_name = os.path.splitext(file_name)[0]  # 使用文件名作为表名

    with open(os.path.join(data_directory, file_name), 'r', encoding='utf-8', errors='ignore') as file:
        lines = file.readlines()

        # 获取表的字段信息
        cursor.execute(f"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ?", table_name)
        columns = cursor.fetchall()
        column_names = [column[0] for column in columns]

        for line_number, line in enumerate(lines, start=1):
            line = line.strip()
            values = line.split('|')

            # 确保数据与字段一一对应
            if len(values) != len(column_names):
                raise Exception(f"表 '{table_name}' 第 {line_number} 行数据与字段数量不匹配")

            # 构建SQL插入语句
            placeholders = ', '.join('?' for _ in values)
            sql = f"INSERT INTO [{table_name}] ({', '.join(column_names)}) VALUES ({placeholders})"

            try:
                # 将数据转换为与表中字段相应的类型
                converted_values = []
                for i, value in enumerate(values):
                    column_type = columns[i][1]
                    if column_type.startswith('nvarchar'):
                        # 使用CONVERT函数进行类型转换
                        converted_value = value
                    elif column_type.startswith('int'):
                        try:
                            converted_value = int(value)
                        except ValueError:
                            raise Exception(f"表 '{table_name}' 第 {line_number} 行第 {i+1} 列数据类型转换错误: 无法将 '{value}' 转换为整数")
                    elif column_type.startswith('datetime'):
                        converted_value = value
                    else:
                        # 其他数据类型的处理方式
                        converted_value = value
                    converted_values.append(converted_value)

                # 执行SQL语句
                cursor.execute(sql, converted_values)
                conn.commit()
            except pyodbc.Error as e:
                # 抛出异常并记录错误信息
                error_details = f"表 '{table_name}' 第 {line_number} 行插入数据时出现异常: {str(e)}"
                column_name = column_names[i]  # 出错的列名
                error_details += f"，列名: {column_name}"
                error_details += f"，值: {values[i]}"
                error_details += f"，SQL语句: {sql}"
                raise Exception(error_details)

            # 打印填充值后的 SQL 语句
            filled_sql = sql % tuple(converted_values)
            print(f"填充值后的 SQL 语句: {filled_sql}")

    tables_inserted += 1

    # 打印每个表的插入统计
    print(f"表 '{table_name}' 数据插入完成。")

tables_failed = total_tables - tables_inserted

# 打印总体插入统计
print(f"总共 {total_tables} 张表，已插入 {tables_inserted} 张表，失败 {tables_failed} 张表。")

# 关闭数据库连接
cursor.close()
conn.close()