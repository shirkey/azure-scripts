#!/usr/bin/env bash
declare OLDPATH=$PATH
declare -a tests=(
	test_subscription.sh 
	test_region.sh
)

function set_path()
{
	PATH=$OLDPATH:${PWD}/tests
}

function reset_path()
{
	PATH=${OLDPATH}
}

set_path
for idx in ${!tests[@]}
do
	cmd="${tests[${idx}]}"
	echo "***********************************************"
	echo "Running ${cmd}"
	${cmd}
done
reset_path
