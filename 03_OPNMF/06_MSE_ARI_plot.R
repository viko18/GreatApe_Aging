#### create a single plot for the 3 samples MSE change with 30 bootstraps ####
wd <- "~/projects/chimp_human_opnmf/"
setwd(wd)

# load in libraries needed for script #
# need to install pacman if not already installed 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, ggplot2, fs, neurobase, oro.nifti, reshape2, purrr, 
               tidyr, tibble, readr)

# paths to the boot diff daat from each sample #
chimp_path <- paste(path_wd(), "data", "chimpanzee", "bootstraps", sep = "/")
ixi_path <- paste(path_wd(), "data", "IXI", "bootstraps", sep = "/")

# list bootstrap output files #
# multiple files for the same rank due to high compute time #
chimp_fils <- list.files(path = chimp_path)
ixi_fils <- list.files(path = ixi_path)

# empty list for bootstrap mse data to calculate change #
chimp_mse <- vector(mode = "list", length = length(chimp_fils))
# empty vector for bootstrap runs rank number #
chimp_ranks <- vector(length = length(chimp_fils))
for (i  in 1:length(chimp_fils)) {
  
  # read bootstrapped output files #
  c_dat <- read_rds(file = paste(chimp_path, chimp_fils[i], sep = "/"))
  
  # add rank for plotting and organising different bootstrap runs #
  chimp_ranks[i] <- c_dat$rank
  
  # extract mse of bootstrapping run #
  chimp_mse[[i]] <- c_dat$mse[[1]][["orig"]]
  
}

# empty list for bootstrap mse data to calculate change #
ixi_mse <- vector(mode = "list", length = length(ixi_fils))
# empty vector for bootstrap runs rank number #
ixi_ranks <- vector(length = length(ixi_fils))
for (x  in 1:length(ixi_fils)) {
  
  # read bootstrapped output files #
  h_dat <- read_rds(file = paste(ixi_path, ixi_fils[x], sep = "/"))
  
  # add rank for plotting and organizing different bootstrap runs #
  ixi_ranks[x] <- h_dat$rank
  
  # extract mse of bootstrapping run #
  ixi_mse[[x]] <- h_dat$mse[[1]][["orig"]]
  
}

## Create nested data.frame containing chimp and human data ##

# chimp boot nested tibble #
chimp_boot_tib <- tibble(ranks = chimp_ranks,
                         mse = chimp_mse,
                         cohort = as.factor("Chimpanzee")) %>%
  # as multiple runs of the same rank need to join all mse values
  group_by(ranks) %>%
  # create a nested col with all bootstraps per rank
  nest(mse_data = mse) %>%
  arrange(ranks) %>%
  # unlist them into one list with 100 entries #
  mutate(mse_data = map(mse_data, ~unlist(.x)))
chimp_boot_tib

# human boot nested tibble #
ixi_boot_tib <- tibble(ranks = ixi_ranks,
                       mse = ixi_mse,
                       cohort = as.factor("Human")) %>%
  # as multiple runs of the same rank need to join all mse values
  group_by(ranks) %>%
  # create a nested col with all bootstraps per rank
  nest(mse_data = mse) %>%
  arrange(ranks) %>%
  # unlist them into one list with 100 entries #
  mutate(mse_data = map(mse_data, ~unlist(.x)))
ixi_boot_tib

# calculate the difference in ranks mse of each bootstrap #
# wanted to use lag() but run into problems with nest column so will #
# just loop through the rows #

# chimpanzees #
chimp_mse_diff <- vector(mode = "list", length = nrow(chimp_boot_tib)-1)
chimp_mse_diff_mean <- vector(length = length(chimp_mse_diff))
chimp_mse_diff_sd <- vector(length = length(chimp_mse_diff))

# Humans #
ixi_mse_diff <- vector(mode = "list", length = nrow(ixi_boot_tib)-1)
ixi_mse_diff_mean <- vector(length = length(ixi_mse_diff))
ixi_mse_diff_sd <- vector(length = length(ixi_mse_diff))

