#!/bin/bash

##### FSL v5.0 #####
## Create expansion maps from baboon cross species registration using fslmaths ##
## This script should be run in code dir that is then the relative path = ../data/deformations/  
## from the deformation and T1 images. This can be changed by adapting $data_dir ##

## The inputs are the modulated jacobians species templates and the moduated templates ##

## The outputs are the cross species expansion maps that have been coregistered to the opnmf 
## parcellattion maps for each species to downsample them to 3mm for humans and 2mm for chimps ##

############## PATH to both data and script - can be changed #####################################

# prints the relative path to the script #
echo -e "script dir:\n$0"

# using relative paths creates te complete path to the dir and prints #
# from code dir with script go one up and then to Deformations where data is #
data_dir="$(dirname $(dirname $(realpath $0) ) )/data/expansion_maps"
echo -e "###Deformations Dir:###\n$data_dir\n"

##################################################################################################
############################## INPUTS ############################################################
##################################################################################################

################ Chimpanzee (Juna) to Human (MNI) inputs ######################################

# chimp (Juna) to human (MNI) template
juna2MNI_temp=${data_dir}/wmJunaChimp_brain.nii.gz
echo -e "###Chimp to human template location:###\n${juna2MNI_temp}\n"

# check if temp is in the right location
if [ ! -f "$juna2MNI_temp" ]; then
	echo -e "####ERROR####\n${juna2MNI_temp}\ndoesn't exist - check location\n"
fi

# chimp (Juna) to human (MNI) jacobian #
juna2MNI_jac=${data_dir}/wj_JunaChimp_brain.nii.gz
echo -e "###Chimp to human jacobian location:###\n${juna2MNI_jac}\n"

# check if jacobian is in the right location #
if [ ! -f "$juna2MNI_jac" ]; then
	echo -e "####ERROR####\n${juna2MNI_jac}\ndoesn't exist - check location\n"
fi

################ Baboon (Haiko) to Chimpanzee (Juna) inputs ###################################

# baboon (Haiko) to chimp (Juna) template
haiko2juna_temp=${data_dir}/wmsanlm_baboon_Haiko89_Asymmetric.Template_n89.nii.gz
echo -e "###Baboon to chimp template location:###\n${haiko2juna_temp}\n"

# check if temp is in the right location
if [ ! -f "$haiko2juna_temp" ]; then
	echo -e "####ERROR####\n${haiko2juna_temp}\ndoesn't exist - check location\n"
fi

# baboon (Haiko) to chimp (Juna) jacobian #
haiko2juna_jac=${data_dir}/wj_sanlm_baboon_Haiko89_Asymmetric.Template_n89.nii.gz
echo -e "###baboon to chimp jaconian location:###\n${haiko2juna_jac}\n"

# check if jacobian is in the right location #
if [ ! -f "$haiko2juna_jac" ]; then
	echo -e "####ERROR####\n${haiko2juna_jac}\n doesn't exist - check location\n"
fi

################ Macaque (MeanMacaque) to Chimpanzee (Juna) inputs ############################

# baboon (Haiko) to chimp (Juna) template
MM2juna_temp=${data_dir}/wmsanlm_macaque_NMT_v2.0_asym_05mm_SS.nii.gz
echo -e "###Macaquwe to chimp template location:###\n${MM2juna_temp}\n"

# check if temp is in the right location
if [ ! -f "$MM2juna_temp" ]; then
	echo -e "####ERROR####\n${MM2juna_temp}\n doesn't exist - check location\n"
fi

# chimp (Juna) to human (MNI) jacobian #
MM2juna_jac=${data_dir}/wj_MeanMacaque.nii.gz
echo -e "###macaque to chimp jacobian location:###\n${MM2juna_jac}\n"

# check if jacobian is in the right location #
if [ ! -f "$MM2juna_jac" ]; then
	echo -e "####ERROR####\n${MM2juna_jac}\ndoesn't exist - check location\n"
fi

####################### Coregistration & downsampling inputs ##################################

# change location of OPNMF parcellation if needed #
# the chimp opnmf parcellation is 2mm res
chimp_coreg_ref=$(dirname $(dirname $(realpath $0) ) )/data/chimp/opnmf_parc/Chimp_cort_n189_TPM03_rank_17_num_match.nii.gz

