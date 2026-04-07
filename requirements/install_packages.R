#! R 
##########################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This script installs R packages required for processing
# and analysis of data in "Quality Assurance Strategies for Brain State Characterization by MEMRI"
# by Uselman TW, Jacobs RE, and Bearer EL (2026)
#
# Ensure minimum R version requirements are met before running 
#
##########################################################

# List of packages to install
packages_to_manage <- c(
  # Data processing packages
  "openxlsx",
  "tidyverse",
  "RNifti",
  "stringr",
  # Data Visualization
  "ggplot2",
  #Data Analysis/Statistics:
  "nlme",
  "emmeans"
  )

# Function to check, install, and load packages
install_r_packages <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

# Apply the function to each package in the list
invisible(lapply(packages_to_manage, install_r_packages))
