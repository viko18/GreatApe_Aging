#!/bin/bash
#
# OPNMF run script (OPNMF_boot.R)
# OPNMF script requires 4 arguments
# 1 - relative path from working dir to input matrix and name
# 2 - Number of OPNMF factors to be created
# 3 - Number of bootstraps
# 4 - Seed for reproducibility

# Name of R script for OPNMF bootstrapping #
r_script=OPNMF_boot.R

# input data matrix #
inputMat=chimp_cort_n189_02GM_mat.rds

# OPNMF rank
#rank=17

# number of bootstraps #
numboot=30

# set seed for random generation of boostraps and permutations
num_seed=47

for rank in $(seq 2 1 10); do

    Rscript $r_script $inputMat $rank $numboot $num_seed
    echo OPNMF bootstrapping on $inputMat: Ranks - $rank, bootstraps - $numboot, seed: $num_seed 

done
