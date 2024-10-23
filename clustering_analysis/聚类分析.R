library(pheatmap)
glyco_data <-read.csv("./p4.csv",header = T,row.names = 1)
t1 = data.frame(
  type = c(rep('ref',9),rep('test',12)),
  row.names = rownames(glyco_data)
)
pheatmap(glyco_data,color = colorRampPalette(c('navy','white','firebrick3'))(50),
         cluster_row = T,
         cluster_cols = F,
         annotation_row = t1)
