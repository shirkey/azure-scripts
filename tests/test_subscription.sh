#!/usr/bin/env bash
source_file="get_subscription.sh"

source ${source_file}

echo "Testing: ${source_file}"
echo "Test function: select_subscription"
select_subscription
echo "${selected_subscription} returned from function"
