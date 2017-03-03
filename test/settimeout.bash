source ../async.sh
readFile() {
	local _f="$1"
		
	[[ -f ${_f} ]] && {
		while read line;do
			echo $line
		done
	}
}
	
setTimeout "readFile /var/log/syslog" 8
setTimeout "dmesg" 8
