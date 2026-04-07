#!/python

# Author: Taylor W. Uselman (Bearer Lab)
# Date: 9/3/2025

# This Python script installs Python packages using pip. 
# Note that if using an alternative environment or installation package other than pip,
# you will need to install the packages listed in packages_to_install on lines 33 manually.

# Current versions of MRI processing and analysis functions only require the 'pandas' package
# in addition to pre-installed modules in base Python. Later versions will be able to install
# additional packages by extending the list on line 33.

import subprocess
import sys

def install_packages(package_list):
    """
    Installs a list of Python packages using pip.
    """
    for package in package_list:
        try:
            print(f"Attempting to install/upgrading: {package}")
            # Use sys.executable to ensure pip associated with the current Python environment is used
            subprocess.check_call([sys.executable, "-m", "pip", "install", "--upgrade", package])
            print(f"Successfully installed/upgraded: {package}")
        except subprocess.CalledProcessError as e:
            print(f"Error installing/upgrading {package}: {e}")
        except Exception as e:
            print(f"An unexpected error occurred while installing/upgrading {package}: {e}")


packages_to_install = [
    "tkinter",
    "nibabel",
    "numpy",
    "pandas",
    "sklearn"
]

install_packages(packages_to_install)
