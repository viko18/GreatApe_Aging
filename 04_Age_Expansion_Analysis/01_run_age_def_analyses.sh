#!/bin/bash
#
# Run script to conduct age - expansion analyses #
# using parcellation (OPNMF or Davi130) #

# The R script requires 5 input arguments #
### 1 - Working directory (wd) where relative paths can be used to find files 
### 2 - Cohort investigated
### 3 - Parcellation Image used for analyses 
### 4 - Deformation field (Inter-species) Nifti relaltive path from wd
### 5 - name of phenotype meta data with subj names, Age, Sex, Scanner, TIV

# 7 outputs are created and saved in wd/outputs/ #
### OUTPUT 1 - Meta data of sample with comp mean grey matter vol (csv)
### OUTPUT 2 - output statistics from component wise age regression (csv)
### OUTPUT 3 - T-statistic from age reg projected onto brain (nifti)
### OUTPUT 4 - ONLY significant FWE T-statistic from age reg projected onto brain (nifti)
### OUTPUT 5 - Average deformation per parcellation component image (nifti)
### OUTPUT 6 - deformation & T-statistic data fro post-hoc comparison (csv)
### OUTPUT 7 - Z scored parcellation expanion map (nifti)

# Name of R script #
r_script=age_def_analyses.R

# wd #
working_dir="~/projects/chimp_human_opnmf/"

# cohort investigated - "chimp", "IXI", or "eNKI"
cohort="chimp"

# path to GM mask #
parc="chimp_cortex_n189_TPM03_rank_17_num_match.nii.gz"

# Cross-species expansion mapp
exp_map="Haiko2Juna_expansion_0.08_0.8_2mm.nii.gz"

# Name of meta data csv file to gather sample for analyses & age reg model #
meta_sample="chimp_meta_QC_n189.csv"
   
# run R script	
Rscript $r_script $working_dir $cohort $parc $exp_map $meta_sample
echo Conduction age & expansion analyses using $parc parcellation and $exp_map expasnion map on $cohort sample