for (r in 1:length(chimp_mse_diff)) {
  
  # difference mse lists of increasing rank granularity #
  chimp_mse_diff[[r]] <- chimp_boot_tib$mse_data[[r+1]] - chimp_boot_tib$mse_data[[r]]
  ixi_mse_diff[[r]] <- ixi_boot_tib$mse_data[[r+1]] - ixi_boot_tib$mse_data[[r]]
  
  # mean and sd of mse diff #
  # chimp #
  chimp_mse_diff_mean[r] <- mean(chimp_boot_tib$mse_data[[r+1]] - chimp_boot_tib$mse_data[[r]])
  chimp_mse_diff_sd[r] <- sd(chimp_boot_tib$mse_data[[r+1]] - chimp_boot_tib$mse_data[[r]])
  # human #
  ixi_mse_diff_mean[r] <- mean(ixi_boot_tib$mse_data[[r+1]] - ixi_boot_tib$mse_data[[r]])
  ixi_mse_diff_sd[r] <- sd(ixi_boot_tib$mse_data[[r+1]] - ixi_boot_tib$mse_data[[r]])
  
}

# create df for plotting change in mse #

mse_diff_df <- rbind(chimp_boot_tib, ixi_boot_tib) %>%
  select(-mse_data) %>%
  # create empty column for mean mse, sd and ari data #
  mutate(mse_ari_dat = NA,
         sd = NA) 

# input mean and sd value #
# there is no difference value for rank 2 but there is an ARI #
# very hacky !! #
# chimp #
mse_diff_df$mse_ari_dat[2:39] <- chimp_mse_diff_mean
mse_diff_df$sd[2:39] <- chimp_mse_diff_sd
# human #
mse_diff_df$mse_ari_dat[41:78] <- ixi_mse_diff_mean
mse_diff_df$sd[41:78] <- ixi_mse_diff_sd

# ARI INPUT #
ari_dat <- read_rds(file = paste(path_wd(), "outputs", 
                                 "Chimp_TPM03_2_IXI_ARI.rds", sep = "/"))

# change col names to match mse data #
colnames(ari_dat) <- c("ranks", "cohort", "mse_ari_dat")
# add sd column to match mse results with NAs
ari_dat$sd <- NA 
# add manipulation for secondary axis #
ari_dat_sec <- ari_dat %>%
  mutate(mse_ari_dat = map_dbl(mse_ari_dat, ~ (.x - 0.4) / 0.1))
# join the ari and mse data for plotting #
mse_ari <- full_join(ari_dat_sec, mse_diff_df)

# change factor levels to match other figures #
mse_ari$cohort <- factor(mse_ari$cohort, 
                         levels = c("Chimpanzee", "Human", "ARI_IXI_Chimp"))
# rename the factor levels for better labels in plot #
levels(mse_ari$cohort) <- c("Chimpanzee", "Human", "ARI")

# plot #
mse_diff_plot <- ggplot(mse_ari, aes(x = ranks, y = mse_ari_dat, color = cohort,
                                     fill = cohort)) +
  geom_ribbon(aes(ymin=mse_ari_dat-sd, ymax=mse_ari_dat+sd), alpha=0.3, 
              color = NA) + # creates cloud of +- sd
  geom_line(size = 1) +
  geom_point(aes(shape = cohort), size = 3) +
  scale_shape_manual(values = c(15, 16, 18)) +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2") +
    scale_x_continuous(limits = c(2,40),breaks = seq(2, 40, by = 2)) +
  scale_y_continuous(limits = c(-4,0), breaks = seq(-4, 0, by = 0.5), 
                     name = "Reconstruction Error Change",
                     sec.axis = sec_axis(~ (. *0.1) + 0.4, name = "Adjusted Rand Index")) +
  geom_vline(xintercept = c(17), color = "grey", linetype = "dashed", size = 1) +
  labs(x = "OPNMF Granularity", y = "Reconstruction Error Change") + 
  theme_classic(base_size = 25) +
  theme(legend.title = element_blank(), legend.position = c(0.7, 0.2)) 
  
mse_diff_plot 

ggsave(paste(path_wd(), "outputs", 
             "Chimp_IXI_MSE_ARI_R2_40_plot.png", sep = "/"))

