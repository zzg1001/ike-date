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
cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_2;")
print(f'插入的表data_23q3,季度是:3')



category0='''( CASE
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
      END )'''
category1='''( CASE
        WHEN content REGEXP '磁护' THEN '磁护'
        WHEN content REGEXP '极护' THEN '极护'
        WHEN content REGEXP '极净' THEN '极净'
        WHEN content REGEXP 'GTX' THEN 'GTX'
        WHEN content REGEXP '超凡喜力' THEN '超凡喜力'
        WHEN content REGEXP '力霸' THEN '力霸'
        WHEN content REGEXP '美孚1号' THEN '美孚1号'
        WHEN content REGEXP '速霸' THEN '速霸'
        WHEN content REGEXP '美孚' AND referenceKeyword NOT REGEXP '力霸|速霸' THEN '美孚1号'
        WHEN content REGEXP '喜力' AND referenceKeyword NOT REGEXP '超凡喜力' THEN '喜力'
        ELSE NULL
      END )'''

brand0 = '''  ( CASE
        WHEN referenceKeyword regexp '道达尔' THEN '道达尔'
        WHEN referenceKeyword regexp 'castrol' THEN '嘉实多'
        WHEN referenceKeyword regexp '磁护' THEN '嘉实多'
        WHEN referenceKeyword regexp '极护' THEN '嘉实多'
        WHEN referenceKeyword regexp '极净' THEN '嘉实多'
        WHEN referenceKeyword regexp '嘉护' THEN '嘉实多'
        WHEN referenceKeyword regexp '嘉实多' THEN '嘉实多'
        WHEN referenceKeyword regexp '快驰' THEN '嘉实多'
        WHEN referenceKeyword regexp '黑嘉' THEN '嘉实多'
        WHEN referenceKeyword regexp '嘉实多极护' THEN '嘉实多'
        WHEN referenceKeyword regexp '嘉实多EDGE' THEN '嘉实多'
        WHEN referenceKeyword regexp 'edge' THEN '嘉实多'
        WHEN referenceKeyword regexp '嘉实多磁护' THEN '嘉实多'
        WHEN referenceKeyword regexp 'magnatec' THEN '嘉实多'
        WHEN referenceKeyword regexp 'Shell' THEN '壳牌'
        WHEN referenceKeyword regexp '黄壳' THEN '壳牌'
        WHEN referenceKeyword regexp '黄喜力' THEN '壳牌'
        WHEN referenceKeyword regexp '灰壳' THEN '壳牌'
        WHEN referenceKeyword regexp '壳牌' THEN '壳牌'
        WHEN referenceKeyword regexp '蓝壳' THEN '壳牌'
        WHEN referenceKeyword regexp '喜力' THEN '壳牌'
        WHEN referenceKeyword regexp '港壳' THEN '壳牌'
        WHEN referenceKeyword regexp '港灰' THEN '壳牌'
        WHEN referenceKeyword regexp '红壳' THEN '壳牌'
        WHEN referenceKeyword regexp '白壳' THEN '壳牌'
        WHEN referenceKeyword regexp '金壳' THEN '壳牌'
        WHEN referenceKeyword regexp '紫壳' THEN '壳牌'
        WHEN referenceKeyword regexp '壳牌先锋' THEN '壳牌'
        WHEN referenceKeyword regexp '壳牌锐净' THEN '壳牌'
        WHEN referenceKeyword regexp '壳牌喜力' THEN '壳牌'
        WHEN referenceKeyword regexp '超级喜力' THEN '壳牌'
        WHEN referenceKeyword regexp '极净' THEN '壳牌'
        WHEN referenceKeyword regexp '超凡喜力' THEN '壳牌'
        WHEN referenceKeyword regexp '昆仑机油' THEN '昆仑'
        WHEN referenceKeyword regexp '昆仑润滑' THEN '昆仑'
        WHEN referenceKeyword regexp '昆仑天润' THEN '昆仑'
        WHEN referenceKeyword regexp '昆仑之星' THEN '昆仑'
        WHEN referenceKeyword regexp '昆仑' THEN '昆仑'
        WHEN referenceKeyword regexp '龙蟠1号' THEN '龙蟠'
        WHEN referenceKeyword regexp '龙蟠机油' THEN '龙蟠'
        WHEN referenceKeyword regexp '龙蟠' THEN '龙蟠'
        WHEN referenceKeyword regexp '龙蟠1号' THEN '龙蟠1号'
        WHEN referenceKeyword regexp '龙蟠机油' THEN '龙蟠1号'
        WHEN referenceKeyword regexp '龙蟠润滑油' THEN '龙蟠1号'
        WHEN referenceKeyword regexp '金美' THEN '美孚'
        WHEN referenceKeyword regexp '银美' THEN '美孚'
        WHEN referenceKeyword regexp 'Mobil' THEN '美孚'
        WHEN referenceKeyword regexp '力霸' THEN '美孚'
        WHEN referenceKeyword regexp '美孚' THEN '美孚'
        WHEN referenceKeyword regexp '美孚1号' THEN '美孚'
        WHEN referenceKeyword regexp '速霸' THEN '美孚'
        WHEN referenceKeyword regexp '美孚速霸' THEN '美孚'
        WHEN referenceKeyword regexp '美1' THEN '美孚'
        WHEN referenceKeyword regexp '美一' THEN '美孚'
        WHEN referenceKeyword regexp '统一机油' THEN '统一'
        WHEN referenceKeyword regexp '统一润滑油' THEN '统一'
        WHEN referenceKeyword regexp '统一润滑' THEN '统一'
        WHEN referenceKeyword regexp '统一' THEN '统一'
        WHEN referenceKeyword regexp '长城机油' THEN '长城'
        WHEN referenceKeyword regexp '长城润滑油' THEN '长城'
        WHEN referenceKeyword regexp '长城润滑' THEN '长城'
        WHEN referenceKeyword regexp '长城' THEN '长城'
        ELSE NULL
    END ) '''

