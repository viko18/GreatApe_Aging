# Structural Preprocessing

Structural preprocessing (T1-weighted images) for chimpanzee and human cohorts utilizing [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) and [CAT12](http://www.neuro.uni-jena.de/cat/). The Matlab scripts are to be used as batch inputs to then adapted in the SPM batch editor. 

Following preprocessing move the ```mwp1*``` and smoothed modulated images into ```$project_dir/data/$cohort/wmp1/``` directory and then run the ```run_GM_matrix_create.sh``` to create the data matrix for OPNMF parcellation.

