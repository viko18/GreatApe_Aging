#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
### Analysis of interspecies deformation and aging utilising OPNMF structural 
### covariance regions
### 5 INPUTS: 
### ARG_1 - Working directory (wd) where relative paths can be used to find files 
### ARG_2 - Cohort investigated
### ARG_3 - Parcellation Image used for analyses 
### ARG_4 - Deformation field (Inter-species) Nifti relaltive path from wd
### ARG_5 - name of phenotype meta data with subj names, Age, Sex, Scanner, TIV

## arg1 working dir ##
wd <- args[1] # e.g. "~/projects/chimp_human_opnmf/"   
setwd(wd)

# load in libraries needed for script #
# need to install pacman if not already installed 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(oro.nifti, neurobase, fs, ggplot2, dplyr, tidyr, reshape2, readr,
               broom, tibble, MASS, sfsmisc)
### A utility script needs to be in wd/code which contains helper functions
# source the utility script for helper functions #
source(file = paste(path_wd(), "code", "OPNMF_util.R", sep = "/"))

### 6 OUTPUTS:
### all output files from script will be written in a created wd/outputs dir
output_path <- paste(path_wd(), "outputs", sep = "/") # output dir
# from fs creates dir but ignores if already exists #
dir_create(path = output_path) 
### OUTPUT 1 - Meta data of sample with comp mean grey matter vol (csv)
### OUTPUT 2 - output statistics from component wise age regression (csv)
### OUTPUT 3 - T-statistic from age reg projected onto brain (nifti)
### OUTPUT 4 - ONLY significant FWE T-statistic from age reg projected onto brain (nifti)
### OUTPUT 5 - Average deformation per parcellation component image (nifti)
### OUTPUT 6 - deformation & T-statistic data fro post-hoc comparison (csv)
### OUTPUT 7 - Z scored parcellation expanion map (nifti)


#### Part 1: Read in input files for script ####

## Cohort Name ##
cohort <- args[2]

# parcellation for masking and analysis #
## arg2 input parcellation ##
parc_fil <- args[3]

parc_path <- paste(path_wd(), "data", cohort, "opnmf_parc", 
                 parc_fil, sep = "/")

parc_name <- paste(sub(pattern = ".nii.gz", replacement = "\\1", 
                      basename(parc_path)), sep = "") 

print(paste0("Read in parcellation image ", parc_path))
opnmf_parc <- readnii(parc_fil)
print("DONE!")

# deformation image #
## arg 3 input deformation field ##
def_name <- args[4] # Name of cross-species expansion map  
# e.g. JunaChimp_expansionMNI_3mm.nii.gz# 
def_path <- paste(path_wd(), "data", "expansion_maps",
                  def_name, sep = "/")
print(paste0("Read in Deformation image ", def_name))
def_img <- readnii(def_path)
print("DONE!")

# dir containing the sample for analysis - IXI, chimp, or eNKI #
## preprocessed images need to be put int /wd/data/$cohort/mwp1 
GM_img_dir <- paste(path_wd(), "data", cohort, "mwp1", sep = "/")

# read in meta data from sample e.g. age, sex, subj names #
## arg 5 .csv file containing meta data ##
meta_dat_name <- args[5] # e.g. IXI_n304_U58_meta.csv
meta_dat_path <- paste(path_wd(), "data", cohort, 
                       meta_dat_name, sep = "/")

print(paste0("Read in Meta Data csv ", meta_dat_name))
GM_img_meta <- read_csv(file = meta_dat_path)
print("DONE!")

#### Part 2: Parcellation AVG GMV of sample ####
# Number of components or parcels in parcellation #
num_comps <- length(unique(c(img_data(opnmf_parc))))-1
# convert characters to factros for easier handling #
GM_img_meta <- mutate(GM_img_meta, across(where(is.character),as.factor))

comp_GM_mat <- matrix(data = NA, nrow = nrow(GM_img_meta), # No. Subjects
                      ncol = num_comps) # No. Comps
