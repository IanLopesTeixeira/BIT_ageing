setwd("d:/Thesis/final")


#DSB Characterization#####
library("ggplot2")
library("dplyr")


dsb_info_mcf7_file <- "MCF7/DSB_MCF7_single_characteristics.txt"
ncol_file <- max(count.fields(dsb_info_mcf7_file, sep="\t"))
dsb_info_mcf7 <- as.data.frame(read.table(dsb_info_mcf7_file, header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info_mcf7 <- as.data.frame(t(dsb_info_mcf7))
dsb_info_mcf7$Distances <- as.numeric(dsb_info_mcf7$Distances)

dsb_info_mcf7_graph <- data.frame(
  group=c("1", "2-10",">10"),
  number=c(length(dsb_info_mcf7[dsb_info_mcf7$Distances==1,1]),
           length(dsb_info_mcf7[dsb_info_mcf7$Distances <= 10 & dsb_info_mcf7$Distances > 1,1]),
           length(dsb_info_mcf7[dsb_info_mcf7$Distances > 10,1])))

dsb_info_mcf7_graph <- within(dsb_info_mcf7_graph, group <- factor(group, levels=c("1", "2-10", ">10")))
dsb_info_mcf7_graph <- dsb_info_mcf7_graph %>% 
  mutate(percentage = number/sum(number))


ggplot(dsb_info_mcf7_graph, aes(x=group, y=number)) +
  geom_bar(stat="identity",fill="#105d97",color="#e9ecef", width=0.6) +
  labs(x="DSB size", y="Number of DSB", title="Distribution of MCF7 DSB size (BLISS)") +
  geom_text(aes(label=paste0(round(number/sum(number)*100,2), "%")), vjust=-0.5, size=3.5)+
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  annotate("text", x=3, y=3.5*10^5, label=paste0("Avrg: ", round(mean(dsb_info_mcf7$Distances),2)), size=3.5) +
  annotate("text", x=3, y=3.3*10^5, label=paste0("Median: ", round(median(dsb_info_mcf7$Distances),2)), size=3.5)



#DSB Characterization_DSBome#####
library("ggplot2")
library("dplyr")

dsb_files <- list.files(path="DSBome/", pattern="characteristics")

#GM06990
ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[1]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[1]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("A", length(dsb_info$Distances))
ggplot(dsb_trim,aes(x=Name, y=Distances)) +
  geom_boxplot() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  labs(x="Samples", y="DSB size", title="Distribution of GM08990 DSB size (Break-seq)") +
  coord_cartesian(ylim=c(0,2500))


#NHEK
ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[2]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[2]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("A", length(dsb_info$Distances))
ggplot(dsb_trim,aes(x=Name, y=Distances)) +
  geom_boxplot() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  labs(x="Samples", y="DSB size", title="Distribution of NHEK DSB size (DSBcapture)") +
  coord_cartesian(ylim=c(0,2000))

#MCF7
ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[3]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[3]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("A", length(dsb_info$Distances))
final_dsb_trim <- as.data.frame(dsb_trim)

ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[4]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[4]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("B", length(dsb_info$Distances))
final_dsb_trim <- rbind(final_dsb_trim,dsb_trim)

ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[5]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[5]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("C", length(dsb_info$Distances))
final_dsb_trim <- rbind(final_dsb_trim,dsb_trim)

ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[6]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[6]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("D", length(dsb_info$Distances))
final_dsb_trim <- rbind(final_dsb_trim,dsb_trim)

ggplot(final_dsb_trim,aes(x=Name, y=Distances)) +
  geom_boxplot() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  labs(x="Samples", y="DSB size", title="Distribution of MCF7 DSB size (Break-seq)") +
  coord_cartesian(ylim=c(0,2000))

#MCF10A
ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[7]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[7]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("A", length(dsb_info$Distances))
final_dsb_trim <- as.data.frame(dsb_trim)

ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[8]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[8]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("B", length(dsb_info$Distances))
final_dsb_trim <- rbind(final_dsb_trim,dsb_trim)

ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[9]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[9]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("C", length(dsb_info$Distances))
final_dsb_trim <- rbind(final_dsb_trim,dsb_trim)

ncol_file <- max(count.fields(paste0("DSBome/",dsb_files[10]), sep="\t"))
dsb_info <- as.data.frame(read.table(paste0("DSBome/",dsb_files[10]), header = F, sep = "\t",stringsAsFactors = F, quote = "", fill = T, row.names = 1))
dsb_info <- as.data.frame(t(dsb_info))
dsb_trim <- as.data.frame(as.numeric(dsb_info$Distances))
colnames(dsb_trim) <- "Distances"
dsb_trim$Name <- rep("D", length(dsb_info$Distances))
final_dsb_trim <- rbind(final_dsb_trim,dsb_trim)

ggplot(final_dsb_trim,aes(x=Name, y=Distances)) +
  geom_boxplot() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  labs(x="Samples", y="DSB size", title="Distribution of MCF10A DSB size (Break-seq)") +
  coord_cartesian(ylim=c(0,2000))

#DSBome_distribution####

dsbome_counter <- as.data.frame(read.table("DSBome/DSBome_files/common_dsb.dsbome.counter.bed", header = F, sep = " ",stringsAsFactors = F, quote = ""))
dsbome <- as.data.frame(read.table("DSBome/DSBome_files/common_dsb.dsbome.bed", header=F, sep = "\t",stringsAsFactors = F, quote = ""))
df_dsbome_contribution <- data_frame(Cell=c("MCF10A", "NHEK", "GM08990", "MCF7"), Contribution=dsbome_w_names$V2)
df_dsbome_contribution <- df_dsbome_contribution %>%
  mutate(Percentage=round(Contribution*100/length(dsbome$V1),2))

ggplot(df_dsbome_contribution, aes(x=Cell,y=Percentage)) +
  geom_bar(stat = "identity", fill="#105d97",color="#e9ecef", width=0.6) +
  labs(title="Contribution of each Cell Line for the DSBome") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  geom_text(aes(label=paste0(Percentage, "%")), position = position_dodge(width = 1), hjust= 0.43, vjust=-0.5, size=3.5) +
  coord_cartesian(ylim = c(0, 100))


#Canonical 1st exons####

library("rtracklayer")
library("dplyr")

gencode <- as.data.frame(import("genomes/gencode.v42.annotation.gtf"))
gencode_transcript_canonical <- gencode[ gencode$type == "transcript" & gencode$tag == "Ensembl_canonical",]
gencode_transcript_canonical <- filter(gencode_transcript_canonical, rowSums(is.na(gencode_transcript_canonical)) != ncol(gencode_transcript_canonical))

gencode_transcript_canonical_1st_exon <- gencode[1,]
gencode_transcript_canonical_1st_exon <- gencode_transcript_canonical_1st_exon[-1,]

for (ix in gencode_transcript_canonical$transcript_id) {
  poss <- gencode[!is.na(gencode$transcript_id) & gencode$transcript_id == ix,]
  transcript <- poss[poss$type == "transcript",]
  exons <- poss[poss$type == "exon",]
  if (length(exons$strand) > 1) {
    if (exons$strand[1] == "+") {
      f_exon <- exons[ exons$exon_number == 1,]
      transcript$end <- f_exon$end
      gencode_transcript_canonical_1st_exon <- rbind(gencode_transcript_canonical_1st_exon, transcript)
    } else {
      f_exon_n <- max(exons$exon_number)
      f_exon <- exons[ exons$exon_number == f_exon_n, ]
      transcript$start <- f_exon$start
      gencode_transcript_canonical_1st_exon <- rbind(gencode_transcript_canonical_1st_exon, transcript)
    }
  } else {
    gencode_transcript_canonical_1st_exon <- rbind(gencode_transcript_canonical_1st_exon,transcript)
  }
}

export(gencode_transcript_canonical_1st_exon, "genomes/gencode.v42.annotation.trans_canonical_only_1exon.gtf", format = "gtf")
#TATA box Selection####

library("rtracklayer")


oreganno <- as.data.frame(import("hg38.oreganno.gtf"))

oreganno_attr <- read.delim("hg38.oreganno_attr.tsv", sep ="\t")

oreganno_attr_tfbs <- oreganno_attr[ oreganno_attr$attribute=="TFbs",]
oreganno_attr_tfbs_tpb <- oreganno_attr_tfbs[ oreganno_attr_tfbs$attrVal=="TBP",]

final_oreganno <- oreganno[oreganno$gene_id %in% oreganno_attr_tfbs_tpb$X.id, ]

oreganno_attr_tfbs_tata <- oreganno_attr_tfbs[ grepl("TATA", oreganno_attr_tfbs$attrVal),]
final_tata <- oreganno[oreganno$gene_id %in% oreganno_attr_tfbs_tata$X.id, ]
final_oreganno <- rbind(final_oreganno, final_tata)
export(final_oreganno, "hg38.oreganno_tata.bed", format = "bed")

#DESeq analysis
library("DESeq2")
library("GEOquery")
library("ggplot2")

countData <- as.matrix(read.csv("fibroblast_ageing/merged_info/transcript_count_matrix.csv", row.names="transcript_id"))

gse <- getGEO(filename="fibroblast_ageing/GSE113957_family.soft.gz")
pheno_total <- c()
pos <- c()
age_l <- c()

for (ix in seq(length(names(GSMList(gse))))) {
  file <- Meta(GSMList(gse)[[ix]])$geo_accession
  age <- strsplit(Meta(GSMList(gse)[[ix]])$characteristics_ch1[4],": ")[[1]][2]
  disease <- strsplit(Meta(GSMList(gse)[[ix]])$characteristics_ch1[2],": ")[[1]][2]
  for (xi in seq(nchar(age))) {
    if (is.na(strtoi(substr(age,xi,xi)))) {
      age <- strtoi(substr(age, 1, xi-1))
      break
    }
  }
  age <- as.numeric(age)
  if (age < 65) {
    pheno_total <- c(pheno_total, "Young")
  } else {
    pheno_total <- c(pheno_total, "Old")
  }
  age_l <- c(age_l, age)
  if (disease != "Normal" ){
    print(age)
    pos <- c(pos,"No")
  } else {
    pos <- c(pos, "Yes")
    print(age)
  }
}
new_count <- countData[,pos== "Yes"]
new_pheno <- pheno_total[pos=="Yes"]


new_pheno_df <- as.data.frame(new_pheno)
rownames(new_pheno_df) <- colnames(new_count)
colnames(new_pheno_df) <- "Age"

dds <- DESeqDataSetFromMatrix(countData = new_count, colData = new_pheno_df, design = ~ Age)

dds <- DESeq(dds)
res <- results(dds)
(resOrdered <- res[order(res$padj), ])

palb2_bit <- countData["ENST00000697375.1", pos == "Yes"]
age_l_t <- age_l[pos=="Yes"]
spearman<-cor.test(palb2_bit, age_l_t, method = "spearman")
df <- as.data.frame(cbind(palb2_bit,age_l_t))
ggplot(df, aes(y=palb2_bit, x=age_l_t)) + geom_point() + geom_smooth(method=lm , color="red", fill="#69b3a2", se=TRUE)

#CpG and TAT box Distance MCF7####

library("ggplot2")

cpg_mcf7 <- as.data.frame(read.table("MCF7/MCF7_transcriptome_no_multimap/intersection_upstream/intersect_upstream_mcf7.tss.intragenic.same_strand.non_canonical_cases.sorted.closest_cpg.gtf"))

ggplot(cpg_mcf7,aes(x=V38)) +
  geom_density() +
  labs(x="Distance", y="Density", title="Distribution of distance of the closest CpG island to MCF7 BIT-RNA") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  coord_cartesian(xlim=c(-50000,50000))

tata_mcf7 <- as.data.frame(read.table("MCF7/MCF7_transcriptome_no_multimap/intersection_upstream/intersect_upstream_mcf7.tss.intragenic.same_strand.non_canonical_cases.sorted.closest_tata.gtf"))

ggplot(tata_mcf7,aes(x=V30)) +
  geom_density() +
  labs(x="Distance", y="Density", title="Distribution of distance of the closest TATA box to MCF7 BIT-RNA") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10))