# the human opnmf parc is 3mm res
human_coreg_ref=$(dirname $(dirname $(realpath $0) ) )/data/IXI/opnmf_parc/IXI_cort_n480_rank_17.nii.gz

###############################################################################################
########################### OUTPUTS ###########################################################
###############################################################################################

###### create output directories for each species ######

# chimp out put DIR #
chimp_out_dir=${data_dir}/Juna
[ ! -d $chimp_out_dir ] && mkdir $chimp_out_dir

# Baboon out put DIR #
baboon_out_dir=${data_dir}/Haiko
[ ! -d $baboon_out_dir ] && mkdir $baboon_out_dir

# Macaque out put DIR #
macaque_out_dir=${data_dir}/MeanMacaque
[ ! -d $macaque_out_dir ] && mkdir $macaque_out_dir

##### Output name for images from each species ######
juna2MNI_output="juna2MNI"
haiko2juna_output="Haiko2Juna"
MM2juna_output="MeanMacaque2Juna"

#################################################################################################
### Affine scaling factor between species ############

chimp2human_diff=1.15 
baboon2chimp_diff=4
macaque2chimp_diff=4.5

###############################################################################################
### min and max jacobian threshold to remove extreme outier values following brain masking ###

# chimp to human #
juna2MNI_thr_min=0.2
juna2MNI_thr_max=2

# baboon to chimp #
haiko2juna_thr_min=0.08
haiko2juna_thr_max=0.8

# macaque to chimp #
MM2juna_thr_min=0.05
MM2juna_thr_max=0.8

#################################################################################################
##### Create Species specific brain mask for jacobian using template ############################

# chimp brain mask output file name #
mask_out_chimp=${chimp_out_dir}/${juna2MNI_output}_brain_mask.nii.gz

echo -e "create chimp brain mask"
# check if chimp mask doesn't exists  #
if [ ! -e "$mask_out_chimp" ]; then
  fslmaths ${juna2MNI_temp} -ero -bin $mask_out_chimp
  echo -e "### DONE ### \nLocation: \n$mask_out_chimp\n"
else 
  echo -e "### Mask already exists here:### \n$mask_out_chimp\n"
fi

# Baboon brain mask output file name #
mask_out_baboon=${baboon_out_dir}/${haiko2juna_output}_brain_mask.nii.gz

echo -e "create baboon brain mask"
# check if baboon mask doesn't exists  #
if [ ! -e "$mask_out_baboon" ]; then
  fslmaths ${haiko2juna_temp} -ero -bin $mask_out_baboon
  echo -e "### DONE ### \nLocation: \n$mask_out_baboon\n"
else
  echo -e "### Mask already exists here:###\n$mask_out_baboon\n"  	
fi

# Macaque brain mask output file name #
mask_out_macaque=${macaque_out_dir}/${MM2juna_output}_brain_mask.nii.gz

echo -e "create baboon brain mask"
# check if macaque mask doesn't exists  #
if [ ! -e "$mask_out_macaque" ]; then
  fslmaths ${MM2juna_temp} -ero -bin $mask_out_macaque
  echo -e "### DONE ### \nLocation:\n$mask_out_macaque\n"
else
  echo -e "### Mask already exist here:###\n$mask_out_macaque\n"
fi

##################################################################################################
##################### Apply brain mask to jacobian map ###########################################

## apply brain mask to jacobian ##

# human #
jac_out_chimp=${chimp_out_dir}/${juna2MNI_output}_jac_brain.nii.gz

echo -e "Brain mask chimp jacobian"
# check if mask doesn't exists  #
if [ ! -e "$jac_out_chimp" ]; then
  fslmaths $juna2MNI_jac -mas $mask_out_chimp $jac_out_chimp
  echo -e "### DONE ### \nLocation:\n$jac_out_chimp\n"
else
  echo -e "### Masked Jacobian already exists here:###\n$jac_out_chimp\n"
fi

# Baboon #
jac_out_baboon=${baboon_out_dir}/${haiko2juna_output}_jac_brain.nii.gz