brand1 = '''  ( CASE
        WHEN content regexp '道达尔' THEN '道达尔'
        WHEN content regexp 'castrol' THEN '嘉实多'
        WHEN content regexp '磁护' THEN '嘉实多'
        WHEN content regexp '极护' THEN '嘉实多'
        WHEN content regexp '极净' THEN '嘉实多'
        WHEN content regexp '嘉护' THEN '嘉实多'
        WHEN content regexp '嘉实多' THEN '嘉实多'
        WHEN content regexp '快驰' THEN '嘉实多'
        WHEN content regexp '黑嘉' THEN '嘉实多'
        WHEN content regexp '嘉实多极护' THEN '嘉实多'
        WHEN content regexp '嘉实多EDGE' THEN '嘉实多'
        WHEN content regexp 'edge' THEN '嘉实多'
        WHEN content regexp '嘉实多磁护' THEN '嘉实多'
        WHEN content regexp 'magnatec' THEN '嘉实多'
        WHEN content regexp 'Shell' THEN '壳牌'
        WHEN content regexp '黄壳' THEN '壳牌'
        WHEN content regexp '黄喜力' THEN '壳牌'
        WHEN content regexp '灰壳' THEN '壳牌'
        WHEN content regexp '壳牌' THEN '壳牌'
        WHEN content regexp '蓝壳' THEN '壳牌'
        WHEN content regexp '喜力' THEN '壳牌'
        WHEN content regexp '港壳' THEN '壳牌'
        WHEN content regexp '港灰' THEN '壳牌'
        WHEN content regexp '红壳' THEN '壳牌'
        WHEN content regexp '白壳' THEN '壳牌'
        WHEN content regexp '金壳' THEN '壳牌'
        WHEN content regexp '紫壳' THEN '壳牌'
        WHEN content regexp '壳牌先锋' THEN '壳牌'
        WHEN content regexp '壳牌锐净' THEN '壳牌'
        WHEN content regexp '壳牌喜力' THEN '壳牌'
        WHEN content regexp '超级喜力' THEN '壳牌'
        WHEN content regexp '极净' THEN '壳牌'
        WHEN content regexp '超凡喜力' THEN '壳牌'
        WHEN content regexp '昆仑机油' THEN '昆仑'
        WHEN content regexp '昆仑润滑' THEN '昆仑'
        WHEN content regexp '昆仑天润' THEN '昆仑'
        WHEN content regexp '昆仑之星' THEN '昆仑'
        WHEN content regexp '昆仑' THEN '昆仑'
        WHEN content regexp '龙蟠1号' THEN '龙蟠'
        WHEN content regexp '龙蟠机油' THEN '龙蟠'
        WHEN content regexp '龙蟠' THEN '龙蟠'
        WHEN content regexp '龙蟠1号' THEN '龙蟠1号'
        WHEN content regexp '龙蟠机油' THEN '龙蟠1号'
        WHEN content regexp '龙蟠润滑油' THEN '龙蟠1号'
        WHEN content regexp '金美' THEN '美孚'
        WHEN content regexp '银美' THEN '美孚'
        WHEN content regexp 'Mobil' THEN '美孚'
        WHEN content regexp '力霸' THEN '美孚'
        WHEN content regexp '美孚' THEN '美孚'
        WHEN content regexp '美孚1号' THEN '美孚'
        WHEN content regexp '速霸' THEN '美孚'
        WHEN content regexp '美孚速霸' THEN '美孚'
        WHEN content regexp '美1' THEN '美孚'
        WHEN content regexp '美一' THEN '美孚'
        WHEN content regexp '统一机油' THEN '统一'
        WHEN content regexp '统一润滑油' THEN '统一'
        WHEN content regexp '统一润滑' THEN '统一'
        WHEN content regexp '统一' THEN '统一'
        WHEN content regexp '长城机油' THEN '长城'
        WHEN content regexp '长城润滑油' THEN '长城'
        WHEN content regexp '长城润滑' THEN '长城'
        WHEN content regexp '长城' THEN '长城'
        ELSE NULL
    END ) '''

