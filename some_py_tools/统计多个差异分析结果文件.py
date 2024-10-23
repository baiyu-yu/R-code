import pandas as pd  
from collections import defaultdict 
import os  
  
# 假设csv文件列表如下  
csv_files = ["C:/Users/10042/Desktop/compare/GSE57945/CD-HC_DEGs.select_up.csv", 
             "C:/Users/10042/Desktop/compare/GSE83687/CD-HC_DEGs.select_up.csv", 
             "C:/Users/10042/Desktop/compare/GSE111889/CD-HC_DEGs.select_up.csv", 
             "C:/Users/10042/Desktop/compare/GSE112057/CD-HC_DEGs.select_up.csv", 
             "C:/Users/10042/Desktop/compare/GSE117993/CD-HC_DEGs.select_up.csv",  
             "C:/Users/10042/Desktop/compare/GSE137344/CD-HC_DEGs.select_up.csv", 
             "C:/Users/10042/Desktop/compare/GSE153974/CD-HC_DEGs.select_up.csv", 
             "C:/Users/10042/Desktop/compare/GSE165512/CD-HC_DEGs.select_up_diff_name.csv", 
             "C:/Users/10042/Desktop/compare/GSE179128/CD-HC_DEGs.select_up_diff_name.csv", 
             "C:/Users/10042/Desktop/compare/GSE193677/CD-HC_DEGs.select_up_diff_name.csv"]  
  
# 创建一个defaultdict来存储字符及其出现的次数和文件列表  
char_occurrences = defaultdict(lambda: {'count': 0, 'files': []})  
  
# 遍历CSV文件并收集字符及其出现的次数和文件  
for file in csv_files:  
    df = pd.read_csv(file, usecols=[0])  # 只读取第一列  
    if not df.empty:  
        chars = df.iloc[1:].squeeze().dropna().unique()  # 获取唯一字符列表  
        for char in chars:  
            char_occurrences[char]['count'] += 1  
            # 提取文件路径中"GSE"后面的部分  
            file_part = next((part for part in file.split('/') if 'GSE' in part), '')  
            if file_part:  
                char_occurrences[char]['files'].append(file_part)  
  
# 过滤出那些至少出现两次的字符，并按出现次数从多到少排序  
filtered_chars = sorted([(char, info) for char, info in char_occurrences.items() if info['count'] >= 2], key=lambda x: x[1]['count'], reverse=True)  
  
# 将结果转换为DataFrame格式  
results = [{'Character': char, 'Count': info['count'], 'Files': ', '.join(info['files'])} for char, info in filtered_chars]  
result_df = pd.DataFrame(results)  
  
# 将结果写入新的XLSX文件  
output_file = "C:/Users/10042/Desktop/compare/a.xlsx"  
result_df.to_excel(output_file, index=False)  
  
print(f"字符出现次数及文件列表已写入 {output_file}")