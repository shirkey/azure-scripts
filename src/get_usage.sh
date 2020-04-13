#!/usr/bin/env bash

function load_vm_data()
{
	IFS=","
        local selected_region="${1:?Please provide a region name as argument}"
        local vm_usage_file="/tmp/usage_${selected_region}_vm.json"

        if [ ! -f "${vm_usage_file}" ]; then
            echo "Retrieving VM usage and limits for ${selected_region}, caching to ${vm_usage_file}"
            $(az vm list-usage --location ${selected_region} > ${vm_usage_file})
        else
            echo "Retrieving VM usage and limits for ${selected_region} from cache (${vm_usage_file})"
        fi
	echo "Data loaded"
}

function get_vm_usage()
{
        local selected_region="${1:?Please provide a region name as argument}"
        local vm_usage_file="/tmp/usage_${selected_region}_vm.json"
	local vm_usage_file_ext="/tmp/usage_${selected_region}_vm_ext.json"

	load_vm_data ${selected_region} 
	$(jq -s '.[][] | { "id": .name.value, "name": .localName, "limit": (.limit | tonumber), "usage": (.currentValue | tonumber), "capacity": ((.limit | tonumber) - (.currentValue | tonumber)) } | {"id": .id, "name": .name, "limit": .limit, "capacity": .capacity, "usage": .usage, "usagePercent": ( if .limit > 0 then 100*(.usage / .limit) else 0 end)}' ${vm_usage_file} > ${vm_usage_file_ext})
}

declare selected_vm

function select_vm_type()
{ 
        local selected_region="${1:?Please provide a region name as argument}"
        local vm_usage_file="/tmp/usage_${selected_region}_vm.json"
	get_vm_usage ${selected_region} 

	#IFS=","
	declare -a vm_names=($(jq -s '.[][] | select(.localName | contains("Family"))? | .localName' ${vm_usage_file} | tr -d "\"" | tr "\r\n" ","))
	declare -a vm_ids=($(jq -s '.[][] | select(.localName | contains("Family"))? | .name.value' ${vm_usage_file} | tr -d "\"" | tr "\r\n" "," ))

	PS3="Select VM type: "
	select vm_name in ${vm_names[@]}
	do
		selected_vm=${vm_ids[${REPLY}-1]}
		echo "You selected: ${vm_name} (VM ID: ${selected_vm})"
		break
	done
}

function get_vm_usage_by_region_and_id()
{
        local selected_region="${1:?Please provide a region name as argument}"
	local selected_vm="${2:?Please provide the vm type id}"
	local vm_usage_file_ext="/tmp/usage_${selected_region}_vm_ext.json"
	get_vm_usage ${selected_region}

	filter=".[] | select(.id | contains(\"${selected_vm}\"))?"
	echo ${filter}
	echo $(jq -s ${filter} ${vm_usage_file_ext})

}
