#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

library(ggplot2)

library(ggpubr)

library(dplyr)

if (length(args)==0) {
  stop("One stats file is need as an argument", call.=FALSE)
}

stats_file = args[1]

#load
f1_file <- read.table(stats_file, header = FALSE, sep='\t')
colnames(f1_file) <- c('sample','tool', 'feature', 'sensitivity', 'precision', 'f1')

# remove trailing spaces and string 'level'
f1_file$feature <- gsub("level", "", gsub(" ", "", trimws(f1_file$feature)))

#plots
base_plot <- ggplot(f1_file[f1_file$feature == 'Base', ], aes(x=sensitivity, y=precision, shape=tool, colour=sample)) + 
  geom_point(size=5) + ggtitle('Base') + scale_colour_manual(values=c("grey", "#db5a6b", "#E69F00", "#56B4E9","#009999"))

exon_plot <- ggplot(f1_file[f1_file$feature == 'Exon', ], aes(x=sensitivity, y=precision, shape=tool, colour=sample)) + 
  geom_point(size=5) + ggtitle('Exon') + scale_colour_manual(values=c(AcaCa="grey",BlaHom="#db5a6b",LasPus="#E69F00", MalRes="#56B4E9", OstLuc="#009999"))

intron_plot <- ggplot(f1_file[f1_file$feature == 'Intron', ], aes(x=sensitivity, y=precision, shape=tool, colour=sample)) + 
  geom_point(size=5) + ggtitle('Intron') + scale_colour_manual(values=c(AcaCa="grey",BlaHom="#db5a6b",LasPus="#E69F00", MalRes="#56B4E9", OstLuc="#009999"))

transcript_plot <- ggplot(f1_file[f1_file$feature == 'Transcript', ], aes(x=sensitivity, y=precision, shape=tool, colour=sample)) + 
  geom_point(size=5) + ggtitle('Transcript') + scale_colour_manual(values=c(AcaCa="grey",BlaHom="#db5a6b",LasPus="#E69F00", MalRes="#56B4E9", OstLuc="#009999"))

# combine_plots
combined_plot <- ggarrange(base_plot, exon_plot, intron_plot, transcript_plot,
          ncol = 2, nrow = 2,  common.legend = TRUE)

ggsave("f1_stats.pdf", width = 20, height = 20, units = "cm")
