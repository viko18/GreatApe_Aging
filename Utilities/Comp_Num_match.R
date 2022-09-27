# match OPNMF component numbers across two parcellations 
# for easier plotting #
wd <- "~/projects/chimp_human_opnmf/" # Working Directory
setwd(wd) 
# use neuroconductor to install neurobase as install.packahes("neurobase") fails
# Neurobase just makes it a bit easier to work with nifti's #
source("https://neuroconductor.org/neurocLite.R")
neuro_install("neurobase")
# Load oro.nifti and neurobase to deal with Nifit Images easily &
# fs for file structure manipulation - mainly using 'path_wd()'
pacman::p_load(oro.nifti, fs, neurobase) # clue - might not be needed

# Helper script with useful functions #
source(file = paste(path_wd(), "code", "OPNMF_util.R", sep = "/"))

### INPUTS ###
# INPUT 1: Selected Chimp OPNMF (17) parcellation in MNI space following 
# cross-species registration and same resolution as IXI OPNMF data #
# Path to chimp OPNMF solutions #
chimp_path <- paste(path_wd(), "data", "chimp", "opnmf_parc", sep = "/")
# Name of chimp OPNMF parcellation #
chimp_img_name <- "wChimp_cort_n189_TPM03_rank_17_median.nii.gz"
# Read in chimp image #
chimp_img <- readnii(paste(chimp_path, chimp_img_name, sep="/"))

# Input 2: Selected IXI OPNMF parcellation (17) used to match the chimp OPNMF 
# Number based on their spatial location as best as possible #
# path to IXI OPNMF solutions #
IXI_path <- paste(path_wd(), "data", "IXI", "opnmf_parc", sep = "/")
# Name of IXI image #
IXI_img_name <- "IXI_cort_n480_rank_17_median.nii.gz"
# Read in IXI image #
IXI_img <- readnii(paste(IXI_path, IXI_img_name, sep = "/"))


#Input 3: Chimp OPNMF parcellation in Juna (Chimp) space to have its numbering 
# changed to match IXI 17-parcellation solution #
# Name of chimp OPNMF solution in Juna chimp space #
orig_name <- "Chimp_cort_n189_TPM03_rank_17.nii.gz"
# Read in original chimp image #
chimp_orig <- readnii(paste(chimp_path, orig_name, sep = "/"))



### Prepare images for matching parcellation numbers ####

# Create a Chimp in MNI space GM mask to be used to mask the IXI image #
# Create GM mask nifti #
c_masked <- mask_img(chimp_img, IXI_img > 0)
# vector of GM mask #
GM_mask <- c(img_data(c_masked > 0))

# create GM volume vectors for both species in MNI space #
chimp_vol <- c(img_data(chimp_img))
IXI_vol <- c(img_data(IXI_img))
# GM Volume vectors #
chimp_GM <- chimp_vol[GM_mask]
IXI_GM <- IXI_vol[GM_mask]

# Create volume vector for chimp nifti in Juna space #
chimp_orig_ind <- c(img_data(chimp_orig > 0))
# GM volume vector #
chimp_orig_GM <- c(img_data(chimp_orig))[chimp_orig_ind]

#### Match Parcel Numbers & Write out New Nifti's ####

# use matching function function to match parcel numbers sing GM vectors # 
comp_change <- minWeightBipartiteMatching(chimp_GM, IXI_GM)

# Create chimp vectors in MNI and Juna space to be used to change numbering & 
# write out new number matched images #

# New vector for chimp in Juna space #
chimp_orig_new <- chimp_orig_GM
# New vector for chimp in MNI space #
chimp_GM_ind <- c(img_data(chimp_img > 0))
chimp_GM_new <- chimp_vol[chimp_GM_ind]
chimp_GM_out <- chimp_GM_new

# loop over parcel numbers and change to matched numbers with IXI solution #
for (i in 1:length(unique(chimp_GM))) {
  
  # index for chimp in mni space #
  comp_ind_mni <- chimp_GM_new == i
  # index for chimp in Juna space #
  comp_ind_orig <- chimp_orig_GM == i
  # new numbers for the chimp in mni space #
  chimp_GM_out[comp_ind_mni] <- comp_change[i]
  # new number for chimp in Juna space #
  chimp_orig_new[comp_ind_orig] <- comp_change[i]
  
}

#### OUTPUTS ####
# Output 1: chimp OPNMF solution in Juna space parcel number matched to IXI 17 #
# write out new images #
# chimp in Juna space #
out_name_orig <- paste(substr(orig_name, 1, nchar(orig_name)-7), "num_match",
                       sep = "_")
out_vol_orig <- c(img_data(chimp_orig))  #chimp_vol
out_vol_orig[chimp_orig_ind] <- chimp_orig_new
# Help function for simply writing out new nifit's using vectors #
vol_2_img(vol_vec = out_vol_orig, img_info = chimp_orig, location = chimp_path,
          img_name = out_name_orig)
# Output 2: Chimp OPNMF solution in MNI space matched to IXI parecel numbers #
# chimp in MNI space #
out_name_mni <- paste(substr(chimp_img_name, 1, nchar(chimp_img_name)-7), 
                      "num_match", sep = "_")
out_vol_mni <- chimp_vol  #chimp_vol MNI space
out_vol_mni[chimp_GM_ind] <- chimp_GM_out
vol_2_img(vol_vec = out_vol_mni, img_info = chimp_img, location = chimp_path,
          img_name = out_name_mni)
