#!/bin/bash

##### FSL v5.0 #####
## Create expansion maps from baboon cross species registration using fslmaths ##
## This script should be run in code dir that is then ../data/deformations/ away ##
## from the deformation and T1 images. This can be changed by adapting $data_dir ##

## 5 INPUTS ##
# INPUT 1 - Name of T1 image for brain mask (string)
# INPUT 2 - Name of modulated jacobian (string)
# INPUT 3 - Name of template (MNI, Haiko, NMT, D99, INIA19, MeanMacaque)
# INPUT 4 - Minimum threshold value for thresholding modulated jacobian for extreme values
# INPUT 5 - Max threshold value for thresholding modulated jacobian for extreme values

## OUTPUTS ##
# Directory for output files as name of template in $data_dir
# 1 - brain mask
# 2 - brain masked jacobian 
# 3 - brain masked expansion map
# 4 - brain masked jacobian with threshold
# 5 - voxels above threshold
# 5 - voxels below threshold

# prints the relative path to the script #
echo -e "script dir:\n$0"

# using relative paths creates te complete path to the dir and prints #
# from code dir with script go one up and then to Deformations where data is #
data_dir="$(dirname $(dirname $(realpath $0) ) )/data/Deformations"
echo -e "Deformations Dir:\n$data_dir"

# name of registered T1 template image used to mask the deformation map #
# INPUT 1 #
T1_name=$1
echo -e "T1 Name: \n$data_dir/$T1_name"

# name of modulated jacobian file 
# INPUT 2 #
def_name=$2
echo -e "Deformation Name: \n$data_dir/$def_name"

# User input of template name if MNI then chimp-human exp factor  #
# if not then go through the different baboon and macaque templates that can be used #
# if none of these are given print error message #
if [[ "$3" == "MNI" ]]; then
	echo "#### Human (MNI) Pipeline"
	# human brain ~ 3.5x chimp so 1/35 = 0.286
	out_name=$3
	exp_factor=0.286
	[ ! -d $data_dir/$out_name ] && mkdir $data_dir/$out_name
	
elif [[ "$3" == "Haiko" ]]; then
	echo "#### Baboon Pipeline ####"
	# chimp brain ~2.5x baboon so 1/2.5 = 0.4 manipulation
	out_name=$3
	exp_factor=0.4
	[ ! -d $data_dir/$out_name ] && mkdir $data_dir/$out_name

elif [[ "$3" == "NMT" ]]; then
	echo "#### Macaque Pipeline ####"
        # chimp brain ~4.5x macaque brain so 1/4.5 = 0.22 manipulation
	out_name=$3
	exp_factor=0.22
	[ ! -d $data_dir/$out_name ] && mkdir $data_dir/$out_name

elif [[ "$3" == "D99"  ]]; then
	echo "#### Macaque Pipeline ####"
	# 0.22 manipulation with macaque #
	out_name=$3
	exp_factor=0.22
	[ ! -d $data_dir/$out_name ] && mkdir $data_dir/$out_name

elif [[ "$3" == "INIA19" ]]; then
	echo "#### Macaque Pipeline ####"
	# 0.22 manipulation for macaque #
	out_name=$3
	exp_factor=0.22
	[ ! -d $data_dir/$out_name ] && mkdir $data_dir/$out_name

elif [[ "$3" == "MeanMacaque" ]]; then
	echo "#### Macaque Pipeline ####"
	# 0.22 manipulation for macaque #
	out_name=$3
	exp_factor=0.22
	[ ! -d $data_dir/$out_name ] && mkdir $data_dir/$out_name

else 
	echo -e "#### DO NOT RECOGNISE TEMPLATE NAME ####\n#### ERROR ####"
	exp_factor=0
fi

# a non threholded map will be created along with an image with provided threshold #
# INPUT 4  lower limit of threshold for jacoabian #
min_thr=$4

# INPUT 5 upper limt of threshold for jacobian #
max_thr=$5

# Create a mask of the brain #
# brian mask output file name #
mask_out_name=$data_dir/${out_name}/${out_name}_brain_mask.nii.gz
echo -e "Brain mask: \n$mask_out_name"

# check if mask doesn't exists  #
if [ ! -e "$mask_out_name" ]; then
  fslmaths ${data_dir}/$T1_name -ero -bin $mask_out_name
fi

# mask the deformation map using the brain mask #
# create masked jacobian deformation map #
jac_out_name=$data_dir/${out_name}/${out_name}_jac_brain.nii.gz
echo -e "Jacobian Brain: \n$jac_out_name"

# check if mask doesn't exists  #
if [ ! -e "$jac_out_name" ]; then
  fslmaths ${data_dir}/$def_name -mas $mask_out_name $jac_out_name
fi

#  create the expansion map using the expansion factor #
# name of expansion map with any threshold #
exp_no_thr=$data_dir/${out_name}/${out_name}2Juna_expansion_noThr.nii.gz
echo -e "Expansion No Threshold: \n$exp_no_thr"

if [ ! -e "$exp_no_thr" ]; then
  fslmaths $mask_out_name -div $exp_factor -div $jac_out_name $exp_no_thr
fi

# create additional expansion map using upper and low threshold of extreme values #
exp_thr=$data_dir/${out_name}/${out_name}2Juna_expansion_${min_thr}_${max_thr}.nii.gz
echo -e "Expansion Thresholded: \n$exp_thr"

# If the expanaion map has not been created using the same threshold then create it #
if [ ! -e "$exp_thr" ]
 then
  
  # create mask for upper threshold to be added back to final image #
  max_thr_out=${data_dir}/${out_name}/${out_name}_${max_thr}
  fslmaths ${data_dir}/$def_name -thr $max_thr -mas $mask_out_name \
  -bin -mul $max_thr $max_thr_out
  
  # create mask for lower threshold to be added back to final image #
  min_thr_out=${data_dir}/${out_name}/${out_name}_${min_thr}
  fslmaths ${data_dir}/$def_name -uthr $min_thr -mas $mask_out_name \
  -bin -mul $min_thr $min_thr_out
  
  # threshold image with upper and lower and make values outside the threshold value #
  jac_min_max=${data_dir}/${out_name}/${out_name}_jac_thr_${min_thr}_${max_thr}
  fslmaths ${data_dir}/$def_name -thr $min_thr -uthr $max_thr -mas $mask_out_name \ 
  -add $max_thr_out -add $min_thr_out $jac_min_max
  
  # Now create expansion map with the thresholded jacobian #
  fslmaths $mask_out_name -div $exp_factor -div $jac_min_max $exp_thr
  
fi