echo -e "Brain mask baboon jacobian"
# check if mask doesn't exists  #
if [ ! -e "$jac_out_baboon" ]; then
  fslmaths $haiko2juna_jac -mas $mask_out_baboon $jac_out_baboon
  echo -e "### DONE ### \nLocation:\n$jac_out_baboon\n"
else
  echo -e "### Masked Jacobian already exists here:###\n$jac_out_baboon\n"
fi

# Macaque #
jac_out_macaque=${macaque_out_dir}/${MM2juna_output}_jac_brain.nii.gz

echo -e "Brain mask macaque jacobian"
# check if mask doesn't exists  #
if [ ! -e "$jac_out_macaque" ]; then
  fslmaths $MM2juna_jac -mas $mask_out_macaque $jac_out_macaque
  echo -e "### DONE ### \nLocation:\n$jac_out_macaque\n"
else
  echo -e "### Masked Jacobian already exists here:###\n$jac_out_macaque\n"
fi

########################## Create unthresholded expansion maps ###################################
##################################################################################################

# To create expanison maps from jacobians -> first mutliply by relative brain expansion and then
# inverse the jacobian to enable high values indicating greater expansion #

# Chimp #

expansion_noThr_chimp=${chimp_out_dir}/${juna2MNI_output}_expansion_noThr.nii.gz

echo -e "create chimp to human expansion map without thresholding"
if [ ! -e "$expansion_noThr_chimp" ]; then
  fslmaths $jac_out_chimp -mul $chimp2human_diff -recip $expansion_noThr_chimp 
  echo -e "### DONE ### \nLocation:${expansion_noThr_chimp}\n"
else
  echo -e "### chimp to human no threshold expansion map already exists here:###\n$expansion_noThr_chimp\n"
fi

# Baboon #

expansion_noThr_baboon=${baboon_out_dir}/${haiko2juna_output}_expansion_noThr.nii.gz

echo -e "create baboon to chimp expansion map without thresholding"
if [ ! -e "$expansion_noThr_baboon" ]; then
  fslmaths $jac_out_baboon -mul $baboon2chimp_diff -recip $expansion_noThr_baboon 
  echo -e "### DONE ### \nLocation:${expansion_noThr_baboon}\n"
else
  echo -e "### baboon to chimp no threshold expansion map already exists here:###\n$expansion_noThr_baboon\n"
fi

# Macaque #

expansion_noThr_macaque=${macaque_out_dir}/${MM2juna_output}_expansion_noThr.nii.gz

echo -e "create macaque to chimp expansion map without thresholding"
if [ ! -e "$expansion_noThr_macaque" ]; then
  fslmaths $jac_out_macaque -mul $macaque2chimp_diff -recip $expansion_noThr_macaque 
  echo -e "### DONE ### \nLocation:${expansion_noThr_macaque}\n"
else
  echo -e "### macaque to chimp no threshold expansion map already exists here:###\n$expansion_noThr_macaque\n"
fi

############### Create expansion maps with thresholded jacobians #################################
##################################################################################################

# create upper and lower threshold maps for masking extreme values to the threshold and then
# thresholded expansion map #

# chimpanzee #
expansion_Thr_chimp=${chimp_out_dir}/${juna2MNI_output}_expansion_${juna2MNI_thr_min}_${juna2MNI_thr_max}.nii.gz

