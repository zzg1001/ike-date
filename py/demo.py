import pyodbc
import time
import datetime
from datetime import date
from dateutil.relativedelta import relativedelta

# 连接到SQL Server数据库
conn = pyodbc.connect('DRIVER={SQL Server};SERVER=172.16.31.42,1433;DATABASE=ODS_SRM;UID=DW_YK;PWD=DW_YK')
# 创建游标对象
cursor = conn.cursor()



cnt = 1
cnt +=1
print(cnt )