# GO富集分析
go <- enrichGO(gene = diff_entrez$ENTREZID, # Entrez ID列表
               OrgDb = org.Hs.eg.db, # 指定物种数据库
               keyType = "ENTREZID", # 指定给定的名称类型
               ont = "ALL", # 可选,BP(生物学过程)/CC(细胞组分)/MF(分子功能)/ALL(同时指定)
               pAdjustMethod = "BH", # P值校正方法,还可以是fdr
               pvalueCutoff = 0.05,qvalueCutoff = 0.2, # p/q值阈值
               readable = T # 将ID转换为symbol
)
go.res <- data.frame(go) # 将GO结果转为数据框，方便后续分析（不转也可以，看个人习惯）
write.csv(go.res,"CD_HC_GO.csv",quote = F) # 输出GO富集分析结果
# 绘制GO富集分析条形图，结果默认按qvalue升序，分别选出前十的term进行绘图即可
goBP <- subset(go.res,subset = (ONTOLOGY == "BP"))[1:10,]
goCC <- subset(go.res,subset = (ONTOLOGY == "CC"))[1:10,]
goMF <- subset(go.res,subset = (ONTOLOGY == "MF"))[1:10,]
go.df <- rbind(goBP,goCC,goMF)
# 使画出的GO term的顺序与输入一致
go.df$Description <- factor(go.df$Description,levels = rev(go.df$Description))
# 绘图
go_bar <- ggplot(data = go.df, # 绘图使用的数据
                 aes(x = Description, y = Count,fill = ONTOLOGY))+ # 横轴坐标及颜色分类填充
  geom_bar(stat = "identity",width = 0.9)+ # 绘制条形图及宽度设置
  coord_flip()+theme_bw()+ # 横纵坐标反转及去除背景色
  scale_x_discrete(labels = function(x) str_wrap(x,width = 50))+ # 设置term名称过长时换行
  labs(x = "GO terms",y = "GeneNumber",title = "CD-HC GO enrichment analysis")+ # 设置坐标轴标题及标题
  theme(axis.title = element_text(size = 13), # 坐标轴标题大小
        axis.text = element_text(size = 9), # 坐标轴标签大小
        plot.title = element_text(size = 14,hjust = 0.5,face = "bold"), # 标题设置
        legend.title = element_text(size = 13), # 图例标题大小
        legend.text = element_text(size = 9), # 图例标签大小
        plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm")) # 图边距
ggsave(go_bar,filename = "CD_HC_GO.pdf",width = 9,height = 10)