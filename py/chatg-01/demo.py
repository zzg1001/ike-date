import os
import requests
import base64
import pymysql
import json


# Configuration
API_KEY = "4ca4e46700614918858ea9bc2068e273"
# IMAGE_PATH = "YOUR_IMAGE_PATH"
# encoded_image = base64.b64encode(open(IMAGE_PATH, 'rb').read()).decode('ascii')
headers = {
    "Content-Type": "application/json",
    "api-key": API_KEY,
}

host = '139.224.197.121'
port = 63306
user = 'weizhengbo'
password = 'Password.1'
database = 'shuiwu_analysis'

connection = pymysql.connect(
    host=host,
    port=port,
    user=user,
    password=password,
    db=database,
    charset='utf8mb4',
    cursorclass=pymysql.cursors.DictCursor
)


# Payload for the request
keywords =  f""" 机器人, 无人机, 水泵, 泵车, 移动泵站, 围板, 挡水板, 防汛打桩, 
    冲锋舟, 橡皮艇, 抛投器, 膨胀袋, 智能防汛设备, 智能搜救设备, 
    报警器, 应急通信, 物资投送,逃生, 清洁, 药具, 
    食物, 漂浮物, 求救物, 沙袋, 抛石, 
    堵漏, 保温 """


def send(id,msg):
    payload = {
    "messages": [
        {
        "role": "system",
        "content": [
            {
            "type": "text",
            "text": "我是数据分析师，给数据打标签"
            }
        ]
        },
        {
        "role": "user",
        "content": [
            {
            "type": "text",
            "text": msg
            }
        ]
        }
        
    ],
    "temperature": 0,
    "top_p": 0.95,
    "max_tokens": 800
    }

    ENDPOINT = "https://ai-zuogongzhangai6573653805773011.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-15-preview"

    # Send request
    try:
        response = requests.post(ENDPOINT, headers=headers, json=payload)
        response.raise_for_status()  # Will raise an HTTPError if the HTTP request returned an unsuccessful status code
    except requests.RequestException as e:
        raise SystemExit(f"Failed to make the request. Error: {e}")

    # Handle the response as needed (e.g., print or process)
    rs_cursor = connection.cursor()
    
    data = response.json()
    print(data)
    flag = data['choices'][0]['message']['content']
    print(flag)
    insert_sql ="insert into shuiwu_analysis.example_flag_data (id,flag) VALUES (%s, %s)"
    rs_cursor.execute(insert_sql,(id,flag))
    connection.commit()


try:
    with connection.cursor() as cursor:
        # 执行SQL查询
        sql = "        select id,CONCAT(COALESCE(title,''),COALESCE(summary,'')) summary   FROM shuiwu_analysis.example_data_1 "  # 请替换为你的表名称
        cursor.execute(sql)
        
        # 获取所有结果
        results = cursor.fetchall()
        
        # 遍历结果
        for row in results:
            id = row['id']
            content=row['summary']
            print("content->"+content)
            msg = "给定的文本内容打标签，标签的范围是防汛设备，防汛物质，防汛工具，标签返回值用一下关键词表示:"+keywords+",或者与关键词相近的词，并且请给出相关的标签并解释相关的原因,如果没有相关的内容就返回null(就null没有其他的)不需要解释。下面是文本内容:"+content
            send(id,msg)

finally:
    # 关闭数据库连接
    connection.close()