#CpG and TAT box Distance Fibroblasts####

library("ggplot2")

cpg_fibroblast <- as.data.frame(read.table("fibroblast_ageing/merged_info/intersection_hotspot/intersect_hotspot_fibroblasts.intragenic.same_strand.non_canonical_cases.sorted.closest_cpg.gtf", sep="\t"))


ggplot(cpg_fibroblast,aes(x=V8,y=V19)) +
  geom_violin() +
  labs(x="Distance", y="Density", title="Distribution of distance of the closest CpG island to fibroblast BIT-RNA") +
  geom_point(position = position_jitter(seed = 1, width = 0.2)) +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  coord_cartesian(ylim=c(min(cpg_fibroblast$V19), 60000))

tata_fibroblast <- as.data.frame(read.table("fibroblast_ageing/merged_info/intersection_hotspot/intersect_hotspot_fibroblasts.intragenic.same_strand.non_canonical_cases.sorted.closest_tata.gtf", sep="\t"))

ggplot(tata_fibroblast,aes(x=V8,y=V16)) +
  geom_violin() +
  geom_point(position = position_jitter(seed = 1, width = 0.2)) +
  labs(x="Distance", y="Density", title="Distribution of distance of the closest TATA box to fibroblast BIT-RNA") +
  geom_hline(yintercept=-1, col="red") +
  annotate("text", x=1.5, y=3.5*10^6, label="-1") +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) 

