#!/usr/bin/env bash
source_file="get_usage.sh"

source ${source_file}

echo "Testing: ${source_file}"
echo "Test function: get_vm_usage"
get_vm_usage southeastasia
echo "Test function: select_vm_type"
select_vm_type eastasia
echo "${selected_vm} returned from function"
