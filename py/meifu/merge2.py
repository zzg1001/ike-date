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


brand0 = '''  ( CASE
        WHEN weiboTopicKeyword regexp '道达尔' THEN '道达尔'
        WHEN weiboTopicKeyword regexp 'castrol' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '磁护' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '极护' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '极净' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '嘉护' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '嘉实多' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '快驰' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '黑嘉' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '嘉实多极护' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '嘉实多EDGE' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp 'edge' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp '嘉实多磁护' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp 'magnatec' THEN '嘉实多'
        WHEN weiboTopicKeyword regexp 'Shell' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '黄壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '黄喜力' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '灰壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '壳牌' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '蓝壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '喜力' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '港壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '港灰' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '红壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '白壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '金壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '紫壳' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '壳牌先锋' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '壳牌锐净' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '壳牌喜力' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '超级喜力' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '极净' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '超凡喜力' THEN '壳牌'
        WHEN weiboTopicKeyword regexp '昆仑机油' THEN '昆仑'
        WHEN weiboTopicKeyword regexp '昆仑润滑' THEN '昆仑'
        WHEN weiboTopicKeyword regexp '昆仑天润' THEN '昆仑'
        WHEN weiboTopicKeyword regexp '昆仑之星' THEN '昆仑'
        WHEN weiboTopicKeyword regexp '昆仑' THEN '昆仑'
        WHEN weiboTopicKeyword regexp '龙蟠1号' THEN '龙蟠'
        WHEN weiboTopicKeyword regexp '龙蟠机油' THEN '龙蟠'
        WHEN weiboTopicKeyword regexp '龙蟠' THEN '龙蟠'
        WHEN weiboTopicKeyword regexp '龙蟠1号' THEN '龙蟠1号'
        WHEN weiboTopicKeyword regexp '龙蟠机油' THEN '龙蟠1号'
        WHEN weiboTopicKeyword regexp '龙蟠润滑油' THEN '龙蟠1号'
        WHEN weiboTopicKeyword regexp '金美' THEN '美孚'
        WHEN weiboTopicKeyword regexp '银美' THEN '美孚'
        WHEN weiboTopicKeyword regexp 'Mobil' THEN '美孚'
        WHEN weiboTopicKeyword regexp '力霸' THEN '美孚'
        WHEN weiboTopicKeyword regexp '美孚' THEN '美孚'
        WHEN weiboTopicKeyword regexp '美孚1号' THEN '美孚'
        WHEN weiboTopicKeyword regexp '速霸' THEN '美孚'
        WHEN weiboTopicKeyword regexp '美孚速霸' THEN '美孚'
        WHEN weiboTopicKeyword regexp '美1' THEN '美孚'
        WHEN weiboTopicKeyword regexp '美一' THEN '美孚'
        WHEN weiboTopicKeyword regexp '统一机油' THEN '统一'
        WHEN weiboTopicKeyword regexp '统一润滑油' THEN '统一'
        WHEN weiboTopicKeyword regexp '统一润滑' THEN '统一'
        WHEN weiboTopicKeyword regexp '统一' THEN '统一'
        WHEN weiboTopicKeyword regexp '长城机油' THEN '长城'
        WHEN weiboTopicKeyword regexp '长城润滑油' THEN '长城'
        WHEN weiboTopicKeyword regexp '长城润滑' THEN '长城'
        WHEN weiboTopicKeyword regexp '长城' THEN '长城'
        ELSE NULL
    END ) '''