#FIBROBLAST PALB2#####
library("GEOquery")
library("DESeq2")
library("edgeR")
library(PCAtools)
library("rtracklayer")

countData <- as.matrix(read.csv("fibroblast_ageing/merged_info/transcript_count_matrix.csv", row.names="transcript_id"))

gse <- getGEO(filename="fibroblast_ageing/GSE113957_family.soft.gz")

pheno_total <- c()
pos <- c()
age_l <- c()

for (ix in seq(length(names(GSMList(gse))))) {
  file <- Meta(GSMList(gse)[[ix]])$geo_accession
  age <- strsplit(Meta(GSMList(gse)[[ix]])$characteristics_ch1[4],": ")[[1]][2]
  disease <- strsplit(Meta(GSMList(gse)[[ix]])$characteristics_ch1[2],": ")[[1]][2]
  for (xi in seq(nchar(age))) {
    if (is.na(strtoi(substr(age,xi,xi)))) {
      age <- strtoi(substr(age, 1, xi-1))
      break
    }
  }
  
  age <- as.numeric(age)
  if (age < 65) {
    pheno_total <- c(pheno_total, "Young")
  } else {
    pheno_total <- c(pheno_total, "Old")
  }
  age_l <- c(age_l, age)
  print(disease)
  if (disease != "Normal") {
    print(age)
    pos <- c(pos,"No")
  } else {
    pos <- c(pos, "Yes")
    print(age)
    print("n")
  }
}

