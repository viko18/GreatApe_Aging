#### Single parcel ARI comparison between chimp and human 17-factor solutions ####
## creates Fig. 2B volume nifti ##
wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

if (!require("pacman")) install.packages("pacman")
pacman::p_load(oro.nifti, fs, neurobase, aricode, reshape2, ggplot2, dplyr) 
# Helper script with useful functions #
source(file = paste(path_wd(), "code", "OPNMF_util.R", sep = "/"))

# path to human opnmf solutions #
human_path <- paste(path_wd(), "data", "IXI", "opnmf_parc", sep = "/")
# path to chimpanzee opnmf solutions #
chimp_path <- paste(path_wd(), "data", "chimp", "opnmf_parc", sep = "/")

# Read in human and chimp opnmf solutions for single ARI evaluation #
## INPUT 1: Human OPNMF 17-factor solution ##
# Parcellation image median filtered to minimize slight morphology differences #
human_img <- readnii(paste(human_path, "IXI_cort_n480_rank_17.nii.gz",
                             sep = "/")) 
img_A <- human_img

# INPUT 2: Chimp parcellation in MNI space #
chimp_img <- readnii(paste(chimp_path, 
                           "whimp_cortex_n189_TPM03_rank_17_num_match.nii.gz",
                           sep = "/"))
img_B <- chimp_img

# empty list to be filled with single component niftis from both images #
A_imgs <- vector(mode = "list", length = length(unique(c(img_data(img_A))))-1)
B_imgs <- vector(mode = "list", length = length(unique(c(img_data(img_B))))-1)
# IF I want to make this more useable can add an if statement to see if the two
# images have the same amount of components and then do different loops for each
# option #
for (i in 1:length(A_imgs)) {
  
  A_imgs[[i]] <- mask_img(img_A, img_A == i)
  B_imgs[[i]] <- mask_img(img_B, img_B == i)
  
}

# empty matrix to be filled with ari values #
ari_mat <- matrix(NA, nrow = length(A_imgs), ncol = length(B_imgs))
for (k in 1:nrow(ari_mat)) {
  for (j in 1:ncol(ari_mat)) {
    # calculate ari for each parcel compared to all parcels of other species #
    # use human solution as mask b/c it is slightly smaller #
    ari_mat[k,j] <- parc_sim_ARI(A_imgs[[k]], B_imgs[[j]], human_img)
  }
}

comps <- 1:(length(unique(c(img_data(img_A))))-1)
ari_df <- data.frame(comps = as.factor(comps),rbind(ari_mat))
#colnames(ari_df) <- c("comps",paste("comp", 1:ncol(ari_mat), sep = "_"))
colnames(ari_df) <- c("comps", 1:17)
ari_dat <- melt(ari_df, id.vars = 1)
# create a thresholded df for plot labels
ari_thr <- ari_dat %>%
  filter(., value > 0.15) %>%
  rename(., value_thr = value)
# join data frame where less the thr vlaues are now NA's
ari_dat_1 <- full_join(ari_dat, ari_thr)

# create heat map of ARI parcel values #
ggplot(ari_dat_1, aes(x=comps, y=variable)) +
  geom_tile(aes(fill = value)) + 
  geom_text(aes(label = round(value_thr, 2))) +
  scale_fill_viridis_b(option = "plasma") + # viridis or magma
  labs(x = "Chimpanzee Parcel Number", 
       y = "IXI Parcel Number", 
        fill = "ARI") +
  theme_classic(base_size = 20) +
  theme(line = element_blank())
## OUTPUT 1: Heatmap matrix of parcel-wise ARI similarity ###
ggsave(paste(path_wd(), "data","IXI_n480_chimp_n189_TPM03_sing_rank17_ari.png", 
             sep = "/"))  

#### Create ARI brain plot by using max ARI for each parcel & plot of IXI 17 ####

# row-wise max values represent the max ari for each IXI 17-factor parcel
human_max <- apply(ari_mat, 1, max)

# create human img vector volume #
human_vol <- c(img_data(human_img))
# create volume index #
human_ind <- human_vol > 0
# create GM mask human image #
human_GM <- human_vol[human_ind]
# create output human volume for ARI image #
human_out_GM <- human_GM

# loop over parcel numbers and change to matched numbers with IXI solution #
for (i in 1:length(human_max)) {
  
  # index for chimp in mni space #
  comp_ind <- human_GM == i

  # input ARI values for each parcel #
  human_out_GM[comp_ind] <- human_max[i]

}

# Output 2: Parcel-wise ARI plotted on IXI 17-factor solution #
# name of image #
out_name_ari <- paste("IXI_chimp_17C_parcel_ari_MNI", sep = "")

#out_vol_mni <- chimp_vol  #chimp_vol MNI space
human_vol[human_ind] <- human_out_GM
vol_2_img(vol_vec = human_vol, img_info = human_img, location = human_path,
          img_name = out_name_ari)