echo -e "create chimpanzee to human expansion map with min:${juna2MNI_thr_min} and max:${juna2MNI_thr_max} threshold\n"
if [ ! -e "$expansion_Thr_chimp" ]; then

   # create upper threshold to be added to final image #
   max_thr_out_chimp=${chimp_out_dir}/${juna2MNI_output}_${juna2MNI_thr_max}.nii.gz
   echo -e "Create maximum chimp threshold image:\n${max_thr_out_chimp}\n"
   fslmaths $jac_out_chimp -thr $juna2MNI_thr_max -bin -mul $juna2MNI_thr_max $max_thr_out_chimp
   echo -e "### DONE ###\n"
   
   # create lower threshold to be added to final image #
   min_thr_out_chimp=${chimp_out_dir}/${juna2MNI_output}_${juna2MNI_thr_min}.nii.gz
   echo -e "Create minimum chimp threshold image:\n${min_thr_out_chimp}\n"
   fslmaths $jac_out_chimp -uthr $juna2MNI_thr_min -bin -mul $juna2MNI_thr_min $min_thr_out_chimp
   echo -e "### DONE ###\n"
   
   # covert values outside the thresolds to the threshold values #
   jac_min_max_chimp=${chimp_out_dir}/${juna2MNI_output}_jac_thr_${juna2MNI_thr_min}_${juna2MNI_thr_max}.nii.gz
   echo -e "Create threholded expansion map:\n${jac_min_max_chimp}\n"
   fslmaths $jac_out_chimp -thr $juna2MNI_thr_min -uthr $juna2MNI_thr_max -add $max_thr_out_chimp -add $min_thr_out_chimp $jac_min_max_chimp
   echo -e "### DONE ###\n"
  
  # Create expansion map using the thresholded jacobian map #
  echo -e "Create threholded chimpanzee expansion map:\n${expansion_Thr_chimp}\n"
  fslmaths $jac_min_max_chimp -mul $chimp2human_diff -recip $expansion_Thr_chimp 
  echo -e "### DONE ### \nLocation:${expansion_Thr_chimp}\n"
   
else 
  echo -e "### chimp to human threshold expansion map already exists here:###\n${expansion_Thr_chimp}\n"
fi


# baboon #
expansion_Thr_baboon=${baboon_out_dir}/${haiko2juna_output}_expansion_${haiko2juna_thr_min}_${haiko2juna_thr_max}.nii.gz

echo -e "create baboon to chimpanzee expansion map with min:${haiko2juna_thr_min} and max:${haiko2juna_thr_max} threshold\n"
if [ ! -e "$expansion_Thr_baboon" ]; then

   # create upper threshold to be added to final image #
   max_thr_out_baboon=${baboon_out_dir}/${haiko2juna_output}_${haiko2juna_thr_max}.nii.gz
   echo -e "Create maximum baboon threshold image:\n${max_thr_out_baboon}\n"
   fslmaths $jac_out_baboon -thr $haiko2juna_thr_max -bin -mul $haiko2juna_thr_max $max_thr_out_baboon
   echo -e "### DONE ###\n"
   
   # create lower threshold to be added to final image #
   min_thr_out_baboon=${baboon_out_dir}/${haiko2juna_output}_${haiko2juna_thr_min}.nii.gz
   echo -e "Create minimum baboon threshold image:\n${min_thr_out_baboon}\n"
   fslmaths $jac_out_baboon -uthr $haiko2juna_thr_min -bin -mul $haiko2juna_thr_min $min_thr_out_baboon
   echo -e "### DONE ###\n"
   
   # covert values outside the thresolds to the threshold values #
   jac_min_max_baboon=${baboon_out_dir}/${haiko2juna_output}_jac_thr_${haiko2juna_thr_min}_${haiko2juna_thr_max}.nii.gz
   echo -e "Create threholded baboon expansion map:\n${jac_min_max_baboon}\n"
   fslmaths $jac_out_baboon -thr $haiko2juna_thr_min -uthr $haiko2juna_thr_max -add $max_thr_out_baboon -add $min_thr_out_baboon $jac_min_max_baboon
   echo -e "### DONE ###\n"
  
  # Create expansion map using the thresholded jacobian map #
  echo -e "Create threholded baboon expansion map:\n${expansion_Thr_baboon}\n"
  fslmaths $jac_min_max_baboon -mul $baboon2chimp_diff -recip $expansion_Thr_baboon 
  echo -e "### DONE ### \nLocation:${expansion_Thr_baboon}\n"
   
else 
  echo -e "### baboon to chimpanzee threshold expansion map already exists here:###\n${expansion_Thr_baboon}\n"
fi

# Macaque #
expansion_Thr_macaque=${macaque_out_dir}/${MM2juna_output}_expansion_${MM2juna_thr_min}_${MM2juna_thr_max}.nii.gz

