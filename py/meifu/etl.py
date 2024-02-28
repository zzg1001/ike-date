import time
from sqlalchemy import create_engine
from sqlalchemy import text

# 数据库连接信息
database_info = {
    'USER': 'weizhengbo',
    'PASSWORD': 'Password.1',
    'HOST': '139.224.197.121',
    'PORT': '63306',
    'DATABASE': 'ods_海量2023'
}

# 构建数据库连接字符串
db_connection_string = f"mysql+pymysql://{database_info['USER']}:{database_info['PASSWORD']}@{database_info['HOST']}:{database_info['PORT']}/{database_info['DATABASE']}"

# 连接到数据库
engine = create_engine(db_connection_string)

# 获取数据库连接对象
connection = engine.connect()

# 执行第一条SQL语句：删除表
drop_table_query = text("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_1;")
connection.execute(drop_table_query)

# 执行第二条SQL语句：创建表并插入数据
create_table_query = text('''
    CREATE TABLE meifu_analysis_platform_main_2023_1 AS
    SELECT 
        auto_id,
        REGEXP_REPLACE(title, '<[^>]+>', '') AS title,
        is_comment,
        webpageUrl,
        captureWebsiteNew,
        publishedMinute,
        originType,
        author,
        summary,
        province,
        city,
        originTypeThird,
        secondTradeList,
        originAuthorId,
        referenceKeywordNew,
        shareCount,
        comments,
        praiseNum,
        forwardNumber,
        favouritesCount,
        fansNumber,
        friendsCount,
        gender,
        icpProvince,
        id,
        publishedDay,
        readCount,
        subDomain,
        titleHs,
        topicInteractionCount,
        weiboTopicKeyword,
        weiboUserBeanNew,
        zaikanCount,
        create_date,
        description,
        REGEXP_REPLACE(content, '<[^>]+>', '') AS content,
        referenceKeyword,
        project_name
    FROM meifu_analysis_platform_main_2023;
''')
start_time = time.time()
connection.execute(create_table_query)
end_time = time.time()
execution_time = end_time - start_time
print(f"Create table query execution time: {execution_time} seconds")

# 关闭数据库连接
connection.close()