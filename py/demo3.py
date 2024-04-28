import os
import shutil
import pyodbc
import logging

# 配置日志记录器
log_file = '/Users/zhangzuogong/Desktop/aaa/err.log'
logging.basicConfig(filename=log_file, level=logging.ERROR, format='%(asctime)s - %(message)s')

# SQL Server连接配置
server = '139.196.89.86'  # 数据库地址
database = 'fendi'  # 数据库名
username = 'fendi'  # 用户名
password = 'Password.1'  # 密码
driver = '{ODBC Driver 17 for SQL Server}'

# 原始目录路径和文件扩展名
source_directory = '/Users/zhangzuogong/Desktop/sss'
extension = '.dat'

# 建立数据库连接
conn = pyodbc.connect(f"DRIVER={driver};SERVER={server};DATABASE={database};UID={username};PWD={password};TrustServerCertificate=yes;")
cursor = conn.cursor()

try:
    # 获取原始目录下的所有.dat文件
    dat_files = [filename for filename in os.listdir(source_directory) if filename.endswith(extension)]
    total_tables = len(dat_files)
    inserted_tables = 0
    failed_tables = 0

    # 遍历每个.dat文件
    for dat_file in dat_files:
        table_name = os.path.splitext(dat_file)[0]  # 使用文件名作为表名
        file_path = os.path.join(source_directory, dat_file)

        try:
            # 清空表数据
            cursor.execute(f"DELETE FROM [{table_name}]")

            # 获取目标表的字段名和数据类型
            cursor.execute(f"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ?", table_name)
            columns = cursor.fetchall()

            # 读取.dat文件并插入到数据库表中
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as file:
                lines = file.readlines()
                batch_size = 10000
                total_lines = len(lines)
                num_batches = (total_lines + batch_size - 1) // batch_size  # 计算批次数量

                for batch_index in range(num_batches):
                    start_index = batch_index * batch_size
                    end_index = min((batch_index + 1) * batch_size, total_lines)
                    batch_lines = lines[start_index:end_index]

                    values_list = []  # 存储批次数据的列表

                    for line in batch_lines:
                        line = line.strip()
                        values = line.split('|')

                        # 转换数据类型
                        converted_values = []
                        for i, value in enumerate(values):
                            column_name, data_type = columns[i]
                            if data_type == 'int':
                                try:
                                    converted_values.append(int(value))
                                except ValueError:
                                    converted_values.append(1 if value.lower() == 'true' else 0)  # 将布尔类型映射为整数
                            elif data_type == 'float':
                                converted_values.append(float(value))
                            elif data_type in ['numeric', 'decimal']:
                                if value == '':
                                    converted_values.append(None)  # 将空字符串转换为NULL
                                else:
                                    converted_values.append(float(value))  # 保持原始逻辑，将非空值转换为浮点数
                            elif data_type in ['binary', 'varbinary'] and value == '':
                                converted_values.append(None)  # 将空字符串转换为NULL
                            else:
                                converted_values.append(value)

                        values_list.append(converted_values)

                        print(f"表{table_name}:数据行: {converted_values}")

                    # 构建插入语句
                    placeholders = ', '.join(['?' for _ in converted_values])
                    sql = f"INSERT INTO [{table_name}] VALUES ({placeholders})"
                    # 打印每条数据
                    

                    try:
                        # 执行批量插入操作
                        cursor.executemany(sql, values_list)
                        conn.commit()  # 提交事务
                        inserted_tables += 1

                        # 打印每条数据
                        for values in values_list:
                            print(f"执行的SQL语句: {sql}")
                            print(f"数据行: {values}")

                    except pyodbc.Error as e:
                        error_message = f"插入数据时发生错误：表名 - {table_name}，错误信息 - {str(e)}"
                        print(error_message)
                        failed_tables += 1

                        # 将异常信息写入日志文件
                        logging.error(f"插入数据时发生错误：表名 - {table_name}，错误信息 - {str(e)}")

        except pyodbc.Error as e:
            error_message = f"获取表结构时发生错误：表名 - {table_name}，错误信息 - {str(e)}"
            print(error_message)
            failed_tables += 1

            #将异常信息写入日志文件
            logging.error(error_message)

except Exception as e:
    print(f"执行过程中发生异常：{str(e)}")
    logging.exception("执行过程中发生异常")

# 打印成功和失败的数量
print(f"成功插入的表格数量：{inserted_tables}")
print(f"失败的表格数量：{failed_tables}")