# segmentation/

## External Repository

All code is maintained in a dedicated repository:

**[BearerLab/InVivoSegment](https://github.com/bearerlab/InVivoSegment)** — GUI-based pipeline for calculation of *InVivo* Atlas-based segmentation measures from mouse brain data. Please refer to the InVivoSegment repository for full documentation, installation instructions, and software requirements.

## Example Notebook

A copy of the worked example notebook from the InVivoSegment repository is provided here for convenience and reproducibility. This notebook walks through the complete segmentation workflow as applied in this study. This is accompanied by an HTML export.

- **[Examples.ipynb](./Examples.ipynb)** — Step-by-step demonstration of the InVivoSegment pipeline applied to MEMRI data, including examples for how to use the GUI, processing of output data, and visualization of results. Note that this folder will not run directory from here. Please see the *[BearerLab/InVivoSegment](https://github.com/bearerlab/InVivoSegment)* repository for more information.


## Scripts

Scripts used for inverse alignments of the *InVivo* Atlas to the dataset MDT.

| Script | Description |
|---|---|
| `ants_inverse_alignment.py` | ANTS-based inverse alignment implemented in Python|
| `FSL_Inverse_Alignment.sh` | FSL FLIRT/FNIRT shell script and corresponding config file `mdt2atlas_config.cnf` |
| `01_affMDA2Atlas.mat` | SPM12 implementation: data for forward affine transform (FSL). |
| `SPMNormalize_job.m` | SPM12 implementation: batch script for forward warping step. |
| `SPMDeformation_job.m` | SPM12 implementation:  batch script to convert _sn file to deformation field. |
| `SPMInversePullback_job.m` | SPM12 implementation: batch script to invert deformation field. | 
| `01_iwa_Avg2Atlas.mat` | SPM12 implementation: inverted affine transform (FSL). | 