print("starting GM parcel-wise extraction")

for (subj in 1:nrow(comp_GM_mat)) {
  # mwp1 nifti #
  mwp1_img <- readnii(paste(GM_img_dir, 
                            paste("mwp1", 
                                  c(as.character(GM_img_meta$Subject[subj])), sep = ""),
                            sep = "/"))
  comp_GM_mat[subj,] <- parcel_avg(parc=opnmf_parc, img=mwp1_img, img_vol=FALSE)
}
print("Extraction finished!")
# create a data frame to write out as csv file #
comp_df <- data.frame(GM_img_meta, Comp = comp_GM_mat)
# name of output csv file #
out_csv_name <- paste(sub(pattern = ".csv", replacement = "\\1", 
                    basename(meta_dat_name)), "_Rank_", as.character(num_comps),
                    ".csv", sep = "")

## OUTPUT 1: meta data and mean GMV for each component
print(paste0("Write parcel-wise GM data csv ", out_csv_name, 
             " here: ", output_path))
write.csv(comp_df, row.names = FALSE , 
          file = paste(output_path, out_csv_name, sep = "/"))
print("DONE!")

#### Part 3: parcellation component GMV age regression ####

# select variables of interest and conduct a linear model for each comp #
print("Conduct aging regression model")
lm_Comp_age <- dplyr::select(comp_df, Age, Sex, Scanner, TIV, contains("Comp.")) %>%
  melt(., id.vars = c("Age", "Sex", "Scanner", "TIV"), na.rm = TRUE) %>%
  group_by(variable) %>%
  do(tidy(lm(value ~ Age + TIV + Sex + Scanner, data=.)))
print("DONE!")

# extract only age effect #
Tstats_comp_age <- filter(lm_Comp_age, term == "Age")

# conduct post-hoc multiple comparison correction #
Tstats_comp_age$FWE <- p.adjust(Tstats_comp_age$p.value, method = "holm")
Tstats_comp_age$BONF <- p.adjust(Tstats_comp_age$p.value, method = "bonferroni")

# likely a better way to turn non-sig (<= 0.05) folllowing multiple comparison
# correction to zero and the rest to values of statistic column than this 
# two step indexing but this still works
# index sig values
sig_idx <- Tstats_comp_age$FWE <= 0.05
# first create zero column to replace only sig values
Tstats_comp_age$stat_sig <- 0.00001 # small value for better surf projection 
# replace sig values with statistic col values
Tstats_comp_age$stat_sig[sig_idx] <- Tstats_comp_age$statistic[sig_idx]

# name of output t-stat csv file #
Tstat_name <- paste(parc_name, "_Age_Tstats_n", nrow(comp_df), ".csv", sep = "") 

## OUTPUT 2: Component wise age regression statistics ##
print(paste0("Write age regression model csv file ", Tstat_name, 
             " here: ", output_path))
write.csv(Tstats_comp_age, row.names = FALSE, 
          file = paste(output_path, Tstat_name, sep = "/"))
print("DONE!")

# write out T stat parc brain nifti #
age_t_stat <- abs(c(Tstats_comp_age$statistic)) # make positive for easier plotting
age_t_stat_sig <- abs(c(Tstats_comp_age$stat_sig))
# parc volume vector #
parc_vol <- c(img_data(opnmf_parc))

# extra volume used for manipulation and writing #
out_vol <- parc_vol
out_vol_sig <- parc_vol

# change value of parcellation to age regression T-statistic #
print("Insert age effect to appropriate OPNMF factor")
for (i in 1:(length(unique(parc_vol))-1)) {
  
  comp_ind <- parc_vol == i # index comp number
  out_vol[comp_ind] <- age_t_stat[i] # change comp number in vol vector to t-stat
  out_vol_sig[comp_ind] <- age_t_stat_sig[i] # change comp number in vol vector to t-stat sig
}
print("DONE!")
# output dir & output image name #
Tstat_img_name <- paste(parc_name, "_Age_Tstats_n", nrow(comp_df), sep = "") 
Tstat_img_sig_name <- paste(parc_name, "_Age_Tstats_FWE_n", nrow(comp_df), sep = "") 

