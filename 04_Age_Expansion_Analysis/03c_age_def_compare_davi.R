wd <- "~/projects/chimp_human_opnmf/" 
setwd(wd)
# load in libraries needed for script #
# need to install pacman if not already installed 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(fs, ggplot2, dplyr, tidyr, reshape2, readr,
               broom, tibble, MASS, sfsmisc, cocor, oro.nifti, neurobase, ggrepel)

#### INPUTS ####
# path to data - which is the outputs folder from opnmf_age_def.R script #
dat_path <- paste(path_wd(), "outputs", sep = "/")

## INPUT 1: chimp - baboon (haiko) age def OPNMF csv ##
chimp_B_dat <- read_csv(file = paste(dat_path, 
                                   "Chimp_meta_QC_u50_n189_Rank_110Davi130_2mm_cortex.nii_Haiko2Juna_expansion.csv",
                                   sep = "/")) %>%
  mutate(variable = as.factor(1:nrow(.))) %>% #
  add_column(Species = as.factor("Chimpanzee(Baboon)")) %>%
  rename(factor = variable)

## INPUT 2: chimp - Macaque (MeanMacaque) age def OPNMF csv ##
chimp_M_dat <- read_csv(file = paste(dat_path, 
                                     "Chimp_meta_QC_u50_n189_Rank_110Davi130_2mm_cortex.nii_MeanMacaque2Juna_expansion.csv",
                                     sep = "/")) %>%
  mutate(variable = as.factor(1:nrow(.))) %>% # 
  add_column(Species = as.factor("Chimpanzee(Macaque)")) %>%
  rename(factor = variable)


## INPUT 3: Human (IXI) - Chimp age def OPNMF csv ##
human_dat <- read_csv(file = paste(dat_path,
                      "IXI_n304_U58_meta_Rank_110Davi130_MNI_3mm_cortex_Juna2MNI_expansion.csv",
                      sep = "/")) %>%
  mutate(variable = as.factor(1:nrow(.))) %>% 
  add_column(Species = as.factor("Human")) %>%
  rename(factor = variable)

# df with both chimp data 
chimp_MB_dat <- dplyr::full_join(chimp_B_dat, chimp_M_dat) 

#### Compare aging and expansion using permutation testing #####
nperm <- 10e4
### Should turn perm test into a simple function ###

## Species Independently ##
## HUMAN ##

# empty list for human perm correlation results #
perm_res_H <- vector("list", nperm)
set.seed(47)
for (perm_H in 1:nperm) {
  
  perm_res_H[[perm_H]] <- cor(x=sample(human_dat$statistic), y=human_dat$zscore_def, 
                              method = "pearson")
}

H_cor <- cor(human_dat$statistic, human_dat$zscore_def)

perm_res_df_H <- data.frame(perm_R = unlist(perm_res_H))

h_p_val <- sum(unlist(perm_res_H) <= H_cor ) / nperm

ggplot(perm_res_df_H, aes(perm_R)) + 
  geom_density(color="#CC79A7",fill="#CC79A7") +
  geom_vline(xintercept = H_cor, lwd=2, lty=2, color = "grey") +
  scale_x_continuous(limits = c(-1,1), breaks = seq(-1,1,0.5)) +
  labs(x = "Pearson's R",
       y = "Count") + 
  theme_classic(base_size = 20) +
  annotate("text", x=-0.75, y=c(3, 2.5), color = "#CC79A7", 
           label =  c(paste("italic(r) == ", round(H_cor, 2), sep=""),
                      paste("italic(p) == ", sprintf(round(h_p_val,7), fmt = "%#.7f"), 
                            sep = "")), 
           size=8, parse=TRUE) 

ggsave(filename = paste(dat_path, 
                        "IXI_N480_J2M_Davi130_Cortex_R_perm_10e4_IXI304.png",
                        sep = "/"))

## CHIMPNAZEE ##

# Baboon(Haiko) template -> Juna expansion #

perm_res_C_B <- vector("list", nperm)
set.seed(47)
for (perm_C in 1:nperm) {
  
  perm_res_C_B[[perm_C]] <- cor(x=chimp_B_dat$statistic, y=sample(chimp_B_dat$zscore_def), 
                              method = "pearson")
}
# correlation between aging and baboon - chimp expansion of across OPNMF factors #
C_B_cor <- cor(chimp_B_dat$statistic, chimp_B_dat$zscore_def)
# mnake a df fr easier ploting #
perm_res_df_C_B <- data.frame(perm_R = unlist(perm_res_C_B))
# gather p-value
C_B_pval <- sum(unlist(perm_res_C_B) >= C_B_cor ) / nperm

ggplot(perm_res_df_C_B, aes(perm_R)) + 
  geom_density(color= "#E1BE6A", fill= "#E1BE6A") +
  geom_vline(xintercept = C_B_cor, lwd=2, lty=2, color = "grey") +
  scale_x_continuous(limits = c(-1,1), breaks = seq(-1,1,0.5)) +
  labs(x = "Pearson's R",
       y = "Count") + 
  theme_classic(base_size = 20) +
  annotate("text", x=0.75, y=c(3, 2.5), color = "#E1BE6A",
           label =  c(paste("italic(r) == ", round(C_B_cor, 3), sep=""),
                      paste("italic(p) == ", sprintf(round(C_B_pval,2), fmt = "%#.4f"), 
                            sep = "")), 
           size=8, parse=TRUE) 

