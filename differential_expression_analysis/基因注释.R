library('biomaRt')

mart <- useDataset("hsapiens_gene_ensembl", useMart("ensembl"))

my_ensembl_gene_id<-row.names(res)

hg_symbols<- getBM(attributes=c('ensembl_gene_id','external_gene_name',"description"),filters = 'ensembl_gene_id', values = my_ensembl_gene_id, mart = mart)

ensembl_gene_id<-rownames(res)

diff_gene_deseq2<-cbind(ensembl_gene_id,res)

colnames(diff_gene_deseq2)[1]<-c("ensembl_gene_id")

diff_name<-merge(diff_gene_deseq2,hg_symbols,by="ensembl_gene_id")

head(diff_name)

diff_name = diff_name[order(diff_name$pvalue),]

write.csv(diff_name,file = "CDu-HC_DESeq2results_diff_name.csv")