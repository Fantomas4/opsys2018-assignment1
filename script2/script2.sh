#!/bin/bash

input_zip_file_dir="./input_file.tar.gz"
unzipped_files_dir="./unzipped_files"
repos_clone_dir="./assignments"
txt_files_dir_array=()
repo_names_array=()

# Unzip the given .tar.gz file
unzip $input_zip_file_dir -d $unzipped_files_dir > /dev/null 2>&1

# Find all .txt files in the unzipped_files folder and store them into an array
mapfile -t txt_files_dir_array < <( find ./unzipped_files -type f -name "*.txt" )

# For every .txt file directory stored in txt_files_dir_array, read the git repo url the given
# .txt file contains
for txt_dir in "${txt_files_dir_array[@]}"
do
	#echo $txt_dir

	# Find the first line in the .txt file that is NOT a comment
	# and contains a git repo url
	while IFS= read -r txt_line 
	do	
		# ${input_url:0:1} expands to the substring starting at position 
		# 0 of length 1 (gives us the first character of the line)
		if [ ${txt_line:0:1} = "#" ]; then
			echo "Found # so line was discarded"
		else
			repo_url=("$txt_line")
			#echo $repo_url
			break
		fi
	done < "$txt_dir"

	# Extract the repository name from the repository url
	repo_name="$(basename $repo_url)"
	
	# Add the current repository's name to the repo_names_array
	repo_names_array+=("$repo_name")
	
	# Attempt to clone the given repo_url from github
	git clone $repo_url "$repos_clone_dir/$repo_name" > /dev/null 2>&1

	clone_status=$? 
	#echo $clone_status

	if [ $clone_status == 0 ]; then
		
		# Print message to stdout
		echo "$repo_url: Cloning OK"

	else
		# Print message to stderr
		echo "$repo_url: Cloning FAILED" >&2

	fi
	
	#echo -e "\n"

done

echo -e "\n"

# For every repo that was cloned, print its collective results (status)
for repo_name in "${repo_names_array[@]}"
do
	echo $repo_name:
	echo "Number of directories : "
	echo "Number of txt files : "
	echo "Number of other files : "
	echo -e "\n"

done

# Delete the unzipped_files folder before exiting the script
rm -rf $unzipped_files_dir


