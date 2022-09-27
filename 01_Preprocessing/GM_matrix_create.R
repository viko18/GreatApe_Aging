#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
# Create masked GM matrix (subj x voxels) for OPNMF analyses #

### Arguments  ###

# 1: Species investigated - "chimp" or "human"
# 2: Name of meta data .csv file #
# 3: Name and relative path of GM mask Nifti image #


wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

# load in libraries needed for script #
# need to install pacman if not already installed 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, readr, dplyr, neurobase, oro.nifti)

# sample species either human (IXI) or chimp for locating images and naming outputs #
cohort <-  args[1] # "chimp" or "human

# sample meta data to gather image names #
meta_name <-  args[2] #"Chimp_meta_QC_u50_n189.csv"
meta_data <- read_csv(file = paste(path_wd(), "data", cohort, meta_name, 
                                   sep = "/"))
# smoothing kernel of images - chimp 4mm & IXI 6mm #
if (cohort == "chimp") {
  s_kernel <- "s4"
} else if (cohort == "human") {
  s_kernel <- "s6"
} else {
  print("!! ERROR don't recognise species given should be chimp or human !!")
}
# file names of images to create GM data matrix #
subj_name <- c(paste0(s_kernel, "_mwp1", meta_data$Subject, ".gz"))
# path to images#
img_path <- paste(path_wd(), "data",  cohort, "mwp1", sep = "/")

# create GM index at TPM 0.3GM #
mask_name <-  args[3] #"masks/Chimp_GM_TPM_03_Cortex_2mm.nii.gz"
GM_mask <- readnii(paste(path_wd(), mask_name ,sep = "/"))
# GM index mask vector #
GM_ind <- c(img_data(GM_mask > 0))

# empty lists #
imgs <- vector(mode = "list", length = nrow(meta_data))
imgs_GM <- vector(mode = "list", length = nrow(meta_data))

# fill lists with GM data from each subject #
for (i in 1:length(subj_name)) {
  # read nifti images #
  imgs[[i]] <- readnii(paste(img_path, subj_name[i], sep= "/"))
  # mask GM data #
  imgs_GM[[i]] <- c(img_data(imgs[[i]])[GM_ind])
}

# create a GM matrix subj x voxels #
GM_mat <- rbind(matrix(unlist(imgs_GM), 
                       ncol = length(imgs_GM[[1]]), byrow = TRUE))
# Name of outpu data matrix #
if (cohort == "chimp") {
  out_name <- paste0("Chimp_cort_n", nrow(meta_data), "_TPM03_mat.rds")
} else if (cohort == "human") {
  out_name <- paste0("IXI_cort_n", nrow(meta_data), "_mat.rds")
} else {
  print("!! ERROR don't recognise species given should be chimp or human !!")
}
# save data matrix #
saveRDS(GM_mat, file = paste(path_wd(), "data", cohort, out_name, sep="/"))

