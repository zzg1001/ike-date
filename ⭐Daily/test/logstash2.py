from kafka import KafkaProducer
from datetime import datetime, timedelta
import random
import json
import time

# Kafka 配置
bootstrap_servers = '172.16.10.132:9092'
topic = 'sensor_monitor'

# 设备 ID 和名称映射
device_id_name_map = {
    '24e124136e235846': '传感器02-4F机房',
    # '24e124136e235800': '传感器01-1F中控室',
    # '24e124136e231168': '传感器27-206-1F',
    # '24e124136e231226': '传感器29-207-1F',
    # '24e124136e231267': '传感器06-102-6F',
    # '24e124136e231155': '传感器16-107-6F',
    # '24e124136e231288': '传感器17-108-1F',
    # '24e124136e231108': '传感器07-103-1F',
    # '24e124136e231242': '传感器18-108-6F',
     '24e124136e231088': '传感器21-111-1F',
    # '24e124136e231452': '传感器25-201-1F',
    # '24e124136e231137': '传感器30-207-8F',
    # '24e124136e231156': '传感器24-113-6F',
    # '24e124136e231283': '传感器15-107-1F',
    # '24e124136e231461': '传感器26-201-6F',
    # '24e124136e231243': '传感器28-206-8F',
    # '24e124136e231249': '传感器22-111-6F',
    # '24e124136e231212': '传感器19-109-1F',
    # '24e124136e231348': '传感器05-102-1F',
    # '24e124136e231114': '传感器04-101-6F',
    # '24e124136e231277': '传感器11-105-1F',
    # '24e124136e231123': '传感器13-106-1F',
    # '24e124136e231504': '传感器08-103-6F',
    # '24e124136e231139': '传感器12-105-6F',
    # '24e124136e231195': '传感器20-109-6F',
    # '24e124136e231378': '传感器23-113-1F',
    # '24e124136e230525': '传感器14-106-6F',
    # '24e124136e231285': '传感器03-101-1F',
    '24e124136e231096': '传感器31-配电房1',
    '24e124136e231302': '传感器32-配电房2',
    '24e124136e231282': '传感器33-水泵房'
}

# 创建 Kafka 生产者
producer = KafkaProducer(bootstrap_servers=bootstrap_servers,
                        value_serializer=lambda v: json.dumps(v).encode('utf-8'))

# 生成测试数据
start_date = datetime(2024, 6,14)
end_date = datetime(2024, 6, 30)
date_range = [start_date + timedelta(days=x) for x in range((end_date - start_date).days + 1)]

while True:
    for date in date_range:
        for device_id, device_name in device_id_name_map.items():
            data = {
                'id': random.randint(1, 1000000),
                'device_id': device_id,
                'device_name': device_name,
                'datetime': date.strftime('%Y-%m-%d %H:%M:%S'),
                'battery': random.randint(0, 100),
                'co2': random.randint(400, 2000),
                'humidity': round(random.uniform(0, 100), 1),
                'light_level': random.randint(0, 100),
                'pir_trigger': random.randint(0, 1),
                'pm10': random.randint(0, 200),
                'pm2_5': random.randint(0, 100),
                'pressure': round(random.uniform(900, 1100), 1),
                'temperature': 34.6,
                'tvoc': random.randint(0, 500),
                'smoke': round(random.uniform(0, 10), 2),
                'mail_flag': random.randint(0, 1),
                'city_temperature': round(random.uniform(0, 40), 2),
                'city_humidity': round(random.uniform(0, 100), 2),
                'station_temperature': round(random.uniform(0, 40), 2),
                'station_humidity': round(random.uniform(0, 100), 2)
            }
            print(data)

            # 发送数据到 Kafka
            producer.send(topic, value=data)

    # 暂停 1 秒
    time.sleep(1)