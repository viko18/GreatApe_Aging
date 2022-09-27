# create meta data csv fie for eNKI sample to conduct age_def_compare #

wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

# load in libraries needed for script #
# need to install pacman if not already installed 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, ggplot2, dplyr, tidyr, readr, tibble)

# dir with eNKI data inclusding meta data csv files #
meta_dir <- paste(path_wd(), "data", "eNKI", sep = "/")

# csv file with meta data from complete eNKI sample #
eNKI_meta_total <- read_csv(file = paste(meta_dir, "eNKI_meta.csv", sep = "/")) %>%
  filter(isPatient %in% 0) %>% # remove patients
  rename(Subject = participant_id, Sex = sex, Age = age) %>% # col name Subject to match other meta data files
  dplyr::select(Subject, Sex, Age) %>%
  distinct(Subject, .keep_all = TRUE) %>% # remove duplicates of subjects
  na.omit() # remove rows with any missing data

# csv file with meta data from CAT12 preprocessed images and Juelich atlas ROI's
# this represents the images we have preprocessed to be used #
eNKI_meta_CAT <- read_csv(file = paste(meta_dir, 
                                       "eNKI_cat12.8_1mm_rois_julichbrain.csv", sep = "/")) %>%
  dplyr::select(1:9) %>% # remove columns for roi atlas data
  mutate(Session = as.factor(Session)) %>%
  rename(Subject = SubjectID) %>% # col name Subject to match other meta data files
  distinct(Subject, .keep_all = TRUE) %>% # remove multiple scans
  na.omit() # remove rows with any missing data

# outliers for QC measures to remove poor quality images #
poor_NCR_2 <- mean(eNKI_meta_CAT$NCR) + (2 * sd(eNKI_meta_CAT$NCR)) 
poor_IQR_2 <- mean(eNKI_meta_CAT$IQR) + (2 * sd(eNKI_meta_CAT$IQR)) 
poor_ICR_2 <- mean(eNKI_meta_CAT$ICR) + (2 * sd(eNKI_meta_CAT$ICR)) 

# filter out poor images based on QC outliers #
eNKI_meta_CAT_QC <- eNKI_meta_CAT %>%
  filter(NCR <= poor_NCR_2) %>%
  filter(IQR <= poor_IQR_2) %>%
  filter(ICR <= poor_ICR_2)


# join with meta data csv to add age of subjects and remove young people #
# lower & upper age limit for filtering #
# lifespan sample #
age_min <- 0
age_max <- 90
eNKI_sample_total <- inner_join(eNKI_meta_CAT_QC, eNKI_meta_total, by = "Subject") %>%
  filter(Age >= age_min & Age <= age_max) # keep only adults

write_csv(eNKI_sample_total, file = paste(meta_dir, 
                                          paste0("eNKI_meta_QC_n", 
                                                 nrow(eNKI_sample_total), 
                                                 "_min", age_min, "_max", age_max,
                                                 ".csv"),
                                          sep = "/"))

