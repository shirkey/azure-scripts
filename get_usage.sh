#!/usr/bin/env bash
declare vm_usage_file

function get_vm_usage()
{
	IFS=","
	local selected_region="${1:?Please provide a region name as argument}"
	vm_usage_file="/tmp/usage_${selected_region}_vm.json"

	if [ ! -f "${vm_usage_file}" ]; then
	    echo "Retrieving VM usage and limits for ${selected_region}, caching to ${vm_usage_file}"
	    $(az vm list-usage --location ${selected_region} > ${vm_usage_file})
	else
	    echo "Retrieving VM usage and limits for ${selected_region} from cache (${vm_usage_file})"
	fi
	echo $(jq -s '.[][] | { "id": .name.value, "name": .localName, "limit": (.limit | tonumber), "usage": (.currentValue | tonumber), "capacity": ((.limit | tonumber) - (.currentValue | tonumber)) } | {"id": .id, "name": .name, "limit": .limit, "capacity": .capacity, "usage": .usage, "usagePercent": ( if .limit > 0 then 100*(.usage / .limit) else 0 end)}' ${vm_usage_file})
}


