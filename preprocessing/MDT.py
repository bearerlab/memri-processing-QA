#!/python
#############################################################
# Author: Taylor W. Uselman (Bearer Lab)
# Date: 4/7/2025
#
# This python script performs iterative linear alignments of input MR brain images to generate a minimal deformation target (MDT) as described in "Quality Assurance Strategies for Brain State Characterization by MEMRI". by Uselman TW, Jacobs RE, and Bearer EL (2026).
# 
# Note that this script requires FSL to be installed and configured on the same system as Python version be used here. 
#############################################################

import sys,os,os.path
import tkinter as tk
from tkinter import filedialog

# System Arguments Default if not provided
NAvg = 2
dof = [6 , 12]
# If provided checking for correctness
if len(sys.argv)>1:
    print("\nERROR: Invalid input.\n")
    print("Usage: python MDT.py\n")
    sys.exit()

# Select input files for creating MDT
## Note that first iamge provided in list is used as the reference image
root = tk.Tk()
root.withdraw()  # Hide the main window
file_paths = filedialog.askopenfilenames(title="Select input images for MDT")
if len(file_paths) == 0:
  print("\nNo files provided...exiting\n")
  sys.exit()
fnum = len(file_paths)
fnamesout = [None] * fnum
workingdir=os.getcwd()

def append_to_log(log_file_path, text_to_append):
    # Appends a string to the next line of a log file.
    # Args:
    #     log_file_path (str): The path to the log file.
    #     text_to_append (str): The string to append.
    with open(log_file_path, "a") as log_file:
        log_file.write("\n" + text_to_append)

log_file = workingdir + "/MDT.log"

# Running iterations of FSL linear alignments followed by averaging
for i in range(NAvg):
    i1 = i + 1
    if i == 0:
        cdir = workingdir + "/Avg" + str(i1)
        os.mkdir(cdir)
        fslalign = "flirt -in "
        fslalignoptions = " -bins 1000 -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof " + str(dof[0]) + " -cost normmi -interp trilinear -datatype int"
        logtext = "Starting Rigid Body Alignments for First Average using FSL flirt" 
        print("\n"+ logtext)
        append_to_log(log_file, logtext)
    else:
        cdir = workingdir + "/MDT"
        os.mkdir(cdir)
        fslalign = "flirt -in "
        fslalignoptions = " -bins 1000 -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof " + str(dof[1]) + " -cost normmi -interp trilinear -datatype int"
        logtext = "Starting Affine Alignments for MDT using FSL flirt" 
        print("\n"+ logtext)
        append_to_log(log_file, logtext)

    for j in range(fnum):
        fname = file_paths[j]
        if j == 0:
            fslalignref = " -ref " + fname
        basename = os.path.basename(fname)
        fnamesout[j] = cdir + "/Avg" + str(i1) + "_" + basename  
        fslalign_final = fslalign + fname + fslalignref + " -out " + fnamesout[j] + fslalignoptions
        
        logtext = ".....Aligning " + basename
        print(logtext)
        append_to_log(log_file, logtext)
        append_to_log(log_file, fslalign_final)
        os.system(fslalign_final)

    if i1 < NAvg:
        logtext = "Creating Average #" + str(i1) + " using an fslmaths procedure"
        print("\n"+ logtext)
        append_to_log(log_file, logtext)
        AvgName = cdir + "/DataAvg" + str(i1) + ".nii"
    else:
        logtext = "Creating MDA using an fslmaths procedure"
        print("\n"+ logtext)
        append_to_log(log_file, logtext)
        AvgName = cdir + "/MDA.nii"

    final = fnum - 1
    for j in range(fnum):
        fname = fnamesout[j]
        if j == 0:
            fslavg = "fslmaths " + fname + " -add "
        elif j == final:
            fslavg = fslavg + fname + " -div " + str(fnum) + " " + AvgName + " -odt int"
        else:
            fslavg = fslavg + fname + " -add "

    append_to_log(log_file, fslavg)
    os.system(fslavg)

    if os.path.exists(AvgName):
        bnameout = os.path.basename(AvgName)
        logtext = bnameout + " created...\n"
        print(logtext)
        append_to_log(log_file, logtext)
    else:
        bnameout = os.path.basename(AvgName)
        logtext = "ERROR: " + bnameout + " not calculated"
        print("\n"+ logtext + "... exiting...\n")
        append_to_log(log_file, logtext)
        sys.exit()