#!/usr/bin/env bash

declare -a JOB_IDS

setTimeout() {
    local command="$1"
    local after="$2"
    
    declare -F $command &>/dev/null
    local status=$?

    { (( status != 0 )) || [[ -z "$command" ]] ; } && {
	printf "%s\n" "\"${command}\" function has not been defined"

	return 1;
    }
    
    [[ ! $after =~ ^[[:digit:]]+$ ]] && {
	printf "%s\n" "require an integer as the second argument but got \"$after\" "
	
	return 1;
    }

    {
	sleep ${after}
	$command
    } &
    
    JOB_IDS+=( $! )
}

setInterval() {
    
    local command="$1"
    local after="$2"
    
    declare -F $command &>/dev/null
    local status=$?

    { (( status != 0 )) || [[ -z "$command" ]] ; } && {
	printf "%s\n" "\"${command}\" function has not been defined"

	return 1;
    }
    
    [[ ! $after =~ ^[[:digit:]]+$ ]] && {
	printf "%s\n" "require an integer as the second argument but got \"$after\" "
	
	return 1;
    }
    
}

killJob() {
    
    local jobToKill="$1"
    local signal="$2"
    
    signal=${signal^^}
    
    [[ ! $jobToKill =~ ^[[:digit:]]+$ ]] && {
	
	printf "%s\n" "\"$jobToKill\" should be an integer ";
	
	return 1;
    }
    
    
    {
	[[ -z "$signal" ]]  && {
	    signal="SIGTERM"
	}
    } || {
	# for loop worked better than read line in this case
	local __al__signals=$(kill -l);
	local isSig=0;
	for sig in ${__al__signals};do
	    
	    [[ ! $sig =~ ^[[:digit:]]+\)$ ]] && {
		[[ $signal == $sig ]] && {
		    isSig=1;
		    break;
		}
	    }
	done
	
	(( isSig != 1 )) && {
	    signal="SIGTERM"
	    echo "$signal"
	}
	
    }
    
    
    for job in ${!JOB_IDS[@]};do
	
	(( job == jobToKill )) && {
	    :
	}
	
    done
}
killJob 5

function s() {
    while read line;do
	echo $line
    done < /etc/passwd
}

#setTimeout s 10

#echo ${JOB_IDS[0]}


#echo "Hi"

