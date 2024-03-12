import pymysql
import time

if __name__=="__main__":

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
    cursor.execute(insert)
    end_time = time.time()  # 记录结束时间
    execution_time = end_time - start_time
    print(f"插入数据执行时间：{execution_time}秒")

    cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_3;")
    comp = ''' 
    create table meifu_analysis_platform_main_2023_3 as 
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
                    from meifu_analysis_platform_main_2023_2 a 
                    left join (select webpageUrl_new, brand from meifu_analysis_platform_main_2023_2 where is_comment = 0
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