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


start_time = time.time()  # 记录开始时间

cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_9 ;")
print(f"删除表:meifu_analysis_platform_main_2023_9")
# 创建表格
cursor.execute('''   create table meifu_analysis_platform_main_2023_9 as 
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
            brand,
            scene,
            commentContent,
            project_name,
              sentiment_flag,
              shuijun,
            case when is_comment = 0 then row_number()over(PARTITION by webpageUrl order by cpf_cnt desc) else null end r 
         from meifu_analysis_platform_main_2023_8   ''')


cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_10 ;")
print(f"删除表:meifu_analysis_platform_main_2023_10")
# 创建表格
cursor.execute('''   create table meifu_analysis_platform_main_2023_10 as 
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
            brand,
            scene,
            commentContent,
            sentiment_flag,
            shuijun,
            project_name
            from meifu_analysis_platform_main_2023_9 a
            where r = 1 or r is null
               
               ''')


end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"创建表格执行时间：{execution_time}秒")

# 提交更改并关闭连接
conn.commit()
conn.close()