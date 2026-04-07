# preprocessing/

This subdirectory contains code used for MEMRI data preprocessing and quality assurance (QA) metric computation, as well as the statistical analyses and figures corresponding to these steps. Links to external Bearer Lab repositories used during preprocessing are also provided below.

## External Repositories

The following Bearer Lab GitHub repositories contain code used during MEMRI preprocessing. Descriptions and usage instructions are provided on their respective pages.


- **[BearerLab/memri-ela-vs-std](https://github.com/bearerlab/memri-ela-vs-std/blob/main/01_preprocessing/02_memri_preprocessing/slice_interpolation.m)** — A script from this repo is used for slice interpolation. Analysis files of the output from this processing is included here.
- **[BearerLab/Skull-Stripper](https://github.com/bearerlab/skull-stripper)** — This repo is used for skull stripping of MR brain images. Analysis files of the output from this processing is included here. 
- **[BearerLab/Modal-Scaling](https://github.com/bearerlab/modal-scaling)** — This repo is used for intensity normalization. The analysis file of the output from this processing is included here. 

## Scripts

### MATLAB / SPM Batch Scripts

| Script | Description |
|---|---|
| `SDDM_calculate.m` | Calculates the SDDM image from individual deformation images from the dataset. This requires additional files from SPM-based normalizatio.|


### Python Scripts

| Script | Description |
|---|---|
| `MDT.py` | Computes minimal deformation target (MDT) images from pre-Mn(II) images. |
| `NMI.py` | Computes normalized mutual information (NMI) between registered images with dataset MDT as a QA metric. |
| `JSI.py` | Computes the Jaccard similarity index (JSI) between brain masks of registered images with that of the dataset MDT and as a QA metric. |

### R Scripts / R Markdown Files

| Script | Description |
|---|---|
| `SNR_Analysis.Rmd` | R Markdown file that performs statistical comparisons of signal- and contrast-to-noise (SNR/CNR) across experimental groups. |
| `MDT_SimilarityComparisons.R` | R script thaterforms statistical comparisons of NMI and JSI between the dataset MDT and input image used to generate the MDT at each step. |
| `ModalScalingTest.R` | R script that generates publication-quality figures for assessing grayscale normalization and plotting QA metrics. |
| `Warp_SimilarityComparisons.R` | R script that generates publication-quality figures for assessing alignment via similarity QA metrics. |


## Notes

- `MDT.py` requires `FSL` to run see [FSL documentation](https://fsl.fmrib.ox.ac.uk/fsl/docs/index.html)
- Many processing QA scripts here require input MEMRI images across processing steps to run and cannot be run as is without this specific input.
