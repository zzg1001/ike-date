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
cursor.execute("DROP TABLE IF EXISTS meifu_analysis_platform_main_2024_1;")
print(f'插入的表24q1_mobil')

category1 = '''  ( case
	WHEN commentContent regexp '道达尔'      then '快驰'
	WHEN commentContent regexp '快驰'      then '快驰'
	WHEN commentContent regexp 'castrol'      then null
	WHEN commentContent regexp '磁护'      then '磁护'
	WHEN commentContent regexp '极护'      then '极护'
	WHEN commentContent regexp '嘉护'      then 'GTX'
	WHEN commentContent regexp 'GTX'      then 'GTX'
	WHEN commentContent regexp '黑嘉'      then 'GTX'
	WHEN commentContent regexp '嘉实多极护'      then '极护'
	WHEN commentContent regexp 'EDGE'      then '极护'
	WHEN commentContent regexp 'edge'      then '极护'
	WHEN commentContent regexp '嘉实多磁护'      then '磁护'
	WHEN commentContent regexp 'magnatec'      then '磁护'
	WHEN commentContent regexp '嘉实多'      then null
	WHEN commentContent regexp 'Shell'      then null
	WHEN commentContent regexp '黄壳'      then '喜力'
	WHEN commentContent regexp '黄喜力'      then '喜力'
	WHEN commentContent regexp '灰壳'      then '超凡喜力'
	WHEN commentContent regexp '蓝壳'      then '喜力'
	WHEN commentContent regexp '壳牌喜力'      then '喜力'
	WHEN commentContent regexp '港壳'      then '超凡喜力'
	WHEN commentContent regexp '港灰'      then '超凡喜力'
	WHEN commentContent regexp '红壳'      then '喜力'
	WHEN commentContent regexp '白壳'      then '喜力'
	WHEN commentContent regexp '金壳'      then '超凡喜力'
	WHEN commentContent regexp '紫壳'      then '喜力'
	WHEN commentContent regexp '壳牌先锋'      then '超凡喜力'
	WHEN commentContent regexp '壳牌锐净'      then '超凡喜力'
	WHEN commentContent regexp '壳牌喜力'      then '超凡喜力'
	WHEN commentContent regexp '超级喜力'      then '超凡喜力'
	WHEN commentContent regexp '恒护'      then '超凡喜力'
	WHEN commentContent regexp '极净'      then '超凡喜力'
	WHEN commentContent regexp '超凡喜力'      then '超凡喜力'
	WHEN commentContent regexp '壳牌'      then null
	WHEN commentContent regexp '昆仑机油'      then '昆仑'
	WHEN commentContent regexp '昆仑润滑'      then '昆仑'
	WHEN commentContent regexp '昆仑天润'      then '昆仑'
	WHEN commentContent regexp '昆仑之星'      then '昆仑'
	WHEN commentContent regexp '昆仑'      then '昆仑'
	WHEN commentContent regexp '龙蟠1号'      then '龙蟠1号'
	WHEN commentContent regexp '龙蟠机油'      then '龙蟠1号'
	WHEN commentContent regexp '龙蟠1号'      then '龙蟠1号'
	WHEN commentContent regexp '龙蟠机油'      then '龙蟠1号'
	WHEN commentContent regexp '龙蟠润滑油'      then '龙蟠1号'
	WHEN commentContent regexp '龙蟠'      then '龙蟠1号'
	WHEN commentContent regexp '金美'      then '美1'
	WHEN commentContent regexp '银美'      then '美1'
	WHEN commentContent regexp '超金'      then '美1'
	WHEN commentContent regexp 'Mobil'      then '美1'
	WHEN commentContent regexp '力霸'      then '力霸'
	WHEN commentContent regexp '美孚1号'      then '美1'
	WHEN commentContent regexp '速霸'      then '速霸'
	WHEN commentContent regexp '美孚速霸'      then '速霸'
	WHEN commentContent regexp '美1'      then '美1'
	WHEN commentContent regexp '美一'      then '美1'
	WHEN commentContent regexp '美孚'      then '美1'
	WHEN commentContent regexp '统一机油'      then '统一'
	WHEN commentContent regexp '统一润滑油'      then '统一'
	WHEN commentContent regexp '统一润滑'      then '统一'
	WHEN commentContent regexp '统一'      then '统一'
	WHEN commentContent regexp '长城机油'      then '长城'
	WHEN commentContent regexp '长城润滑油'      then '长城'
	WHEN commentContent regexp '长城润滑'      then '长城'
	WHEN commentContent regexp '长城'      then '长城'
	ELSE NULL
	END 
) '''
category0 = '''  ( case
	WHEN content regexp '道达尔'    then '快驰'
	WHEN content regexp '快驰'      then '快驰'
	WHEN content regexp 'castrol'  then null
	WHEN content regexp '磁护'      then '磁护'
	WHEN content regexp '极护'      then '极护'
	WHEN content regexp '嘉护'      then 'GTX'
	WHEN content regexp 'GTX'      then 'GTX'
	WHEN content regexp '黑嘉'      then 'GTX'
	WHEN content regexp '嘉实多极护'      then '极护'
	WHEN content regexp 'EDGE'      then '极护'
	WHEN content regexp 'edge'      then '极护'
	WHEN content regexp '嘉实多磁护'      then '磁护'
	WHEN content regexp 'magnatec'      then '磁护'
	WHEN content regexp '嘉实多'      then null
	WHEN content regexp 'Shell'      then null
	WHEN content regexp '黄壳'      then '喜力'
	WHEN content regexp '黄喜力'      then '喜力'
	WHEN content regexp '灰壳'      then '超凡喜力'
	WHEN content regexp '蓝壳'      then '喜力'
	WHEN content regexp '壳牌喜力'      then '喜力'
	WHEN content regexp '港壳'      then '超凡喜力'
	WHEN content regexp '港灰'      then '超凡喜力'
	WHEN content regexp '红壳'      then '喜力'
	WHEN content regexp '白壳'      then '喜力'
	WHEN content regexp '金壳'      then '超凡喜力'
	WHEN content regexp '紫壳'      then '喜力'
	WHEN content regexp '壳牌先锋'      then '超凡喜力'
	WHEN content regexp '壳牌锐净'      then '超凡喜力'
	WHEN content regexp '壳牌喜力'      then '超凡喜力'
	WHEN content regexp '超级喜力'      then '超凡喜力'
	WHEN content regexp '恒护'      then '超凡喜力'
	WHEN content regexp '极净'      then '超凡喜力'
	WHEN content regexp '超凡喜力'      then '超凡喜力'
	WHEN content regexp '壳牌'      then null
	WHEN content regexp '昆仑机油'      then '昆仑'
	WHEN content regexp '昆仑润滑'      then '昆仑'
	WHEN content regexp '昆仑天润'      then '昆仑'
	WHEN content regexp '昆仑之星'      then '昆仑'
	WHEN content regexp '昆仑'      then '昆仑'
	WHEN content regexp '龙蟠1号'      then '龙蟠1号'
	WHEN content regexp '龙蟠机油'      then '龙蟠1号'
	WHEN content regexp '龙蟠1号'      then '龙蟠1号'
	WHEN content regexp '龙蟠机油'      then '龙蟠1号'
	WHEN content regexp '龙蟠润滑油'      then '龙蟠1号'
	WHEN content regexp '龙蟠'      then '龙蟠1号'
	WHEN content regexp '金美'      then '美1'
	WHEN content regexp '银美'      then '美1'
	WHEN content regexp '超金'      then '美1'
	WHEN content regexp 'Mobil'      then '美1'
	WHEN content regexp '力霸'      then '力霸'
	WHEN content regexp '美孚1号'      then '美1'
	WHEN content regexp '速霸'      then '速霸'
	WHEN content regexp '美孚速霸'      then '速霸'
	WHEN content regexp '美1'      then '美1'
	WHEN content regexp '美一'      then '美1'
	WHEN content regexp '美孚'      then '美1'
	WHEN content regexp '统一机油'      then '统一'
	WHEN content regexp '统一润滑油'      then '统一'
	WHEN content regexp '统一润滑'      then '统一'
	WHEN content regexp '统一'      then '统一'
	WHEN content regexp '长城机油'      then '长城'
	WHEN content regexp '长城润滑油'      then '长城'
	WHEN content regexp '长城润滑'      then '长城'
	WHEN content regexp '长城'      then '长城'
	ELSE NULL
	END 
) '''

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

