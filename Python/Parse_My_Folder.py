# Asks user to enter Directory path to sort files by extension and year/month of file creation time.
# Scans only top-level files in the specified folder.
# Creates folders like source_dir/txt, source_dir/pdf, source_dir/no_extension, etc.
# Copies each file into the corresponding folder if it’s not already there.

import os
import shutil
from datetime import datetime

def Copy_files_by_extension(source_dir):
    
    for filename in os.listdir(source_dir):                                  # Get the list of all files and directories in the source directory
        file_path = os.path.join(source_dir, filename)                       # Construct full file path for each
        if not os.path.isfile(file_path):
            continue
        ext = os.path.splitext(filename)[1].lower().strip('.')               # Get the file extension
        if not ext:
            ext = "no_extension"
        creation_time = os.path.getctime(file_path)
        year_month = datetime.fromtimestamp(creation_time).strftime("%Y-%m") # Get the year and month of the file creation time
        ext_date_folder = os.path.join(source_dir, ext, year_month)          # Create a new directory for the file extension if it doesn't exist
        os.makedirs(ext_date_folder, exist_ok=True)
        destination = os.path.join(ext_date_folder, filename)                # Construct the destination file path
        if not os.path.exists(destination):
            shutil.copy2(file_path, destination)                             # Only copy the file to the new directory if it doesn't already exist
source_dir = input("Enter the full path to the folder to parse: ")           # Example: C:\Users\Johndoe\Desktop\test
Copy_files_by_extension(source_dir)