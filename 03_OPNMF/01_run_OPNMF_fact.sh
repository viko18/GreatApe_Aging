#!/bin/bash
#
# OPNMF run script (OPNMF_fact.R)
# OPNMF script requires 2 arguments
# 1 - relative path from working dir to input matrix and name
# 2 - Number of OPNMF factors to be created

# Name of R script #
r_script=OPNMF_fact.R

# input data matrix #
# The relative path from the working/project dir also needs to be provided #
inputMat="data/chimp/cort_n189_02GM_mat_rds.data"

# OPNMF rank range
# rank=17

# loop over rank range and save outputs in wd/outputs/ #
for rank in $(seq 2 1 40); do
    
    # run OPNMF R script	
    Rscript $r_script $inputMat $rank 
    echo using $rscript on $inputMat with $rank factors 

done
