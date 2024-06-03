
### match IXI sample to chimp under 41 sample ###
wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

library("readr")
library("ggplot2")
library("MASS")
library("dplyr")
library("fs")
library("stringr")
library("MatchIt")
library("optmatch")
library("rgenoud")
library("broom")
#library("emmeans") no package by this name

### INPUT 1: Chimpanzee meta data csv ###
# chimp csv meta data #
chimp_path<- path_wd("data", "chimp")

chimp_meta <- read_csv(path(chimp_path, "Chimp_meta_QC_n194.csv"))

### INPUT 2: IXI meta data csv ###
# IXI csv meta data #
ixi_path <- path_wd("data", "IXI")

IXI_meta <- read_csv(path(ixi_path, "IXI_TIV_AGE.csv"))

### Chimpanzee clean meta data set #####
# remove the very old (> 50) for parcelation to remove very large aging effects #
 
# clean up data & create same labels for the same data #
chimp_clean <- chimp_meta %>%
  select(Subject, Sex, Age, Scanner) %>%
  filter(Age <= 50) %>% # remove 5 very old chimps
  mutate(across(where(is.character), as.factor)) # convert char col to factors

# save data #
write_csv(chimp_clean, file = path(chimp_path, 
                                   "Chimp_meta_QC_u50_n189.csv"))

# clean IXI meta data by removing NaN's, IOP sample, irrelevant data, and
# subject over 75 y/o to get the n=480 sample used for paper. The >75 y/o
# are removed due to being very old and having large aging effects that are not
# present in chimpanzees #

IXI_clean <- IXI_meta %>% 
  na.omit() %>%
  select(Site, Subject, TIV, GM, WM, CSF, WMH, IQR, 
         AGE, `SEX_ID (1=m, 2=f)`) %>%
  filter(Site %in% c("GUYS", "HH")) %>%
  filter(AGE <= 75) %>%
  mutate(Site = str_replace_all(Site, c("GUYS" = "1.5T", "HH" = "3T"))) %>%
  rename(Scanner = Site, Age = AGE, Sex = `SEX_ID (1=m, 2=f)`) %>%
  mutate(
    Sex = str_replace_all(Sex, c("1" = "Male", "2" = "Female")),
    across(where(is.character), as.factor),
    Age = round(Age, 2)
    )

### OUTPUT 1: clean IXI meta data (N=480) csv file ###
write_csv(IXI_clean, file = path(ixi_path, "IXI_n480_u75_meta.csv"))

### join df for easier plotting ###

# select columns that are needed for plotting  & add species column #
chimp_join <- chimp_clean %>% 
  select(Subject, Age, Sex, Scanner) %>%
  mutate(Species = as.factor("Chimpanzee"))

IXI_join <- IXI_clean %>%
  select(Subject, Age, Sex, Scanner) %>%
  mutate(Species = as.factor("Human"))

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
                        "chimp_n189_IXI_n480_meta_plot.png", 
                        sep = "/"), 
       dpi = 400)

# match the chimp to human age using factor ~1.15 so chimp 50 = human 57.5 or 58 
# ref: https://www.biorxiv.org/content/10.1101/2020.08.06.240077v1
# max IXI age <= 58

IXI_u58_n304 <- IXI_clean %>%
  filter(Age <= 58)

# save data #
write_csv(IXI_u58_n304, file = path(ixi_path, "IXI_n304_U58_meta.csv"))

### create age, sex dsitribution of max age match chimp and IXI samples ####

set.seed(181) # to reproduce the jitter
total_meta %>%
  filter(Age <= 58) %>% # only IXI sample has age > 50 so this will only remove humans
  ggplot(aes(x=Species, y=Age)) +
  geom_violin(aes(fill=Species), trim = FALSE) +
  geom_jitter(aes(color=Sex), width = 0.2, size = 2.5) +
  scale_fill_brewer(palette = "Pastel2") +
  scale_color_manual(values = c("#d01c8b", "#0571b0")) +
  scale_shape_manual(values = c(17, 19)) +
  theme_classic(base_size = 15)

# save plot #
ggsave(filename = paste(path_wd(), "outputs", 
                        "chimp_n189_IXI_n304_meta_plot.png", 
                        sep = "/"), 
       dpi = 400)

# Match IXI sample to chimps (n189) by Age, Sex, & Scanner #

# chimp matching sample (n=189) #
chimp_match <- chimp_clean %>%
  mutate(
    Age = Age * 1.15,
    Species = 1 # add species column for matching after joining with IXI
    )

# IXI matching sample (n=480) #
IXI_match <- IXI_clean %>%
  select(Subject, Age, Sex, Scanner) %>%
  mutate(Species = 0) # add species column for matching after joining with chimp


# Join chimp and human sample for matching #
IXI_chimp_match_df <- rbind(IXI_match, chimp_match) 

