# async-bash

***async-bash*** is a bash script that implements few asynchronous functions

This script was created to be compatible with bash versions that does not support `coproc`

## functions

1. setTimeout ( excute a function after a particular time has elapsed )
2. setInterval ( execute a function continously after waiting for a particular number of time )
3. async ( execute a function asynchronously )
4. parallel ( execute bunch of functions asynchronously );
5. KillJob ( kills a particular job );


**each of this functions returns a job id , which can be sent a kill signal**


## Usage

***setTimeout*** excute a function after a particular time has elapsed. setTimeout takes a command as the first argument and the number of milliseconds/seconds/minutes/hours that will elapse before the command is executed



```bash
	writeFile() {
		local _f="$1"
		
		[[ -f ${_f} ]] && {
			while read line;do
				echo $line >> my_syslog.txt
			done
		}
	}
	
	setTimeout "readFile /var/log/syslog" 2

    setTimeout "dmesg" 2
```

***setInterval*** execute a function continously after waiting for a particular number of time. This functions takes the same argument as setTimeout


```bash

	setInterval "uptime --pretty" 10

```


***async*** executes a function asynchronously.This command takes 3 arguments, the first argument is the command or function to execute asynchronously, the second argument is a function to invoke when the command has been succesfully excuted, and the third function is invoked when an error occurs. The second argument is been passed the result of the command, while the third argument is passed the return code of the command when it fails

```bash

	success() {
		local _content="$1"
		
		echo ${_content} > my_file.html
	}
	
	error() {
		local _err="$1"
		
		echo ${_err}
	}

	async "curl -s http://google.com/" success error
	
	async "curl -s http://googlejajajaj.com/" success error

```

***parallel*** execute an array of functions asynchronously. This command takes three arguments. The first argument is the main function or command to execute , the result of this command if it is successful will be passed as an argument to the second argument which is an array of functions. The third argument is the final function to execute. If the main function or array of functions fails this third argument is invoked and exits with the exit status of the failed function. The final function ( third argument ) is called last if all the functions executed successfully


```bash

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
	

```


***killJob*** This command kills a job returned by any of the asynchronous function. It takes 2 arguments. The first argument is the job id , while the second argument is the signal to send to the job. If the signal is not specified, the job with the specified id is sent a SIGTERM signal


## license

This program is free software; you can redistribute it andor modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or  (at your option) any later version.
