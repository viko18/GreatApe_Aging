# Great Ape Aging & Expansion Comparison


Utilizing a comparative framework employing both inter- and intra-species similarities we investigated the relationship between cross-species expansion and age-mediated gray matter changes in two great ape species, chimpanzees and humans. The  [NCBR](https://www.chimpanzeebrain.org/) (National Chimpannzee Brain Resource) was used for the chimpanzee images and the open [IXI](http://brain-development.org/ixi-dataset/) (Information eXtraction from Images) were used for humans as it has a similar sge, sex, and scanner field strength distribution. Additionally, the [eNKI](http://fcon_1000.projects.nitrc.org/indi/enhanced/index.html) (Enhanced Nathan Kline Institute) dataset was used to replicate our finding in humans.

Our anlyses can be seperated into four parts:

- ```/01_Preprocessing/``` the prrocessing, segmentation, and registration of the T1w images using [CAT12](https://neuro-jena.github.io/cat//) in both species and creating data matrices (Subj x Voxels) for Orhtogonal Projective Non-Negative Matrix Factorization (OPNMF).

- ```/02_Cross-species_Registration/``` creating cross-species expansion maps, including chimpnazee to human, baboon to chimpanzee, and macaque to chimpanzee.

- ```/03_OPNMF/``` conducting OPNMF, cross-species factorization similarity, and selecting the most appropriate granularity for further analysis.

- ```/04_Age_Expansion_Analysis/``` utilize the selected OPNMF solution to compare aging and cross-species expansion as well as their relationship with each other in chimpanzees and humans.

**Manuscript**: The Uniqueness of Human Vulnerability to Brain Aging in Great Ape Evolution; Sam Vickery, Kaustubh R. Patil, Robert Dahnke, William D. Hopkins, Chet C. Sherwood, Svenja Caspers, Simon B. Eickhoff, Felix Hoffstaedter; https://www.biorxiv.org/content/10.1101/2022.09.27.509685v1
