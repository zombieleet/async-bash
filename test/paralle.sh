source ../async.sh
	fArray=( "readFile" "removeSpace" )
	
	mainFunc() {
		local file="${1}"
		
		if [[ -f $file ]]; then
			echo "$file"
		else 
			echo "no such file $file"
			return 1;
		fi
	}

	readFile() {
		local file="$1"
		while read line;do
			echo "$line"
		done <${file}
	}
	
	removeSpace() {
		local line="$1"
		line=$(sed -n 's/\s\+//pg' <<<"${line}")
		echo $line
	}
	
	finalFunc() {
		local succ="$1"
		local error="$2"
		
		if [[ -z ${succ} ]];then
			echo "$error has occured"
		else
			echo "${succ}" >> newfile.txt
		fi
			
	}
	parallel "mainFunc /var/log/syslog" "${fArray[*]}" finalFunc
        parallel "mainFunc /var/log/sysasdflog" "${fArray[*]}" finalFunc

