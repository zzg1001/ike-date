from kafka import KafkaProducer
from datetime import datetime, timedelta
import random
import json
import time

# Kafka 配置
bootstrap_servers = '172.16.10.132:9092'
topic = 'sensor_monitor'



# 创建 Kafka 生产者
producer = KafkaProducer(bootstrap_servers=bootstrap_servers,
                        value_serializer=lambda v: json.dumps(v).encode('utf-8'))

# 生成测试数据




    # 发送数据到 Kafka
producer.send(topic, value=data)

    # 暂停 1 秒
time.sleep(1)