#!/bin/bash
#
# Run script for GM matrix create #
# which creates the data matrix for input into OPNMF analyses #

# The R script requires 3 input arguments #
# 1 - Speceis investigated - "chimp" or "human"
# 2 - Name of the cohort phenotype data file e.g. chimp_meta_QC_n189.csv
# 3 - Name and relative path from project dir to GM mask e.g. "wd/masks/chimp_GM_TPM_03_Cortex_2mm.nii.gz

# Name of R script #
r_script=GM_matrix_create.R

# Cohort speceis chimp or human #
species="chimp"

# Name of meta data csv file to gather sample for data matrix #
cohort="chimp_meta_QC_n189.csv"

# path to GM mask #
GM_mask="masks/chimp_GM_TPM_03_Cortex_2mm.nii.gz"
   
# run R script	
Rscript $r_script $species $cohort $GM_mask
echo Creating $species data matrix 


