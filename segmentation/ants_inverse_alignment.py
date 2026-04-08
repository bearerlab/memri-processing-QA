#!/usr/bin/env python3
"""
Advanced Normalization Tools (ANTs) Inverse Alignment: # ANTs python wrapper to perform inverse alignment of MEMRI based InVivo Atlas to dataset space using ATNsPy ants.registration() and ants.apply_transforms(). 

This function performs a step-wise linear to nonlinear registration of the InVivo Mouse brain Atlas to the prodided MDT/dataset average, then applies the inverse transforms to warp the atlas grayscale and its label image to the dataset space. The step-wise procedure includes rigid followed by affine linear alignment, then a deformable SyN (Symmetric Normalization) step. We have performed testing on iteration number, sampling factors, and smoothing sigmas to optimize the registration for our T1w MEMRI data. The specific parameters used may need to be adjusted for other modalities and resolutions.

Note that ANTs registration does not read NIfTI image matrices/headers as nibabel, or other processing softwares (e.g, FSL, SPM) do, which leads to potential orientation and translation/padding issues during registration or resampling. It is recommended to ensure that all images (Atlas, labels and Data template) are have similar orientation and FOV. In this code, padding is not automated and was manually determined and applied in a separate step using ants.pad_image() prior to alignment. 

Example:
    $ python ants_inverse_alignment.py <Path to InVivo Atlas Grayscale> <Path to InVivo Atlas Labels> <Path to MDT/Dataset Average>

Dependencies:
    ants (ANTsPy - primary NIfTI image registration package)
    pickle (for saving registration results)

Attributes:
    __author__ = "Taylor W. Uselman"
    __date__ = "8 December 2025"
    __credits__ = "GitHub Copilot and Google AI for coding support"
    __license__ = "MIT"
    __version__ = "Version 1.0.0"
    __maintainer__ = "Bearer Lab"
    __email__ = "elaine.bearer@gmail.com"
"""

# ANTS Python for Inverse InVivo Atlas Alignment



# Import requirements (ants imported within function to prevent unnecessary load if not used)
import os
import sys
import pickle

if sys.argv[1] in ("-h", "--help"):
    print("\nOverview: This script performs an inverse alignment of the InVivo Atlas to dataset space using ANTsPy.")
    print("Usage: python ants_inv_align.py <Path to InVivo Atlas Grayscale> <Path to InVivo Atlas Labels> <Path to MDT/Dataset Average>\n")
    sys.exit(1)
elif len(sys.argv) == 1:
    print("\nError: No images provided.")
    print("Usage: python ants_inv_align.py <Path to InVivo Atlas Grayscale> <Path to InVivo Atlas Labels> <Path to MDT/Dataset Average>\n\n")
    sys.exit(1)
elif not os.path.isfile(sys.argv[1]):
    print(f"Error: InVivo Atlas Grayscale Image '{sys.argv[1]}' does not exist")
    sys.exit(1)
elif not os.path.isfile(sys.argv[2]):
    print(f"Error: InVivo Atlas Label Image '{sys.argv[2]}' does not exist")
    sys.exit(1)
elif not os.path.isfile(sys.argv[3]):
    print(f"Error: MDT/Dataset Average file '{sys.argv[3]}' does not exist")
    sys.exit(1)
else:
     atlas_path = sys.argv[1]
     atlas_label_path = sys.argv[2]
     mdt_path = sys.argv[3]


def inverse_alignment(atlas_path, atlas_label_path, mdt_path):
        """This script is a wrapper for ANTSpy ants.registration() to perform an inverse alignment of the InVivo Atlas to dataset space using Advanced Normalization Tools (ANTs)"""
        # imports 
        import ants
        # Load images (replace with your actual image paths)
        # The goal is to warp the moving image to the fixed image space, and then invert that process.
        mdt = ants.image_read(mdt_path)
        atlas = ants.image_read(atlas_path)
        atlas_label = ants.image_read(atlas_label_path)

        # 1. Perform forward linear and then nonlinear (SyN) alignment. The 'SyN' transform type includes a rigid, then affine, then deformable SyN stage. This generates all required transforms (forward and inverse)
        # # For setting smoothing resolution/scale
        resolution = round(mdt.spacing[1],2) # in mm (assumes isotropic voxels)
        typeoftransform = 'SyNAggro' # Using 'SyNRA' for Rigid + Affine + Deformation (SyN) with mutual information optimization

        # For the affine stage: 
        my_aff_iterations = [1000, 500, 250, 250]
        my_aff_shrink_factors = [4, 2, 1, 1] # downsampling factors
        my_aff_smoothing_sigmas = [num * resolution for num in [3, 1.5, 1.5, 0]] # in millimeters

        # For the deformable (SyN) stage
        my_syn_iterations = [1000, 500, 250, 250]
        my_syn_shrink_factors = [4, 2, 1, 1] # downsampling factors
        my_syn_smoothing_sigmas = [num * resolution for num in [3, 1.5, 1.5, 0]] # in millimeters

        print("\nPerforming forward registration at MDA to Atlas...\n\n")

        registration_results = ants.registration(
            fixed = atlas,
            moving = mdt,
            type_of_transform = typeoftransform,
            # Affine parameters
            aff_iterations       = my_aff_iterations, 
            aff_shrink_factors   = my_aff_shrink_factors,
            aff_smoothing_sigmas = my_aff_smoothing_sigmas,
            # SyN parameters
            reg_iterations       = my_syn_iterations, 
            reg_shrink_factors   = my_syn_shrink_factors,
            reg_smoothing_sigmas = my_syn_smoothing_sigmas, 
            verbose = True
        )

        # The output dictionary contains the warped image and transform file paths: 
        # 1. 'warpedmovout' is the moving image warped to the fixed space (forward warp result);
        # 2. 'fwdtransforms' is the list of forward transforms; 
        # 3. 'invtransforms' is the list of inverse transforms


        print("\nForward registration complete. Applying inverse transforms of Atlas and Labels to MDA...\n\n")

        # 2. Apply the inverse transforms to get the warped moving image
        # This step is automatically done and stored in registration_resuls ['warpedmovout']
        invwarp_atlas = ants.apply_transforms(
            fixed  = mdt,
            moving = atlas,
            transformlist = registration_results['invtransforms'],
            interpolator = 'linear'
        )

        invwarp_labels = ants.apply_transforms(
            fixed  = mdt,
            moving = atlas_label,
            transformlist = registration_results['invtransforms'],
            interpolator = 'nearestNeighbor'
        )
        # Verify the result
        # ants.plot(fi, warped_moving_image_forward, axis=2, overlay=True, title="Fixed Image with Forward-Warped Moving Image Overlay")

        print("\nSaving and cleaning up...\n\n")
        # Save Results
        ## Define base path based on atlas
        base_path = os.path.dirname(atlas_path)
        ## Inverse Warped Atlas and Labels
        ### Atlas
        invwarp_atlas.image_write(os.path.join(base_path,"iwInVivo2MDA.nii"))
        ### Labels
        invwarp_labels.image_write(os.path.join(base_path,"iwInVivoLabels2MDA.nii"))
        ## Registration Results (includes transforms)
        result_path = os.path.join(base_path,"InverseWarpOutput.pkl")
        with open(result_path, 'wb') as file:
            pickle.dump(registration_results, file)

        print(f"Inverse alignment complete. Results saved to {base_path}")


if __name__ == "__main__":
    # Run inverse alignment
    inverse_alignment(atlas_path, atlas_label_path, mdt_path)