func = ''' case
     WHEN content REGEXP '磨损' then '功能特性'
	 WHEN content REGEXP '粘度' then '功能特性'
	 WHEN content REGEXP '动力' then '功能特性'
	 WHEN content REGEXP '抗磨' then '功能特性'
	 WHEN content REGEXP '冷启动' then '功能特性'
	 WHEN content REGEXP '保护' then '功能特性'
	 WHEN content REGEXP '油膜' then '功能特性'
	 WHEN content REGEXP '长效' then '功能特性'
	 WHEN content REGEXP '积碳' then '功能特性'
	 WHEN content REGEXP '清洁' then '功能特性'
	 WHEN content REGEXP '噪音' then '功能特性'
	 WHEN content REGEXP '抖动' then '功能特性'
	 WHEN content REGEXP '油泥' then '功能特性'
	 WHEN content REGEXP '静音' then '功能特性'
	 ELSE null
 END '''

## 配方
formulation = ''' case
     WHEN content REGEXP '合成'     then '成分与配方'
	 WHEN content REGEXP '半合成'   then '成分与配方'
	 WHEN content REGEXP '添加剂'   then '成分与配方'
	 WHEN content REGEXP '抗磨剂'   then '成分与配方'
	 WHEN content REGEXP '清净'     then '成分与配方'
	 WHEN content REGEXP '分散剂'   then '成分与配方'
	 WHEN content REGEXP '基础油'   then '成分与配方'
	 WHEN content REGEXP '改进剂'   then '成分与配方'
	 WHEN content REGEXP '抗氧化剂' then '成分与配方'
	 ELSE null
 END '''