new_count <- countData[,pos== "Yes"]
new_pheno <- pheno_total[pos=="Yes"]


new_pheno_df <- as.data.frame(new_pheno)
rownames(new_pheno_df) <- colnames(new_count)
colnames(new_pheno_df) <- "Age"

dds <- DESeqDataSetFromMatrix(countData = new_count, colData = new_pheno_df, design = ~ Age)

dds <- DESeq(dds)
res <- results(dds)
(resOrdered <- res[order(res$padj), ])

palb2_bit <- countData["ENST00000697375.1", pos == "Yes"]
age_l_t <- age_l[pos=="Yes"]
spearman<-cor.test(palb2_bit, age_l_t, method = "spearman")
df <- as.data.frame(cbind(palb2_bit,age_l_t))
ggplot(df, aes(y=palb2_bit, x=age_l_t)) + geom_point() +
  theme_classic() +
  theme(plot.title = element_text(hjust = 0.5, size=11), axis.title.x = element_text(size=10), axis.title.y = element_text(size=10)) +
  labs(x="Age", y= "ENST00000697375 Normalized Counts")

for (ix in bit_candidates$transcript_id) {
  palb2_bit <- countData[ix, pos == "Yes"]
  print(ix)
  age_l_t <- age_l[pos=="Yes"]
  spearman<-cor.test(palb2_bit, age_l_t, method = "spearman")
  if (!is.na(spearman$p.value)) {
    if (spearman$p.value < 0.05) {
      print(ix)
      print("yes")
    }
  }
}
#PCA

