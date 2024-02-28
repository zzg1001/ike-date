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
    REGEXP_REPLACE(title, '<[^>]+>', '') title,
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
    REGEXP_REPLACE(content, '<[^>]+>', '')  content,
    CASE
        WHEN content REGEXP '磨损' THEN '磨损'
        WHEN content REGEXP '粘度' THEN '粘度'
        WHEN content REGEXP '动力' THEN '动力'
        WHEN content REGEXP '抗磨' THEN '抗磨'
        WHEN content REGEXP '冷启动' THEN '冷启动'
        WHEN content REGEXP '保护' THEN '保护'
        WHEN content REGEXP '油膜' THEN '油膜'
        WHEN content REGEXP '长效' THEN '长效'
        WHEN content REGEXP '积碳' THEN '积碳'
        WHEN content REGEXP '清洁' THEN '清洁'
        WHEN content REGEXP '噪音' THEN '噪音'
        WHEN content REGEXP '抖动' THEN '抖动'
        WHEN content REGEXP '油泥' THEN '油泥'
        WHEN content REGEXP '静音' THEN '静音'
        ELSE NULL
    END AS func,
    referenceKeyword,
     CASE
        WHEN referenceKeyword REGEXP '磁护' THEN '磁护'
        WHEN referenceKeyword REGEXP '极护' THEN '极护'
        WHEN referenceKeyword REGEXP '极净' THEN '极净'
        WHEN referenceKeyword REGEXP 'GTX' THEN 'GTX'
        WHEN referenceKeyword REGEXP '超凡喜力' THEN '超凡喜力'
        WHEN referenceKeyword REGEXP '力霸' THEN '力霸'
        WHEN referenceKeyword REGEXP '美孚1号' THEN '美孚1号'
        WHEN referenceKeyword REGEXP '速霸' THEN '速霸'
        WHEN referenceKeyword REGEXP '美孚' AND referenceKeyword NOT REGEXP '力霸|速霸' THEN '美孚1号'
        WHEN referenceKeyword REGEXP '喜力' AND referenceKeyword NOT REGEXP '超凡喜力' THEN '喜力'
        ELSE NULL
    END AS category,
    CASE
        WHEN referenceKeyword = '道达尔' THEN '道达尔'
        WHEN referenceKeyword = 'castrol' THEN '嘉实多'
        WHEN referenceKeyword = '磁护' THEN '嘉实多'
        WHEN referenceKeyword = '极护' THEN '嘉实多'
        WHEN referenceKeyword = '极净' THEN '嘉实多'
        WHEN referenceKeyword = '嘉护' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多' THEN '嘉实多'
        WHEN referenceKeyword = '快驰' THEN '嘉实多'
        WHEN referenceKeyword = '黑嘉' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多极护' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多EDGE' THEN '嘉实多'
        WHEN referenceKeyword = 'edge' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多磁护' THEN '嘉实多'
        WHEN referenceKeyword = 'magnatec' THEN '嘉实多'
        WHEN referenceKeyword = 'Shell' THEN '壳牌'
        WHEN referenceKeyword = '黄壳' THEN '壳牌'
        WHEN referenceKeyword = '黄喜力' THEN '壳牌'
        WHEN referenceKeyword = '灰壳' THEN '壳牌'
        WHEN referenceKeyword = '壳牌' THEN '壳牌'
        WHEN referenceKeyword = '蓝壳' THEN '壳牌'
        WHEN referenceKeyword = '喜力' THEN '壳牌'
        WHEN referenceKeyword = '港壳' THEN '壳牌'
        WHEN referenceKeyword = '港灰' THEN '壳牌'
        WHEN referenceKeyword = '红壳' THEN '壳牌'
        WHEN referenceKeyword = '白壳' THEN '壳牌'
        WHEN referenceKeyword = '金壳' THEN '壳牌'
        WHEN referenceKeyword = '紫壳' THEN '壳牌'
        WHEN referenceKeyword = '壳牌先锋' THEN '壳牌'
        WHEN referenceKeyword = '壳牌锐净' THEN '壳牌'
        WHEN referenceKeyword = '壳牌喜力' THEN '壳牌'
        WHEN referenceKeyword = '超级喜力' THEN '壳牌'
        WHEN referenceKeyword = '极净' THEN '壳牌'
        WHEN referenceKeyword = '超凡喜力' THEN '壳牌'
        WHEN referenceKeyword = '昆仑机油' THEN '昆仑'
        WHEN referenceKeyword = '昆仑润滑' THEN '昆仑'
        WHEN referenceKeyword = '昆仑天润' THEN '昆仑'
        WHEN referenceKeyword = '昆仑之星' THEN '昆仑'
        WHEN referenceKeyword = '昆仑' THEN '昆仑'
        WHEN referenceKeyword = '龙蟠1号' THEN '龙蟠'
        WHEN referenceKeyword = '龙蟠机油' THEN '龙蟠'
        WHEN referenceKeyword = '龙蟠' THEN '龙蟠'
        WHEN referenceKeyword = '龙蟠1号' THEN '龙蟠1号'
        WHEN referenceKeyword = '龙蟠机油' THEN '龙蟠1号'
        WHEN referenceKeyword = '龙蟠润滑油' THEN '龙蟠1号'
        WHEN referenceKeyword = '金美' THEN '美孚'
        WHEN referenceKeyword = '银美' THEN '美孚'
        WHEN referenceKeyword = 'Mobil' THEN '美孚'
        WHEN referenceKeyword = '力霸' THEN '美孚'
        WHEN referenceKeyword = '美孚' THEN '美孚'
        WHEN referenceKeyword = '美孚1号' THEN '美孚'
        WHEN referenceKeyword = '速霸' THEN '美孚'
        WHEN referenceKeyword = '美孚速霸' THEN '美孚'
        WHEN referenceKeyword = '美1' THEN '美孚'
        WHEN referenceKeyword = '美一' THEN '美孚'
        WHEN referenceKeyword = '统一机油' THEN '统一'
        WHEN referenceKeyword = '统一润滑油' THEN '统一'
        WHEN referenceKeyword = '统一润滑' THEN '统一'
        WHEN referenceKeyword = '统一' THEN '统一'
        WHEN referenceKeyword = '长城机油' THEN '长城'
        WHEN referenceKeyword = '长城润滑油' THEN '长城'
        WHEN referenceKeyword = '长城润滑' THEN '长城'
        WHEN referenceKeyword = '长城' THEN '长城'
        ELSE NULL
    END  brand,
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
        func,
        referenceKeyword,
        category,
        brand,
        project_name
    )
    SELECT
        auto_id,
        {table[8]} quarter,
        REGEXP_REPLACE(title, '<[^>]+>', '') title,
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
        CASE
        WHEN content REGEXP '磨损' THEN '磨损'
        WHEN content REGEXP '粘度' THEN '粘度'
        WHEN content REGEXP '动力' THEN '动力'
        WHEN content REGEXP '抗磨' THEN '抗磨'
        WHEN content REGEXP '冷启动' THEN '冷启动'
        WHEN content REGEXP '保护' THEN '保护'
        WHEN content REGEXP '油膜' THEN '油膜'
        WHEN content REGEXP '长效' THEN '长效'
        WHEN content REGEXP '积碳' THEN '积碳'
        WHEN content REGEXP '清洁' THEN '清洁'
        WHEN content REGEXP '噪音' THEN '噪音'
        WHEN content REGEXP '抖动' THEN '抖动'
        WHEN content REGEXP '油泥' THEN '油泥'
        WHEN content REGEXP '静音' THEN '静音'
        ELSE NULL
    END AS func,
        referenceKeyword,
     CASE
        WHEN referenceKeyword REGEXP '磁护' THEN '磁护'
        WHEN referenceKeyword REGEXP '极护' THEN '极护'
        WHEN referenceKeyword REGEXP '极净' THEN '极净'
        WHEN referenceKeyword REGEXP 'GTX' THEN 'GTX'
        WHEN referenceKeyword REGEXP '超凡喜力' THEN '超凡喜力'
        WHEN referenceKeyword REGEXP '力霸' THEN '力霸'
        WHEN referenceKeyword REGEXP '美孚1号' THEN '美孚1号'
        WHEN referenceKeyword REGEXP '速霸' THEN '速霸'
        WHEN referenceKeyword REGEXP '美孚' AND referenceKeyword NOT REGEXP '力霸|速霸' THEN '美孚1号'
        WHEN referenceKeyword REGEXP '喜力' AND referenceKeyword NOT REGEXP '超凡喜力' THEN '喜力'
        ELSE NULL
    END AS category,
    CASE
        WHEN referenceKeyword = '道达尔' THEN '道达尔'
        WHEN referenceKeyword = 'castrol' THEN '嘉实多'
        WHEN referenceKeyword = '磁护' THEN '嘉实多'
        WHEN referenceKeyword = '极护' THEN '嘉实多'
        WHEN referenceKeyword = '极净' THEN '嘉实多'
        WHEN referenceKeyword = '嘉护' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多' THEN '嘉实多'
        WHEN referenceKeyword = '快驰' THEN '嘉实多'
        WHEN referenceKeyword = '黑嘉' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多极护' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多EDGE' THEN '嘉实多'
        WHEN referenceKeyword = 'edge' THEN '嘉实多'
        WHEN referenceKeyword = '嘉实多磁护' THEN '嘉实多'
        WHEN referenceKeyword = 'magnatec' THEN '嘉实多'
        WHEN referenceKeyword = 'Shell' THEN '壳牌'
        WHEN referenceKeyword = '黄壳' THEN '壳牌'
        WHEN referenceKeyword = '黄喜力' THEN '壳牌'
        WHEN referenceKeyword = '灰壳' THEN '壳牌'
        WHEN referenceKeyword = '壳牌' THEN '壳牌'
        WHEN referenceKeyword = '蓝壳' THEN '壳牌'
        WHEN referenceKeyword = '喜力' THEN '壳牌'
        WHEN referenceKeyword = '港壳' THEN '壳牌'
        WHEN referenceKeyword = '港灰' THEN '壳牌'
        WHEN referenceKeyword = '红壳' THEN '壳牌'
        WHEN referenceKeyword = '白壳' THEN '壳牌'
        WHEN referenceKeyword = '金壳' THEN '壳牌'
        WHEN referenceKeyword = '紫壳' THEN '壳牌'
        WHEN referenceKeyword = '壳牌先锋' THEN '壳牌'
        WHEN referenceKeyword = '壳牌锐净' THEN '壳牌'
        WHEN referenceKeyword = '壳牌喜力' THEN '壳牌'
        WHEN referenceKeyword = '超级喜力' THEN '壳牌'
        WHEN referenceKeyword = '极净' THEN '壳牌'
        WHEN referenceKeyword = '超凡喜力' THEN '壳牌'
        WHEN referenceKeyword = '昆仑机油' THEN '昆仑'
        WHEN referenceKeyword = '昆仑润滑' THEN '昆仑'
        WHEN referenceKeyword = '昆仑天润' THEN '昆仑'
        WHEN referenceKeyword = '昆仑之星' THEN '昆仑'
        WHEN referenceKeyword = '昆仑' THEN '昆仑'
        WHEN referenceKeyword = '龙蟠1号' THEN '龙蟠'
        WHEN referenceKeyword = '龙蟠机油' THEN '龙蟠'
        WHEN referenceKeyword = '龙蟠' THEN '龙蟠'
        WHEN referenceKeyword = '龙蟠1号' THEN '龙蟠1号'
        WHEN referenceKeyword = '龙蟠机油' THEN '龙蟠1号'
        WHEN referenceKeyword = '龙蟠润滑油' THEN '龙蟠1号'
        WHEN referenceKeyword = '金美' THEN '美孚'
        WHEN referenceKeyword = '银美' THEN '美孚'
        WHEN referenceKeyword = 'Mobil' THEN '美孚'
        WHEN referenceKeyword = '力霸' THEN '美孚'
        WHEN referenceKeyword = '美孚' THEN '美孚'
        WHEN referenceKeyword = '美孚1号' THEN '美孚'
        WHEN referenceKeyword = '速霸' THEN '美孚'
        WHEN referenceKeyword = '美孚速霸' THEN '美孚'
        WHEN referenceKeyword = '美1' THEN '美孚'
        WHEN referenceKeyword = '美一' THEN '美孚'
        WHEN referenceKeyword = '统一机油' THEN '统一'
        WHEN referenceKeyword = '统一润滑油' THEN '统一'
        WHEN referenceKeyword = '统一润滑' THEN '统一'
        WHEN referenceKeyword = '统一' THEN '统一'
        WHEN referenceKeyword = '长城机油' THEN '长城'
        WHEN referenceKeyword = '长城润滑油' THEN '长城'
        WHEN referenceKeyword = '长城润滑' THEN '长城'
        WHEN referenceKeyword = '长城' THEN '长城'
        ELSE NULL
    END  brand,
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