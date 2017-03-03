source ../async.sh
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
