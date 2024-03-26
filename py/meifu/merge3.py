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


category1 = '''  ( case
	WHEN title regexp '道达尔'      then '快驰'
	WHEN title regexp '快驰'      then '快驰'
	WHEN title regexp 'castrol'      then null
	WHEN title regexp '磁护'      then '磁护'
	WHEN title regexp '极护'      then '极护'
	WHEN title regexp '嘉护'      then 'GTX'
	WHEN title regexp 'GTX'      then 'GTX'
	WHEN title regexp '黑嘉'      then 'GTX'
	WHEN title regexp '嘉实多极护'      then '极护'
	WHEN title regexp 'EDGE'      then '极护'
	WHEN title regexp 'edge'      then '极护'
	WHEN title regexp '嘉实多磁护'      then '磁护'
	WHEN title regexp 'magnatec'      then '磁护'
	WHEN title regexp '嘉实多'      then null
	WHEN title regexp 'Shell'      then null
	WHEN title regexp '黄壳'      then '喜力'
	WHEN title regexp '黄喜力'      then '喜力'
	WHEN title regexp '灰壳'      then '超凡喜力'
	WHEN title regexp '蓝壳'      then '喜力'
	WHEN title regexp '壳牌喜力'      then '喜力'
	WHEN title regexp '港壳'      then '超凡喜力'
	WHEN title regexp '港灰'      then '超凡喜力'
	WHEN title regexp '红壳'      then '喜力'
	WHEN title regexp '白壳'      then '喜力'
	WHEN title regexp '金壳'      then '超凡喜力'
	WHEN title regexp '紫壳'      then '喜力'
	WHEN title regexp '壳牌先锋'      then '超凡喜力'
	WHEN title regexp '壳牌锐净'      then '超凡喜力'
	WHEN title regexp '壳牌喜力'      then '超凡喜力'
	WHEN title regexp '超级喜力'      then '超凡喜力'
	WHEN title regexp '恒护'      then '超凡喜力'
	WHEN title regexp '极净'      then '超凡喜力'
	WHEN title regexp '超凡喜力'      then '超凡喜力'
	WHEN title regexp '壳牌'      then null
	WHEN title regexp '昆仑机油'      then '昆仑'
	WHEN title regexp '昆仑润滑'      then '昆仑'
	WHEN title regexp '昆仑天润'      then '昆仑'
	WHEN title regexp '昆仑之星'      then '昆仑'
	WHEN title regexp '昆仑'      then '昆仑'
	WHEN title regexp '龙蟠1号'      then '龙蟠1号'
	WHEN title regexp '龙蟠机油'      then '龙蟠1号'
	WHEN title regexp '龙蟠1号'      then '龙蟠1号'
	WHEN title regexp '龙蟠机油'      then '龙蟠1号'
	WHEN title regexp '龙蟠润滑油'      then '龙蟠1号'
	WHEN title regexp '龙蟠'      then '龙蟠1号'
	WHEN title regexp '金美'      then '美1'
	WHEN title regexp '银美'      then '美1'
	WHEN title regexp '超金'      then '美1'
	WHEN title regexp 'Mobil'      then '美1'
	WHEN title regexp '力霸'      then '力霸'
	WHEN title regexp '美孚1号'      then '美1'
	WHEN title regexp '速霸'      then '速霸'
	WHEN title regexp '美孚速霸'      then '速霸'
	WHEN title regexp '美1'      then '美1'
	WHEN title regexp '美一'      then '美1'
	WHEN title regexp '美孚'      then '美1'
	WHEN title regexp '统一机油'      then '统一'
	WHEN title regexp '统一润滑油'      then '统一'
	WHEN title regexp '统一润滑'      then '统一'
	WHEN title regexp '统一'      then '统一'
	WHEN title regexp '长城机油'      then '长城'
	WHEN title regexp '长城润滑油'      then '长城'
	WHEN title regexp '长城润滑'      then '长城'
	WHEN title regexp '长城'      then '长城'
	ELSE NULL
	END 
) '''


