#! /bin/bash

# 1. Create a “daemon supervisor”

if [ $# -lt 4 ]
then
	echo "ERROR: Invalid usage of script"
	echo "USAGE: ./supervisor <second> <max_attempts> <process name> <interval>"
	exit 1
fi

second=$1
max_attempts=$2
process=$3
interval=$4
log_file="process.log"

attempts=0

if ! 	[ -z "${second//[0-9]}" ]; 				then echo "Seconds should be integer only"; 		exit 1; fi
if ! 	[ -z "${max_attempts//[0-9]}" ]; 		then echo "Max attempts should be integer only"; 	exit 1; fi
if  	[ -z "${process//[ ]}" ]; 				then echo "Invalid process"; 						exit 1; fi
if ! 	[ -z "${interval//[0-9]}" ]; 			then echo "Interval should be integer only"; 		exit 1; fi
#if		[ -f "$log_file" ]; 					then rm $log_file; 											fi
echo -e "Test case: \tSecond: $second \tMax Attempts: $max_attempts \tInterval: $interval \tProcess: $process" >> $log_file

while true; do
	ps -aef | grep "$process" | grep -v grep | grep -v $0 > /dev/null
	if [ $? -ne 0 ]; then
		while [ $attempts -lt $max_attempts ]; do
			((attempts++))
			echo "`date +%F\ %T`: Restart attempt $((attempts)) of $max_attempts for process" >> $log_file
			bash -c "$process" & > /dev/null 2>&1
			ps -aef | grep "$process" | grep -v grep | grep -v $0 > /dev/null 
			if [ $? -eq 0 ]; then
				sleep $interval
				continue 2
			fi
			sleep $second   #If failed attempt it will wait for this much time
		done
		echo "`date +%F\ %T`: Max attempts reached. Exiting....." >> $log_file
		exit 1 #Max tries reached
	else
		echo "`date +%F\ %T`: Process is up. sleeping for $interval" >> $log_file
		sleep $interval
	fi
done