brand1 = '''  ( CASE
        WHEN summary_new regexp '道达尔' THEN '道达尔'
        WHEN summary_new regexp 'castrol' THEN '嘉实多'
        WHEN summary_new regexp '磁护' THEN '嘉实多'
        WHEN summary_new regexp '极护' THEN '嘉实多'
        WHEN summary_new regexp '极净' THEN '嘉实多'
        WHEN summary_new regexp '嘉护' THEN '嘉实多'
        WHEN summary_new regexp '嘉实多' THEN '嘉实多'
        WHEN summary_new regexp '快驰' THEN '嘉实多'
        WHEN summary_new regexp '黑嘉' THEN '嘉实多'
        WHEN summary_new regexp '嘉实多极护' THEN '嘉实多'
        WHEN summary_new regexp '嘉实多EDGE' THEN '嘉实多'
        WHEN summary_new regexp 'edge' THEN '嘉实多'
        WHEN summary_new regexp '嘉实多磁护' THEN '嘉实多'
        WHEN summary_new regexp 'magnatec' THEN '嘉实多'
        WHEN summary_new regexp 'Shell' THEN '壳牌'
        WHEN summary_new regexp '黄壳' THEN '壳牌'
        WHEN summary_new regexp '黄喜力' THEN '壳牌'
        WHEN summary_new regexp '灰壳' THEN '壳牌'
        WHEN summary_new regexp '壳牌' THEN '壳牌'
        WHEN summary_new regexp '蓝壳' THEN '壳牌'
        WHEN summary_new regexp '喜力' THEN '壳牌'
        WHEN summary_new regexp '港壳' THEN '壳牌'
        WHEN summary_new regexp '港灰' THEN '壳牌'
        WHEN summary_new regexp '红壳' THEN '壳牌'
        WHEN summary_new regexp '白壳' THEN '壳牌'
        WHEN summary_new regexp '金壳' THEN '壳牌'
        WHEN summary_new regexp '紫壳' THEN '壳牌'
        WHEN summary_new regexp '壳牌先锋' THEN '壳牌'
        WHEN summary_new regexp '壳牌锐净' THEN '壳牌'
        WHEN summary_new regexp '壳牌喜力' THEN '壳牌'
        WHEN summary_new regexp '超级喜力' THEN '壳牌'
        WHEN summary_new regexp '极净' THEN '壳牌'
        WHEN summary_new regexp '超凡喜力' THEN '壳牌'
        WHEN summary_new regexp '昆仑机油' THEN '昆仑'
        WHEN summary_new regexp '昆仑润滑' THEN '昆仑'
        WHEN summary_new regexp '昆仑天润' THEN '昆仑'
        WHEN summary_new regexp '昆仑之星' THEN '昆仑'
        WHEN summary_new regexp '昆仑' THEN '昆仑'
        WHEN summary_new regexp '龙蟠1号' THEN '龙蟠'
        WHEN summary_new regexp '龙蟠机油' THEN '龙蟠'
        WHEN summary_new regexp '龙蟠' THEN '龙蟠'
        WHEN summary_new regexp '龙蟠1号' THEN '龙蟠1号'
        WHEN summary_new regexp '龙蟠机油' THEN '龙蟠1号'
        WHEN summary_new regexp '龙蟠润滑油' THEN '龙蟠1号'
        WHEN summary_new regexp '金美' THEN '美孚'
        WHEN summary_new regexp '银美' THEN '美孚'
        WHEN summary_new regexp 'Mobil' THEN '美孚'
        WHEN summary_new regexp '力霸' THEN '美孚'
        WHEN summary_new regexp '美孚' THEN '美孚'
        WHEN summary_new regexp '美孚1号' THEN '美孚'
        WHEN summary_new regexp '速霸' THEN '美孚'
        WHEN summary_new regexp '美孚速霸' THEN '美孚'
        WHEN summary_new regexp '美1' THEN '美孚'
        WHEN summary_new regexp '美一' THEN '美孚'
        WHEN summary_new regexp '统一机油' THEN '统一'
        WHEN summary_new regexp '统一润滑油' THEN '统一'
        WHEN summary_new regexp '统一润滑' THEN '统一'
        WHEN summary_new regexp '统一' THEN '统一'
        WHEN summary_new regexp '长城机油' THEN '长城'
        WHEN summary_new regexp '长城润滑油' THEN '长城'
        WHEN summary_new regexp '长城润滑' THEN '长城'
        WHEN summary_new regexp '长城' THEN '长城'
        ELSE NULL
    END ) '''
# 删除表格
cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_3;")
insert =f'''
 create table meifu_analysis_platform_main_2023_3 as 
      select
        `quarter`,
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
       case when captureWebsiteNew     in('新浪微博','微博头条')  then {brand0}
            when captureWebsiteNew not in('新浪微博','微博头条')  then {brand1} 
            end as brand,
        scene,
        commentContent,
        project_name
	from meifu_analysis_platform_main_2023_2 ;
                '''


start_time = time.time()  # 记录开始时间
cursor.execute(insert)
end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"插入数据执行时间：{execution_time}秒")

cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_4;")
comp = ''' 
create table meifu_analysis_platform_main_2023_4 as 
select
        `quarter`,
        title,
        maintenance,
        is_comment,
        webpageUrl,
        a.webpageUrl_new,
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
        a.brand,
		case when b.brand  LIKE CONCAT('%',a.brand, '%') then a.brand else null end brand_new,
        scene,
        commentContent,
        project_name
				from meifu_analysis_platform_main_2023_3 a 
				left join (select webpageUrl_new, brand from meifu_analysis_platform_main_2023_3 where is_comment = 0
				   group by webpageUrl_new, brand) b 
				 on  REGEXP_REPLACE(a.webpageUrl_new, '/+$', '') 
                 =  REGEXP_REPLACE(b.webpageUrl_new, '/+$', ''); '''
start_time = time.time()  # 记录开始时间
cursor.execute(comp)
end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"插入数据执行时间：{execution_time}秒")

# 提交更改并关闭连接
conn.commit()
conn.close()