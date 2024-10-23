library("limma") 
library("edgeR")

design_colon_CD_HC <- model.matrix(~0+condition)
rownames(design_colon_CD_HC) = colnames(colon_CD_HC)
colnames(design_colon_CD_HC) <- levels(condition)
DGElist <- DGEList( counts = colon_CD_HC, group = condition)
DGEList_colon_CD_HC = DGEList

#标准化，大概，算个什么cpm
keep_gene_colon_CD_HC <- rowSums( cpm(DGElist) > 1 ) >= 2
table(keep_gene_colon_CD_HC)

#算那些数值
DGElist <- DGElist[ keep_gene_colon_CD_HC, , keep.lib.sizes = FALSE ]
DGElist <- calcNormFactors( DGElist )
DGElist <- estimateGLMCommonDisp(DGElist, design_colon_CD_HC)
DGElist <- estimateGLMTrendedDisp(DGElist, design_colon_CD_HC)
DGElist <- estimateGLMTagwiseDisp(DGElist, design_colon_CD_HC)
fit_colon_CD_HC <- glmFit(DGElist, design_colon_CD_HC)
results_colon_CD_HC <- glmLRT(fit_colon_CD_HC, contrast = c(-1, 1))
nrDEG_edgeR_colon_CD_HC <- topTags(results_colon_CD_HC, n = nrow(DGElist))
nrDEG_edgeR_colon_CD_HC <- as.data.frame(nrDEG_edgeR_colon_CD_HC)
write.csv(nrDEG_edgeR_colon_CD_HC, file = "colon_CD_HC_DEGs.csv")

#看上调下调，但是这个是对所有up，down输出，不上标记
padj = 0.05 # 自定义
foldChange= 1 # 自定义
nrDEG_edgeR_signif_colon_CD_HC = nrDEG_edgeR_colon_CD_HC[(nrDEG_edgeR_colon_CD_HC$FDR < padj & (nrDEG_edgeR_colon_CD_HC$logFC>foldChange | nrDEG_edgeR_colon_CD_HC$logFC<(-foldChange))),]
nrDEG_edgeR_signif_colon_CD_HC = nrDEG_edgeR_signif_colon_CD_HC[order(nrDEG_edgeR_signif_colon_CD_HC$logFC),]
write.csv(nrDEG_edgeR_signif_colon_CD_HC, file = "nrDEG_edgeR_signif_colon_CD_HC.csv")
#上个标记，但是没有order，可以手动order
k1_colon_CD_HC = (nrDEG_edgeR_signif_colon_CD_HC$PValue < 0.05)&(nrDEG_edgeR_signif_colon_CD_HC$logFC < -1)
k2_colon_CD_HC = (nrDEG_edgeR_signif_colon_CD_HC$PValue < 0.05)&(nrDEG_edgeR_signif_colon_CD_HC$logFC > 1)
nrDEG_edgeR_signif_colon_CD_HC$change = ifelse(k1_colon_CD_HC,"down",ifelse(k2_colon_CD_HC,"up","not"))
write.csv(nrDEG_edgeR_signif_colon_CD_HC, file = "nrDEG_edgeR_signif_colon_CD_HC.csv")