scene0 ='''  CASE
        WHEN commentContent REGEXP '高速' THEN '高速'
        WHEN commentContent REGEXP '高架' THEN '高架'
        WHEN commentContent REGEXP '快速路' THEN '快速路'
        WHEN commentContent REGEXP '市区' THEN '市区'
        WHEN commentContent REGEXP '郊区' THEN '郊区'
        WHEN commentContent REGEXP '农村' THEN '农村'
        WHEN commentContent REGEXP '城市' THEN '城市'
        WHEN commentContent REGEXP '市郊' THEN '市郊'
        WHEN commentContent REGEXP '村子' THEN '村子'
        WHEN commentContent REGEXP '村里' THEN '村里'
        WHEN commentContent REGEXP '城区' THEN '城区'
        WHEN commentContent REGEXP '买菜' THEN '买菜'
        WHEN commentContent REGEXP '代步' THEN '代步'
        WHEN commentContent REGEXP '上下班' THEN '上下班'
        WHEN commentContent REGEXP '通勤' THEN '通勤'
        WHEN commentContent REGEXP '长途' THEN '长途'
        WHEN commentContent REGEXP '游玩' THEN '游玩'
        WHEN commentContent REGEXP '短途' THEN '短途'
        ELSE null
    END '''

scene1 ='''  CASE
        WHEN content REGEXP '高速' THEN '高速'
        WHEN content REGEXP '高架' THEN '高架'
        WHEN content REGEXP '快速路' THEN '快速路'
        WHEN content REGEXP '市区' THEN '市区'
        WHEN content REGEXP '郊区' THEN '郊区'
        WHEN content REGEXP '农村' THEN '农村'
        WHEN content REGEXP '城市' THEN '城市'
        WHEN content REGEXP '市郊' THEN '市郊'
        WHEN content REGEXP '村子' THEN '村子'
        WHEN content REGEXP '村里' THEN '村里'
        WHEN content REGEXP '城区' THEN '城区'
        WHEN content REGEXP '买菜' THEN '买菜'
        WHEN content REGEXP '代步' THEN '代步'
        WHEN content REGEXP '上下班' THEN '上下班'
        WHEN content REGEXP '通勤' THEN '通勤'
        WHEN content REGEXP '长途' THEN '长途'
        WHEN content REGEXP '游玩' THEN '游玩'
        WHEN content REGEXP '短途' THEN '短途'
        ELSE null
    END '''

