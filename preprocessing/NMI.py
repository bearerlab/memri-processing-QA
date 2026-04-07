#!/python
#############################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This python script calculate the normalized mutual informaiton (NMI) between a set of images and a template as described in "Quality Assurance Strategies for Brain State Characterization by MEMRI". by Uselman TW, Jacobs RE, and Bearer EL (2026). 
#############################################################

# Normalized Mutual Information calculations of NIfTI image to template
import sys,os,os.path,csv
import tkinter as tk
from tkinter import filedialog
import nibabel as nib
import numpy as np
from sklearn.metrics import normalized_mutual_info_score


THR = 0
NBINS = 256
# If provided checking for correctness
if len(sys.argv)==1:
    print("\nNo threshold or # of bins provided, using defaults of 0 and 256.\n")
else:
    for x in range(1,len(sys.argv)):
        if x%2 != 0:
            if sys.argv[x]=='-thr':
                THR=int(sys.argv[x+1])
            elif sys.argv[x]=='-nbins':
                NBINS=int(sys.argv[x+1])
            elif sys.argv[x]=='-h' or sys.argv[x]=='-help':
                print("Usage: python NMI.py\nOptional:\n\t-thr <Intensity Threshold>\n\t-nbins <# of Histogram Bins>\n")
                sys.exit()
            else:
                print("\nError invalid input.\n")
                print("Usage: python NMI.py\nOptional:\n\t-thr <Intensity Threshold>\n\t-nbins <# of Histogram Bins>\n")
                sys.exit()

root = tk.Tk()
root.withdraw()  # Hide the main window
file_paths = filedialog.askopenfilenames(title="Select images to calculate NMI for")
if len(file_paths) == 0:
  print("\nNo files provided...exiting\n")
  sys.exit()

ref_path = filedialog.askopenfilename(title="Select template to compare images against")
if len(ref_path) == 0:
  print("\nNo file provided...exiting\n")
  sys.exit()

def calculate_nmi_with_binning(data1, data2, num_bins, thr):
    """
    Calculates Normalized Mutual Information (NMI) between two datasets after binning.
    Args:
        data1 (array-like): First dataset.
        data2 (array-like): Second dataset.
        num_bins (int): Number of bins to use for discretization.
    Returns:
        float: Normalized Mutual Information score.
    """
    # Bin Data
    binned_data1 = np.histogramdd(np.where(data1 < thr, 0, data1), bins=num_bins)[0]
    binned_data2 = np.histogramdd(np.where(data2 < thr, 0, data2), bins=num_bins)[0]

    # Flatten the binned data
    flat_data1 = binned_data1.flatten()
    flat_data2 = binned_data2.flatten()
    
    nmi = round(normalized_mutual_info_score(flat_data1, flat_data2),3)
    return nmi

refimg = nib.load(ref_path)
refdata = refimg.get_fdata()
refdatavec = refdata.reshape(-1)

def add_line_csv(csvfname,data):
	with open(csvfname, 'a', newline='') as csvfile:
		writer = csv.writer(csvfile, delimiter=",")
		writer.writerow(data)

filename = os.path.dirname(file_paths[0]) + "/NMI.csv"
fieldnames = ["Image", "NMI"]
for i in range(len(file_paths)):
	if i == 0:
		add_line_csv(filename,fieldnames)
	fname = file_paths[i]
	bfname = os.path.basename(fname)
	alignedimg = nib.load(fname)
	aligneddata = alignedimg.get_fdata()
	aligneddatavec = aligneddata.reshape(-1)
	NMI = calculate_nmi_with_binning(refdatavec,aligneddatavec,NBINS,THR)
	csvline = [bfname, NMI]
	add_line_csv(filename,csvline)