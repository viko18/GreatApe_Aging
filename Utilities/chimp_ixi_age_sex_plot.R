# Create violin plots for the chimp and IXI whole sample meta data #
# to show age, sex, & scanner distribution #

wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

# load in libraries needed for script #
# need to install pacman if not already installed 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, ggplot2, dplyr, tidyr, readr, tibble, stringr)


#### Load meta data from csv files for both samples ####

### INPUT 1: Chimpanzee meta data csv ###
# chimp csv meta data #
chimp_path <- paste(path_wd(), "data", "chimp", sep = "/")
chimp_meta <- read_csv(file = paste(chimp_path, 
                                    "Chimp_meta_QC_u50_n189.csv",
                                    sep = "/"))
### INPUT 2: IXI meta data csv ###
# IXI csv meta data #
IXI_path <- paste(path_wd(), "data", "IXI", sep = "/")
IXI_meta <- read_csv(file = paste(IXI_path,
                                  "IXI_TIV_AGE.csv", sep = "/"))
# clean IXI meta data by removing NaN's, IOP sample, irrelevant data, 
# subject over 75 y/o to get the n=480 sample used for paper #

IXI_clean <- IXI_meta %>% 
  na.omit() %>%
  select(Site, Subject, TIV, GM, WM, CSF, WMH, IQR, 
         AGE, `SEX_ID (1=m, 2=f)`) %>%
  filter(Site %in% c("GUYS", "HH")) %>%
  filter(AGE < 75) %>%
  mutate(Site = str_replace_all(Site, c("GUYS" = "1.5T", "HH" = "3T"))) %>%
  rename(Scanner = Site, Age = AGE, Sex = `SEX_ID (1=m, 2=f)`) %>%
  mutate(Sex = str_replace_all(Sex, c("1" = "Male", "2" = "Female")))
  
### OUTPUT 1: clean IXI meta data (N=480) csv file ###
write_csv(IXI_clean, file = paste(IXI_path, "IXI_n480__U75_meta.csv", 
                                  sep = "/"))

### join df for easier plotting ###

# select columns that are needed for plotting  & add species column #
chimp_join <- chimp_meta %>% 
  select(Subject, Age, Sex, Scanner) %>%
  mutate(Species = "Chimpanzee")
IXI_join <- IXI_clean %>%
  select(Subject, Age, Sex, Scanner) %>%
  mutate(Species = "Human")

# combine samples #
total_meta <- rbind(chimp_join, IXI_join)

ggplot(data = total_meta, aes(x=Species, y=Age)) +
  geom_violin(aes(fill=Species), trim = FALSE) +
  geom_jitter(aes(shape=Scanner, color=Sex), width = 0.2, size = 2.5) +
  scale_fill_brewer(palette = "Pastel2") +
  scale_color_manual(values = c("#d01c8b", "#0571b0")) +
  scale_shape_manual(values = c(17, 19)) +
  theme_classic(base_size = 15)
### OUTPUT 2: Chimp & Human meta data violin plot ###
ggsave(filename = paste(path_wd(), "outputs", 
                        "chimp_IXI_meta_plot.png", sep = "/"), dpi = 400)