## 价格性价比
cost = '''case 
	WHEN content REGEXP  '价格'   then '价格性价比'
	WHEN content REGEXP  '成本'   then '价格性价比'
	WHEN content REGEXP  '折扣'   then '价格性价比'
	WHEN content REGEXP  '价位'   then '价格性价比'
	WHEN content REGEXP  '昂贵'   then '价格性价比'
	WHEN content REGEXP  '经济'   then '价格性价比'
	WHEN content REGEXP  '竞争力'   then '价格性价比'
	WHEN content REGEXP  '优惠'   then '价格性价比'
	WHEN content REGEXP  '性价比'   then '价格性价比'
	WHEN content REGEXP  '物超所值'   then '价格性价比'
	WHEN content REGEXP  '便宜'   then '价格性价比'
	WHEN content REGEXP  '实惠'   then '价格性价比'
	WHEN content REGEXP  '打折'   then '价格性价比'
	WHEN content REGEXP  '费用'   then '价格性价比'
	WHEN content REGEXP  '价钱'   then '价格性价比'
	WHEN content REGEXP  '定价'   then '价格性价比'
	WHEN content REGEXP  '奢侈'   then '价格性价比'
	WHEN content REGEXP  '高价'   then '价格性价比'
	WHEN content REGEXP  '廉价'   then '价格性价比'
	 ELSE null
 END '''


ranges = ''' case
			WHEN content REGEXP  '发动机'  then '适用范围'
			WHEN content REGEXP  '涡轮'  then '适用范围'
			WHEN content REGEXP  '直列'  then '适用范围'
			WHEN content REGEXP  '六缸'  then '适用范围'
			WHEN content REGEXP  '增压'  then '适用范围'
			WHEN content REGEXP  '四缸'  then '适用范围'
			WHEN content REGEXP  'V型'  then '适用范围'
			WHEN content REGEXP  '引擎'  then '适用范围'
			ELSE null
		END '''

## 经济性与耐久性
effective = '''
     case
		WHEN content REGEXP '节能'  then '经济性与耐久性'
		WHEN content REGEXP '延长'  then '经济性与耐久性'
		WHEN content REGEXP '摩擦'  then '经济性与耐久性'
		WHEN content REGEXP '输出'  then '经济性与耐久性'
		WHEN content REGEXP '提高'  then '经济性与耐久性'
		WHEN content REGEXP '降耗'  then '经济性与耐久性'
		WHEN content REGEXP '换油'  then '经济性与耐久性'
		WHEN content REGEXP '增加'  then '经济性与耐久性'
		WHEN content REGEXP '稳定'  then '经济性与耐久性'
		WHEN content REGEXP '周期'  then '经济性与耐久性'
		ELSE null
 END '''

