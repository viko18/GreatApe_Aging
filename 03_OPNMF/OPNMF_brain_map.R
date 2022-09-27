#!/usr/bin/env Rscript

# create OPNMF brain parcellations by projecting W matrix onto volume space #

args = commandArgs(trailingOnly=TRUE)
### Arguments ####

# 1: Species of OPNMF output - "chimip" or "human" #
# 2: relative path and name of GM mask used in creating OPNMF data matrix and OPNMF solutions #

# Utilising thse arguments will gather the .rds files which contain the output from OPNMF_fact.R #
# These should be in the directory 'wd/data/Speceis(e.g. chimp or human)/W_H/*.rds #
# When downloading the OPNMF solutions from (....Zenodo....) they will have this structure for each species #


wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

# load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, oro.nifti, neurobase, readr)

print(paste0("###### WORKING DIR: ", path_wd(), " #######"))

# load OPNMF helper functions for simpler creation of brain Niftis #
print(paste0("Source helper functions from ", 
             paste(path_wd(), "code", "OPNMF_util.R", sep = "/")))
source(file = paste(path_wd(), "code", "OPNMF_util.R", sep = "/"))
print("DONE!")
# input 1: Species string for gathering OPNMF solutions and naming output niftis #
cohort <- args[1]

# input 2: GM for projecting OPNMF solutions #
GM_mask <- paste0(path_wd(), args[2])

print(paste0("Read in GM mask from ", GM_mask))
GM_mask_img <- readnii(GM_mask)
print("DONE!")

# Name of mask to easily gather OPNMF W H outputs as this is how they are saved 
# following OPNMF_fact.R e.g. "{GM_mask_name}_mat_rank_2_W_H.rds
GM_mask_name <- paste(sub(pattern = ".nii.gz", replacement = "\\1", 
                          basename(GM_mask)))
# index GM voxels to be replaced with opnmf parcellation #
GM_ind <- c(img_data(GM_mask_img > 0))
# create vector of GM mask #
GM_vol <- c(img_data(GM_mask_img))
# volume for wrting out OPNMF parcellation
out_vol <- GM_vol 

# Create species specific images with specific file path and file names #
if (cohort == "chimp") {
  
  # path to WH data #
  W_H_path <- paste(path_wd(), "data", cohort, "W_H", sep = "/")
  # name of W_H .rds files #
  W_H_names <- list.files(path = W_H_path,
                          pattern = glob2rx(pattern = "chimp_cort*.rds"))
  
  # create parcallation output dir
  parc_dir <- paste(path_wd(), "data", cohort, "opnmf_parc", sep="/")
  # if outputs dir doesn't exists create it #
  if (!dir_exists(parc_dir)) {
    dir_create(parc_dir)
    print(paste0("created ", parc_dir))
  } else {
    print(paste0(parc_dir, " already created"))
  }
  
  # create OPNMF brain images using WH data in dir #
  # Only create images that have not been created at "path_wd()/dat/chimp/opnmf_parc/"
  
  for (i in 1:length(W_H_names)) {
    
    # volume for wrting out OPNMF parcellation
    parc_vol <- GM_vol 
    
    # W_H data for creating brain projection #
    W_H_data <- readRDS(file = paste(W_H_path, W_H_names[i], sep = "/"))
    
    # name of output parcellation brain #
    parc_name <- paste(parc_dir, paste0("Chimp_cort_n", ncol(W_H_data$H), 
                       "_TPM03_rank_", ncol(W_H_data$W), ".nii.gz"), sep = "/")
    
    if (!file_exists(parc_name)) {
      # check if image has already been mapped out #
      parc_vol[GM_ind] <- apply(W_H_data$W, 1, which.max)
      
      # write out image #
      print(paste0("create ", parc_name))
      vol_2_img(vol_vec =  parc_vol, img_info =  GM_mask_img, 
                img_name =  basename(parc_name), location = parc_dir)
      print("DONE!")
    } else {
      print(paste0(parc_name, " already created"))
    }

  }
  
} else if (cohort == "human") {
  W_H_path <- paste(path_wd(), "data", cohort, "W_H", sep = "/")
  W_H_names <- list.files(path = W_H_path,
                          pattern = glob2rx(pattern = "IXI_cort*.rds"))
  
  # create parcallation output dir
  parc_dir <- paste(path_wd(), "data", cohort, "opnmf_parc", sep="/")
  
  # if outputs dir doesn't exists create it #
  if (!dir_exists(parc_dir)) {
    dir_create(parc_dir)
    print(paste0("created ", parc_dir))
  } else {
    print(paste0(parc_dir, " already created"))
  }
  
  # create OPNMF brain images using WH data in dir #
  # Only create images that have not been created at "path_wd()/dat/chimp/opnmf_parc/"
  
  for (i in 1:length(W_H_names)) {
    
    # volume for wrting out OPNMF parcellation
    parc_vol <- GM_vol 
    
    # W_H data for creating brain projection #
    W_H_data <- readRDS(file = paste(W_H_path, W_H_names[i], sep = "/"))
    
    # name of output parcellation brain #
    parc_name <- paste(parc_dir, paste0("IXI_cort_n", ncol(W_H_data$H), 
                                        "_rank_", ncol(W_H_data$W), ".nii.gz"), 
                       sep = "/")
    
    if (!file_exists(parc_name)) {
      # check if image has already been mapped out #
      parc_vol[GM_ind] <- apply(W_H_data$W, 1, which.max)
      
      # write out image #
      print(paste0("create ", parc_name))
      vol_2_img(vol_vec =  parc_vol, img_info =  GM_mask_img, 
                img_name =  basename(parc_name), location = parc_dir)
      print("DONE!")
    } else {
      print(paste0(parc_name, " already created"))
    }
  }
} else {
  print("!! ERROR don't recognise species given should be chimp or human !!")
}
