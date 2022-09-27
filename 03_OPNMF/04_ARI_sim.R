# Compares parcel similarity between chimp and human OPNMF solutions #
# chimpanzee OPNMF solutions have been registered to human MNI space #
# using 03_Chimp_opnmf_def_batch.m SPM batch script #

# working project directory #
wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

# load in libraries needed for script #
# need to install pacman if not already installed 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, neurobase, oro.nifti)

### A utility script needs to be in wd/code which contains helper functions
# needed for ari_sim function #
source(file = paste(path_wd(), "code", "OPNMF_util.R", sep = "/"))
### OUTPUTS:

parc1_path <- paste(path_wd(), "data", "chimp", "opnmf_parc", sep = "/")
parc2_path <- paste(path_wd(), "data", "IXI","opnmf_parc", sep = "/")

# GM mask use the chimp parcellation in MNI space #
GM_mask <- readnii(paste(parc1_path,"wchimp_cortex_n189_TPM03_rank_2.nii.gz", 
                            sep = "/"))
# index GM voxels to be replaced with opnmf parcellation #
GM_ind <- c(img_data(GM_02_cort > 0))
# create vector of GM mask #
#GM_02_vol <- c(img_data(GM_02_cort))

# path to images #

ranks <- 2:40
ari_sim <- rep(NA, length(ranks))

for (i in 1:length(ranks)) {
  # 1st parcellation GM masked #
  parc1 <- readnii(
      paste(parc1_path, 
            paste("wchimp_cort_n189_TPM03_rank_", ranks[i], "_median.nii", sep = ""), 
            sep = "/")
    )
  # 2nd parc GM masked #
  parc2 <- readnii(
      paste(parc2_path, 
            paste("IXI_cortex_n480_rank_", ranks[i], "_median.nii.gz", sep = ""), 
            sep = "/")
    )
  # calculate ARI for parcellations #
  ari_sim[i] <- parc_sim_ARI(parc1, parc2, GM_mask)
}

ari_df <- data.frame("ranks" = ranks, "ARI_IXI_Chimp" = ari_sim) 
# melt for easier plotting #
ari_tib <- melt(ari_df, id.vars = c("Ranks"))
saveRDS(ari_tib, file = paste(path_wd(), "outputs", 
                              "Chimp_TPM03_2_IXI_ARI.rds", sep = "/"))
