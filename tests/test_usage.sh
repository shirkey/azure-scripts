#!/usr/bin/env bash
source_file="get_usage.sh"

source ${source_file}
selected_region="southeastasia"

echo "Testing: ${source_file}"

echo "Test function: get_vm_usage"
get_vm_usage ${selected_region}

echo "Test function: select_vm_type"
select_vm_type ${selected_region} <<< 2
echo "${selected_vm} returned from function"

echo "Test function: get_vm_usage_by_region_and_id"
get_vm_usage_by_region_and_id ${selected_region} ${selected_vm}
