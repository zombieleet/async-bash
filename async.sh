#!/usr/bin/env bash


# This script implements 3 asynchronous function
# setTimeout
# setInterval
# async
# killJob function is not asynchronous

# check the README.md for information on how to use this script

declare -a JOB_IDS

declare -i JOBS=1;

#source ./functions.sh;

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

    (
	sleep ${after}
	$command
    ) &
    
    JOB_IDS+=( "${JOBS} ${command}" )
    

    
    read -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"
    
    echo ${__kunk__}

    : $(( JOBS++ ))

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

    {
	while sleep ${after};do
	    $command
	done
    } &
    
    JOB_IDS+=( "${JOBS} ${command}" )
    
    read -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"

    echo ${__kunk__}

    : $(( JOBS++ ))
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
	}
	
    }
    
    

    for job in ${JOB_IDS[@]};do
	
	# increment job to 1 since array index starts from 0
	read -d " " -a __kunk__ <<< "${JOB_IDS[$job]}"
	
	(( __kunk__ == jobToKill )) && {
	    

	    read -d " " -a __kunk__ <<< "${JOB_IDS[$job]}"
	    
	    kill -${signal} %${__kunk__}
	    
	    local status=$?
	    
	    (( status != 0 )) && {
		

		printf "cannot kill %s %d\n" "${JOB_IDS[$job]}" "${__kunk__}"
		
		return 1;
	    }

	    printf "%d killed with %s\n" "${__kunk__}" "${signal}" 
	    
	    return 0;
	}
	
    done    
}

function async() {
    
    local commandToExec="$1"
    local resolve="$2"
    local reject="$3"

    [[ -z "$commandToExec" ]] || [[ -z "$reject" ]] || [[ -z "$resolve" ]] && {
	printf "%s\n" "Insufficient number of arguments";
	return 1;
    }

    
    
    local __temp=( "$commandToExec" "$reject" "$resolve" )
    
    
    for _c in "${__temp[@]}";do

	
	read -d " " comm <<<"${_c}"
	
	type "${comm}" &>/dev/null
	
    	local status=$?
	
    	(( status != 0 )) && {
    	    printf "\"%s\" is neither a function nor a recognized command\n" "${_c}";
	    unset _c
	    return 1;
    	}
	
    done
    
    unset __temp ;  unset _c
    
    {
	local __result=$($commandToExec)
	
	status=$?
	
	(( status == 0 )) && {
	    $resolve "${__result}"
	} || {
	    $reject "${status}"
	}
    } &


    
    JOB_IDS+=( "${JOBS} ${command}" )
    
    read -d " " -a __kunk__ <<< "${JOB_IDS[$(( ${#JOB_IDS[@]} - 1))]}"
    
    echo ${__kunk__}
    

    : $(( JOBS++ ))
    
}
