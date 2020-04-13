#!/usr/bin/env bash
declare OLDPATH=$PATH
declare OLDIFS=$IFS
declare -a tests=(
	test_subscription.sh 
	test_region.sh
	test_usage.sh
)
declare -a result_codes
declare -a results

function set_env()
{
	PATH=${OLDPATH}:${PWD}/tests:${PWD}/src
}

function reset_env()
{
	IFS=${OLDIFS}
	PATH=${OLDPATH}
}

function run_tests()
{
	set_env
	for idx in ${!tests[@]}
	do
		cmd="${tests[${idx}]}"
		echo "********************************************"
		echo "Running ${cmd}"
		${cmd}
		cmd_result=$?
		if [ ${cmd_result} -ne 0 ]; then result_codes+=("FAILED ("${cmd_result}")"); else result_codes+=("SUCCESS ("${cmd_result}")"); fi
	done
	echo "********************************************"
	echo "TEST RESULTS"
	for idx in ${!tests[@]}
	do	
	 	echo "${tests[${idx}]}: ${result_codes[${idx}]}"
	done
	reset_env
}

run_tests
