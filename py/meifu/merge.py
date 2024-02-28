import pymysql
import time

# 连接到数据库
conn = pymysql.connect(
    host='139.224.197.121',
    port=63306,
    user='weizhengbo',
    password='Password.1',
    database='ods_海量2023'
)
cursor = conn.cursor()

# 删除表格
cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023;")
print(f'插入的表data_23q3_1,季度是:3')
# 创建表格
create_table_query = '''
CREATE TABLE IF NOT EXISTS meifu_analysis_platform_main_2023 AS
SELECT
    auto_id,
    '3' quarter,
    title,
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
    content,
    referenceKeyword,
    project_name
FROM data_23q3_1;
'''
start_time = time.time()  # 记录开始时间
cursor.execute(create_table_query)
end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"创建表格执行时间：{execution_time}秒")

# 列表中的表名
table_list = ['data_23q2_1'
              , 'data_23q3_2'
              , 'data_23q3_3'
              , 'data_23q4_1'
              , 'data_23q4_2'
              , 'data_23q4_3'
              , 'data_23q4_4']

# 循环插入数据
for table in table_list:
    print(f'插入的表{table},季度是:{table[8]}')
    insert_query = f'''
    INSERT INTO meifu_analysis_platform_main_2023 (
        auto_id,
        quarter,
        title,
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
        content,
        referenceKeyword,
        project_name
    )
    SELECT
        auto_id,
        {table[8]} quarter,
        title,
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
        content,
        referenceKeyword,
        project_name
    FROM {table};
    '''
    start_time = time.time()  # 记录开始时间
    cursor.execute(str(insert_query))
    end_time = time.time()  # 记录结束时间
    execution_time = end_time - start_time
    print(f"插入数据执行时间：{execution_time}秒")

# 提交更改并关闭连接
conn.commit()
conn.close()