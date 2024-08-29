# Script to clone SUMMA
# Reads GitHub location of the fork and desired install location from 'summaWorkflow_public/0_control_files/control_active.txt'


# --- Settings
# Find the line with the GitHub url
setting_line=$(grep -m 1 "^github_ostrich" ../0_control_files/control_active.txt) # -m 1 ensures we only return the top-most result. This is needed because variable names are sometimes used in comments in later lines

# Extract the url
github_url=$(echo ${setting_line##*|}) # remove the part that ends at "|"
github_url=$(echo ${github_url%%#*}) # remove the part starting at '#'; does nothing if no '#' is present

# Find the line with the destination path
dest_line=$(grep -m 1 "^install_path_ostrich" ../0_control_files/control_active.txt) 

# Extract the path
ostrich_path=$(echo ${dest_line##*|}) 
ostrich_path=$(echo ${ostrich_path%%#*}) 


# Specify the default path if needed
if [ "$ostrich_path" = "default" ]; then
  
 # Get the root path
 root_line=$(grep -m 1 "^root_path" ../0_control_files/control_active.txt)
 root_path=$(echo ${root_line##*|}) 
 root_path=$(echo ${root_path%%#*}) 
 ostrich_path="${root_path}/installs/ostrich/"
fi

# --- Clone
# Clone the 'develop' branch of the specified SUMMA repository
echo "cloning ${github_url} into ${ostrich_path}"
git clone --single-branch --branch v21.03.16 "$github_url" "$ostrich_path"

# Navigate into the new 'ostrich' dir
owd=$(pwd)
cd "$ostrich_path"

# Navigate back to the old working directory where this script is found
cd "$owd"

# --- Code provenance
# Generates a basic log file in the domain folder and copies the control file and itself there.
# Make a log directory if it doesn't exist
log_path="${ostrich_path}/_workflow_log/"
mkdir -p $log_path

# Log filename
today=`date '+%F'`
log_file="${today}_clone_log.txt"

# Make the log
this_file="3a_clone_ostrich.sh"
echo "Log generated by ${this_file} on `date '+%F %H:%M:%S'`"  > $log_path/$log_file # 1st line, store in new file
echo 'Cloned ostrich into parent directory' >> $log_path/$log_file # 2nd line, append to existing file

# Copy this file to log directory
cp $this_file $log_path










