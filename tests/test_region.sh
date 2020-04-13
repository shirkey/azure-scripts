#!/usr/bin/env bash
source_file="get_region.sh"

source ${source_file}

echo "Testing: ${source_file}"
echo "Test function: select_region"
select_region
echo "${selected_region} returned from function"