# use matchit package to match chimp adjusted age to IXI 
# based on age, sex, & scanner
species_match <- matchit(Species ~ Scanner + Age + Sex, 
                         data = IXI_chimp_match_df, 
                         method = "optimal", ratio = 1)

# look at the matching improvement #
summary(species_match) 

# extract the IXI matched sample n=189 #
match_sample <- match.data(species_match)
ixi_match_ids <- match_sample %>%
  filter(Species == 0) %>%
  mutate(Subject = as.character(Subject)) %>%
  pull(Subject)

# create matched IXI sample df #
IXI_n189_matched <- IXI_clean %>%
  filter(Subject %in% ixi_match_ids)

# save data frame #
write_csv(IXI_n189_matched, file =  path(ixi_path, 
                                         "IXI_n189_matched_meta.csv"))

##### Total GM Volume age regression in IXI samples and chimp sample ######

# chimpanzee total GM volume age regression model #
# to account for differences in brain size GM will be expressed 
# as a percentage of TIV
 
chimp_lm_df <- chimp_meta %>%
  filter(Age <= 50) %>%
  select(Subject, Age, Sex, Scanner, GM, TIV) %>%
  mutate(
    GM_perc = GM / TIV * 100,
    across(where(is.character), as.factor)
  )

# chimp n189 total GM percentage regression model
chimp_lm_mod <- lm(GM_perc ~ Age + Sex + Scanner, data = chimp_lm_df)
chimp_lm_GM_mod <- lm(GM_perc ~ Age,data = chimp_lm_df)

# lm model output dataframe with all terms
chimp_lm_mod_df <- broom::tidy(chimp_lm_mod, conf.int = TRUE)

# whole model statistical outputs - used for labeling regression plots #
chimp_lm_mod_output <- glance(chimp_lm_mod)
chimp_lm_mod_GM_output <- glance(chimp_lm_GM_mod)

## create perc GM - age regression scatter plot with linear regression line 
## in chimps

chimp_lm_df %>%
  ggplot(aes(x = Age, y = GM_perc, color = Sex)) +
  geom_point() +
  scale_color_manual(values = c("#d01c8b", "#0571b0")) +
  geom_smooth(formula = y ~ x, color = "black", method = lm) +
  labs(x = "Age (years)",
       y = "% Gray matter of total intracranial volume") +
  #ylim(c(25, 55)) +
  scale_y_continuous(limits = c(25, 55), breaks = seq(25, 55, 5)) +
  annotate("text",
           x = 12, y = 32, 
           label = paste("r^2 ==",round(chimp_lm_mod_GM_output$r.squared, 2)),
           parse = TRUE, size = 6) +
  annotate("text",
           x = 12, y = 29, 
           label = paste("p = 1.63e-9"), # chimp_lm_mod_GM_output$p.value
           size = 6) +
  theme_classic(base_size = 15)

# save plot #
ggsave(filename = path_wd("outputs", "chimp_n189_age_total_GM_lm.png"),
       dpi = 400)

# IXI total GM volume age regression model #
# to account for differences in brain size GM will be expressed 
# as a percentage of TIV


### IXI total n480 ####
IXI_lm_n480_df <- IXI_clean %>%
  select(Subject, Age, Sex, Scanner, GM, TIV) %>%
  mutate(
    GM_perc = GM / TIV * 100,
    across(where(is.character), as.factor)
  )

# IXI n480 total GM percentage regression model
IXI_n480_lm_mod <- lm(GM_perc ~ Age + Sex + Scanner, data = IXI_lm_n480_df)
IXI_n480_lm_GM_mod <- lm(GM_perc ~ Age,data = IXI_lm_n480_df)

# lm model output dataframe with all terms
IXI_n480_lm_mod_df <- broom::tidy(IXI_n480_lm_mod, conf.int = TRUE)

# whole model statistical outputs - used for labeling regression plots #
IXI_n480_lm_mod_output <- glance(IXI_n480_lm_mod)
IXI_n480_lm_mod_GM_output <- glance(IXI_n480_lm_GM_mod)

## create perc GM - age regression scatter plot with linear regression line 
## in IXI n=480

IXI_lm_n480_df %>%
  ggplot(aes(x = Age, y = GM_perc, color = Sex)) +
  geom_point() +
  scale_color_manual(values = c("#d01c8b", "#0571b0")) +
  geom_smooth(formula = y ~ x, color = "black", method = lm) +
  labs(x = "Age (years)",
       y = "% Gray matter of total intracranial volume") +
  #ylim(c(30, 55)) +
  scale_y_continuous(limits = c(30, 52), breaks = seq(30, 50, 5)) +
  scale_x_continuous(limits = c(20, 75), breaks = seq(20, 75, 5)) +
  #xlim(c(20,75)) +
  annotate("text",
           x = 25, y = 37, 
           label = paste("r^2 ==",round(IXI_n480_lm_mod_GM_output$r.squared, 2)),
           parse = TRUE, size = 6) +
  annotate("text",
           x = 25, y = 35, 
           label = paste("p = 1.28e-100"), # IXI_n480_lm_mod_GM_output$p.value
           size = 6) +
  theme_classic(base_size = 15)

