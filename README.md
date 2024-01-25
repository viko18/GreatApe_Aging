# Great Ape Aging & Expansion Comparison

Utilizing a comparative framework employing both inter- and intra-species similarities we investigated the relationship between cross-species expansion and age-mediated gray matter changes in two great ape species, chimpanzees and humans. The  [NCBR](https://www.chimpanzeebrain.org/) (National Chimpannzee Brain Resource) was used for the chimpanzee images and the open [IXI](http://brain-development.org/ixi-dataset/) (Information eXtraction from Images) were used for humans as it has a similar sge, sex, and scanner field strength distribution. Additionally, the [eNKI](http://fcon_1000.projects.nitrc.org/indi/enhanced/index.html) (Enhanced Nathan Kline Institute) dataset was used to replicate our finding in humans.

The scripts with this repository are written to be used in a ```/$project/``` directory with subsequent ```/$project/data/```, ```/$project/code/```, and ```/$project/outputs/``` directories. This repository should be placed in the ```/$project/code/``` directory. The data required to complete the analyses exluding the indetifying phenotypical data (E.g. age, sex, subject ID etc.) and brain scans, can be found openly available on Zenodo. The brain scans and phenotypical data can be retrieved from the above URL's. The [GM masks](https://zenodo.org/record/6463123#.YzV-REhByV4) in a seperate Zenodo repository. The rest of the data is avalilable at this [LINK](https://zenodo.org/record/7116203#.YzVCgkhByV4). Here you can find outputs of our analyses at ```outputs.zip``` which should be unzipped into ```/$project/``` as a sub-directory. Additionally, the appropriate data for chimpanzees and humans can be downlaoded at ```chimp.zip``` and ```IXI.zip``` and also should be unzipped as sub-directories in ```/$project/data/```. 

Our anlyses can be seperated into four parts:

- ```/01_Preprocessing/``` the prrocessing, segmentation, and registration of the T1w images using [CAT12](https://neuro-jena.github.io/cat//) in both species and creating data matrices (Subj x Voxels) for Orhtogonal Projective Non-Negative Matrix Factorization (OPNMF).

- ```/02_Cross-species_Registration/``` creating cross-species expansion maps, including chimpnazee to human, baboon to chimpanzee, and macaque to chimpanzee.

- ```/03_OPNMF/``` conducting OPNMF, cross-species factorization similarity, and selecting the most appropriate granularity for further analysis.

- ```/04_Age_Expansion_Analysis/``` utilize the selected OPNMF solution to compare aging and cross-species expansion as well as their relationship with each other in chimpanzees and humans.

**Manuscript**: The Uniqueness of Human Vulnerability to Brain Aging in Great Ape Evolution; Sam Vickery, Kaustubh R. Patil, Robert Dahnke, William D. Hopkins, Chet C. Sherwood, Svenja Caspers, Simon B. Eickhoff, Felix Hoffstaedter; [LINK](https://www.biorxiv.org/content/10.1101/2022.09.27.509685v2)
