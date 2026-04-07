#!/bin/bash

wdir=$1
if [[ -z $wdir ]] || [[ ! -d $wdir ]];
then
	echo "ERROR: input directory not provided"
	echo "Usage: ./ExtractConfusion.sh <directory>"
	exit 1
fi
# change to working directory
cd $wdir
# Generate CSV to push data to
echo "Path,SPM,Mask,Kernel,CohD,ClusterSize,Total,PosAct,PosPre,TP,NegActBound,PosPreBound" > ConfusionData.csv
# Get Grid Mask
mask='./GridMasks/Grid_CohD_Mask.nii'
# Get Total Voxel Counts
Total=(`fslstats $mask -v`)
# Loop through all SPMs
for f in ./NoiseImages/Sample_1/Positive/SPM_s*/spmT_Pos_*.nii;
do
	# Obtain Directory, Filename, Smoothing Kernel, Effect Size, and Cluster Size from File Name
	dir=${f:32:8};
	f2=$(basename $f);
	sm=${f2:10:3};
	cohd=${f2:19:12};
	clsz=${f2:33:-4};
	#############################
	# FSL fslstats calculations #
	#############################
	# Actual Positives
	PosAct=(`fslstats $mask -n -V`)
	PosAct=${PosAct[0]}
	# Predicted Positives
	PosPre=(`fslstats $f -n -V`)
	PosPre=${PosPre[0]}
	# True Positives
	fslmaths $f -mul $mask ./tmp_data_mask.nii
	TP=(`fslstats ./tmp_data_mask.nii -n -V`)
	TP=${TP[0]}
	# Find relevant smoothing boundary mask 
	NegActBound='NA'
	PosPreBound='NA'
	for maskbound in "${BoundaryMasks[@]}"; do
		if [[ $maskbound == *"${sm}"* ]]; then
			# For Calculation of False Positives/Negatives in Smoothing Boundary
			fslmaths $f -mul $maskbound ./tmp_data_mask.nii
			NegActBound=(`fslstats $maskbound -n -V`)
			PosPreBound=(`fslstats ./tmp_data_mask -n -V`)
			break # Exit the loop after the first match
		fi
	done
	# Push Calculations to CSV
	echo "${dir},${f2},${mask},${sm},${cohd},${clsz},${Total},${PosAct},${PosPre},${TP},${NegActBound},${PosPreBound}" >> ConfusionData.csv;
done
rm -r ./tmp_data_mask.nii
echo ""
echo "Confusion Matrix Data Extraction Complete!"
echo ""