bit_candidates <- as.data.frame(import("fibroblast_ageing/merged_info/intersection_hotspot/intersect_hotspot_fibroblasts.intragenic.same_strand.non_canonical_cases.gtf"))

new_count_PCA <- as.data.frame(new_count[rownames(new_count) %in% bit_candidates$transcript_id,])
y <- DGEList(counts=new_count_PCA, group=age_l_t)
y <- calcNormFactors(y)
cpms <- edgeR::cpm(y, offset = y$offset, log = T)

cpms_pca <- as.data.frame(cpms[rownames(cpms) %in% bit_candidates$transcript_id,])

df_age <- data.frame(age_l_t)

rownames(df_age) <- colnames(cpms)
pca.res <- pca(cpms,metadata = df_age)
biplot(pca.res, colby = "Age",hline = 0, vline = 0,legendPosition = 'top', lab="")

bit_candidates_total <- as.data.frame(import("fibroblast_ageing/merged_info/intersection_hotspot/intersect_hotspot_fibroblasts.gtf"))
new_count_PCA <- as.data.frame(new_count[rownames(new_count) %in% bit_candidates_total$transcript_id,])
y_t <- DGEList(counts=new_count_PCA, group=age_l_t)
y_t <- calcNormFactors(y_t)
cpms_t <- edgeR::cpm(y_t, offset = y_t$offset, log = T)

cpms_pca_t <- as.data.frame(cpms_t[rownames(cpms_t) %in% bit_candidates_total$transcript_id,])

df_age <- data.frame(age_l_t)

rownames(df_age) <- colnames(cpms_t)
colnames(df_age) <- c("Age")
pca.res <- pca(cpms_t,metadata = df_age)
biplot(pca.res, colby = "Age",hline = 0, vline = 0,legendPosition = 'top', lab="")

#Annotation####

mcf7_annotation <- read.table("MCF7/MCF7_transcriptome_no_multimap/stringtie_MCF7_transcriptome_no_multimap.chr_trimming.chrM_removal.gffcompare.stringtie_MCF7_transcriptome_no_multimap.chr_trimming.chrM_removal.gtf.refmap",header=T, sep="\t")

mcf7_bit <- as.data.frame(import("MCF7/MCF7_transcriptome_no_multimap/intersection_upstream/intersect_upstream_mcf7.tss.gtf"))

bit_candidates_no_filter <- as.data.frame(import("fibroblast_ageing/merged_info/intersection_hotspot/intersect_hotspot_fibroblasts.gtf"))


#######GTEX_datseT#####
library("readxl")
library("ggpubr")
library("ggplot2")


