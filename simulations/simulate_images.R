#! R 
##########################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This script simulates noise-only (false positive) and
# embedded positive (true positive) signals in image volumes
# based on real MEMRI data features, as described in 
# "Quality Assurance Strategies for Brain State 
# Characterization by MEMRI" by Uselman TW, Jacobs RE,
# and Bearer EL (2026)
#
# Ensure minimum R version requirements are met before running 
#
##########################################################

# Load/Install required libraries.
libs = c("RNifti","stringr")
lL = length(libs)
vers = c("3.5.0","4.0.0") # minimum R required is 4.0.0
lV = length(vers)
minvers = max(package_version(vers))
if (getRversion() != minvers) {stop(paste0("ERROR: minimum R version must be ",minvers))} 
for (i in 1:length(libs)) {
  if (lL != lV) {stop("be sure correct minvers are included libs")}
  if (!requireNamespace(libs[i], quietly = TRUE)) {install.packages(libs[i])}
}

#######################
# Set Local Directory #
#######################
wdir = "SET-LOCAL-DIRECTORY"
#######################
if (!dir.exists(wdir)) {
  dir.create(wdir)
  setwd(wdir)
} else {
  setwd(wdir)
}

# Generate base directories
if(!dir.exists("./NoiseImages")) {dir.create("./NoiseImages")}
dout = paste0("./GridMasks")
if (!dir.exists(dout)) {dir.create(dout)}

# Setup Image Templates (MDA)
### This MDA.nii file has provided to reproduce this analysis. 
nii_tmp = readNifti("./MDA.nii") # template nii
nii_hdr = niftiHeader(nii_tmp) # header info from template
dim_nii = dim(nii_tmp) # dimensional size

# Manual input based on data set
n = 11 # Sample size used (assumed that two groups or conditions are to be assessed)
std_tot = 763 # 'fslmaths ResMS.nii -k MDA_mask.nii -n -M'
noise_std = 287 # Dataset average noise (std) from SNR
noise_avg = 1000 # Dataset average signal magnitude of noise measurements
sig_std = sqrt(std_tot^2 - 2*noise_std^2) # sqrt(mean(ResMS.nii) - 300^2) (noise from SNR) = individual variability in sample (not measurement noise)
sig_avg = 6000 # 6,000 roughly brain-wide average of tissue signal intensity
# This avg and std were determined from measuring PreMn BL avg, and the ResMS for the Std HC > BL comparisons. It is assumed that individual variability (1 standard deviation) of voxel wise signal intensity differences between a pre- and post-Mn(II) images is roughly 71 intensity units. Below we use the m to estimate the mean, cohd to estimate the mean of the second group of images, and sd to generate a sample-wise standard deviation of 71 that is added onto the measurement noise of 300.



Nboot = 1 # Number of bootstraps if multiple samples required
## Here we only use a single bootstrap since we have a fairly refined CohD ramping from d = 0.5 to 1.2 by 0.1
sl = str_length(as.character(Nboot)) # for bootstrap id labeling purposes


# Cohen's D Effect Sizes to ramp for positive controls 
cohd   = round(c(1.8124611,2.6735847,3.1494393) / sqrt(n), 3)
cluster_sizes <- c(1, 2, 3, 4, 5) # Edge length of cube clusters (voxels)
replicates <- 8               # Number of times to repeat the grid along Z-axis


cohdgen = function(n, m, s, d, type=c("unpaired","paired")) { 
  ##################################################################
  # function to generate signals of effect size d (cohen's d)
  # n = number of samples
  # m = mean difference
  # s = standard deviation of differences -- assumes equal variance
  # type = type of test -- currently only setup for 'paired' t-tests
  ##################################################################
  if (type == "unpaired") {
    r1 = rnorm(n, m, s) # Group/Condition 1 list of Signals
    r2 = m + rnorm(n, d * s, s) # add to mean of r1
  } else if (type == "paired") {
    r1 = rnorm(n, m, s)# Group/Condition 1 list of Signals
    r2 = r1 + rnorm(n, d * s, s) # add pairwise to r1
  } else {
    stop("'type' not specified correctly")
  }
  r12 = c(r1, r2)
  names(r12) = c(rep("r1",n),rep("r2",n))
  return(r12)
}


#Setup Positive Signal Grids
x0 = round(2*dim_nii[1]/27,0)
y0 = round(1*dim_nii[2]/27,0)
z0 = round(5*dim_nii[3]/27,0)
x_steps = seq(x0, by = 25, length.out = length(cluster_sizes)) # was replicates
y_steps = seq(y0, by = 25, length.out = replicates)
z_steps = seq(z0, by = 25, length.out = length(cohd))



# Bounding Box
## Full image matrix
bb = array(1,dim = dim_nii)
writeNifti(
  asNifti(bb, reference = nii_hdr),
  file = paste0(dout,"/Full_Image_BB.nii"),
  datatype = "int16"
)
## Rectilinear Grid Volume
bb = array(0,dim = dim_nii)
bb[x_steps[1]:x_steps[length(cluster_sizes)],
   y_steps[1]:y_steps[replicates],
   z_steps[1]:z_steps[length(cohd)]] = 1
writeNifti(
  asNifti(bb, reference = nii_hdr),
  file = paste0(dout,"/Grid_BB.nii"),
  datatype = "int16"
)


