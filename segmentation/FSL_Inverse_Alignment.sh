#!/bin/bash

# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2026


MDT=$1
ATLAS=$2
LABELS=$3


if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; 
then
    echo "ERROR: Incorrect Usage. Use formatting below, replacing"
    echo "./FSL_Inverse_Alignment.sh <MDT> <ATLAS> <LABELS>"
    exit 1
fi

wdir=""
cnt=1
while [[ ! -d $wdir ]];
do
	[[ $cnt -gt 1 ]] && echo "" && echo "ERROR: ${wdir} is not a valid directory." && echo "Please try again..."
	read -p "Please provide the working directory: " wdir
	cnt=$(($cnt+1))
done

if [[ ! -f "${wdir}/${MDT}" ]] && [[ ! -f "${wdir}/${ATLAS}" ]] && [[ ! -f "${wdir}/${LABELS}" ]]; 
then
    echo "ERROR: Arguments provided are not in working directory"
    exit 1
elif [[ ! -f "${wdir}/${MDT}" ]]; 
then
    echo "ERROR: ${MDT} is not in working directory"
    exit 1
elif [[ ! -f "${wdir}/${ATLAS}" ]]; 
then
    echo "ERROR: ${ATLAS} is not in working directory"
    exit 1
elif [[ ! -f "${wdir}/${LABELS}" ]]; 
then
    echo "ERROR: ${LABELS} is not in working directory"
    exit 1
fi

cd $wdir
[[ ! -d ./00_Forward ]] && mkdir 00_Forward
[[ ! -d ./01_Inverse ]] && mkdir 01_Inverse

MDTn=$(basename $MDT)
ATLASn=$(basename $ATLAS)
LABELSn=$(basename $LABELS)

# Header Information
cp $ATLAS ./00_Forward/h${ATLASn}
cp $LABELS ./00_Forward/h${LABELSn}
for f in ./00_Forward/h*.nii;
do
	fslcpgeom $MDT $f -d
done

# Forward Linear Alignment
if [[ ! -f ./00_Forward/a${MDTn:0:${#MDTn}-4}.mat ]];
then
    echo ""
    echo "Calculating Affine Transform"
    flirt -in $MDT -ref ./00_Forward/h${ATLASn} -out ./00_Forward/a${MDTn} -omat ./00_Forward/a${MDTn:0:${#MDTn}-4}.mat -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -cost normmi -interp spline -verbose 0
fi

# Forward Nonlinear Alignment
if [[ ! -f ./00_Forward/waMDT2ATLAS.nii ]];
then
    echo ""
    echo "Calculating Nonlinear Warp Field"
    fnirt --ref=./00_Forward/h${ATLASn} --in=$MDT --aff=./00_Forward/a${MDTn:0:${#MDTn}-4}.mat --cout=./00_Forward/waMDT2ATLAS --logout=./00_Forward/InvWarp.log --config=./mdt2atlas_config.cnf --verbose
    #--ref=./00_Forward/h${ATLASn} --in=$MDT --aff=./00_Forward/a${MDTn:0:${#MDTn}-4}.mat --cout=./00_Forward/waMDT2ATLAS --logout=./00_Forward/InvWarp.log --imprefm=0 --impinm=0 --imprefval=0 --impinval=0 --subsamp=4,4,2,2,1,1 --miter=5,10,5,10,5,10 --infwhm=4,3,2,2,1,0 --reffwhm=4,3,2,2,1,0 --lambda=300,150,100,50,40,30 --estint=1,1,1,1,1,0 --warpres=1,1,1 --splineorder=3 --ssqlambda=1 --jacrange=0.01,100 --regmod=bending_energy --intmod=global_non_linear --intorder=5 --biasres=50,50,50 --biaslambda=1000 --numprec=double --interp=linear --refderiv=0 --applyrefmask=0,0,0,0,0,0 --applyinmask=0 --verbose
    #--warpres=1,1,1 --splineorder=3 --numprec=double --regmod=bending_energy --intmod=global_non_linear --intorder=5 --subsamp=2 --infwhm=3 --reffwhm=0 --miter=16 --lambda=50 --ssqlambda=1 --estint=1 --verbose 
    #--subsamp=4,2,1,1
    # --infwhm=6,3,1.5,0
    #--config=FSL_Inverse_Alignment_Config.cnf
fi
# [[ ! -f ./00_Forward/wa${MDTn:0:${#MDTn}-4}.nii ]] && exit 1

# Inverse Warp
echo ""
echo "Calculating Inverse"
invwarp --ref=$MDT --warp=./00_Forward/waMDT2ATLAS --out=./01_Inverse/iwaATLAS2MDT

# Apply Inverse Warp
echo ""
echo "Applying inverse warp on atlas grayscale"
applywarp --ref=$MDT --in=./00_Forward/h${ATLASn} --warp=./01_Inverse/iwaATLAS2MDT --out=./01_Inverse/iwa${ATLASn} --interp=spline
echo ""
echo "Applying inverse warp on atlas label"
applywarp --ref=$MDT --in=./00_Forward/h${LABELSn} --warp=./01_Inverse/iwaATLAS2MDT --out=./01_Inverse/iwa${LABELSn} --interp=nn

# Rerverse Header
# echo ""
# echo "Managing Header Information"
# cp ./01_Inverse/iwa_${ATLASn} ./01_Inverse/mdt_${ATLASn}
# fslcpgeom $MDT ./01_Inverse/mdt_${ATLASn} -d

# cp ./01_Inverse/iwa_${LABELSn} ./01_Inverse/mdt_${LABELSn}
# fslcpgeom $MDT ./01_Inverse/mdt_${LABELSn} -d


echo ""
echo ""
echo "Inverse Alignment of Atlas to Data Complete!"
echo ""
echo ""