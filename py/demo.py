from datetime import datetime, timedelta

def get_date_range(start_date, end_date):
    """
    根据给定的起始日期和结束日期,生成该时间段内的每一天日期。
    
    参数:
    start_date (str) - 起始日期, 格式为 "YYYY-MM-DD"
    end_date (str) - 结束日期, 格式为 "YYYY-MM-DD"
    
    返回:
    list - 包含时间段内每一天日期的列表,格式为 "YYYY-MM-DD"
    """
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")
    
    date_range = [start + timedelta(days=x) for x in range((end - start).days + 1)]
    return [date.strftime("%Y-%m-%d") for date in date_range]

# 示例使用
start_date = "2024-01-01"
end_date = "2024-01-03"
dates = get_date_range(start_date, end_date)

for date in dates:
    print(date)