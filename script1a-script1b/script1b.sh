#!/bin/bash

webpage_input_dir="$1"
webpages_queue_dir="./webpages_queue"

# array that will be used to hold the initial webpage data entries, loaded from the webpages_queue file
initial_webpages_queue_array=()

# array that will be used to hold the webpage entries loaded from the input_webpages file
webpages_input_array=()

# final_webpages_queue_array will be used to store the refreshed and up-to-date
# data of the initial entries saved in initial_webpages_queue_array.
final_webpages_queue_array=()


################################# FUNCTIONS #################################

function process_input_url {
	
	local target_url=$1
	
	# Check whether the given url already exists in the initial_webpages_queue_array
	found_url=0
	
	for queue_entry in "${initial_webpages_queue_array[@]}"
	do
		# get the saved webpage url, md5sum and status seperately
		entry_data=($queue_entry)
		queue_url=${entry_data[0]}
		url_md5sum=${entry_data[1]}
		url_status=${entry_data[2]}
		
		if [ "$target_url" = "$queue_url" ]; then
			# Found the target url in the url_queue"
			#echo "Found the target url in the url_queue"
			found_url=1
			
			# Check if the target url is reachable
			# 0 stands for true, 1 for false
			target_reachable=0
			curl $target_url -s -f -o /dev/null || target_reachable=1
			
			if [ $target_reachable -eq 0 ]; then
				# target url was found to be reachable!
				
				current_status="REACHABLE"
				
				# *** Check the webpage for changes ***
				# Download the currect webpage's md5sum and compare it 
				# to the stored md5sum for this webpage.
				current_md5sum=($(wget -q -O - $target_url | md5sum))
				
				
				if [ "$url_md5sum" != "$current_md5sum" ] || [ "$url_status" == "UNREACHABLE" -a "$current_status" == "REACHABLE" ]; then
					# the webpage HAS changed
					# the webpage's md5sum we retrieved from the file is different compared to the one we generated now, so we conclude the webpage has changed
					# or
					# target was saved as UNREACHABLE, but during the last check was found to be REACHABLE, so we assume the webpage has changed

					#echo "Detected changes in the given webpage:"
					echo $queue_url
					
					# append the changed webpage's url and md5sum as a new entry to the webpages_queue_dir file
					# (update the webpage's md5sum number)
					echo "$target_url $current_md5sum $current_status" >> $webpages_queue_dir
				
				else 
					# the webpage has not changed, so we simply append it to our the webpages_queue_dir file
					echo "$target_url $url_md5sum $url_status" >> $webpages_queue_dir
			
				fi
				
			
			else
				# target url was found to be unreachable
				# append the unreachable webpage's url and (old) md5sum as a new entry to the final_webpages_queue_array
				current_status="UNREACHABLE"
				echo "$target_url $url_md5sum $current_status" >> $webpages_queue_dir
				
			fi

				
		fi
		
	done
	
	if [ $found_url = 0 ]; then
		# Target url was NOT found in the url_queue
		#echo "Target url was NOT found in the url_queue"
		
		# Check if the target url is reachable
		# 0 stands for true, 1 for false
		target_reachable=0
		curl $target_url -s -f -o /dev/null || target_reachable=1
		
		if [ $target_reachable -eq 0 ]; then
			# target url was found to be reachable!
			
			# generate the webpage's md5sum
			url_md5sum=($(wget -q -O - $target_url | md5sum))
			
			# status indicates whether we were able to reach the webpage during our last attempt
			status="REACHABLE"

			# append the webpage's url and md5sum as a new entry to the webpages_queue_dir file
			echo "$target_url $url_md5sum $status" >> $webpages_queue_dir

			echo "$target_url INIT"
		else
			# target url was found to be unreachable
			echo "$target_url FAILED" >&2
			
			# status indicates whether we were able to reach the webpage during our last attempt
			status="UNREACHABLE"
			
			url_md5sum="------------------"
			
			# append the webpage's url and (empty) md5sum as a new entry to the webpages_queue_dir file
			echo "$target_url $url_md5sum $status" >> $webpages_queue_dir
			
		fi

	fi

}


####################### MAIN ####################### 

# Load all the webpage entries from the webpages_input file to an array
while IFS= read -r input_url
do	
	# ${input_url:0:1} expands to the substring starting at position 
	# 0 of length 1 (gives us the first character of the line)
	if [ "${input_url:0:1}" != "#" ]; then
		webpages_input_array+=("$input_url")
	fi
	
done < $webpage_input_dir

# Check if the webpages_queue.txt file exists in the webpages_queue_dir directory.
# If it doesn't, then create it.
if [ ! -f "$webpages_queue_dir" ]; then
    #echo "File not found!"
	touch webpages_queue
fi

# Load all the webpage entries from the webpages_queue file to an array
while IFS= read -r file_entry
do
	initial_webpages_queue_array+=("$file_entry")
	
done < $webpages_queue_dir

# Empty the webpages_queue file
> $webpages_queue_dir

# Iterate through all the webpage entries of the webpages_input_array,
# checking the webpages one by one

for input_url in "${webpages_input_array[@]}"
do
	process_input_url $input_url &
	
done
wait

















