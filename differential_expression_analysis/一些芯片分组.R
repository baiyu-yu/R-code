#我当时在干什么啊，现在有点看不明白了，先存着
library(GEOquery)
gse_id <- "GSE165512"
gse_info <- getGEO(gse_id, destdir = ".", AnnotGPL = FALSE ,getGPL = F)
pdata = gse_info$GSE165512_series_matrix.txt.gz@phenoData@data
group_data = pdata[,c('title','characteristics_ch1','source_name_ch1')]
（选取有分组信息的列出来造一个数据框）

group_data$group_easy <- ifelse(grepl("colon", group_data$characteristics_ch1), "colon", "ileum")
（这个是正则匹配，如果不是正则用下面这一串）
【
library(stringr)

# 确保'characteristics_ch1'列是字符型 
group_data$characteristics_ch1 <- as.character(group_data$characteristics_ch1)
# 使用str_detect检查每个元素是否包含"CD"或"UC"
group_data$group_more <- ifelse(str_detect(group_data$source_name_ch1, "CD"), "CD",  ifelse(str_detect(group_data$source_name_ch1, "UC"), "UC", "healthy"))
】

setwd("C:\\Users\\10042\\Desktop\\aaa")
unique_data <- read.csv("GSE165512_raw_data.csv", row.names = 1)

#对两个处理方法第一步分组
groups_1 <- c("colon")
title_1 <- unique(group_data$title[group_data$group_easy %in% groups_1])
colon <- unique_data[, title_1, drop = FALSE] 

groups_2 <- c("ileum") 
title_2 <- unique(group_data$title[group_data$group_easy %in% groups_2])
ileum <- unique_data[, title_2]

#第二步分组，选取需要对比的两组
groups_to_compare <- c("CD", "healthy") 
title_CD_HC <- unique(group_data$title[group_data$group_more %in% groups_to_compare])
#选个交集，在第一个分组的基础上进行第二次分组
existing_columns <- title_CD_HC[title_CD_HC %in% names(colon)]
colon_CD_HC <- colon[, existing_columns, drop = FALSE]
existing_columns_1 <- title_CD_HC[title_CD_HC %in% names(ileum)]
ileum_CD_HC <- ileum[, existing_columns_1, drop = FALSE]

countData <- as.matrix(colon_CD_HC)
countData <- countData[rowMeans(countData)>1,] 

#选出前面选出的那个表格用来做分组框
selected_columns <- group_data[, c(1, 3)]
filtered_data <- subset(selected_columns, source_name_ch1 %in% c("colon_CD", "colon_healthy"))
filtered_data$source_name_ch1 <- factor(filtered_data$source_name_ch1)
colData <- data.frame(row.names = colnames(countData), source_name_ch1 = filtered_data$source_name_ch1)
condition <- filtered_data$condition
condition <- factor(colData$condition)#反正就类似前面拿向量叠分组一样需要一个分组的因子

#毕竟前面那种方法出来的不一定按顺序，不知道能不能正确处理，反正这样就可以把每个组单独提出来然后在依据需要综合
colon_CD_a <- subset(colData, condition %in% c("colon_CD"))
colon_healthy_a <- subset(colData, condition %in% c("colon_healthy"))
groups_3 <- c("colon_CD")
title_3 <- unique(group_data$title[group_data$source_name_ch1 %in% groups_3])
colon_CD_b <- unique_data[, title_3, drop = FALSE]
groups_4 <- c("colon_healthy")
title_4 <- unique(group_data$title[group_data$source_name_ch1 %in% groups_4])
colon_healthy_b <- unique_data[, title_4, drop = FALSE]
colon_CD_HC <- cbind(colon_CD_b,colon_healthy_b)
condition <- factor(c(rep("colon_CD",40),rep("colon_healthy",35)))



【columns_to_keep <- setdiff(names(group_data), "group_a")  
group_data <- group_data[, columns_to_keep]（这个是数据框删除指定列）】

【# 读取数据，忽略第一列作为行名
2raw_data <- read.csv("GSE165512_raw_data.csv", header = TRUE)
3
4# 检查并处理重复的行名（第一列）
5rownames_to_keep <- sapply(split(raw_data[, 1], raw_data[, 1]), function(x) {
6  avg_expr <- rowMeans(raw_data[x, -1])  # 计算每组内重复行的平均表达量
7  max_avg_idx <- which.max(avg_expr)  # 找到平均表达量最大的行索引
8  x[max_avg_idx]  # 返回该行索引对应的行名
9})
10
11# 保留平均值最大的行
12unique_data <- raw_data[rownames_to_keep, ]
13
14# 更新行名
15rownames(unique_data) <- unique_data[, 1]
16unique_data <- unique_data[, -1]  # 移除第一列（原行名列）
17
18# 现在您可以使用 unique_data 进行后续分析
】（把每出现重复的行中选取平均值最大的保留剩下的删除，未测试可行性）
expr = avereps(expr[,-1],ID = expr$X)

【# 假设 raw_data 是一个数据框，且您想基于第一列（索引为 1）的唯一值来筛选行
unique_rows <- !duplicated(raw_data[, 1])
# 使用逻辑索引提取具有唯一值的行
unique_data <- raw_data[unique_rows, ]
# 将 unique_data 的第一列设为行名
rownames(unique_data) <- unique_data[, 1]
# 删除已用作行名的第一列
unique_data <- unique_data[, -1]
】（直接删除有重复的，合理性不足）

# 读取CSV文件
2df <- read.csv("your_file.csv")
3
4# 选择第一列（这里假设列名为 "column_name"）
5first_column <- df[, "column_name"]
6
7# 找出重复字符
8duplicates <- duplicated(first_column)
9
10# 提取出重复字符
11repeated_chars <- first_column[duplicates]
12
13# 显示重复字符
14repeated_chars
（看看重复的）