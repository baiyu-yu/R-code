#下载下来是个什么raw_data.rar，解压之后是什么什么R.txt.gz，再打开之后里面只有两条（也有可能是多条，反正是只有一个实验对象的）
dir <- "C:/Users/10042/Desktop/bbb/GSE117993_RAW/"
files <- list.files(path = dir, pattern = "*.txt.gz", recursive = T)
#不一样的地方用*代替，如果有目标文件名可以用这种筛选，到时候再试试吧
expr <- lapply(files, function(x){ expr <- read.table(file = file.path(dir,x), sep = "\t", header = T, stringsAsFactors = F)[,c(2)] return(expr) })#这个序列索引和py里不一样他不是从0开始的，诡异
expr_list <- lapply(files, function(x) {  
  data <- read.table(file = file.path(dir, x), sep = "\t", header = TRUE, stringsAsFactors = FALSE)  
  return(data[, 3])  
})
#在实际运行时上面那块不知道为什么会报错，但是这个不知道为什么又可以，我是真的搞不懂了，上面那个明明经过实验了的

df <- do.call(cbind, expr)
genename <- read.table(file = file.path("GSM3316656_01-070-R.txt.gz"), sep = "\t", header = T, stringsAsFactors = F)[,c(1)]#这个地方文件那里，要是它硬是要说没有就加绝对路径，诡异
rownames(df) <- genename
column_names <- group_data$geo_accession
column_names <- as.character(column_names)
colnames(df) <- column_names
#整个行名和列名，到时候自己找东西整吧

#其实还有一种下下来说是cel什么什么文件的，那个似乎是下面这种处理方法：（没测试过）
library(affy)
dir_cels='D:\\test_analysis\\TNBC\\cel_files'
affy_data = ReadAffy(celfile.path=dir_cels)
eset.mas5 = mas5(affy_data)