## 环保特性
protection = ''' case
		WHEN content REGEXP '挥发性' then '环保特性'
		WHEN content REGEXP '排放' then '环保特性'
		WHEN content REGEXP '再生' then '环保特性'
		WHEN content REGEXP '环保' then '环保特性'
		WHEN content REGEXP '废弃物' then '环保特性'
		ELSE null
 END '''

service = ''' case
		WHEN content REGEXP  '保修' then '售后服务'
		WHEN content REGEXP  '技术支持' then '售后服务'
		WHEN content REGEXP  '咨询' then '售后服务'
		WHEN content REGEXP  '使用建议' then '售后服务'
		WHEN content REGEXP  '问题解决' then '售后服务'
		WHEN content REGEXP  '售后' then '售后服务'
		WHEN content REGEXP  '服务' then '售后服务'
		ELSE null
 END '''

# 创建表格
create_table_query = f'''
CREATE TABLE IF NOT EXISTS meifu_analysis_platform_main_2024_1 AS
  SELECT
        CONCAT(YEAR(publishedMinute), '-Q', QUARTER(publishedMinute)) quarter,
        REGEXP_REPLACE(title, '<[^>]+>', '') title,
        CASE WHEN title REGEXP  '美孚1号车养护' then '美孚1号车养护'  else null end as is_meifu_maintain,
        is_comment,
        webpageUrl,
        SUBSTRING_INDEX(webpageUrl,'?',1) webpageUrl_new,
        captureWebsiteName,
        publishedMinute,
        originType,
        author,
        summary,
        province,
        city,
        originTypeThird,
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
        {func} AS func,
        {formulation} AS formulation,
        {cost} AS cost,
        {ranges} AS ranges,
        {effective} AS effective,
        {protection} AS protection,
        {service} AS service,
        referenceKeyword,
        case when is_comment = '0' then {category0} 
             when is_comment = '1'then {category1} else null end
        AS category,
      case when is_comment = '0' then {scene0} 
             when is_comment = '1' then {scene1} else null end 
        as scene,
        REGEXP_REPLACE(commentContent, '<[^>]+>', '')  commentContent,
        project_name
FROM 24q1_mobil;
'''

start_time = time.time()  # 记录开始时间
cursor.execute(create_table_query)
end_time = time.time()  # 记录结束时间
execution_time = end_time - start_time
print(f"创建表格执行时间：{execution_time}秒")

# 列表中的表名
table_list = ['24q1_castrol','24q1_other','24q1_shell','24_q2_1_mobil','24_q2_3_castrol','24_q2_4_other','24_q2_2_shell']

# 循环插入数据
for table in table_list:
    print(f'插入的表{table},季度是:{table[8]}')


    insert_query = f'''
    INSERT INTO meifu_analysis_platform_main_2024_1 (
        quarter,
        title,
        is_meifu_maintain,
        is_comment,
        webpageUrl,
        webpageUrl_new,
        captureWebsiteName,
        publishedMinute,
        originType,
        author,
        summary,
        province,
        city,
        originTypeThird,
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
        formulation,
        cost,
        ranges,
        effective,
        protection,
        service,
        referenceKeyword,
        category,
        scene,
        commentContent,
        project_name
    )
    SELECT
        CONCAT(YEAR(publishedMinute), '-Q', QUARTER(publishedMinute)) quarter,
        REGEXP_REPLACE(title, '<[^>]+>', '') title,
        CASE WHEN title REGEXP  '美孚1号车养护' then '美孚1号车养护'  else null end as is_meifu_maintain,
        is_comment,
        webpageUrl,
       SUBSTRING_INDEX(webpageUrl,'?',1) webpageUrl_new,
       captureWebsiteName,
        publishedMinute,
        originType,
        author,
        summary,
        province,
        city,
        originTypeThird,
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
        {func} AS func,
        {formulation} AS formulation,
        {cost} AS cost,
        {ranges} AS ranges,
        {effective} AS effective,
        {protection} AS protection,
        {service} AS service,
        referenceKeyword,
        case when is_comment = '0' then {category0} 
             when is_comment = '1'then {category1} else null end
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