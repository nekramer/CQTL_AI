import pandas as pd
import sys

 
# sys.argv[1]: allele counts file

## Read in alleleCounts file
alleleCounts = pd.read_csv(sys.argv[1])

## Split chromosome into separate column
alleleCounts['chr'] = alleleCounts['variantID'].str.extract('(chr[0-9]{1,2})', expand = True)

## Go through each chromosome and get split
for chr in range(1, 23):
    # Get subset of chromosome
    alleleCount_subset = alleleCounts.loc[alleleCounts.chr == ('chr' + str(chr))]
    # Drop extra 'chr' column
    alleleCount_subset = alleleCount_subset.drop('chr', axis = 1)
    # Write to file
    alleleCount_subset.to_csv('output/AI/chr' + str(chr) + '_alleleCounts_filtered.csv', header = True, index = False)