echo -e "create macaque to chimpanzee expansion map with min:${MM2juna_thr_min} and max:${MM2juna_thr_max} threshold\n"
if [ ! -e "$expansion_Thr_macaque" ]; then

   # create upper threshold to be added to final image #
   max_thr_out_macaque=${macaque_out_dir}/${MM2juna_output}_${MM2juna_thr_max}.nii.gz
   echo -e "Create maximum macaque threshold image:\n${max_thr_out_macaque}\n"
   fslmaths $jac_out_macaque -thr $MM2juna_thr_max -bin -mul $MM2juna_thr_max $max_thr_out_macaque
   echo -e "### DONE ###\n"
   
   # create lower threshold to be added to final image #
   min_thr_out_macaque=${macaque_out_dir}/${MM2juna_output}_${MM2juna_thr_min}.nii.gz
   echo -e "Create minimum macaque threshold image:\n${min_thr_out_macaque}\n"
   fslmaths $jac_out_macaque -uthr $MM2juna_thr_min -bin -mul $MM2juna_thr_min $min_thr_out_macaque
   echo -e "### DONE ###\n"
   
   # covert values outside the thresolds to the threshold values #
   jac_min_max_macaque=${macaque_out_dir}/${MM2juna_output}_jac_thr_${MM2juna_thr_min}_${MM2juna_thr_max}.nii.gz
   echo -e "Create threholded macaque expansion map:\n${jac_min_max_macaque}\n"
   fslmaths $jac_out_macaque -thr $MM2juna_thr_min -uthr $MM2juna_thr_max -add $max_thr_out_macaque -add $min_thr_out_macaque $jac_min_max_macaque
   echo -e "### DONE ###\n"
  
  # Create expansion map using the thresholded jacobian map #
  echo -e "Create threholded macaque expansion map:\n${expansion_Thr_macaque}\n"
  fslmaths $jac_min_max_macaque -mul $macaque2chimp_diff -recip $expansion_Thr_macaque 
  echo -e "### DONE ### \nLocation:${expansion_Thr_macaque}\n"
   
else 
  echo -e "### macaque to chimpanzee threshold expansion map already exists here:###\n${expansion_Thr_macaque}\n"
fi

###################### Coregister and down_sample the expansion maps ##############################################

# use the opnmf parcellation from humans for the juna2mni expansion and the chimp for the baboon and macaque #

# Chimpanzee #

chimp_coreg_ouput=${chimp_out_dir}/${juna2MNI_output}_expansion_${juna2MNI_thr_min}_${juna2MNI_thr_max}_3mm.nii.gz

if [ ! -e "$chimp_coreg_ouput" ]; then
   
   echo -e "Coregister and downsample chimpanzee to human expansion map using ${human_coreg_ref}"
   flirt -in $expansion_Thr_chimp -ref $human_coreg_ref -out $chimp_coreg_ouput -applyxfm -interp nearestneighbour 
   echo -e "### DONE ###\nLocation:${chimp_coreg_ouput}\n"
   
else 
   echo -e "### downsampled chimpanzee to human expansion map already exists here: ####\n${chimp_coreg_ouput}\n"
fi

# Baboon #

baboon_coreg_output=${baboon_out_dir}/${haiko2juna_output}_expansion_${haiko2juna_thr_min}_${haiko2juna_thr_max}_2mm.nii.gz

if [ ! -e "$baboon_coreg_output" ]; then
   
   echo -e "Coregister and downsample baboon to chimpanzee expansion map using ${chimp_coreg_ref}"
   flirt -in $expansion_Thr_baboon -ref $chimp_coreg_ref -out $baboon_coreg_output -applyxfm -interp nearestneighbour
   echo -e "### DONE ###\nLocation:${baboon_coreg_output}\n"
   
else 
   echo -e "### downsampled baboon to chimpanzee expansion map already exists here: ####\n${baboon_coreg_output}\n"
fi

# Macaque #

macaque_coreg_output=${macaque_out_dir}/${MM2juna_output}_expansion_${MM2juna_thr_min}_${MM2juna_thr_max}_2mm.nii.gz

if [ ! -e "$macaque_coreg_output" ]; then
   
   echo -e "Coregister and downsample macaque to chimpanzee expansion map using ${chimp_coreg_ref}"
   flirt -in $expansion_Thr_macaque -ref $chimp_coreg_ref -out $macaque_coreg_output -applyxfm -interp nearestneighbour 
   echo -e "### DONE ###\nLocation:${macaque_coreg_output}\n"
   
else 
   echo -e "### downsampled macaque to chimpanzee expansion map already exists here: ####\n${macaque_coreg_output}\n"
fi


