import pandas as pd
from collections import defaultdict
import os
import re

# CSV文件路径列表，这里应替换为实际路径
csv_paths = [
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE57945/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE83687/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE111889/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE111889/KEGG/colon_CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE111889/KEGG/intestinal_CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE111889/KEGG/rectum_CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE112057/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE117993/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE117993/KEGG/colonic_CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE117993/KEGG/ileal_CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE137344/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE153974/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE165512/KEGG/colon_CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE179128/KEGG/CD_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE179128/KEGG/CDa_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE179128/KEGG/CDu_HC_KEGG.csv",
    "C:/Users/10042/Desktop/富集分析/富集分析 取前500/GSE193677/KEGG/CD_HC_KEGG.csv"
    # 添加更多路径...
]\

# 用于存储描述及出现信息的字典
description_counts = defaultdict(lambda: {'count': 0, 'ranks': [], 'paths': []})

# 遍历每个CSV文件路径
for idx, csv_path in enumerate(csv_paths, start=1):
    # 读取CSV文件
    df = pd.read_csv(csv_path)
    
    # 按'Count'列降序排序，并添加排名（考虑可能有相同的Count值）
    df['Rank'] = df['Count'].rank(method='min', ascending=False)
    
    # 遍历处理每个Description
    for desc, rank in zip(df['Description'], df['Rank']):
        description_counts[desc]['count'] += 1
        description_counts[desc]['ranks'].append(rank)
        # 提取从GSE开始到CSV结尾的部分作为路径标识
        match = re.search(r'GSE.*?\.csv', csv_path)
        if match:
            path_id = match.group()
        else:
            path_id = os.path.basename(csv_path)
        description_counts[desc]['paths'].append(path_id + f'_Rank{rank:.0f}')
        
# 筛选出重复出现的项目（即出现次数大于1的项目）
duplicate_descriptions = {k: v for k, v in description_counts.items() if v['count'] > 1}

# 将结果写入新的CSV文件
output_df = pd.DataFrame([(desc, info['count'], ', '.join(info['paths'])) 
                          for desc, info in duplicate_descriptions.items()],
                         columns=['Description', 'Appearance_Count', 'File_Rank_Details'])

output_path = 'C:/Users/10042/Desktop/测试富集/duplicates.csv'  # 输出文件路径，请自行设置
output_df.to_csv(output_path, index=False)

print(f"重复描述统计完成，结果已保存至：{output_path}")