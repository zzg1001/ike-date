<<<<<<< HEAD
from ftplib import FTP
import os

# FTP 服务器连接信息
ftp_host = "172.16.31.187"
ftp_user = "ftpuser1"
ftp_pass = "fanruanfanruan"
ftp_dir = "/home/ftpuser1/supplierperformance"
ftp_file = "双环--2000-2024-03供应商成绩单.pdf"

# 本地保存路径
local_dir = r"D:\\work\\aa"
local_file = os.path.join(local_dir, ftp_file)

# 创建本地保存目录
os.makedirs(local_dir, exist_ok=True)

# 建立 FTP 连接
ftp = FTP(ftp_host)
ftp.login(ftp_user, ftp_pass)

# 切换到目标目录
ftp.cwd(ftp_dir)

# 读取文件内容
with open(local_file, "wb") as local_file_obj:
    ftp.retrbinary(f"RETR {ftp_file}", local_file_obj.write)

# 关闭 FTP 连接
ftp.quit()

print(f"File downloaded successfully to: {local_file}")
=======
import pyodbc 

server = '172.16.31.42' # 数据库地址
# 其他设置server的方法
# server = 'localhost\sqlexpress' # 实例名
# server = 'myserver,port' # 指定端口
database = 'ODS_SRM' # 数据库名
username = 'DW_YK' # 用户名
password = 'DW_YK' # 密码
# conn = pyodbc.connect('DRIVER={SQL Server};SERVER=172.16.31.42,1433;DATABASE=ODS_SRM;UID=DW_YK;PWD=DW_YK')
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
cursor = cnxn.cursor()

cursor.execute("SELECT * from  Outsourcing_Dashboard.dbo.sap_base_field_wide;") 
row = cursor.fetchone() 
while row: 
    print (row[0])
    row = cursor.fetchone()
>>>>>>> 80def5a98b8dd20fc791672843b57b1bf7be36d2
