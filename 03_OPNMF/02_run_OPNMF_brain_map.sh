#!/bin/bash
#
# run script OPNMF solution brain projection 
# R script requires 2 aguments #
## 1: Cohort to be investigated - "chimp" or "human"

## 2: relative path to GM mask for cohort e.g. "/masks/Chimp_GM_TPM_03_Cortex_2mm.nii.gz"
## Here wd = ~/project/chimp_human_opnmf/ which is hard coded into R script

# Cohort #
cohort="chimp"
echo "$cohort brain Projection"

# relative path from wd to GM mask #
mask_img="/masks/Chimp_GM_TPM_03_Cortex_2mm.nii.gz"


# Run Rscript #
Rscript OPNMF_brain_map.R $cohort $mask_img


