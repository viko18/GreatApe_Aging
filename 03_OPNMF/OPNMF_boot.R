#!/usr/bin/env Rscript

# OPNMF on data matrix (subj x voxel) over a range of ranks or factors by steps 
# of one. W = factor matrix, H = subject matrix
args = commandArgs(trailingOnly=TRUE)
### Arguments ####

## 1: relative path to data matrix (subj x voxel) as .rds file ## 
## if matrix is in wd/data/mat.rds then arg="data/mat.rds ##

## 2: factor number for OPNMF ##

## 3: Number of bootstraps ##

## 4: Seed for reproducibility ##

## INPUT: data matrix .rds file ##
## OUTPUT: OPNMF bootstrapping output data for a factor solution ##

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
remotes::install_github("kaurao/opnmfR")

# bootstrapping perm sel function built on top of opnmfR_ranksel_perm
# location of github repo code #
print("load opnmfR_boot.R functoin")
source(paste(path_wd(), "code", "03_OPNMF", "opnmfR_boot.R", sep = "/"))
print("DONE!")

# load input matrix as a .rds #
input_file <- paste(path_wd(), args[1] , sep="/")

print(paste0("Read input data matrix: ",input_file))
input_mat <- readRDS(input_file)
print("DONE!")

# seed for permutation and bootstrapping for reproducibility #
seed <- as.integer(args[4])
print(paste("Seed:", seed, sep = " "))
# run perm rank selection with bootstrapping of original matrix #
print(paste0("Run OPNMF bootsrapping on factor ", args[2], " with boot = ", args[3]))
perm_boot_sel <- opnmfR_ranksel_perm_boot(X = t(input_mat), rs = as.integer(args[2]),
                                        W0 = "nndsvd", max.iter = 5e4,   
                                        use.rcpp = TRUE, seed = seed, nboot = as.integer(args[3]),
                                       fact = FALSE, plots = FALSE) 
print("DONE!")

# add the rank to the output list for easier post-processing #
perm_boot_sel$rank <- as.integer(args[2])

# out dir to print outputs to #
out_dir <- paste(path_wd(), "outputs", sep="/")
# Name string of output file #
out_name <- paste0(args[1], "_rank_", args[2], "_nboot_", args[3], 
                  "_seed_", args[4],"_perm_boot_sel.rds")
print(paste0("Bootstapping data saved here: ", out_dir, "/", out_name))
# save outputs #
saveRDS(perm_boot_sel, file = paste(out_dir, out_name, sep="/"))
print("DONE!")
