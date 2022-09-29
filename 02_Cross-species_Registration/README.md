# Cross-Species Registration

The tempates used for cross-species expansion and registration are:

- Human: [MNI](http://www.bic.mni.mcgill.ca/ServicesAtlases/ICBM152NLin2009)
- Chimpanzee: [Juna](http://junachimp.inm7.de/)
- Baboon: [Haiko89](https://www.nitrc.org/projects/haiko89/)
- Macaque: [D99](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/nonhuman/macaque_tempatl/atlas_d99v2.html), [INIA19](https://www.nitrc.org/projects/inia19/), and [NMT](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/nonhuman/macaque_tempatl/template_nmtv2.html#download-symmetric-nmt-v2-datasets)

The modulated jacobians are used to create the cross-species expansion maps as well as the chimpanzee (Juna) to human (MNI) deformation field map for deforming OPNMF solution to MNI space can be found [here](https://zenodo.org/record/7116203#.YzLvCfexWV4).

The ```exp_create.sh``` script uses FSL in particular ```fslmaths``` to mask and establish the expansion maps from the jacobians.

