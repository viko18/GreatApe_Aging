#!/usr/bin/env Rscript

# OPNMF on data matrix (subj x voxel) over a range of ranks or factors by steps 
# of one. W = factor matrix, H = subject matrix
args = commandArgs(trailingOnly=TRUE)
### Arguments ####

## 1: relative path to data matrix (subj x voxel) as .rds file ## 
## if matrix is in wd/data/mat.rds then arg="data/mat.rds ##

## 2: Number of ranks or factors for OPNMF ##

## INPUT: data matrix .rds file ##
## OUTPUT: OPNMF solutions over range selected as list .rds file ##

# !!set working directory!! #
wd <-  "~/projects/chimp_human_opnmf/" 
setwd(wd)

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, remotes)
# Biocmanager is needed to install Biobase and then NMF packages #
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
install.packages("Biobase")
# install opnmfR package from github #
# might be better to remotes::install_local() after downloading the repo with 
# Microsoft open R #
remotes::install_github("kaurao/opnmfR")

# input data matrix file (.rds #)
input_file <- paste(path_wd(), args[1] , sep="/")
print(paste0("read iput matrix: ", input_file))
input_mat <- readRDS(input_file)
print("DONE!")
# nput file name for naming OPNMF output .rds fle '
input_name <- paste(sub(pattern = ".rds", replacement = "\\1", 
                        basename(input_file)))

# factors to be investigated #
rank <- as.integer(args[2])
# Empty list for the different OPNMF rank solutions
W_H <- vector(mode = "list", length = length(rank))

print(paste0("Run OPNMF with ", rank, " factors"))
# opnmfRcpp is used for improved compute speed #
W_H <- opnmfR::opnmfRcpp(X = t(input_mat), r = rank, 
                                         W0 = "nndsvd", max.iter = 5e4)
print("DONE!")

out_dir <- paste(path_wd(), "outputs", sep="/")
# if outputs dir doesn't exists create it #
if (!dir_exists(out_dir)) {
  dir_create(out_dir)
  print(paste0("created ", out_dir))
} else {
  print(paste0(out_dir, " already created"))
}

## OUTPUT ##
# save OPNMF solutions to outputs #
print(paste0("Save OPNMF W H matrix here: ", out_dir))
saveRDS(W_H, file = paste(out_dir, 
                          paste(input_name, "rank", args[2], "W_H.rds", sep="_"), 
                          sep = "/"))
print("DONE!")