x<-1
0
glengths <- c(4.6, 3000, 50000) 
glengths
species <- c("ecoli", "human", "corn") 
species
test<-c(5000,7000,6000)
df<-data.frame(glengths,species)

# Installing tidyvers
install.packages("tidyverse")
# installing DESeq2
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("DESeq2")
# initialize libraries
library(tidyverse)
library(DESeq2)
# Set working directory
setwd("//homes.mtu.edu/home/Desktop/BL5300")

# import data
counts<-read.csv("GSE80323_normalized_gene_tpm.csv")
metadata<-read.csv("RNASeq_metadata.csv")
annotation<-read.csv("Drosophila_geneID_name.csv")

# Set up my DESeq object
dds.data <- DESeqDataSetFromMatrix(countData=counts, 
                                   colData=metadata, 
                                   design=~dex, 
                                   tidy=TRUE)


## Run DESEq
dds <- DESeq(dds.data)

## Export results
res <- results(dds, contrast=c("dex","Normal","Three_times"))

## View
res

# Convert res file to dataframe

res.df<-as.data.frame(res)

## Select columns of interest
res.df2<-res.df%>%
  select(baseMean,log2FoldChange,padj)

## remove rows with NA
res.df2<-na.omit(res.df2) 

## Extract genes that are significantly different in their expression
sigtab<-res.df2%>%
  filter(padj<=0.05 & log2FoldChange>=2 | log2FoldChange<=-2)

## Label dataframe
res.df.labeled<-res.df2%>%
  mutate(significance=ifelse(padj<=0.05 & log2FoldChange>=2, "Normal", 
                             ifelse(padj<=0.05 & log2FoldChange<=-2, "Three-times",
                                    "Non-significant")))

## show median
res.df.labeled%>%
  group_by(significance)%>%
  summarize(median(padj))


res.df.labeled<-rownames_to_column(res.df.labeled)%>%
  inner_join(annotation, by=c("rowname"="GeneID"))

## plot gene counts
plotCounts(dds, gene="CG44625", intgroup="dex",returnData=TRUE)%>%
  ggplot(aes(x=dex,y=count))+
  geom_boxplot(aes(fill=dex))+
  scale_y_log10()

#Plot PCA

## Normalize data by log transforming the data
rld=rlog(dds)

## Plot PCA
plotPCA(rld, intgroup = "dex")


## Make MA plot
ggplot(res.df.labeled)+
  geom_point(aes(x=baseMean, y=log2FoldChange,color=significance))

## Make a volcano plot
ggplot(res.df.labeled)+
  geom_point(aes(x=log2FoldChange, y=-log(padj),color=significance))





