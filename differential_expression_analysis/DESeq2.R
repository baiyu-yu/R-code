library(DESeq2)
library(ggplot2)
library(ggrepel)

setwd("")

countData <- as.matrix(read.csv("GSE222070_Normdata_CD-HC.csv"))
row.names(countData) <- countData[, 1]
countData <- countData[, -1]
class(countData) <- "numeric"
#似乎是基因名有重复的状态下上面这种可以解决，没有注释这种最好
#countData <- as.matrix(read.csv("HC_AM_NT.csv",row.names="Gene_id"))

countData <- countData[rowMeans(countData)>1,]
#去除表达量低的基因，row平均值为0的基因

condition <- factor(c(rep("treatment",16),rep("control",10)))
colData <- data.frame(row.names=colnames(countData), condition)

dds <- DESeqDataSetFromMatrix(countData = countData, colData = colData, design = ~ condition)

# 1.构建 DESeqDataSet 对象
dds1 <- DESeq(dds, fitType = 'mean', minReplicatesForReplace = 7, parallel = FALSE)

# 2.用result()函数来获取结果
# 注意，需将 treatment 在前，control 在后，意为 treatment 相较于 control 中哪些基因上调/下调
res <- results(dds1, contrast = c('condition', 'IBD', 'HC'))
res = res[order(res$pvalue),]    #利用order 函数先对数值进行排序，然后返回排序后各数值的索引
summary(res)

res1 <- data.frame(res, stringsAsFactors = FALSE, check.names = FALSE)
write.csv(res1,file = "AM_NT-HC_DESeq2results.csv")

table(res$padj<0.05)

#主成分分析 PCA（Principal Components Analysis）
# 样本量少于30，选择rlog；多于30，建议vst
rld <- rlog(dds)  # DESeq2分析构建的dds矩阵
plotPCA(rld,intgroup="condition")

vsd <- vst(dds)  # DESeq2分析构建的dds矩阵
plotPCA(vsd,intgroup="condition")

#筛选显著差异表达，padj有0.05/0.01两种常用阈值，log2FC好像怪怪的
res1[which(res1$log2FoldChange >= 1 & res1$padj < 0.05),'sig'] <- 'up'
res1[which(res1$log2FoldChange <= -1 & res1$padj < 0.05),'sig'] <- 'down'
res1[which(abs(res1$log2FoldChange) <= 1 | res1$padj >= 0.05),'sig'] <- 'none'

#输出选择的差异基因总表
res1_select <- subset(res1, sig %in% c('up', 'down'))
write.csv(res1_select, file = "AM_NT-HC_DEGs.select_0.05.csv")

#根据 up 和 down 分开输出
res1_up <- subset(res1, sig == 'up')
res1_down <- subset(res1, sig == 'down')

write.csv(res1_up, file = "AM_NT-HC_DEGs.select_up.csv")
write.csv(res1_down, file = "AM_NT-HC_DEGs.select_down.csv")

#显著差异表达火山图绘制
data <- read.csv("AM_NT-HC_DESeq2results.csv") 

#先根据阈值分出上调和下调基因:(pvalue=0.01)
data$change <- as.factor(ifelse(data$pvalue< 0.01 & abs(data$log2FoldChange) > 1,
                                ifelse(data$log2FoldChange > 1,'UP','DOWN'),'NONE'))
#标示差异显著的基因
data$sign <- ifelse(data$pvalue < 0.001 & abs(data$log2FoldChange) > 3,data$gene,NA)