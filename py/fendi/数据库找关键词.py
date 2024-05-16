import os
import re

# ANSI转义序列，用于修改文本颜色为红色和重置颜色
RED_COLOR = '\033[91m'
RESET_COLOR = '\033[0m'

def search_keyword_in_files(directory, keyword):
    result = []
    total_count = 0

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dat'):
                file_path = os.path.join(root, file)
                print(f"正在搜索文件：{file_path}")
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    counter = 1  # 行号计数器
                    count = 0  # 匹配行计数器
                    for line in f:
                        # 使用正则表达式进行不区分大小写的搜索
                        match = re.search(re.escape(keyword), line, re.IGNORECASE)
                        if match:
                            count += 1
                            # 将匹配到的关键词修改为红色
                            matched_line = line[:match.start()] + RED_COLOR + line[match.start():match.end()] + RESET_COLOR + line[match.end():]
                            result.append((file_path, matched_line.rstrip('\n')))
                    total_count += count

    return result, total_count

# 指定目录和关键词
directory = r'/Users/zhangzuogong/Desktop/test/原数据'
keyword = '|4768|'
# 指定结果文件路径
result_file_path = r'/Users/zhangzuogong/Desktop/test/rs.txt'

# 在目录中搜索关键词（不区分大小写）
search_results, total_results = search_keyword_in_files(directory, keyword)

if search_results:
    print(f'关键词 "{keyword}" 在以下文件中找到了 {total_results} 条匹配项：')
    with open(result_file_path, 'w', encoding='utf-8') as result_file:
        result_file.write(f'关键词 "{keyword}" 在以下文件中找到了 {total_results} 条匹配项：\n')
        for file_path, matched_line in search_results:
            result_file.write(f'文件：{file_path}\n')
            result_file.write(f'匹配行：{matched_line}\n\n')
            print(f'文件：{file_path}')
            print(f'匹配行：{matched_line}\n')
else:
    print(f'关键词 "{keyword}" 在指定目录下的 dat 文件中未找到。')
    with open(result_file_path, 'w', encoding='utf-8') as result_file:
        result_file.write(f'关键词 "{keyword}" 在指定目录下的 dat 文件中未找到。\n')

print(f'搜索结果已保存到文件：{result_file_path}')