# save plot #
ggsave(filename = path_wd("outputs", "IXI_n480_age_total_GM_lm.png"),
       dpi = 400)

### IXI max age matched n304 ####
IXI_lm_n304_df <- IXI_u58_n304 %>%
  select(Subject, Age, Sex, Scanner, GM, TIV) %>%
  mutate(
    GM_perc = GM / TIV * 100,
    across(where(is.character), as.factor)
  )

# IXI n304 total GM percentage regression model
IXI_n304_lm_mod <- lm(GM_perc ~ Age + Sex + Scanner, data = IXI_lm_n304_df)
IXI_n304_lm_GM_mod <- lm(GM_perc ~ Age,data = IXI_lm_n304_df)

# lm model output dataframe with all terms
IXI_n304_lm_mod_df <- broom::tidy(IXI_n304_lm_mod, conf.int = TRUE)

# whole model statistical outputs - used for labeling regression plots #
IXI_n304_lm_mod_output <- glance(IXI_n304_lm_mod)
IXI_n304_lm_mod_GM_output <- glance(IXI_n304_lm_GM_mod)

## create perc GM - age regression scatter plot with linear regression line 
## in IXI n=304

IXI_lm_n304_df %>%
  ggplot(aes(x = Age, y = GM_perc, color = Sex)) +
  geom_point() +
  scale_color_manual(values = c("#d01c8b", "#0571b0")) +
  geom_smooth(formula = y ~ x, color = "black", method = lm) +
  labs(x = "Age (years)",
       y = "% Gray matter of total intracranial volume") +
  scale_y_continuous(limits = c(35, 52), breaks = seq(35, 50, 5)) +
  scale_x_continuous(limits = c(20, 60), breaks = seq(20, 60, 5)) +
  annotate("text",
           x = 25, y = 39, 
           label = paste("r^2 ==",round(IXI_n304_lm_mod_GM_output$r.squared, 2)),
           parse = TRUE, size = 6) +
  annotate("text",
           x = 25, y = 37, 
           label = paste("p = 9.65e-40"), # IXI_n304_lm_mod_GM_output$p.value
           size = 6) +
  theme_classic(base_size = 15)

# save plot #
ggsave(filename = path_wd("outputs", "IXI_n304_u58_age_total_GM_lm.png"),
       dpi = 400)

### IXI 1:1 matched n189 ####
IXI_lm_n189_df <- IXI_clean %>%
  filter(Subject %in% IXI_n189_matched$Subject) %>%
  select(Subject, Age, Sex, Scanner, GM, TIV) %>%
  mutate(
    GM_perc = GM / TIV * 100,
    across(where(is.character), as.factor)
  )

# IXI n189 total GM percentage regression model
IXI_n189_lm_mod <- lm(GM_perc ~ Age + Sex + Scanner, data = IXI_lm_n189_df)
IXI_n189_lm_GM_mod <- lm(GM_perc ~ Age,data = IXI_lm_n189_df)

# lm model output dataframe with all terms
IXI_n189_lm_mod_df <- broom::tidy(IXI_n189_lm_mod, conf.int = TRUE)

# whole model statistical outputs - used for labeling regression plots #
IXI_n189_lm_mod_output <- glance(IXI_n189_lm_mod)
IXI_n189_lm_mod_GM_output <- glance(IXI_n189_lm_GM_mod)

## create perc GM - age regression scatter plot with linear regression line 
## in IXI n=189

IXI_lm_n189_df %>%
  ggplot(aes(x = Age, y = GM_perc, color = Sex)) +
  geom_point() +
  scale_color_manual(values = c("#d01c8b", "#0571b0")) +
  geom_smooth(formula = y ~ x, color = "black", method = lm) +
  labs(x = "Age (years)",
       y = "% Gray matter of total intracranial volume") +
  scale_y_continuous(limits = c(35, 52), breaks = seq(35, 50, 5)) +
  scale_x_continuous(limits = c(20, 62), breaks = seq(20, 60, 5)) +
  annotate("text",
           x = 25, y = 39, 
           label = paste("r^2 ==",round(IXI_n189_lm_mod_GM_output$r.squared, 2)),
           parse = TRUE, size = 6) +
  annotate("text",
           x = 25, y = 37, 
           label = paste("p = 7.77e-18"), # IXI_n189_lm_mod_GM_output$p.value
           size = 6) +
  theme_classic(base_size = 15)

# save plot #
ggsave(filename = path_wd("outputs", "IXI_n189_matched_age_total_GM_lm.png"),
       dpi = 400)
