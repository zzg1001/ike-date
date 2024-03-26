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
    print(f"插入数据执行")
    category_null =''' 
            CASE
                    WHEN CASE
                            WHEN is_comment = 0 THEN content
                            WHEN is_comment = 1 THEN commentContent
                        END REGEXP 'castrol' THEN '嘉实多'
                    WHEN CASE
                            WHEN is_comment = 0 THEN content
                            WHEN is_comment = 1 THEN commentContent
                        END REGEXP '嘉实多' THEN '嘉实多'
                    WHEN CASE
                            WHEN is_comment = 0 THEN content
                            WHEN is_comment = 1 THEN commentContent
                        END REGEXP 'Shell' THEN '壳牌'
                    WHEN CASE
                            WHEN is_comment = 0 THEN content
                            WHEN is_comment = 1 THEN commentContent
                        END REGEXP '壳牌' THEN '壳牌'
                   WHEN CASE
                            WHEN is_comment = 0 THEN content
                            WHEN is_comment = 1 THEN commentContent
                        END REGEXP 'Mobil' THEN '美孚'
                    WHEN CASE
                            WHEN is_comment = 0 THEN content
                            WHEN is_comment = 1 THEN commentContent
                        END REGEXP '美孚' THEN '美孚'
                    WHEN CASE
                            WHEN is_comment = 0 THEN content
                            WHEN is_comment = 1 THEN commentContent
                        END REGEXP '恒久动力' THEN '美孚'
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
    
    funcs = ''' case
        WHEN content REGEXP '磨损'   then '磨损'  
        WHEN content REGEXP '粘度'   then '粘度'  
        WHEN content REGEXP '动力'   then '动力'  
        WHEN content REGEXP '抗磨'   then '抗磨'  
        WHEN content REGEXP '冷启动' then '冷启动'
        WHEN content REGEXP '保护'   then '保护'  
        WHEN content REGEXP '油膜'   then '油膜'  
        WHEN content REGEXP '长效'   then '长效'  
        WHEN content REGEXP '积碳'   then '积碳'  
        WHEN content REGEXP '清洁'   then '清洁'  
        WHEN content REGEXP '噪音'   then '噪音'  
        WHEN content REGEXP '抖动'   then '抖动'  
        WHEN content REGEXP '油泥'   then '油泥'  
        WHEN content REGEXP '静音'   then '静音'  
        ELSE null
    END '''

    ## 配方
    formulation = ''' case
        WHEN content REGEXP '合成'     then '合成'    
        WHEN content REGEXP '半合成'   then '半合成'  
        WHEN content REGEXP '添加剂'   then '添加剂'  
        WHEN content REGEXP '抗磨剂'   then '抗磨剂'  
        WHEN content REGEXP '清净'     then '清净'    
        WHEN content REGEXP '分散剂'   then '分散剂'  
        WHEN content REGEXP '基础油'   then '基础油'  
        WHEN content REGEXP '改进剂'   then '改进剂'  
        WHEN content REGEXP '抗氧化剂' then '抗氧化剂'
        ELSE null
    END '''


    ## 价格性价比
    cost = '''case 
        WHEN content REGEXP  '价格'        then '价格'    
        WHEN content REGEXP  '成本'        then '成本'    
        WHEN content REGEXP  '折扣'        then '折扣'    
        WHEN content REGEXP  '价位'        then '价位'    
        WHEN content REGEXP  '昂贵'        then '昂贵'    
        WHEN content REGEXP  '经济'        then '经济'    
        WHEN content REGEXP  '竞争力'      then '竞争力'  
        WHEN content REGEXP  '优惠'        then '优惠'    
        WHEN content REGEXP  '性价比'      then '性价比'  
        WHEN content REGEXP  '物超所值'    then '物超所值'
        WHEN content REGEXP  '便宜'        then '便宜'    
        WHEN content REGEXP  '实惠'        then '实惠'    
        WHEN content REGEXP  '打折'        then '打折'    
        WHEN content REGEXP  '费用'        then '费用'    
        WHEN content REGEXP  '价钱'        then '价钱'    
        WHEN content REGEXP  '定价'        then '定价'    
        WHEN content REGEXP  '奢侈'        then '奢侈'    
        WHEN content REGEXP  '高价'        then '高价'    
        WHEN content REGEXP  '廉价'        then '廉价'    
        ELSE null
    END '''

    cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_2;")
    print(f"删除表：meifu_analysis_platform_main_2023_2")
    
    comp = f''' 
    create table meifu_analysis_platform_main_2023_2 as 
    select
            `quarter`,
            title,
            is_meifu_maintain,
            '' is_brand_kol,
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
            {funcs} as functions,
            {formulation} as formulations ,
            {cost} as cost_performance ,
              CASE -- 产品层面
                WHEN func IS NULL THEN
                    CASE
                        WHEN formulation IS NULL THEN
                            CASE
                                WHEN ranges IS NULL THEN
                                    CASE
                                        WHEN effective IS NULL THEN
                                            CASE
                                                WHEN protection IS NULL THEN service
                                                ELSE protection
                                            END
                                        ELSE effective
                                    END
                                ELSE ranges
                            END
                        ELSE formulation
                    END
                ELSE func
            END AS product_attributes,
            referenceKeyword,
            category,
           { brand } AS brand,
            scene,
            commentContent,
            project_name
         from meifu_analysis_platform_main_2023_1 a 
                  '''
    cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2023_1;")
    print(f"删除表：meifu_analysis_platform_main_2023_1")
    start_time = time.time()  # 记录开始时间
    cursor.execute(comp)
    end_time = time.time()  # 记录结束时间
    execution_time = end_time - start_time
    print(f"插入数据执行时间：{execution_time}秒")

    # 提交更改并关闭连接
    conn.commit()
    conn.close()