# 创建表格
create_table_query = f'''
CREATE TABLE IF NOT EXISTS meifu_analysis_platform_main_2023_2 AS
  SELECT
        CONCAT(YEAR(publishedMinute), '-Q', QUARTER(publishedMinute)) quarter,
        REGEXP_REPLACE(title, '<[^>]+>', '') title,
        CASE WHEN title REGEXP  '美孚养护店' then '美孚养护店'  else null end as maintenance,
        is_comment,
        webpageUrl,
        SUBSTRING_INDEX(webpageUrl,'?',1) webpageUrl_new,
        captureWebsiteNew,
        publishedMinute,
        originType,
        author,
        summary,
         case when captureWebsiteNew not in('新浪微博','微博头条') 
             then SUBSTRING(summary, 1, LOCATE('<', summary) - 1) 
             else captureWebsiteNew end 
             as summary_new,
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
        case when is_comment = '0' then {category0} 
             when is_comment = '1'then {category0} else null end
        AS category,
      case when is_comment = '0' then {scene0} 
             when is_comment = '1' then {scene1} else null end 
        as scene,
        commentContent,
        project_name
FROM data_23q3;
'''

start_time = time.time()  # 记录开始时间
cursor.execute(create_table_query)
end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"创建表格执行时间：{execution_time}秒")

# 列表中的表名
table_list = ['data_23q4']

# 循环插入数据
for table in table_list:
    print(f'插入的表{table},季度是:{table[8]}')


    insert_query = f'''
    INSERT INTO meifu_analysis_platform_main_2023_2 (
        quarter,
        title,
        maintenance,
        is_comment,
        webpageUrl,
        webpageUrl_new,
        captureWebsiteNew,
        publishedMinute,
        originType,
        author,
        summary,
        summary_new,
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
        description,
        content,
        func,
        referenceKeyword,
        category,
        scene,
        commentContent,
        project_name
    )
    SELECT
        CONCAT(YEAR(publishedMinute), '-Q', QUARTER(publishedMinute)) quarter,
        REGEXP_REPLACE(title, '<[^>]+>', '') title,
        CASE WHEN title REGEXP  '美孚养护店' then '美孚养护店'  else null end as maintenance,
        is_comment,
        webpageUrl,
        case when captureWebsiteNew in ( '大鱼号','百家号','微信')  
            then SUBSTRING_INDEX(webpageUrl,'?',1) else webpageUrl end webpageUrl_new,
        captureWebsiteNew,
        publishedMinute,
        originType,
        author,
        summary,
        case when captureWebsiteNew not in('新浪微博','微博头条') 
             then SUBSTRING(summary, 1, LOCATE('<', summary) - 1) 
             else captureWebsiteNew end 
             as summary_new,
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
        case when is_comment = '0' then {category0} 
             when is_comment = '1'then {category0} else null end
        AS category,
      case when is_comment = '0' then {scene0} 
             when is_comment = '1' then {scene1} else null end 
        as scene,
        commentContent,
        project_name
    FROM {table} ;
    '''
    start_time = time.time()  # 记录开始时间
    cursor.execute(insert_query)
    end_time = time.time()  # 记录结束时间
    execution_time = end_time - start_time
    print(f"插入数据执行时间：{execution_time}秒")

# 提交更改并关闭连接
conn.commit()
conn.close()