## OUTPUT 3 & 4: T-statistic brain projection of parcellation Sig and total ##
print(paste0("Write age effect Tstat image ", Tstat_img_name, " & ", 
             Tstat_img_sig_name, " here: ", output_path))

vol_2_img(vol_vec =  out_vol, img_info =  opnmf_parc, 
          img_name =  Tstat_img_name, location =  output_path)
vol_2_img(vol_vec =  out_vol_sig, img_info =  opnmf_parc, 
          img_name =  Tstat_img_sig_name, location =  output_path)

print("DONE!")

#### Part 4: Deformation GM Aging decline correlation ####

# create the def avg parcellation vol data to write out #

parc_def <- parcel_avg(parc = opnmf_parc, img = def_img, img_vol = TRUE)

# write out def parc #
## Output 5: Average deformation parcellation image ##
def_parc_name <- paste(parc_name, sub(pattern = ".nii.gz", replacement = "\\1",
                       basename(def_name)), sep = "_")

print(paste0("Write OPNMF deformation image ", def_parc_name, 
             " here: ", output_path))
vol_2_img(vol_vec =  parc_def, img_info =  opnmf_parc, img_name = def_parc_name, 
          location =  output_path)
print("DONE!")

# vector of deformation avg in each parcel #

def_dat <- parcel_avg(parc = opnmf_parc, img = def_img, img_vol = FALSE)

print("Create csv file with aging and deformaiton data")
# df with T-stat and def for each parcel & zscore for easier plotting #
age_def_df <- dplyr::select(Tstats_comp_age, variable, statistic) %>%
  #mutate(statistic = abs(statistic)) %>%
  add_column(., def_dat) %>% 
  as_tibble() %>% # must add or zscore cols are NA's not sure why?? # 
  mutate(
    zscore_def = (def_dat - mean(def_dat)) / sd(def_dat, na.rm = T),
    zscore_age = (statistic - mean(statistic)) / sd(statistic)
  )
print("DONE!")

### OUTPUT 6 - def - age table for post-hoc analysis 
out_age_def_name <- paste(sub(pattern = ".csv", replacement = "\\1", 
                              basename(meta_dat_name)), "_Rank_", 
                          as.character(num_comps), def_parc_name,
                          ".csv", sep = "")
print(paste0("Write aging and deformation csv file ", out_age_def_name,
             " here: ", output_path))
write.csv(age_def_df, row.names = FALSE,
          file = paste(output_path, out_age_def_name, sep="/"))
print("DONE!")

# write a deformation Zscore image #

# extra volume used for manipulation and writing #
out_vol_def <- parc_vol

# change value of parcellation to age regression T-statistic #
print("Insert Zscore deformation to appropriate OPNMF factor")
for (j in 1:(length(unique(parc_vol))-1)) {
  
  comp_ind <- parc_vol == j # index comp number
  out_vol_def[comp_ind] <- age_def_df$zscore_def[j] # change comp number in vol vector to t-stat
  
}
print("DONE!")

## Output 7: Average deformation Zscore parcellation image ##
def_parc_name_Z <- paste(parc_name, sub(pattern = ".nii.gz", replacement = "\\1",
                                        basename(def_name)), "Zscore", sep = "_")

print(paste0("Write OPNMF Zscore deformation image ", def_parc_name_Z, 
             " here: ", output_path))
vol_2_img(vol_vec =  out_vol_def, img_info =  opnmf_parc, img_name = def_parc_name_Z, 
          location =  output_path)
print("DONE!")

# print age and def tibble data to check if correct or makes sense #
age_def_df