exp <- read.delim("GTEx_Analysis_2017-06-05_v8_RSEMv1.3.0_transcript_tpm.ENSG00000083093.gct", header = FALSE)
header <- read.delim("GTEx_Analysis_2017-06-05_v8_RSEMv1.3.0_transcript_tpm.header.gct", header = FALSE)

colnames(exp) <- header[1,]

age <- read.table("GTEx_Analysis_v8_Annotations_SubjectPhenotypesDS.txt", sep="\t", header = TRUE)
tissue <- read.delim("GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt", sep="\t", header = TRUE)

tissue_trim <- tissue[tissue$SAMPID %in% colnames(exp),]

df <- data.frame(Sample_ID=character(0), Expression=numeric(0), Tissue=character(0), Age=character(0), Transcript=character(0))

for (ix in tissue_trim[,1]) {
  exp_sit <- as.data.frame(exp[,colnames(exp) == ix])
  tis <- tissue_trim[tissue_trim$SAMPID == ix, "SMTSD"]
  tis <- rep(tis, length(exp_sit[,1]))
  id_parts <- strsplit(ix,"-")
  age_id <- paste0(id_parts[[1]][1], "-", id_parts[[1]][2])
  age_f <- age[ age$SUBJID == age_id, "AGE"]
  age_f <- rep(age_f, length(exp_sit[,1]))
  id <- rep(ix, length(exp_sit[,1]))
  tis <- as.data.frame(tis)
  age_f <- as.data.frame(age_f)
  id <- as.data.frame(id)
  transID <- as.data.frame(exp$transcript_id)
  new_info <- cbind(id, exp_sit, tis, age_f, transID)
  colnames(new_info) <- colnames(df)
  df <- rbind(df, new_info)
}

for (ix in unique(df$Tissue)) {
  file_name <- paste0("R_plots_fibroblasts/", ix, ".pdf")
  pdf(file=file_name)
  for (xi in exp$transcript_id) {
    new_df <- df[ df$Tissue==ix & df$Transcript==xi,]
    if (length(new_df$Tissue) >= 20) {
      bp <- boxplot(Expression ~ Age, data=new_df, xlab="Age group", ylab="Expression Level", main=xi)
      
      # Perform ANOVA
      anova_result <- aov(Expression ~ Age, data = new_df)
      
      # Extract p-values from ANOVA result
      p_values <- summary(anova_result)[[1]][1,5]
      
      if (is.na(p_values)) {
        p_values<-0
      }
      
      # Add significance indicators to the plot
      signif_level <- 0.05
      legend_labels <- c(paste0("ANOVA:",p_values))
      tukey <- TukeyHSD(anova_result)
      group <- length(unique(new_df$Age))
      count <- 1
      for (i in 1:(group - 1)) {
        for (j in (i + 1):group) {
          p_value_adj <- tukey[[1]][count,4]
          if (is.na(p_value_adj)) {
            p_value_adj<-0
          }
          count <- count + 1
          if (p_value_adj < signif_level) {
            legend_labels <- c(legend_labels, paste0(names(tukey[[1]][,4])[count], ":", p_value_adj))
            mid_point <- mean(c(i, j))
            y_pos <- max(bp$stats) + 0.05 * diff(range(bp$stats))
            text(mid_point, y_pos, "*", cex = 2)
          }
        }
      }
      
      # Add the legend
      legend("topright", legend = legend_labels)
      
    } else {
      print(ix)
      print(xi)
    }
  }
  dev.off()
}

file_name <- paste0("R_plots_fibroblasts/stacked_barplot/GTEX.pdf")
pdf(file=file_name)