category_null =''' 
              CASE
                    WHEN title REGEXP 'castrol' THEN '嘉实多'
                    WHEN title REGEXP '嘉实多' THEN '嘉实多'
                    WHEN title REGEXP 'Shell' THEN '壳牌'
                    WHEN title REGEXP '壳牌' THEN '壳牌'
                    WHEN title  REGEXP 'Mobil' THEN '美孚'
                    WHEN title REGEXP '美孚' THEN '美孚'
                    WHEN title REGEXP '恒久动力' THEN '美孚'
                    else null 
                END  '''

brand = f'''
            CASE
                WHEN category = '快驰' THEN '道达尔'
                WHEN category = '磁护' THEN '嘉实多'
                WHEN category = '极护' THEN '嘉实多'
                WHEN category = '极净' THEN '嘉实多'
                WHEN category = 'GTX' THEN '嘉实多'
                WHEN category = '喜力' THEN '壳牌'
                WHEN category = '超凡喜力' THEN '壳牌'
                WHEN category = '昆仑' THEN '昆仑'
                WHEN category = '龙蟠1号' THEN '龙蟠'
                WHEN category = '美1' THEN '美孚'
                WHEN category = '力霸' THEN '美孚'
                WHEN category = '速霸' THEN '美孚'
                WHEN category = '统一' THEN '统一'
                WHEN category = '长城' THEN '长城'
                WHEN category is null THEN {category_null} 
                else null
            END   '''

start_time = time.time()  # 记录开始时间

cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_3 ;")
print(f"删除表:meifu_analysis_platform_main_2023_3")
# 创建表格
cursor.execute('''create table  meifu_analysis_platform_main_2023_3 as 
              select distinct * from meifu_analysis_platform_main_2023_2 
               where webpageUrl is not null ;''')



cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_4 ;")
print(f"删除表:meifu_analysis_platform_main_2023_4")
cursor.execute('''create table  meifu_analysis_platform_main_2023_6 as 
              select a.*,b.sentiment_flag,b.shuijun from meifu_analysis_platform_main_2023_3 a 
               left join meifu_sentiment_flag_2023 b 
                 on a.id = b.id
               ''')


cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_5 ;")
print(f"删除表:meifu_analysis_platform_main_2023_5")
# 创建表格
cursor.execute(f'''
    create table meifu_analysis_platform_main_2023_5 as 
    select
            `quarter`,
            title,
            is_meifu_maintain,
            is_brand_kol,
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
            functions,
            formulations ,
            cost_performance ,
            product_attributes,
            referenceKeyword,
            case when category is null  then {category1} else category end as category,
             brand,
            scene,
            commentContent,
            sentiment_flag,
            shuijun,
            project_name
         from meifu_analysis_platform_main_2023_4 a 

               ''')

cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_6 ;")
print(f"删除表:meifu_analysis_platform_main_2023_6")
# 创建表格
cursor.execute(f'''
   create table meifu_analysis_platform_main_2023_6 as 
    select
            `quarter`,
            title,
            is_meifu_maintain,
            is_brand_kol,
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
            functions,
            formulations ,
            cost_performance ,
            product_attributes,
            referenceKeyword,
            category,
             case when brand is null then {brand} else brand end brand,
            (comments + praiseNum + forwardNumber) cpf_cnt,
            scene,
            commentContent,
             sentiment_flag,
            shuijun,
            project_name
         from meifu_analysis_platform_main_2023_5 a 
               
               ''')

cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_3 ;")
print(f"删除表:meifu_analysis_platform_main_2023_3")
cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_4 ;")
print(f"删除表:meifu_analysis_platform_main_2023_4")
cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_5 ;")
print(f"删除表:meifu_analysis_platform_main_2023_5")
end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"创建表格执行时间：{execution_time}秒")

# 提交更改并关闭连接
conn.commit()
conn.close()