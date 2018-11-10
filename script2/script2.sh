#!/bin/bash

input_zip_file_dir="./input_file.tar.gz"
unzipped_files_dir="./unzipped_files"
txt_files_dir_array=()

# Unzip the given .tar.gz file
#unzip $input_zip_file_dir -d $unzipped_files_dir

# Find all .txt files and store them into an array
mapfile -t txt_files_dir_array < <( find . -type f -name "*.txt" )

echo "----------------------- DIAG START -----------------------"

for txt_dir in "${txt_files_dir_array[@]}"
do
	#echo "mpika3-------------------"
	#echo $queue_entry
	#echo "-------------------------"
	echo $txt_dir
	#echo "" >> $webpages_queue_dir

done

echo "----------------------- DIAG END -----------------------"

# For every .txt file directory stored in txt_files_dir_array, read the git repo url the given
# .txt file contains

for txt_dir in "${txt_files_dir_array[@]}"
do
	#echo $txt_dir
	
	#read -r repo_url < "$txt_dir"
	
	#echo $repo_url
	
	
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
			echo $repo_url
			break
		fi
	done < "$txt_dir"
	

	

done


