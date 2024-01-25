# Orthogonal Projective Non-Negative Matrix Factorization (OPNMF)

The scripts should be run in sequential order to establish OPNMF parcellations for chimpanzees and humans, conduct ARI (adjusted rand index) comparison, bootstrapping, and finally create the granularity selection plot (Fig. 2A in article). Additionally ```parcel_ari.R``` can be used to create the parcel-wise ARI brain map by projecting the highest cross-species ARI per parcel onto the human MNI template space.

OPNMF is conducted using this repo (https://github.com/kaurao/opnmfR) which needs to be installed using ```remotes::install_github("kaurao/opnmfR")```. For bootstrapping (```run_OPMNF_boot.sh```) the ```opnmfR_boot.R``` function is used.

OPNMF solutions for the chimpanzee (n189) and IXI (n480) with granularities of 2 - 40 can be downlaoded [here](https://zenodo.org/records/10141986). Additionally the output of all 100 bootstraps (without the parcellations) is also provided.
