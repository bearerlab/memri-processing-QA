# Code Used in 'Quality Assurance Strategies for Brain State Characterization by MEMRI'

## Citation [![JNEUMETH](https://shields.io/badge/DOI-Journal_of_Neuroscience_Methods-blue)](https://doi.org/10.1016/j.jneumeth.2026.110896)

> Uselman, T.W., Jacobs, R.E., and Bearer, E.L., 2026. Quality assurance strategies for brain state characterization by MEMRI. _J. Neurosci. Meth._ (in press), 110896. doi:10.1016/j.jneumeth.2026.110896






## Overview

Provided in this repository is the code used (or links to GitHub repositories) in various processing and analysis steps from "Quality Assurance Strategies for Brain State Characterization by MEMRI." Below, we link to each of the major subsections of this repository, which correspond to various sections and figures within the manuscript. Corresponding figures for each subsection are listed in the subdirectories' `README.md` files. Note that some sections used code from other Bearer Lab GitHub repositories and require various software dependencies (see Requirements.txt). Descriptions and instructions for scripts from those repositories are described on their respective GitHub pages; links to these repositories are provided within subdirectories here for which that software was used.

Please review each of the following subdirectories for more information on 1) MEMRI data preprocessing and quality assurance (QA) metrics; 2) noise simulations and statistical validation; and 3) *InVivo* Atlas-based brain segmentation and summarization.

Note: To run scripts/markdown files, data must be run locally (perhaps after a git clone) and the correct working directory will need to be set as user specific input. In the code provided here, user input for the directory will be indicated by the following character string: ```SET-LOCAL-DIRECTORY```.

## Repository Subdirectories

- **[preprocessing/](./preprocessing/)** — MEMRI data preprocessing, QA metrics (e.g., NMI, JSI, MDT), and statistical analysis of QA outcomes
- **[requirements/](./requirements)** —  R and Python requirement install functions.
- **[segmentation/](./segmentation/)** —  *InVivo* brain segmentation using the __*InVivoSegment*__ pipeline (a separate GitHub repo)
- **[simulations/](./simulations/)** — Generation and processing of noise-only and simulation data, and statistical analysis

## Requirements

- [MATLAB](https://www.mathworks.com/products/matlab.html) with [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/)
- [FSL](https://fsl.fmrib.ox.ac.uk/fsl/docs/)
- Python 3.8+ with packages as specified in individual scripts
- R 4.1 with packages as specified in individual R scripts and R Markdown files
- See linked external repositories for their respective dependencies


For R and Python package dependencies, please see the *install_packages* files in [requirements/](./requirements).