# Run Generation
for (nb in 1:Nboot) {
  cat(paste0("\n\n===== Bootstrap ",nb, "/", Nboot,"\n"))
  dn = str_pad(as.character(nb),sl,side="left",pad="0") # more labeling
  # Generate Bootstrap Sample Directories
  if (!dir.exists(paste0("./NoiseImages/Sample_",dn))) { 
    dir.create(paste0("./NoiseImages/Sample_",dn))
    dir.create(paste0("./NoiseImages/Sample_",dn,"/Negative/"))
    dir.create(paste0("./NoiseImages/Sample_",dn,"/Positive/"))
  }
  
  test_ls_neg = list()
  cat("===== Negative Controls =====\n")
  for (i in 1:(2*n)) {
    prog = round(100*i/(2*n),0)
    progstr = str_pad(as.character(prog), 3, side="left", pad=" ")
    cat(paste0("\r-- ", progstr, "%   \r"))
    # Generate noise arrays
    test_ls_neg[[i]] = array(rnorm(prod(dim_nii),
                                   noise_avg,
                                   noise_std + sig_std), # both must be included
                             dim = dim_nii)
    if (i <= n) { # labeling based on two sample of the same size (n).
      id = str_pad(as.character(i),
                   str_length(as.character(n)),
                   side="left",pad="0")
      g = 1
    } else {
      id = str_pad(as.character((i - n)),
                   str_length(as.character(n)),
                   side="left",pad="0")
      g = 2
    }
    # Flip required to match original data orientation
    test_ls_neg[[i]] = test_ls_neg[[i]][rev(seq_len(nrow(test_ls_neg[[i]]))), , ]
    # Save to Noise Only NIfTIs to Negative Controls
    writeNifti(
      asNifti(test_ls_neg[[i]], reference = nii_hdr),
      file = paste0("./NoiseImages/Sample_",dn,"/Negative/G",g,"_Sub",id,".nii"),
      datatype = "int16"
    )
  }
  
  
  r12_list = list()
  test_ls_pos = test_ls_neg
  cat("===== Positive Controls =====\n")
  for (d in 1:length(cohd)) { # loop through Cohen's d values
    pos_r12p = replicate(1e4, cohdgen(n = n,
                                      m = noise_avg + sig_avg,
                                      s = sig_std,
                                      d = cohd[d],
                                      type="paired"))
    diff1 = pos_r12p[(n+1):(2*n),] - pos_r12p[1:(n),]
    mean1 = apply(diff1, MARGIN=2, FUN=mean)
    std1  = apply(diff1, MARGIN=2, FUN=sd)
    cohd1 = mean1 / std1
    cost = abs(cohd1-cohd[d])
    idx = which(cost == min(cost))
    
    cat(paste0("-- Actual Cohen's D = ",round(cohd1[idx],5),"\n"))
    
    r12_list[[d]] = list(pos_r12p[1:(n),idx],pos_r12p[(n+1):(2*n),idx])
    if (nb == 1) {
      grid_mask_out = array(0, dim = dim_nii)
    }
    for (i in 1:(2*n)) {
      if (i <= n) {
        signal_add = r12_list[[d]][[1]][i]
        id = str_pad(as.character(i),
                     str_length(as.character(n)),
                     side="left",pad="0")
        g = 1
      } else {
        signal_add = r12_list[[d]][[2]][(i-n)]
        id = str_pad(as.character((i - n)),
                     str_length(as.character(n)),
                     side="left",pad="0")
        g = 2
      }
      for (x in 1:length(cluster_sizes)) {
        for (z in 1:replicates) {
          xSpan = c(x_steps[x]:(x_steps[x]+(x-1)))
          zSpan = c(z_steps[d]:(z_steps[d]+(x-1)))
          ySpan = c(y_steps[z]:(y_steps[z]+(x-1)))
          test_ls_pos[[i]][xSpan,ySpan,zSpan] = test_ls_pos[[i]][xSpan,ySpan,zSpan] + signal_add
          if (nb == 1 & i == 1) {
            grid_mask_out_bin = grid_mask_out
            grid_mask_out_bin[xSpan,ySpan,zSpan] = 1
            grid_mask_out[xSpan,ySpan,zSpan] = grid_mask_out[xSpan,ySpan,zSpan] + cohd1[idx]
            writeNifti(
              asNifti(grid_mask_out_bin, reference = nii_hdr),
              file = paste0(dout,"/Grid_CohD_Mask.nii"),
              datatype = "int16"
            )
            writeNifti(
              asNifti(grid_mask_out, reference = nii_hdr),
              file = paste0(dout,"/Grid_CohD_Values.nii"),
              datatype = "int16"
            )
          }
        }
      }
    }
  }
  for (i in 1:(2*n)) {
    cat(paste0("...Saving files...",100*round(i/(2*n),4),"%                           \r"))
    if (i <= n) {
      id = str_pad(as.character(i),
                   str_length(as.character(n)),
                   side="left",pad="0")
      g = 1
    } else {
      id = str_pad(as.character((i - n)),
                   str_length(as.character(n)),
                   side="left",pad="0")
      g = 2
    }
    writeNifti(
      asNifti(test_ls_pos[[i]], reference = nii_hdr),
      file = paste0("./NoiseImages/Sample_",dn,"/Positive/G",g,"_Sub",id,".nii"),
      datatype = "int16"
    )
  }
}

saveRDS(r12_list, file=paste0("./NoiseImages/Sample_",dn,"/Positive/samples.rds"))
cat(paste0("                           \r\nSimulation Complete!\n"))