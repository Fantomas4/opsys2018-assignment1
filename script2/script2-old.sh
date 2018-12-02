#!/bin/bash

input_zip_file_dir="./input_file.tar.gz"
unzipped_files_dir="./unzipped_files"
repos_clone_dir="./assignments"
txt_files_dir_array=()
repo_names_array=()
wanted_repo_structure=()

# Populate the wanted_repo_structure array with the
# wanted directories
wanted_repo_structure+=(".")
wanted_repo_structure+=("./dataA.txt")
wanted_repo_structure+=("./more")
wanted_repo_structure+=("./more/dataB.txt")
wanted_repo_structure+=("./more/dataC.txt")

# Check if the assignments directory exists. If it doesn't, create it.
mkdir -p "$repos_clone_dir"

# Unzip the given .tar.gz file
unzip $input_zip_file_dir -d $unzipped_files_dir > /dev/null 2>&1

# Find all .txt files in the unzipped_files folder and store them into an array
mapfile -t txt_files_dir_array < <( find ./unzipped_files -type f -name "*.txt" )

# For every .txt file directory stored in txt_files_dir_array, read the git repo url the given
# .txt file contains
for txt_dir in "${txt_files_dir_array[@]}"
do

	# Find the first line in the .txt file that is NOT a comment
	# and contains a git repo url
	while IFS= read -r txt_line 
	do	
		# ${input_url:0:1} expands to the substring starting at position 
		# 0 of length 1 (gives us the first character of the line)
		if [ "${txt_line:0:1}" != "#" ]; then
			repo_url=("$txt_line")
			break
		fi
	done < "$txt_dir"
	
	# Swith to the assignments directory
	cd "$repos_clone_dir"
	
	# Attempt to clone the given repo_url from github
	git clone $repo_url > /dev/null 2>&1
	clone_status=$? 
	
	# Switch back to the script's main directory
	cd ..

	if [ $clone_status == 0 ]; then
		
		# Print message to stdout
		echo "$repo_url: Cloning OK"

	else
		# Print message to stderr
		echo "$repo_url: Cloning FAILED" >&2

	fi

done

#echo -e "\n"

# Get the names of all the repositories that were successfully cloned inside the assignments folder and
# put them inside the repo_names_array
mapfile -t repo_names_array < <( find ./assignments -maxdepth 1 -mindepth 1 \
    -type d -exec basename {} \; )

# For every repo that was cloned, 
# print its collective results (status)
# and check whether its structure conforms with
# the wanted repository structure
for repo_name in "${repo_names_array[@]}"
do
	num_of_dirs=()
	
	# Change directory to the repo's folder
	cd "./assignments/$repo_name"
	
	repo_structure=($(find . -not -iwholename '*.git*'))
	
	# Get the repo's collective results
	num_of_dirs=($(find . -not -iwholename '*.git*' -not -path '.' -type d))
	num_of_txt_files=($(find . -type f -name "*.txt"))
	num_of_other_files=($(find . -not -iwholename '*.git*' -not -name "*.txt" -not -path '.' -not -type d))
	
	# Change directory back to the project's main folder
	cd ".."
	cd ".."

	# Print the repo's collective results
	echo $repo_name:
	echo "Number of directories: ${#num_of_dirs[@]}"
	echo "Number of txt files: ${#num_of_txt_files[@]}"
	echo "Number of other files: ${#num_of_other_files[@]}"
	
	# Check if the current repo's structure conforms to
	# the wanted repo structure
	
	correct_structure=1
	
	if [ ${#repo_structure[@]} == ${#wanted_repo_structure[@]} ]; then
	
		for wanted_dir in "${wanted_repo_structure[@]}"
		do
			#echo "wanted_dir: $wanted_dir"
			
			found_wanted_dir=0
		
			for test_dir in "${repo_structure[@]}"
			do
				#echo "test_dir: $test_dir"
				
				if [ $test_dir == $wanted_dir ]; then
					found_wanted_dir=1
					break
				fi
				
			done
			
			if [ $found_wanted_dir == 0 ]; then
				correct_structure=0
			fi
			
		done
		
	else
		
		# If the amount of directories of the repo under test is different than
		# the amount of directories of the wanted repo structure, then the structure
		# is NOT correct
		correct_structure=0
	
	fi
	
	if [ $correct_structure == 1 ]; then
		
		echo "Directory structure is OK."
	
	else
		echo "Directory structure is NOT OK." >&2
	
	fi
	
done

# Delete the unzipped_files folder before exiting the script
rm -rf $unzipped_files_dir


