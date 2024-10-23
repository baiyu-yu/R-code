#kegg,但是是deseq2,但是CD
# 加载必要的R包
library(clusterProfiler)
library(org.Hs.eg.db)# 人类注释数据库，根据你的物种更换
library(stringr)
library(ggplot2)
library(enrichplot)

# 读取差异表达分析结果
diff_results <- read.csv("CD-HC_DESeq2results.csv", header = TRUE, stringsAsFactors = FALSE)
colnames(diff_results)[1] <- "GeneID"

# 筛选显著差异表达的基因
significant_genes <- diff_results$GeneID[
  (diff_results$pvalue < 0.05) & 
    ((diff_results$log2FoldChange > 1) | (diff_results$log2FoldChange < -1))
]

# 进行KEGG富集分析
diff_entrez <- bitr(significant_genes,
                    fromType = "SYMBOL",#现有的ID类型
                    toType = "ENTREZID",#需转换的ID类型
                    OrgDb = "org.Hs.eg.db")

kegg_res <- enrichKEGG(gene = diff_entrez$ENTREZID, 
                       keyType = 'kegg',
                       organism = "hsa", # 根据你的物种更换
                       pvalueCutoff = 0.05, 
                       qvalueCutoff = 0.25)

KEGG_diff <- setReadable(kegg_res,
                         OrgDb = "org.Hs.eg.db",
                         keyType = "ENTREZID")
write.csv(KEGG_diff,file = "CD_HC_KEGG.csv")
# 筛选并可视化
min_gene_count <- 10
kegg_filtered <- KEGG_diff[KEGG_diff$Count >= min_gene_count, ]

#可视化另一种
colnames(kegg_filtered)
p = ggplot(kegg_filtered)+
  geom_col(aes(x=Count,y=reorder(Description,Count),fill=pvalue),color='black',width = 0.6)+
  geom_text(aes(x=Count,y=reorder(Description,Count),label =Count),hjust=-0.5,vjust =0.5)+#添加Count值标注
  scale_fill_gradientn(colours = c('firebrick','steelblue'))+#设置颜色   #'firebrick','lightblue'
  theme_minimal()+
  scale_y_discrete(expand = c(0,0))+
  geom_vline(xintercept = 0,lwd=0.1,color="black")+
  theme(legend.position = 'right')+#设置图例位置
  labs(x = "Count",y = NULL,title = "CD-HC KEGG enrichment analysis")+
  theme(axis.text.x = element_text(angle = 0,hjust = 1,vjust =0.5,size = 8,face = 'bold',family = 'serif'),
        axis.text.y = element_text(angle = 0,size = 10,face = 'plain',family = 'serif'))
ggsave(p,filename = "CD_HC_KEGG.pdf",width = 10,height = 9)
