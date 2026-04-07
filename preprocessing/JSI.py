#!/python
#############################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This python script calculate the Jaccard Similarity Index (JSI) between a set of images and a template as described in "Quality Assurance Strategies for Brain State Characterization by MEMRI". by Uselman TW, Jacobs RE, and Bearer EL (2026). 
#############################################################

# Jaccard calculations of NIfTI image to template
import sys,os,os.path,csv
import tkinter as tk
from tkinter import filedialog
import nibabel as nib
import numpy as np

THR = 0
# If provided checking for correctness
if len(sys.argv)==1:
    print("\nNo Threshold provided, using default of 0.\n")
else:
	for x in range(1,len(sys.argv)):
		if x%2 != 0:
			if sys.argv[x]=='-thr':
				THR=int(sys.argv[x+1])
			elif sys.argv[x]=='-h' or sys.argv[x]=='-help':
				print("Usage: python JacSim.py\nOptional:\n\t-thr <Intensity Threshold>\n")
				sys.exit()
			else:
				print("\nError invalid input.\n")
				print("Usage: python JacSim.py\nOptional:\n\t-thr <Intensity Threshold>\n")
				sys.exit()

root = tk.Tk()
root.withdraw()  # Hide the main window
file_paths = filedialog.askopenfilenames(title="Select images to calculate JSI for")
if len(file_paths) == 0:
  print("\nNo files provided...exiting\n")
  sys.exit()

ref_path = filedialog.askopenfilename(title="Select template to compare images against")
if len(ref_path) == 0:
  print("\nNo file provided...exiting\n")
  sys.exit()

def jaccard_similarity(vec1, vec2, thr):
    """
    Calculates the Jaccard similarity between two vectors.
    Args:
        vec1: The first vector (list or set).
        vec2: The second vector (list or set).
    Returns:
        The Jaccard similarity (float) between 0 and 1.
    """
    bvec1 = np.where(np.array(vec1) > thr, 1, 0)
    bvec2 = np.where(np.array(vec2) > thr, 1, 0)
    intersection = sum(np.where(np.array(bvec1 * bvec2) > 0, 1, 0))
    union = sum(np.where(np.array(bvec1 + bvec2) > 0, 1, 0))
    return round(intersection / union, 3) if union > 0 else 0.0

refimg = nib.load(ref_path)
refdata = refimg.get_fdata()
refdatavec = refdata.reshape(-1)

def add_line_csv(csvfname,data):
	with open(csvfname, 'a', newline='') as csvfile:
		writer = csv.writer(csvfile, delimiter=",")
		writer.writerow(data)

filename = os.path.dirname(file_paths[0]) + "/JacSim.csv"
fieldnames = ["Image", "JSI"]
for i in range(len(file_paths)):
	if i == 0:
		add_line_csv(filename,fieldnames)
	fname = file_paths[i]
	bfname = os.path.basename(fname)
	alignedimg = nib.load(fname)
	aligneddata = alignedimg.get_fdata()
	aligneddatavec = aligneddata.reshape(-1)
	JSI = jaccard_similarity(refdatavec,aligneddatavec,THR)
	csvline = [bfname, JSI]
	add_line_csv(filename,csvline)