ggsave(filename = paste(dat_path, 
                        "Chimp_N189_H2J_davi130_Cortex_R_perm_10e4.png",
                        sep = "/"))

# Macaque(MeanMacaque) template -> Juna expansion #

perm_res_C_M <- vector("list", nperm)
set.seed(47)
for (perm_C in 1:nperm) {
  
  perm_res_C_M[[perm_C]] <- cor(x=chimp_M_dat$statistic, y=sample(chimp_M_dat$zscore_def), 
                                method = "pearson")
}
# correlation between aging and baboon - chimp expansion of across OPNMF factors #
C_M_cor <- cor(chimp_M_dat$statistic, chimp_M_dat$zscore_def)
# mnake a df fr easier ploting #
perm_res_df_C_M <- data.frame(perm_R = unlist(perm_res_C_M))
# gather p-value
C_M_pval <- sum(unlist(perm_res_C_M) >= C_M_cor ) / nperm

ggplot(perm_res_df_C_M, aes(perm_R)) + 
  geom_density(color= "#56B4E9", fill= "#56B4E9") +
  geom_vline(xintercept = C_M_cor, lwd=2, lty=2, color = "grey") +
  scale_x_continuous(limits = c(-1,1), breaks = seq(-1,1,0.5)) +
  labs(x = "Pearson's R",
       y = "Count") + 
  theme_classic(base_size = 20) +
  annotate("text", x=0.75, y=c(3, 2.5), color = "#56B4E9",
           label =  c(paste("italic(r) == ", round(C_M_cor, 2), sep=""),
                      paste("italic(p) == ", sprintf(round(C_M_pval,2), fmt = "%#.4f"), 
                            sep = "")), 
           size=8, parse=TRUE) 

ggsave(filename = paste(dat_path, 
                        "Chimp_N189_MM2J_davi130_Cortex_R_perm_10e4.png",
                        sep = "/"))

#### Plot the comparison of aging and expansion ####

# HUMAN PLOT #
#labels_select <- c(5, 5+17, 3, 3+17, 4, 4+17, 16, 16+17, 15, 15+17, 
#                   8, 8+17, 13, 13+17, 17, 17+17)
# create a col for labels in plot #
#human_dat$labels_sel <- as.character(human_dat$factor)

#human_dat$labels_sel[-labels_select] <- ""


ggplot(human_dat, aes(x = statistic, y = zscore_def, color=Species)) +
  geom_point(size = 4.5) +
  scale_x_continuous(limits = c(-16, 3), breaks = seq(-16, 2, 2)) +
  scale_y_continuous(limits = c(-4, 4), breaks = seq(-4, 4, 1)) +
  geom_smooth(aes(fill = Species),formula = y ~ x, method = "rlm", size = 1.5, alpha = 0.3) +
  #geom_text_repel(size = 10, box.padding = 3, nudge_x = 0.5) +
  theme_bw() +
  scale_fill_manual(values = "#CC79A7") +
  scale_color_manual(values = "#CC79A7") + 
  labs(x = "Age - Gray Matter model (t-statistic)",
       y = "Cross-species Expansion (Z-scale)") + 
  theme_classic(base_size = 25) +
  theme(legend.position = "none") 


ggsave(filename = paste(dat_path, 
                        "IXI_n480_J2M_davi130_Cortex_exp_age_IXI304.png",
                        sep = "/"))

# Chimpanzee aging compared to both macaque and baboon expansion plot #

# create a col for labels in plot #
#chimp_MB_dat$labels_sel <- as.character(chimp_MB_dat$factor)

#chimp_MB_dat$labels_sel[-labels_select] <- ""

ggplot(chimp_MB_dat, aes(x = statistic, y = zscore_def, 
                                color=Species)) +
  geom_point(size = 4.5) +
  scale_x_continuous(limits = c(-8, 2), breaks = seq(-8, 2, 1)) +
  scale_y_continuous(limits = c(-3, 3), breaks = seq(-3, 3, 1)) +
  geom_smooth(aes(fill = Species),formula = y ~ x, method = "rlm", size = 1.5, alpha = 0.3) +
  #geom_text_repel(size = 10, box.padding = 1) +
  theme_bw() +
  scale_fill_manual(values = c("#E1BE6A", "#56B4E9")) +
  scale_color_manual(values = c("#E1BE6A", "#56B4E9")) + 
  labs(x = "Age - Gray Matter model (t-statistic)",
       y = "Cross-species Expansion (Z-scale)") + 
  theme_classic(base_size = 25) +
  theme(legend.position = "none") 

# save plot #
ggsave(filename = paste(dat_path, 
                        "Chimp_n189_H2J_M2J_davi130_Cortex_exp_age.png",
                        sep = "/"))