for (ix in sort(unique(df$Tissue))) {
  new_df <- df[ df$Tissue == ix,]
  plot_df <- data.frame(replicate(length(unique(new_df$Age)), vector()))
  colnames(plot_df) <- unique(new_df$Age)
  #for (xi in c("ENST00000261584.8","ENST00000561514.1","ENST00000567003.1","ENST00000568219.5","ENST00000565038.1","ENST00000566069.5")) {
  for (xi in c("ENST00000261584.8","ENST00000561514.1","ENST00000568219.5","ENST00000565038.1","ENST00000566069.5")) {
    
    a <- new_df[new_df$Transcript == xi,]
    new_row <- length(plot_df[,1])+1
    for (i in colnames(plot_df)) {
      if (length(a[a$Age==i,1]) == 0) {
        new_med <- 0
      } else {
        new_med <- mean(a[a$Age == i,"Expression"])
      }
      plot_df[new_row,i] <- new_med
    }
    rownames(plot_df)[length(plot_df[,1])] <- xi 
  }
  print(ix)
  plot_df <- plot_df[order(colnames(plot_df))]
  barplot(as.matrix(plot_df), beside = FALSE, col = c("#3f007d","#6a51a3","#dadaeb", "#d95f02", "#1b7837"),legend.text = rownames(plot_df), args.legend = list(x = "topright"),xlab = "Age", ylab = "Expression", main = ix)
}
dev.off()

plot_df <- data.frame(replicate(length(unique(new_df$Age))+1, vector()))
colnames(plot_df) <- c(unique(new_df$Age),"Transcript")

for (ix in sort(unique(df$Tissue))) {
  new_df <- df[ df$Tissue == ix,]
  for (xi in c("ENST00000261584.8","ENST00000561514.1","ENST00000567003.1","ENST00000568219.5","ENST00000565038.1","ENST00000566069.5")) {
    a <- new_df[new_df$Transcript == xi,]
    new_row <- length(plot_df[,1])+1
    for (i in colnames(plot_df)) {
      if (length(a[a$Age==i,1]) == 0) {
        new_med <- 0
      } else {
        new_med <- mean(a[a$Age == i,"Expression"])
      }
      plot_df[new_row,i] <- new_med
    }
    plot_df[new_row,"Transcript"] <- xi
  }
  print(ix)
}

trimmed_df <- df[df$Transcript!="ENST00000567003.1", ]

file_name <- paste0("R_plots_fibroblasts/box_trimmed/GTEX_box.pdf")
pdf.options(width = 10, height = 6)
pdf(file=file_name)
for (ix in sort(unique(trimmed_df$Tissue))) {
  new_df <- trimmed_df[ trimmed_df$Tissue==ix,]
  if (length(new_df$Tissue) >= 100) {
    a <- ggplot(new_df,aes(x=Transcript, y=Expression, fill=Age)) + 
      geom_boxplot() +
      labs(title = ix, x="Transcript", y="Expression (TPM)") +
      theme(plot.title = element_text(hjust = 0.5, vjust = 0, margin = margin(b = 10))) +
      stat_compare_means(aes(group = Age), method = "anova", label = "p.signif")
    print(a)
  } else {
    print(ix)
  }
}
dev.off()

file_name <- paste0("R_plots_fibroblasts/box_trimmed/GTEX_violin.pdf")
pdf.options(width = 10, height = 6)
pdf(file=file_name)
for (ix in sort(unique(trimmed_df$Tissue))) {
  new_df <- trimmed_df[ trimmed_df$Tissue==ix,]
  if (length(new_df$Tissue) >= 100) {
    #boxplot(Expression ~ Age + Transcript, data=new_df, xlab="Age group", ylab="Expression Level", main=ix)
    a <- ggplot(new_df,aes(x=Transcript, y=Expression, fill=Age)) + 
      geom_violin() +
      labs(title = ix, x="Transcript", y="Expression (TPM)") +
      theme(plot.title = element_text(hjust = 0.5, vjust = 0, margin = margin(b = 10)))
    print(a)
  } else {
    print(ix)
  }
}
dev.off()