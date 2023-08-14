library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
chrom <- args[2]
# Read in allele counts file
split_alleleCounts <- read_csv(args[1]) %>%
    # Split variantID column to get ref and alt allele column
    separate(variantID, into = c(NA, NA, "refAllele", "altAllele"), sep = ":", remove = FALSE) %>%
    # Write to new file
    write_csv(file = paste0("output/AI/chr", chrom, "_alleleCounts_filtered_split.csv"))