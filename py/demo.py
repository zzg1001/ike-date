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