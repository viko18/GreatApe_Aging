### utility script for OPNMF post-hoc analysis ####
# Contains functions for commonly used processes #
# S.Vickery 08.2021 #
# FUNCTION 1: Use a parcellation to take the mean of the values of another 
# image/s at each parcel/component #


parcel_avg <- function(parc, img, img_vol = TRUE) {
  require("neurobase")
  require("oro.nifti")
  ### NEED to add checks that imput is an nifti and that the dimensions are the
  ### same !!!
  ### Also add proper function commnets ###
  # read and vectorise parcellation
  #parc_img <- readnii(parc)
  ##### NEED to check for NAN's in image ####
  parc_vol <- c(img_data(parc))
  
  # No. of components in the parcellation #
  num_comps <- length(unique(parc_vol))-1
  
  # read and vectorise image to be masked and mean
  #input_img <- readnii(img)
  input_img_vol <- c(img_data(img))
  
  # output vol to be changed through for loop
  out_vol <- parc_vol
  
  # an empty vector for comp avg values #
  out_avg <-  rep(NA, num_comps)
  
  # create mask for each comp and take mean value of mask 
  for (i in 1:num_comps) {
    
    comp_ind <- parc_vol == i
    if (img_vol) {
      out_vol[comp_ind] <- mean(input_img_vol[comp_ind])
    } else {
      out_avg[i] <- mean(input_img_vol[comp_ind])
    }
    #out_vol[comp_ind] <- mean(input_img_vol[comp_ind])
    #out_avg[i] <- mean(input_img_vol[comp_ind])
    
  }
  # output a vector where the comp values have been changed to an avg of the 
  # input image which can then be used to create a nifti image or conduct further
  # analysis #
  if (img_vol) {
    return(out_vol)
  } else {
    return(out_avg)
  }
 
}


vol_2_img <- function(vol_vec, img_info, img_name, location) {
  require("neurobase")
  require("oro.nifti")
  ### need to check that vol data is the same size as img_info
  # create array to be written into a nifti
  out_arr <- array(vol_vec, dim = dim(img_info)) 
  # copy nifti header info for writing out #
  vol_nifti <- copyNIfTIHeader(img = img_info, arr = out_arr) 
  # create different filnames and write out nifti to directory #
  fil_name <- img_name
  # wriet out nifti to location with filename
  writenii(vol_nifti, filename = paste(location, fil_name, sep = "/"))
}


# labels from cluster A will be matched on the labels from cluster B
# function that takes two cluster vectors and matches the cluster numbers 
# this function was directly copied from 
# https://things-about-r.tumblr.com/post/36087795708/matching-clustering-solutions-using-the-hungarian
minWeightBipartiteMatching <- function(clusteringA, clusteringB) {
  require(clue)
  idsA <- unique(clusteringA)  # distinct cluster ids in a
  idsB <- unique(clusteringB)  # distinct cluster ids in b
  nA <- length(clusteringA)  # number of instances in a
  nB <- length(clusteringB)  # number of instances in b
  if (length(idsA) != length(idsB) || nA != nB) {
    stop("number of cluster or number of instances do not match")
  }
  
  nC <- length(idsA)
  tupel <- c(1:nA)
  
  # computing the distance matrix
  assignmentMatrix <- matrix(rep(-1, nC * nC), nrow = nC)
  for (i in 1:nC) {
    tupelClusterI <- tupel[clusteringA == i]
    solRowI <- sapply(1:nC, function(i, clusterIDsB, tupelA_I) {
      nA_I <- length(tupelA_I)  # number of elements in cluster I
      tupelB_I <- tupel[clusterIDsB == i]
      nB_I <- length(tupelB_I)
      nTupelIntersect <- length(intersect(tupelA_I, tupelB_I))
      return((nA_I - nTupelIntersect) + (nB_I - nTupelIntersect))
    }, clusteringB, tupelClusterI)
    assignmentMatrix[i, ] <- solRowI
  }
  
  # optimization
  result <- solve_LSAP(assignmentMatrix, maximum = FALSE)
  attr(result, "assignmentMatrix") <- assignmentMatrix
  return(result)
}

# compares similarity of clusters between two parcellations #
parc_sim_ARI <- function(parc1, parc2, GM_mask){
  library("oro.nifti") # to read in nifti's
  library("neurobase") # read in nifti's and create data 
  library("aricode")  # determine adjusted Rank Index of cluster similarity
  
  # GM mask for index #
  mask_ind <- c(img_data(GM_mask > 0))
  
  # masked vector of parcellation values
  parc1_dat <- c(img_data(parc1))[mask_ind]
  parc2_dat <- c(img_data(parc2))[mask_ind]
  
  sim <- ARI(parc1_dat, parc2_dat)
  return(sim)
}

